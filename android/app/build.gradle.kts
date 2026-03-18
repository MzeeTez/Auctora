plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.auctora"
    compileSdk = 36 // Better compatibility than 36 for current Flutter plugins
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.auctora"
        minSdk = flutter.minSdkVersion // <-- KEEP THIS AT 21 (For Stripe)
        targetSdk = 34 // (You can leave this at 34 or change to 36, either is fine)
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // REMOVED the hardcoded Firebase dependencies.
    // Flutter handles Firebase automatically via pubspec.yaml!
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.0")
    implementation("androidx.core:core-ktx:1.12.0")
}

flutter {
    source = "../.."
}
