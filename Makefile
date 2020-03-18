.PHONY: lint build-image publish-build-image

JSONNET_FMT := jsonnetfmt

lint:
	@RESULT=0; \
	for f in $$(find . -name '*.libsonnet' -print -o -name '*.jsonnet' -print); do \
		$(JSONNET_FMT) -- "$$f" | diff -u "$$f" -; \
		RESULT=$$(($$RESULT + $$?)); \
	done; \
	exit $$RESULT

build-image:
	docker build -t grafana/cortex-jsonnet-build-image:$(shell git rev-parse --short HEAD) build-image

publish-build-image:
	docker push grafana/cortex-jsonnet-build-image:$(shell git rev-parse --short HEAD)
