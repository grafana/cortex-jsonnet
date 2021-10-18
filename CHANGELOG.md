# Changelog

## master / unreleased

* [CHANGE] Update grafana-builder dependency: use $__rate_interval in qpsPanel and latencyPanel. #372
* [CHANGE] `namespace` template variable in dashboards now only selects namespaces for selected clusters. #311
* [CHANGE] Alertmanager: mounted overrides configmap to alertmanager too. #315
* [CHANGE] Memcached: upgraded memcached from `1.5.17` to `1.6.9`. #316
* [CHANGE] `CortexIngesterRestarts` alert severity changed from `critical` to `warning`. #321
* [CHANGE] Store-gateway: increased memory request and limit respectively from 6GB / 6GB to 12GB / 18GB. #322
* [CHANGE] Store-gateway: increased `-blocks-storage.bucket-store.max-chunk-pool-bytes` from 2GB (default) to 12GB. #322
* [CHANGE] Dashboards: added overridable `job_labels` and `cluster_labels` to the configuration object as label lists to uniquely identify jobs and clusters in the metric names and group-by lists in dashboards. #319
* [CHANGE] Dashboards: `alert_aggregation_labels` has been removed from the configuration and overriding this value has been deprecated. Instead the labels are now defined by the `cluster_labels` list, and should be overridden accordingly through that list. #319
* [CHANGE] Ingester/Ruler: set `-server.grpc-max-send-msg-size-bytes` and `-server.grpc-max-send-msg-size-bytes` to sensible default values (10MB). #326
* [CHANGE] Renamed `CortexCompactorHasNotUploadedBlocksSinceStart` to `CortexCompactorHasNotUploadedBlocks`. #334
* [CHANGE] Renamed `CortexCompactorRunFailed` to `CortexCompactorHasNotSuccessfullyRunCompaction`. #334
* [CHANGE] Renamed `CortexInconsistentConfig` alert to `CortexInconsistentRuntimeConfig` and increased severity to `critical`. #335
* [CHANGE] Increased `CortexBadRuntimeConfig` alert severity to `critical` and removed support for `cortex_overrides_last_reload_successful` metric (was removed in Cortex 1.3.0). #335
* [CHANGE] Grafana 'min step' changed to 15s so dashboard show better detail. #340
* [CHANGE] Replace `CortexRulerFailedEvaluations` with two new alerts: `CortexRulerTooManyFailedPushes` and `CortexRulerTooManyFailedQueries`. #347
* [CHANGE] Removed `CortexCacheRequestErrors` alert. This alert was not working because the legacy Cortex cache client instrumentation doesn't track errors. #346
* [CHANGE] Removed `CortexQuerierCapacityFull` alert. #342
* [CHANGE] Changes blocks storage alerts to group metrics by the configured `cluster_labels` (supporting the deprecated `alert_aggregation_labels`). #351
* [CHANGE] Increased `CortexIngesterReachingSeriesLimit` critical alert threshold from 80% to 85%. #363
* [CHANGE] Decreased `-server.grpc-max-concurrent-streams` from 100k to 10k. #369
* [CHANGE] Decreased blocks storage ingesters graceful termination period from 80m to 20m. #369
* [CHANGE] Changed default `job_names` for query-frontend, query-scheduler and querier to match custom deployments too. #376
* [CHANGE] Increase the rules per group and rule groups limits on different tiers. #396
* [CHANGE] Removed `max_samples_per_query` limit, since it only works with chunks and only when using `-distributor.shard-by-all-labels=false`. #397
* [CHANGE] Removed chunks storage query sharding config support. The following config options have been removed: #398
  * `_config` > `queryFrontend` > `shard_factor`
  * `_config` > `queryFrontend` > `sharded_queries_enabled`
  * `_config` > `queryFrontend` > `query_split_factor`
