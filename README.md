# Jsonnet for Cortex on Kubernetes

This repo has the jsonnet for deploying Cortex and the related monitoring in Kubernetes.

---
**NOTE**

If you are more familiar with helm you should use the [helm chart](https://cortexproject.github.io/cortex-helm-chart/) for cortex

---

To generate the YAMLs for deploying Cortex:

1. Make sure you have tanka and jb installed:

    Follow the steps at https://tanka.dev/install. If you have `go` installed locally you can also use:

    ```console
    $ # make sure to be outside of GOPATH or a go.mod project
    $ GO111MODULE=on go install github.com/grafana/tanka/cmd/tk@v0.21.0
    $ GO111MODULE=on go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@v0.4.0
    ```

1. Initialise the Tanka repo, install the Cortex and Kubernetes Jsonnet libraries.

    ```console
    $ mkdir <name> && cd <name>
    $ tk init --k8s=1.21 # this includes github.com/jsonnet-libs/k8s-libsonnet/1.21@main
    $ jb install github.com/cortexproject/cortex-jsonnet/cortex@main
    ```

1. Use any of the examples to get a main.jsonnet and adjust as needed

    ```console
    $ cp vendor/cortex/azure/main.jsonnet.example environments/default/main.jsonnet
    ```

    ```console
    $ cp vendor/cortex/gcs/main.jsonnet.example environments/default/main.jsonnet
    ```

    ```console
    $ cp vendor/cortex/s3/main.jsonnet.example environments/default/main.jsonnet
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
$ GO111MODULE=on go install github.com/monitoring-mixins/mixtool/cmd/mixtool@2ff523ea63d1cdeee2a10e01d1d48d20adcc7030
$ GO111MODULE=on go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@v0.4.0
$ git clone https://github.com/cortexproject/cortex-jsonnet
$ cd cortex-jsonnet
$ make build-mixin
```

This will leave all the alerts and dashboards in cortex-mixin/cortex-mixin.zip (or cortex-mixin/out).
