# Jsonnet for Cortex

This repo has the jsonnet for deploying cortex and the related monitoring in Kubernetes.

To generate the YAMLs for deploying Cortex:

1. Make sure you have tanka and jb installed:

Follow the steps at https://tanka.dev/install. If you have `go` installed locally you can also use:

```
# make sure to be outside of GOPATH or a go.mod project
$ GO111MODULE=on go get github.com/grafana/tanka/cmd/tk
$ GO111MODULE=on go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
```

2. Initialise the application and download the cortex jsonnet lib.

```
$ mkdir <name> && cd <name>
$ tk init
$ jb install github.com/grafana/cortex-jsonnet/cortex
```

2. Use the example monitoring.jsonnet.example:

```
$ cp vendor/cortex/cortex-manifests.jsonnet.example environments/default/main.jsonnet
```

3. Check what is in the example:

```
$ cat environments/default/main.jsonnet
....
```

4. Generate the YAML manifests:

```
$ tk show environments/default
```

To generate the dashboards and alerts for Cortex:

```
$ cd cortex-mixin
$ jb install
$ mkdir out
$ jsonnet -S alerts.jsonnet > out/alerts.yaml
$ jsonnet -J vendor -S dashboards.jsonnet -m out
$ jsonnet -J vendor -S recording_rules.jsonnet > out/rules.yaml
```
