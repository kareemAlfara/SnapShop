plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.shop_app"
    compileSdk = 36 // ✅ رفعناها من 34 → 36
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.shop_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // ✅ ضروري لتفعيل desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.facebook.android:facebook-login:latest.release")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")

    implementation("com.onesignal:OneSignal:5.1.3")
    // ✅ استخدم آخر إصدار متوافق من مكتبة desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
        // OneSignal already added

    // ✅ Huawei Push Kit (إجباري)
    implementation("com.huawei.hms:push:6.12.0.300")
}


