# Changelog

## master / unreleased

* [CHANGE] Lower the default overrides configs for ingestion and create a new overrides user out of the previous config #183
* [CHANGE] The project is now licensed with Apache-2.0 license. #169
* [CHANGE] Add overrides config to tsdb store-gateway. #167
* [CHANGE] Ingesters now default to running as `StatefulSet` with WAL enabled. It is controlled by the config `$._config.ingester_deployment_without_wal` which is `false` by default. Setting the config to `true` will yield the old behaviour (stateless `Deployment` without WAL enabled). #72
* [CHANGE] We now allow queries that are 32 days long. For example, rate(metric[32d]). Before it was 31d. #173
* [CHANGE] Renamed `container_name` and `pod_name` label names to `container` and `pod` respectively. This is required in order to comply with cAdvisor metrics changes shipped with Kubernetes 1.16. #179
* [CHANGE] Removed the `experimental` prefix from blocks storage CLI flags. #179
* [ENHANCEMENT] Enable support for HA in the Cortex Alertmanager #147
* [ENHANCEMENT] Support `alertmanager.fallback_config` option in the Alertmanager. #179
* [ENHANCEMENT] Add support for S3 block storage. #181
* [ENHANCEMENT] Add support for Azure block storage. #182 #190
* [BUGFIX] Add support the `local` ruler client type  #175
* [BUGFIX] Fixes `ruler.storage.s3.url` argument for the Ruler. It used an incorrect argument. #177

## 1.3.0 / 2020-08-21

This version is compatible with Cortex `1.3.0`.
