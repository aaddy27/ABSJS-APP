import java.util.Properties
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    id("com.android.application")   
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.sabsjs.laravel_auth_flutter"
    ndkVersion = "28.0.13004108"
    // Flutter-managed
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        // Keep compile target at Java 17 (safe for AGP). Gradle will run using org.gradle.java.home JDK.
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    // Kotlin options for Android compilation
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.sabsjs.laravel_auth_flutter"
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        versionCode = 12
        versionName = "1.12.0"
        // multiDexEnabled = true
    }

    // --- Load keystore props (android/key.properties) ---
    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(keystorePropertiesFile.inputStream())
    } else {
        println("WARNING: key.properties not found. Release build will fail to sign.")
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"]?.toString()
            if (!storeFilePath.isNullOrBlank()) {
                storeFile = file(storeFilePath)
                storePassword = keystoreProperties["storePassword"]?.toString()
                keyAlias = keystoreProperties["keyAlias"]?.toString()
                keyPassword = keystoreProperties["keyPassword"]?.toString()
            }
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") { /* default debug signing */ }
    }

    packagingOptions {
        jniLibs {
            // Use legacy packaging to keep the previous .so packaging behavior.
            // This can help avoid issues where newer AGP packaging causes native libs to be compressed/misaligned.
            useLegacyPackaging = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required for flutter_local_notifications (Java 8+ APIs on old Android versions)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// Ensure Kotlin compile tasks also target JVM 17
tasks.withType(KotlinCompile::class.java).configureEach {
    kotlinOptions.jvmTarget = "17"
}
