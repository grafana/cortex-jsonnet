.PHONY: lint build-image publish-build-image

JSONNET_FMT := jsonnetfmt

lint:
	@RESULT=0;
	for f in $$(find . -name '*.libsonnet' -print -o -name '*.jsonnet' -print); do
		$(JSONNET_FMT) -- "$$f" | diff -u "$$f" -;
		RESULT=$$(($$RESULT + $$?));
	done;
	exit $$RESULT

fmt:
	@find . -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print |
		xargs -n 1 -- $(JSONNET_FMT) -i

build-image:
	docker build -t grafana/cortex-jsonnet-build-image:$(shell git rev-parse --short HEAD) build-image

publish-build-image:
	docker push grafana/cortex-jsonnet-build-image:$(shell git rev-parse --short HEAD)

build-mixin:
	cd cortex-mixin
	rm -rf out && mkdir out
	jb install
	jsonnet -J vendor -S dashboards.jsonnet -m out/
	jsonnet -J vendor -S recording_rules.jsonnet > out/rules.yaml
	jsonnet -J vendor -S alerts.jsonnet > out/alerts.yaml
	zip -r cortex-mixin.zip cortex-mixin/out
test-readme:
	rm -rf -- test-readme
	GO111MODULE=on go get github.com/grafana/tanka/cmd/tk
	GO111MODULE=on go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
	mkdir test-readme && cd test-readme
	tk init --k8s=false
	jb install github.com/jsonnet-libs/k8s-alpha/1.18
	cat <<EOF > lib/k.libsonnet
		(import "github.com/jsonnet-libs/k8s-alpha/1.18/main.libsonnet") +
		(import "github.com/jsonnet-libs/k8s-alpha/1.18/extensions/kausal-shim.libsonnet")
	EOF
	jb install github.com/grafana/cortex-jsonnet/cortex
	cp vendor/cortex/cortex-manifests.jsonnet.example environments/default/main.jsonnet
	tk show environments/default
