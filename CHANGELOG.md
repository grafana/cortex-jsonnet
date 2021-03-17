# Changelog

## master / unreleased

* [CHANGE] Updated the trunk branch from `master` to `main`. You need to run the following in your local fork: #265
  ```
  git branch -m master main
  git fetch origin
  git branch -u origin/main main
  ```
* [CHANGE] Alertmanager: use new `alertmanager-storage.*` flags to configure storage. Old flags are going to be deprecated.
* [FEATURE] Added "Cortex / Slow queries" dashboard based on Loki logs. #271
* [ENHANCEMENT] Add `EtcdAllocatingTooMuchMemory` alert for monitoring etcd memory usage. #261
* [ENHANCEMENT] Sort legend descending in the CPU/memory panels. #271
* [BUGFIX] Fixed `CortexQuerierHighRefetchRate` alert. #268

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
* [ENHANCEMENT] Added flag to control usage of bucket-index, and enable it by default when using blocks. #254
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
