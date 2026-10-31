# Fundus (Android Boilerplate)

A minimal Android app template using **Kotlin** and **Jetpack Compose** without Android Studio.
The build process runs inside a container.

## Build Environment
* **os:** linux (tested on **debian 13**)
* **containers:** (tested on **rootless docker**)
* **local tools:** make, adb

## Makefile Rules
* `prepare-builder` — builds the builder image
* `compile-in-container` — compiles the app (`_build/fundus.apk`)
* `lint-in-container`, `ktlint-in-container` — run linters
* `clean-in-container` — cleans up build artifacts

```bash
make prepare-builder compile-in-container
```
or
```bash
make tea
```

## Install on Device
```bash
adb install _build/fundus.apk
```

![screenshot](docs/fundus.png)

