plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // Omit if your app doesn't use Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.schoolapp" // Replace with your app's namespace
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.schoolapp" // Replace with your app's ID
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 1 // Increment as needed
        versionName = "1.0" // Adjust as needed
    }

    buildTypes {
    getByName("release") {
        signingConfig = signingConfigs.getByName("debug")
    }
}

compileOptions {
    isCoreLibraryDesugaringEnabled = true
}

}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}