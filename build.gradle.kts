plugins {
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
    id("org.jlleitschuh.gradle.ktlint") version "12.1.1"
}

extra["composeBom"] = "2024.12.01"

ktlint {
    version.set("1.2.1")
    outputToConsole.set(true)
    coloredOutput.set(true)
    ignoreFailures.set(false)
}
