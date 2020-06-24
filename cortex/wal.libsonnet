{
  _config+:: {
    wal_dir: '/wal_data',
    ingester+: {
      statefulset_replicas: 7,
      statefulset_disk: '150Gi',
    },
  },

  local volumeMount = $.core.v1.volumeMount,

  local pvc = $.core.v1.persistentVolumeClaim,
  local volume = $.core.v1.volume,
  local container = $.core.v1.container,
  local statefulSet = $.apps.v1beta1.statefulSet,

  local ingester_pvc =
    pvc.new() +
    pvc.mixin.spec.resources.withRequests({ storage: $._config.ingester.statefulset_disk }) +
    pvc.mixin.spec.withAccessModes(['ReadWriteOnce']) +
    pvc.mixin.spec.withStorageClassName('fast') +
    pvc.mixin.metadata.withName('ingester-pvc'),

  ingester_statefulset_args:: {
    'ingester.wal-enabled': true,
    'ingester.checkpoint-enabled': true,
    'ingester.recover-from-wal': true,
    'ingester.wal-dir': $._config.wal_dir,
    'ingester.checkpoint-duration': '15m',
    '-log.level': 'info',
    'ingester.tokens-file-path': $._config.wal_dir + '/tokens',
  },

  ingester_statefulset_container::
    $.ingester_container +
    container.withArgsMixin($.util.mapToFlags($.ingester_statefulset_args)) +
    container.withVolumeMountsMixin([
      volumeMount.new('ingester-pvc', $._config.wal_dir),
    ]),

  statefulset_storage_config_mixin::
    statefulSet.mixin.spec.template.metadata.withAnnotationsMixin({ schemaID: $._config.schemaID },) +
    $.util.configVolumeMount('schema-' + $._config.schemaID, '/etc/cortex/schema'),

  ingester_statefulset:
    statefulSet.new('ingester', $._config.ingester.statefulset_replicas, [$.ingester_statefulset_container], ingester_pvc) +
    statefulSet.mixin.spec.withServiceName('ingester') +
    statefulSet.mixin.spec.template.spec.withVolumes([volume.fromPersistentVolumeClaim('ingester-pvc', 'ingester-pvc')]) +
    statefulSet.mixin.metadata.withNamespace($._config.namespace) +
    statefulSet.mixin.metadata.withLabels({ name: 'ingester' }) +
    statefulSet.mixin.spec.template.metadata.withLabels({ name: 'ingester' } + $.ingester_deployment_labels) +
    statefulSet.mixin.spec.selector.withMatchLabels({ name: 'ingester' }) +
    statefulSet.mixin.spec.template.spec.securityContext.withRunAsUser(0) +
    statefulSet.mixin.spec.template.spec.withTerminationGracePeriodSeconds(600) +
    statefulSet.mixin.spec.updateStrategy.withType('RollingUpdate') +
    $.statefulset_storage_config_mixin +
    $.util.configVolumeMount('overrides', '/etc/cortex') +
    $.util.podPriority('high') +
    $.util.antiAffinityStatefulSet,

  ingester_deployment: {},

  ingester_service:
    $.util.serviceFor($.ingester_statefulset, $.ingester_service_ignored_labels),
}
