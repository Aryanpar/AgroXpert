import com.android.build.gradle.LibraryExtension

// ✅ Add Google Services plugin version here
plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    if (name == "flutter_bluetooth_serial") {
        plugins.withId("com.android.library") {
            extensions.configure<LibraryExtension>("android") {
                namespace = "io.github.edufolly.flutterbluetoothserial"
            }
        }
    }
}
