# Deprecated

This project has been deprecated:

- If you're using Grafana Mimir, please use [Grafana Mimir jsonnet](https://github.com/grafana/mimir/tree/main/operations/mimir) instead
- If you're using Cortex, please use [Cortex jsonnet](https://github.com/cortexproject/cortex-jsonnet) instead

# Jsonnet for Cortex on Kubernetes

This repo has the jsonnet for deploying Cortex and the related monitoring in Kubernetes.

To generate the YAMLs for deploying Cortex:

1. Make sure you have tanka and jb installed:

    Follow the steps at https://tanka.dev/install. If you have `go` installed locally you can also use:

    ```console
    $ # make sure to be outside of GOPATH or a go.mod project
    $ GO111MODULE=on go get github.com/grafana/tanka/cmd/tk
    $ GO111MODULE=on go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
    ```

1. Initialise the Tanka, and install the Cortex and Kubernetes Jsonnet libraries.

    ```console
    $ mkdir <name> && cd <name>
    $ tk init --k8s=false
    $ # The k8s-alpha library supports Kubernetes versions 1.14+
    $ jb install github.com/jsonnet-libs/k8s-alpha/1.18
    $ cat <<EOF > lib/k.libsonnet
      (import "github.com/jsonnet-libs/k8s-alpha/1.18/main.libsonnet")
      + (import "github.com/jsonnet-libs/k8s-alpha/1.18/extensions/kausal-shim.libsonnet")
      EOF
    $ jb install github.com/grafana/cortex-jsonnet/cortex@main
    ```

1. Use the example monitoring.jsonnet.example:

    ```console
    $ cp vendor/cortex/cortex-manifests.jsonnet.example environments/default/main.jsonnet
    ```

1. Check what is in the example:

    ```console
    $ cat environments/default/main.jsonnet
    ...
    ```

1. Generate the YAML manifests:

    ```console
    $ tk show environments/default
    ```

    To output YAML manifests to `./manifests`, run:

    ```console
    $ tk export manifests environments/default
    ```

# Monitoring for Cortex

To generate the Grafana dashboards and Prometheus alerts for Cortex:

```console
$ GO111MODULE=on go get github.com/monitoring-mixins/mixtool/cmd/mixtool
$ GO111MODULE=on go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
$ git clone https://github.com/grafana/cortex-jsonnet
$ cd cortex-jsonnet
$ make build-mixin
```

This will leave all the alerts and dashboards in cortex-mixin/cortex-mixin.zip (or cortex-mixin/out).

If you get an error like `cannot use cli.StringSliceFlag literal (type cli.StringSliceFlag) as type cli.Flag in slice literal` when installing [mixtool](https://github.com/monitoring-mixins/mixtool/issues/27), make sure you set `GO111MODULE=on` before `go get`.
