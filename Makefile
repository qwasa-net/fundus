DOCKER_IMAGE := fundus-builder
APK_SRC := app/build/outputs/apk/debug/app-debug.apk
APK_DST := _build/fundus.apk
GRADLE_VERSION := 8.10.2

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

tea: prepare-builder compile-in-container ## 1,2,go

prepare-builder: ## подготовить образ контейнера
	$(DOCKER) build --build-arg GRADLE_VERSION=$(GRADLE_VERSION) -t $(DOCKER_IMAGE) .

compile-in-container: .gradle_cache _build ## собрать debug APK в _build/
	$(DOCKER_RUN) gradle assembleDebug
	cp -v $(APK_SRC) $(APK_DST)
	ls -lh $(APK_DST)

compile-offline-in-container: .gradle_cache _build ## собрать APK в _build/
	$(DOCKER_RUN) gradle assembleDebug --offline
	cp -v $(APK_SRC) $(APK_DST)
	ls -lh $(APK_DST)

clean-in-container: .gradle_cache ## очистить сборку (gradlew clean)
	$(DOCKER_RUN) gradle clean

lint-in-container: .gradle_cache ## запустить lintDebug в контейнере
	$(DOCKER_RUN) gradle lintDebug

ktlint-in-container: .gradle_cache ## проверить стиль Kotlin (ktlint)
	$(DOCKER_RUN) gradle ktlintCheck

format-in-container: .gradle_cache ## автоформатирование Kotlin (ktlint)
	$(DOCKER_RUN) gradle ktlintFormat

shell-in-container:
	$(DOCKER_RUN) /bin/bash

.gradle_cache _build:
	mkdir -pv $@
