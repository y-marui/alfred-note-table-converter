.PHONY: build test lint fmt build-workflow release precommit update-charter update-workflow-notes

build:
	go build ./...

test:
	go test ./...

lint:
	@out=$$(gofmt -l .); \
	if [ -n "$$out" ]; then \
		echo "gofmt needs to be run on:"; \
		echo "$$out"; \
		exit 1; \
	fi
	go vet ./...

fmt:
	gofmt -w .

build-workflow:
	scripts/build-workflow.sh

# Build the tag at HEAD and publish a GitHub Release from this machine —
# a fallback for when .github/workflows/release.yml can't run (e.g. Actions
# billing issues). See scripts/release.sh.
release:
	scripts/release.sh

precommit:
	pre-commit run --all-files

update-charter:
	curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh | CHARTER_UPDATE_ONLY=1 bash

update-workflow-notes:
	curl -fsSL https://raw.githubusercontent.com/y-marui/alfred-workflow-template/main/scripts/install-workflow-notes.sh | bash