* [CHANGE] Split `cortex_api` recording rule group into three groups. This is a workaround for large clusters where this group can become slow to evaluate. #401
* [CHANGE] Increased `CortexIngesterReachingSeriesLimit` warning threshold from 70% to 80% and critical threshold from 85% to 90%. #404
* [ENHANCEMENT] Add overrides config to compactor. This allows setting retention configs per user. #386
* [ENHANCEMENT] cortex-mixin: Make `cluster_namespace_deployment:kube_pod_container_resource_requests_{cpu_cores,memory_bytes}:sum` backwards compatible with `kube-state-metrics` v2.0.0. #317
* [ENHANCEMENT] Cortex-mixin: Include `cortex-gw-internal` naming variation in default `gateway` job names. #328
* [ENHANCEMENT] Ruler dashboard: added object storage metrics. #354
* [ENHANCEMENT] Alertmanager dashboard: added object storage metrics. #354
* [ENHANCEMENT] Added documentation text panels and descriptions to reads and writes dashboards. #324
* [ENHANCEMENT] Dashboards: defined container functions for common resources panels: containerDiskWritesPanel, containerDiskReadsPanel, containerDiskSpaceUtilization. #331
* [ENHANCEMENT] cortex-mixin: Added `alert_excluded_routes` config to exclude specific routes from alerts. #338
* [ENHANCEMENT] Added `CortexMemcachedRequestErrors` alert. #346
* [ENHANCEMENT] Ruler dashboard: added "Per route p99 latency" panel in the "Configuration API" row. #353
* [ENHANCEMENT] Increased the `for` duration of the `CortexIngesterReachingSeriesLimit` warning alert to 3h. #362
* [ENHANCEMENT] Added a new tier (`medium_small_user`) so we have another tier between 100K and 1Mil active series. #364
* [ENHANCEMENT] Extend Alertmanager dashboard: #313
  * "Tenants" stat panel - shows number of discovered tenant configurations.
  * "Replication" row - information about the replication of tenants/alerts/silences over instances.
  * "Tenant Configuration Sync" row - information about the configuration sync procedure.
  * "Sharding Initial State Sync" row - information about the initial state sync procedure when sharding is enabled.
  * "Sharding Runtime State Sync" row - information about various state operations which occur when sharding is enabled (replication, fetch, marge, persist).
