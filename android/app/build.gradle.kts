plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Add this plugin
}

android {
    namespace = "com.example.aa_new"
    compileSdk = 35
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
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Add Google Play Services Auth for Google Sign-In
    implementation("com.google.android.gms:play-services-auth:20.7.0")

    // ✅ Add Facebook SDK if you’re using Facebook Login
    implementation("com.facebook.android:facebook-login:16.0.1")
}
