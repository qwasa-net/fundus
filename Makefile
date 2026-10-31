DOCKER_IMAGE := fundus-builder

GRADLE_VERSION := 8.10.2

APK_DEBUG ?= 1

ifeq ($(APK_DEBUG),1)
APK_SRC := app/build/outputs/apk/debug/app-debug.apk
ASSEMBLE_CMD := assembleDebug
else
APK_SRC := app/build/outputs/apk/release/app-release.apk
ASSEMBLE_CMD := assembleRelease
endif

APK_DST := _build/fundus.apk

DOCKER := DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker

DOCKER_RUN := $(DOCKER) run \
	--rm \
	--tty --interactive \
	-v $(CURDIR):/workspace \
	-v $(CURDIR)/.gradle_cache:/workspace/.gradle_cache \
	-e GRADLE_USER_HOME=/workspace/.gradle_cache \
	-e HOME=/tmp/home \
	-w /workspace \
	$(DOCKER_IMAGE)

.DEFAULT_GOAL := help

.PHONY: help prepare-builder lint-in-container check-style-in-container format-kotlin-in-container compile-in-container compile-offline-in-container clean-in-container shell-in-container

help:
	@echo
	@echo == fundus builder ==
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST)
	@echo
	@echo "> make tea"
	@echo

tea: prepare-builder compile-in-container ## 1, 2, go

prepare-builder: ## prepare docker image
	$(DOCKER) build --build-arg GRADLE_VERSION=$(GRADLE_VERSION) -t $(DOCKER_IMAGE) .

compile-in-container: .gradle_cache _build ## build debug APK to _build/
	$(DOCKER_RUN) gradle $(ASSEMBLE_CMD)
	cp -v $(APK_SRC) $(APK_DST)
	ls -lh $(APK_DST)

compile-offline-in-container: .gradle_cache _build ## build APK offline
	$(DOCKER_RUN) gradle $(ASSEMBLE_CMD) --offline
	cp -v $(APK_SRC) $(APK_DST)
	ls -lh $(APK_DST)

lint-in-container: .gradle_cache ## check style (lint+ktlint+detekt)
	$(DOCKER_RUN) gradle lintDebug ktlintCheck detekt --rerun-tasks -i

format-in-container: .gradle_cache ## auto format (ktlint)
	$(DOCKER_RUN) gradle ktlintFormat

shell-in-container:
	$(DOCKER_RUN) /bin/bash

clean-in-container: .gradle_cache ## clean build (gradlew clean)
	$(DOCKER_RUN) gradle clean

clean: ## clear caches
	rm -rI .gradle_cache _build .kotlin .gradle app/build

.gradle_cache _build:
	mkdir -pv $@