* [ENHANCEMENT] Added 256MB memory ballast to querier. #369
* [ENHANCEMENT] Update gsutil command for `not healthy index found` playbook #370
* [ENHANCEMENT] Update `etcd-operator` to latest version (see https://github.com/grafana/jsonnet-libs/pull/480). #263
* [ENHANCEMENT] Added Alertmanager alerts and playbooks covering configuration syncs and sharding operation: #377 #378
  * `CortexAlertmanagerSyncConfigsFailing`
  * `CortexAlertmanagerRingCheckFailing`
  * `CortexAlertmanagerPartialStateMergeFailing`
  * `CortexAlertmanagerReplicationFailing`
  * `CortexAlertmanagerPersistStateFailing`
  * `CortexAlertmanagerInitialSyncFailed`
* [ENHANCEMENT] Add support for Azure storage in Alertmanager configuration. #381
* [ENHANCEMENT] Add support for running Alertmanager in sharding mode. #394
* [ENHANCEMENT] Allow to customize PromQL engine settings via `queryEngineConfig`. #399
* [ENHANCEMENT] Add recording rules to improve responsiveness of Alertmanager dashboard. #387
* [ENHANCEMENT] Add `CortexRolloutStuck` alert. #405
* [ENHANCEMENT] Added `CortexKVStoreFailure` alert. #406
* [ENHANCEMENT] Add ability to override `datasource` for generated dashboards. #407
* [ENHANCEMENT] Use alertmanager jobname for alertmanager dashboard panels #411
* [BUGFIX] Fixed `CortexIngesterHasNotShippedBlocks` alert false positive in case an ingester instance had ingested samples in the past, then no traffic was received for a long period and then it started receiving samples again. #308
* [BUGFIX] Alertmanager: fixed `--alertmanager.cluster.peers` CLI flag passed to alertmanager when HA is enabled. #329
* [BUGFIX] Fixed `CortexInconsistentRuntimeConfig` metric. #335
* [BUGFIX] Fixed scaling dashboard to correctly work when a Cortex service deployment spans across multiple zones (a zone is expected to have the `zone-[a-z]` suffix). #365
* [BUGFIX] Fixed rollout progress dashboard to correctly work when a Cortex service deployment spans across multiple zones (a zone is expected to have the `zone-[a-z]` suffix). #366
* [BUGFIX] Fixed rollout progress dashboard to include query-scheduler too. #376
* [BUGFIX] Fixed `-distributor.extend-writes` setting on ruler when `unregister_ingesters_on_shutdown` is disabled. #369
* [BUGFIX] Upstream recording rule `node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate` renamed. #379
* [BUGFIX] Treat `compactor_blocks_retention_period` type as string rather than int.#395
* [BUGFIX] Fixed writes/reads/alertmanager resources dashboards to use `$._config.job_names.gateway`. #403

## 1.9.0 / 2021-05-18

* [CHANGE] Replace use of removed Cortex CLI flag `-querier.compress-http-responses` for query frontend with `-api.response-compression-enabled`. #299
* [CHANGE] The default dashboards config now display panels for the Cortex blocks storage only. If you're running Cortex chunks storage, please change `storage_engine` config to `['chunks']` or `['chunks', 'blocks']` if running both. #302
* [CHANGE] Enabled index-header lazy loading in store-gateways. #303
* [CHANGE] Replaced the deprecated CLI flag `-limits.per-user-override-config` (removed in Cortex 1.9) with `-runtime-config.file`. #304
* [CHANGE] Ruler: changed ruler config to use the new storage config. #306
* [CHANGE] Ruler: enabled API response compression. #306
* [CHANGE] Alertmanager: changed alertmanager config to use the new storage config. #307
* [FEATURE] Added "Cortex / Rollout progress" dashboard. #289 #290
* [FEATURE] Added support for using query-scheduler component, which moves the queue out of query-frontend, and allows scaling up of query-frontend component. #295
* [ENHANCEMENT] Added `newCompactorStatefulSet()` function to create a custom statefulset for the compactor. #287
* [ENHANCEMENT] Added option to configure compactor job name used in dashboards and alerts. #287
* [ENHANCEMENT] Added `CortexCompactorHasNotSuccessfullyRunCompaction` alert. #292 #294
* [ENHANCEMENT] Added ingester instance limits to config. #296
* [ENHANCEMENT] Added alerts for ingester reaching the instance limits (if limits are configured). #296:
  * `CortexIngesterReachingSeriesLimit`
  * `CortexIngesterReachingTenantsLimit`
* [ENHANCEMENT] Improved `CortexRulerFailedRingCheck` to avoid firing in case of very short errors. #297
* [BUGFIX] Fixed `CortexCompactorRunFailed` false positives. #288
* [BUGFIX] Add missing components (admin-api, compactor, store-gateway) to `CortexGossipMembersMismatch`. #305

## 1.8.0 / 2021-03-25

* [CHANGE] Updated the trunk branch from `master` to `main`. You need to run the following in your local fork: #265
  ```
  git branch -m master main
  git fetch origin
  git branch -u origin/main main
  ```
* [CHANGE] `CortexRequestErrors` alert severity raised from `warning` to `critical`. #279
* [FEATURE] Added "Cortex / Slow queries" dashboard based on Loki logs. #271
* [ENHANCEMENT] Add `EtcdAllocatingTooMuchMemory` alert for monitoring etcd memory usage. #261
* [ENHANCEMENT] Sort legend descending in the CPU/memory panels. #271
* [ENHANCEMENT] Add config option to enable streaming of chunks in block-based ingesters. #276
* [BUGFIX] Fixed `CortexQuerierHighRefetchRate` alert. #268
* [BUGFIX] Fixed "Disk Writes" and "Disk Reads" panels. #280

## 1.7.0 / 2021-02-24

* [CHANGE] Alertmanager storage backend no longer defaults to `gcs` with bucket name `'%(cluster)s-cortex-%(namespace)s' % $._config`. #258
* [CHANGE] Only single cluster and namespace can now be selected in "resources" dashboards. #251
* [CHANGE] Increased `CortexAllocatingTooMuchMemory` warning alert threshold from 50% to 65%. #256
* [CHANGE] Cleaned up blocks storage config. Moved CLI flags used only be the read path from `genericBlocksStorageConfig` to `queryBlocksStorageConfig`, and flags used only by the ingester from `genericBlocksStorageConfig` to `ingester_args`. #257
* [ENHANCEMENT] Add dedicated parameters to `_config` to configure Alertmanager backend storage. #258
  * `alertmanager_client_type`
  * `alertmanager_s3_bucket_name`
  * `alertmanager_gcs_bucket_name`
* [ENHANCEMENT] Added `unregister_ingesters_on_shutdown` config option to disable unregistering ingesters on shutdown (default is enabled). #213
* [ENHANCEMENT] Improved blocks storage observability: #237
  - Cortex / Queries: added bucket index load operations and latency (available only when bucket index is enabled)
  - Alerts: added "CortexBucketIndexNotUpdated" (bucket index only) and "CortexTenantHasPartialBlocks"
* [ENHANCEMENT] The name of the overrides configmap is now customisable via `$._config.overrides_configmap`. #244
* [ENHANCEMENT] Added flag to control usage of bucket-index and disable it by default when using blocks. #254
* [ENHANCEMENT] Added the alert `CortexIngesterHasUnshippedBlocks`. #255
* [BUGFIX] Honor configured `per_instance_label` in all panels. #239
* [BUGFIX] `CortexRequestLatency` alert now ignores long-running requests on query-scheduler. #242
* [BUGFIX] Honor configured `job_names` in the "Memory (go heap inuse)" panel. #247
* [BUGFIX] Fixed ingester "Disk Space Utilization" to include any `ingester.*` PV. #249
* [BUGFIX] Fixed ingester alerts to include any `ingester.*` job. #252
* [BUGFIX] Set `-querier.second-store-engine` in the ruler too when `querier_second_storage_engine` is configured. #253

## 1.6.0 / 2021-01-05

* [CHANGE] Add default present for ruler limits on all 'user' types. #221, #222
* [CHANGE] Enabled sharding for the blocks storage compactor. #218
* [CHANGE] Removed `-blocks-storage.bucket-store.index-cache.postings-compression-enabled` CLI flag because always enabled in Cortex 1.6. #224
* [ENHANCEMENT] Introduce a resources dashboard for the Alertmanager. #219
* [ENHANCEMENT] Improves query visibility in the Ruler Dashboard for both chunks and blocks storage. #226
* [ENHANCEMENT] Add query-scheduler to dashboards. Add alert for queries stuck in scheduler. #228
* [ENHANCEMENT] Improved blocks storage observability: #224 #230
  - Cortex / Writes: added current number of tenants in the cluster
  - Cortex / Writes Resources: added ingester disk read/writes/utilisation
  - Cortex / Reads Resources: added store-gateway disk read/writes/utilisation
  - Cortex / Queries: added "Lazy loaded index-headers" and "Index-header lazy load duration"
  - Cortex / Compactor: added "Tenants compaction progress", "Average blocks / tenant" and "Tenants with largest number of blocks"
  - Alerts: added "CortexMemoryMapAreasTooHigh"
* [ENHANCEMENT] Fine-tuned gRPC keepalive pings to work nicely with Cortex default settings. #233 #234
  - `-server.grpc.keepalive.min-time-between-pings=10s`
  - `-server.grpc.keepalive.ping-without-stream-allowed:true`
* [BUGFIX] Fixed workingset memory panel while rolling out a StatefulSet. #229
* [BUGFIX] Fixed `CortexRequestErrors` alert to not include `ready` route. #230

## 1.5.0 / 2020-11-12

* [CHANGE] Add the default preset 'extra_small_user' and reference it in the CLI flags. This will raise the limits of the 'small_user' preset to the defaults for `ingester.max-samples-per-query` and `ingester.max-series-per-query`. #200
* [CHANGE] Removed the config option `$._config.ingester.statefulset_replicas` which was used only when running Cortex chunks storage with WAL enabled. To configure the number of ingester replicas you should now use the following: #210
  ```
  ingester_statefulset+:
      statefulSet.mixin.spec.withReplicas(6),
  ```
* [CHANGE] The compactor statefulset is now configured with the `Parallel` pod management policy, in order to scale up quickly. #214
* [ENHANCEMENT] Add the Ruler to the read resources dashboard #205
* [ENHANCEMENT] Read dashboards now use `cortex_querier_request_duration_seconds` metrics to allow for accurate dashboards when deploying Cortex as a single-binary. #199
* [ENHANCEMENT] Improved Ruler dashboard. Includes information about notifications, reads/writes, and per user per rule group evaluation. #197, #205
* [ENHANCEMENT] Add new `CortexCompactorRunFailed` alert when compactor run fails. #206
* [ENHANCEMENT] Add `flusher-job-blocks.libsonnet` with support for flushing blocks disks. #187
* [ENHANCEMENT] Add more alerts on failure conditions for ingesters when running the blocks storage. #208
* [FEATURE] Latency recording rules for the metric`cortex_querier_request_duration_seconds` are now part of a `cortex_querier_api` rule group. #199
* [FEATURE] Add overrides-exporter as optional deployment to expose configured runtime overrides and presets. #198
* [FEATURE] Add a dashboard for the alertmanager. #207
* [BUGFIX] Added `ingester-blocks` to ingester's job label matcher, in order to correctly get metrics when migrating a Cortex cluster from chunks to blocks. #203

## 1.4.0 / 2020-10-02

* [CHANGE] Lower the default overrides configs for ingestion and create a new overrides user out of the previous config #183
* [CHANGE] The project is now licensed with Apache-2.0 license. #169
* [CHANGE] Add overrides config to tsdb store-gateway. #167
* [CHANGE] Ingesters now default to running as `StatefulSet` with WAL enabled. It is controlled by the config `$._config.ingester_deployment_without_wal` which is `false` by default. Setting the config to `true` will yield the old behaviour (stateless `Deployment` without WAL enabled). #72
* [CHANGE] We now allow queries that are 32 days long. For example, rate(metric[32d]). Before it was 31d. #173
* [CHANGE] Renamed `container_name` and `pod_name` label names to `container` and `pod` respectively. This is required in order to comply with cAdvisor metrics changes shipped with Kubernetes 1.16. #179
* [CHANGE] Removed the `experimental` prefix from blocks storage CLI flags. #179
* [CHANGE] Rename flags `store-gateway.replication-factor` and `store-gateway.tokens-file-path` to `store-gateway.sharding-ring.replication-factor` and `store-gateway.sharding-ring.tokens-file-path` in anticipation of v1.4 release. #191
* [ENHANCEMENT] Enable support for HA in the Cortex Alertmanager #147
* [ENHANCEMENT] Support `alertmanager.fallback_config` option in the Alertmanager. #179
* [ENHANCEMENT] Add support for S3 block storage. #181
* [ENHANCEMENT] Add support for Azure block storage. #182 #190
* [BUGFIX] Add support the `local` ruler client type  #175
* [BUGFIX] Fixes `ruler.storage.s3.url` argument for the Ruler. It used an incorrect argument. #177

## 1.3.0 / 2020-08-21

This version is compatible with Cortex `1.3.0`.
