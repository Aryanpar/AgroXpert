plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Add this plugin
}

android {
    namespace = "com.example.aa_new"
    compileSdk = 36
    ndkVersion = "29.0.14033849"

    // Add TensorFlow Lite AAR files directory
    aaptOptions {
        noCompress("tflite")
        noCompress("lite")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.aa_new"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
        manifestPlaceholders["appAuthRedirectScheme"] = "fb1220475616667912"
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            // Disable minification to avoid R8 issues with TensorFlow Lite
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // Avoid hard-failing release builds on dependency lint issues (and reduces memory spikes).
    lint {
        abortOnError = false
        checkReleaseBuilds = false
    }
}

flutter {
    source = "../.."
}

// Workaround: ensure Flutter tool can find the APK under the Flutter project's root `build/` directory.
// Some Gradle configurations/plugins can stop the normal copy behavior, causing `flutter run` to fail
// with "failed to produce an .apk file" even though it exists under android/app/build/.
val flutterProjectDir = rootProject.projectDir.parentFile
val flutterRootBuildApkDir = File(flutterProjectDir, "build/app/outputs/flutter-apk")
tasks.register<Copy>("copyFlutterApkToRootDebug") {
    from(layout.buildDirectory.dir("outputs/flutter-apk"))
    include("*-debug.apk", "*.apk")
    into(flutterRootBuildApkDir)
}
tasks.register<Copy>("copyFlutterApkToRootRelease") {
    from(layout.buildDirectory.dir("outputs/flutter-apk"))
    include("*-release.apk", "*.apk")
    into(flutterRootBuildApkDir)
}
tasks.matching { it.name == "assembleDebug" }.configureEach { dependsOn("copyFlutterApkToRootDebug") }
tasks.matching { it.name == "assembleRelease" }.configureEach { dependsOn("copyFlutterApkToRootRelease") }

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.8.0"))

    // ✅ Add Google Play Services Auth for Google Sign-In
    implementation("com.google.android.gms:play-services-auth:20.7.0")

    // ✅ Add Facebook SDK if you’re using Facebook Login
    implementation("com.facebook.android:facebook-login:16.0.1")
}
