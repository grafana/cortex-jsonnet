{
  local podDisruptionBudget = $.policy.v1beta1.podDisruptionBudget,
  local pvc = $.core.v1.persistentVolumeClaim,
  local statefulSet = $.apps.v1.statefulSet,
  local volume = $.core.v1.volume,

  // The ingesters should persist TSDB blocks and WAL on a persistent
  // volume in order to be crash resilient.
  local ingester_data_pvc =
    pvc.new() +
    pvc.mixin.spec.resources.withRequests({ storage: $._config.cortex_ingester_data_disk_size }) +
    pvc.mixin.spec.withAccessModes(['ReadWriteOnce']) +
    pvc.mixin.spec.withStorageClassName($._config.cortex_ingester_data_disk_class) +
    pvc.mixin.metadata.withName('ingester-data'),

  ingester_args::
    $._config.grpcConfig +
    $._config.ringConfig +
    $._config.blocksStorageConfig +
    $._config.distributorConfig +  // This adds the distributor ring flags to the ingester.
    $._config.ingesterLimitsConfig +
    {
      target: 'ingester',

      // Ring config.
      'ingester.num-tokens': 512,
      'ingester.join-after': '0s',
      'ingester.heartbeat-period': '15s',
      'ingester.max-stale-chunk-idle': '5m',
      'ingester.unregister-on-shutdown': $._config.unregister_ingesters_on_shutdown,

      // Chunk building/flushing config.
      'ingester.retain-period': '15m',
      'ingester.max-chunk-age': '6h',

      // Limits config.
      'ingester.max-chunk-idle': $._config.max_chunk_idle,
      'runtime-config.file': '/etc/cortex/overrides.yaml',
      'server.grpc-max-concurrent-streams': 10000,
      'server.grpc-max-send-msg-size-bytes': 10 * 1024 * 1024,
      'server.grpc-max-recv-msg-size-bytes': 10 * 1024 * 1024,

      'blocks-storage.tsdb.dir': '/data/tsdb',
      'blocks-storage.tsdb.block-ranges-period': '2h',
      'blocks-storage.tsdb.retention-period': '96h',  // 4 days protection against blocks not being uploaded from ingesters.
      'blocks-storage.tsdb.ship-interval': '1m',

      // Persist ring tokens so that when the ingester will be restarted
      // it will pick the same tokens
      'ingester.tokens-file-path': '/data/tokens',
    },

  ingester_statefulset_args::
    $._config.grpcConfig
    {
      'ingester.wal-enabled': true,
      'ingester.checkpoint-enabled': true,
      'ingester.recover-from-wal': true,
      'ingester.wal-dir': $._config.ingester.wal_dir,
      'ingester.checkpoint-duration': '15m',
      '-log.level': 'info',
      'ingester.tokens-file-path': $._config.ingester.wal_dir + '/tokens',
    },

  ingester_ports:: $.util.defaultPorts,

  local name = 'ingester',
  local container = $.core.v1.container,

  ingester_container::
    container.new(name, $._images.ingester) +
    container.withPorts($.ingester_ports) +
    container.withArgsMixin($.util.mapToFlags($.ingester_args)) +
    $.util.resourcesRequests('4', '15Gi') +
    $.util.resourcesLimits(null, '25Gi') +
    $.util.readinessProbe +
    $.jaeger_mixin,

  local volumeMount = $.core.v1.volumeMount,

  ingester_statefulset_container::
    $.ingester_container +
    container.withArgsMixin($.util.mapToFlags($.ingester_statefulset_args)) +
    container.withVolumeMountsMixin([
      volumeMount.new('ingester-pvc', $._config.ingester.wal_dir),
    ]),

  ingester_deployment_labels:: {},

  local ingester_pvc =
    pvc.new('ingester-pvc') +
    pvc.mixin.spec.resources.withRequests({ storage: $._config.ingester.statefulset_disk }) +
    pvc.mixin.spec.withAccessModes(['ReadWriteOnce']) +
    pvc.mixin.spec.withStorageClassName('fast'),

  ingester_service_ignored_labels:: [],

  newIngesterPdb(pdbName, ingesterName)::
    podDisruptionBudget.new() +
    podDisruptionBudget.mixin.metadata.withName(pdbName) +
    podDisruptionBudget.mixin.metadata.withLabels({ name: pdbName }) +
    podDisruptionBudget.mixin.spec.selector.withMatchLabels({ name: ingesterName }) +
    podDisruptionBudget.mixin.spec.withMaxUnavailable(1),

  ingester_pdb: self.newIngesterPdb('ingester-pdb', name),

  newIngesterStatefulSet(name, container, with_anti_affinity=true)::
    statefulSet.new(name, 3, [
      container + $.core.v1.container.withVolumeMountsMixin([
        volumeMount.new('ingester-data', '/data'),
      ]),
    ], ingester_data_pvc) +
    statefulSet.mixin.spec.withServiceName(name) +
    statefulSet.mixin.metadata.withNamespace($._config.namespace) +
    statefulSet.mixin.metadata.withLabels({ name: name }) +
    statefulSet.mixin.spec.template.metadata.withLabels({ name: name } + $.ingester_deployment_labels) +
    statefulSet.mixin.spec.selector.withMatchLabels({ name: name }) +
    statefulSet.mixin.spec.template.spec.securityContext.withRunAsUser(0) +
    // When the ingester needs to flush blocks to the storage, it may take quite a lot of time.
    // For this reason, we grant an high termination period (80 minutes).
    statefulSet.mixin.spec.template.spec.withTerminationGracePeriodSeconds(1200) +
    statefulSet.mixin.spec.updateStrategy.withType('RollingUpdate') +
    $.util.configVolumeMount($._config.overrides_configmap, '/etc/cortex') +
    $.util.podPriority('high') +
    // Parallelly scale up/down ingester instances instead of starting them
    // one by one. This does NOT affect rolling updates: they will continue to be
    // rolled out one by one (the next pod will be rolled out once the previous is
    // ready).
    statefulSet.mixin.spec.withPodManagementPolicy('Parallel') +
    (if with_anti_affinity then $.util.antiAffinity else {}),

  ingester_statefulset: self.newIngesterStatefulSet('ingester', $.ingester_container),

  ingester_service:
    $.util.serviceFor($.ingester_statefulset, $.ingester_service_ignored_labels),
}
