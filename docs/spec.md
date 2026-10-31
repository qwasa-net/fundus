# Спецификация и план реализации шаблона андроид приложения Fundus

## Описание

Минимальный шаблон Android-приложения с одной `Activity` и декларативным UI на Jetpack Compose.

### Технологический стек
- **Язык:** Kotlin
- **UI:** Jetpack Compose (без XML-верстки экранов)
- **Артефакт:** `debug` APK + копия в `_build/fundus.apk`
- **Сборка и линт:** только через Docker, точка входа — `Makefile`

### SDK и toolchain
- `minSdk = 28` (Android 9)
- `targetSdk = 35`
- `compileSdk = 35`
- `JDK = 21 (LTS)`
- `namespace` и `applicationId`: `dev.fundus` (при использовании шаблона заменить)

### Минимальные версии сборочного стека
- **Android Gradle Plugin (AGP):** `8.7.0`
- **Kotlin:** `2.0.21` (+плагин `org.jetbrains.kotlin.plugin.compose`)

Версии AGP, Kotlin и Compose BOM фиксируются явно в Gradle-конфигурации и обновляются централизованно.

---
## Структура проекта

````text
.
├── app
│   ├── build.gradle.kts (настройки сборки программы)
│   └── src
│       └── main
│           ├── AndroidManifest.xml (манифест приложения)
│           ├── java
│           │   └── dev
│           │       └── fundus
│           │           └── MainActivity.kt (код, главный экран)
│           └── res
│               └── values
│                   ├── strings.xml (тексты программы)
│                   └── themes.xml (настройки оформления)
├── build.gradle.kts (управление сборкой проекта)
├── detekt.yml (правила проверки стиля кода)
├── settings.gradle.kts (настройки сборки)
├── gradle.properties (настройки сборки)
├── Makefile (команды для запуска сборки)
└── Dockerfile (образ сборщика)

````

---

### Прикладной код (минимум)

1. `MainActivity.kt`:
   - `ComponentActivity`
   - `setContent { ... }`
   - `@Composable` с текстом `"Hello"` по центру экрана.
2. `AndroidManifest.xml`:
   - единственная `MainActivity`
   - launcher intent filter.
3. `themes.xml`:
   - минимальная совместимая тема для Compose/Activity.


## Сборка проекта

### Makefile как единая точка входа

Обязательные цели:
- `make prepare-builder` — сборка Docker-образа для компиляции приложения
- `make lint-in-container` — запуск `./gradle lintDebug` в контейнере
- `make compile-in-container` — запуск `./gradle assembleDebug` в контейнере
- `make clean-in-container` — запуск `./gradle clean` в контейнере
- `make tea` — быстрый старт: `prepare-builder` + `compile-in-container`

Принцип запуска контейнера:
- монтирование проекта: `$(PWD):/workspace`
- монтирование кэша: `$(PWD)/.gradle_cache:/workspace/.gradle_cache`
- переменные окружения контейнера: `GRADLE_USER_HOME=/workspace/.gradle_cache`, `HOME=/tmp/home`

### Рабочая директория

Проект монтируется в контейнер как `/workspace`.

### Кэширование и права доступа

Цель: быстрая повторная сборка на Linux и корректные права на файлы.

- **Gradle cache:** хранится в `./.gradle_cache`, подключается в контейнер как volume.
- **Кэш включает:** зависимости.

### Dockerfile
Образ сборки на базе JDK 21 (`eclipse-temurin:21-jdk` или эквивалент), включая:
- Android `cmdline-tools`
- принятие лицензий: `yes | sdkmanager --licenses`
- установку SDK-пакетов:
  - `platform-tools`
  - `platforms;android-35`
  - `build-tools;35.0.0`


### Описание стиля проекта (для линтера и автоформаттера)

Рекомендуемый минимальный набор:
- **ktlint** — обязателен (форматирование и базовый стиль Kotlin)
- **detekt** — опционально (мягкий статический анализ)

Базовые правила (без излишней строгости):
- максимальная длина строки: `120`
- wildcard-импорты запрещены
- неиспользуемые импорты — ошибка
- сложность функций и «магические числа» в detekt — warning, не error
- для тестов правила мягче, чем для production-кода

Файлы конфигурации:
- `.editorconfig` — форматирование и стиль
- `detekt.yml` — правила detekt (если включён)
- корневой `build.gradle.kts` — единая фиксация версий AGP/Kotlin/Compose BOM

---
## Критерии готовности (DoD)

1. `make prepare-builder` завершается без ошибок.
2. Первый `make compile-in-container` скачивает зависимости и создает debug APK.
3. Повторный `make compile-in-container` заметно быстрее за счет `./.gradle_cache`.
4. После сборки все файлы проекта доступны пользователю хоста без `sudo`.
5. `app-debug.apk` устанавливается на Android 9+ (API 28+) и показывает **"Hello" по центру экрана**.
6. Файл `_build/fundus.apk` создаётся при `make compile-in-container`.
7. `make lint-in-container` выполняется без критических ошибок.

## Порядок реализации

1. Подготовить `Dockerfile` и `Makefile` (базовый сборочный контур).
2. Добавить Gradle-конфигурацию (`settings.gradle.kts`, root/module `build.gradle.kts`, `gradle.properties`).
3. Добавить Android-файлы (`Manifest`, `MainActivity`, ресурсы).
4. Проверить `make prepare-builder`, `make compile-in-container`, `make lint-in-container`.
5. Проверить наличие `_build/fundus.apk`.
6. Зафиксировать результат в `README.md`.
