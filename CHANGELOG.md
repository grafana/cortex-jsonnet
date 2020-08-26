# Changelog

## master / unreleased

* [CHANGE] Add overrides config to tsdb store-gateway. #167
* [CHANGE] Ingesters now default to running as `StatefulSet` with WAL enabled. It is controlled by the config `$._config.ingester_deployment_without_wal` which is `false` by default. Setting the config to `true` will yeild the old behaviour (stateless `Deployment` without WAL enabled). #72

## 1.3.0 / 2020-08-21

This version is compatible with Cortex `1.3.0`.
