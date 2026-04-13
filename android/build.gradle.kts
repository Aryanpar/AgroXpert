import com.android.build.gradle.LibraryExtension

plugins {
    id("com.google.gms.google-services") version "4.4.4" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Avoid hard-failing Android release builds due to library lint (e.g. firebase_auth lintVital...),
// and reduce memory spikes during APK builds.
subprojects {
    // AGP 8 locks parts of the lint DSL early; disabling the specific tasks is reliable.
    tasks.matching { it.name.startsWith("lintVital") }.configureEach {
        enabled = false
    }
    // Optional: also skip heavy release lint tasks that can OOM in CI/low-RAM machines.
    tasks.matching { it.name == "lintRelease" || it.name == "lintAnalyzeRelease" }.configureEach {
        enabled = false
    }

    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.core" && (requested.name == "core" || requested.name == "core-ktx")) {
                // If the project is flutter_bluetooth_serial, force an older version that doesn't use lStar
                // Otherwise use a modern version.
                if (project.name == "flutter_bluetooth_serial") {
                    useVersion("1.6.0")
                } else {
                    useVersion("1.13.1")
                }
            }
        }
    }
}

subprojects {
    if (name == "flutter_bluetooth_serial") {
        plugins.withId("com.android.library") {
            extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                namespace = "io.github.edufolly.flutterbluetoothserial"
                compileSdk = 31 // SDK 31 is the minimum for lStar but 1.6.0 core doesn't need it
            }
        }
    }
}
