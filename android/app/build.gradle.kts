import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.waelapps.score_keeper"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.waelapps.score_keeper"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Only set signing values when the corresponding property is present and non-blank.
            // This avoids passing an empty string to file(""), which causes the Gradle error
            // "path may not be null or empty string." when key.properties is missing or empty.
            (keystoreProperties["keyAlias"] as String?)?.takeIf { it.isNotBlank() }?.let { keyAlias = it }
            (keystoreProperties["keyPassword"] as String?)?.takeIf { it.isNotBlank() }?.let { keyPassword = it }
            (keystoreProperties["storePassword"] as String?)?.takeIf { it.isNotBlank() }?.let { storePassword = it }
            (keystoreProperties["storeFile"] as String?)?.takeIf { it.isNotBlank() }?.let { storeFile = file(it) }
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
        }
    }
}

flutter {
    source = "../.."
}
