.PHONY: lint build-image publish-build-image test-readme

JSONNET_FMT := jsonnetfmt

# Support gsed/gfind on OSX (installed via brew), falling back to sed/find. On Linux
# systems gsed/gfind won't be installed, so will use sed/gfind as expected.
SED ?= $(shell which gsed 2>/dev/null || which sed)
FIND ?= $(shell which gfind 2>/dev/null || which find)

lint: lint-mixin lint-playbooks

lint-mixin: lint-mixin-with-mixtool lint-mixin-with-jsonnetfmt

lint-mixin-with-jsonnetfmt:
	@RESULT=0; \
	for f in $$(find . -name '*.libsonnet' -print -o -name '*.jsonnet' -print); do \
		$(JSONNET_FMT) -- "$$f" | diff -u "$$f" -; \
		RESULT=$$(($$RESULT + $$?)); \
	done; \
	exit $$RESULT

lint-mixin-with-mixtool:
	cd cortex-mixin && \
	jb install && \
	mixtool lint mixin.libsonnet

lint-playbooks: build-mixin
	@./scripts/lint-playbooks.sh

fmt:
	@find . -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print | \
		xargs -n 1 -- $(JSONNET_FMT) -i

build-image:
	docker build -t grafana/cortex-jsonnet-build-image:$(shell git rev-parse --short HEAD) build-image

publish-build-image:
	docker push grafana/cortex-jsonnet-build-image:$(shell git rev-parse --short HEAD)

build-mixin:
	@cd cortex-mixin && \
	rm -rf out && mkdir out && \
	jb install && \
	mixtool generate all --output-alerts out/alerts.yaml --output-rules out/rules.yaml --directory out/dashboards mixin.libsonnet && \
	zip -q -r cortex-mixin.zip out

test-readme:
	rm -rf test-readme && \
	mkdir test-readme && cd test-readme && \
	tk init --k8s=false && \
	jb install github.com/jsonnet-libs/k8s-alpha/1.18 && \
	printf '(import "github.com/jsonnet-libs/k8s-alpha/1.18/main.libsonnet")\n+(import "github.com/jsonnet-libs/k8s-alpha/1.18/extensions/kausal-shim.libsonnet")' > lib/k.libsonnet && \
	jb install github.com/grafana/cortex-jsonnet/cortex@main && \
	rm -fr ./vendor/cortex && \
	cp -r ../cortex ./vendor/ && \
	cp vendor/cortex/cortex-manifests.jsonnet.example environments/default/main.jsonnet && \
	PAGER=cat tk show environments/default

clean-white-noise:
	@$(FIND) . -type f -regextype posix-extended -regex '.*(md|libsonnet)' -print | \
	SED_BIN="$(SED)" xargs ./scripts/cleanup-white-noise.sh

check-white-noise: clean-white-noise
	@git diff --exit-code --quiet || (echo "Please remove trailing whitespaces running 'make clean-white-noise'" && false)
