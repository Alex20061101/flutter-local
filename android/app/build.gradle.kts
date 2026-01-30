plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 1. ADD THIS BLOCK: This tells Gradle exactly which Java version to use for the YOLO native code
java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(17))
    }
}

android {
    namespace = "com.example.flutter_local"
    compileSdk = 36 // Updated to match the latest SDK you installed
    
    // 2. FIXED NDK: Using the version specifically requested by the YOLO plugin
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.flutter_local"
        
        // 3. MIN SDK UPGRADE: YOLOv8 and modern TFLite require at least 24
        minSdk = 24 
        targetSdk = 35
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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