# Jsonnet for Cortex

This repo has the jsonnet for deploying cortex and the related monitoring in Kubernetes.

To generate the YAMLs for deploying Cortex:

1. Make sure you have tanka and jb installed:

```
$ go get -u github.com/grafana/tanka/cmd/tk
$ go get -u github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
```

2. Initialise the application and download the cortex jsonnet lib.

```
$ tk init
```

3. Install the cortex jsonnet.

```
$ jb install github.com/ksonnet/ksonnet-lib/ksonnet.beta.3
$ cp vendor/ksonnet.beta.3/*.libsonnet lib
$ jb install https://github.com/grafana/cortex-jsonnet/cortex
```

3. Use the example monitoring.jsonnet.example:

```
$ mv vendor/cortex/cortex-manifests.jsonnet.example environments/default/main.jsonnet
```

4. Check what is in the example:

```
$ cat environments/default/main.jsonnet
....
```

5. Generate the YAML manifests:

```
$ tk show environments/default
```

To generate the dashboards and alerts for Cortex:

```
$ cd cortex-mixin
$ jb install
$ jsonnet -S alerts.jsonnet
$ jsonnet -J vendor -S dashboards.jsonnet
$ jsonnet -J vendor -S recording_rules.jsonnet
```
