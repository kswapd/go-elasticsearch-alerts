# Copyright 2019 The Morning Consult, LLC or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may
# not use this file except in compliance with the License. A copy of the
# License is located at
#
#         https://www.apache.org/licenses/LICENSE-2.0
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.

# Disable verbosity
MAKEFLAGS += --silent --no-print-directory

REPO := github.com/$(shell git config remote.origin.url | sed -e 's/.*://g' -e 's/\.git//g')
SOURCES := $(shell find . -name '*.go')
BINARY_NAME=go-elasticsearch-alerts
LOCAL_BINARY=bin/$(BINARY_NAME)

all: build

docker: Dockerfile
	scripts/docker-build.sh
.PHONY: docker

build: $(LOCAL_BINARY)
.PHONY: build

$(LOCAL_BINARY): $(SOURCES)
	@echo "==> Starting binary build..."
	@sh -c "'./scripts/build-binary.sh' '$(shell git describe --tags --abbrev=0)' '$(shell git rev-parse --short HEAD)' '$(REPO)'"
	@echo "==> Done. Your binary can be found at bin/go-elasticsearch-alerts."

git_chglog_check:
	if [ -z "$(shell which git-chglog)" ]; then \
		GOPATH=$(shell pwd) PATH=$$PATH:$(shell pwd)/bin go get -u -v github.com/git-chglog/git-chglog/cmd/git-chglog && GOPATH=$(shell pwd) PATH=$$PATH:$(shell pwd)/bin git-chglog --version; \
	fi
.PHONY: git_chglog_check

changelog: git_chglog_check
	GOPATH=$(shell pwd) PATH=$$PATH:$(shell pwd)/bin git-chglog --output CHANGELOG.md
.PHONY: changelog
