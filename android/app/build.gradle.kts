plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Versi aplikasi
val flutterVersionCode = 1
val flutterVersionName = "1.0.0"

android {
    namespace = "com.wa.tanpa.simpan.nomor"

    compileSdk = 34
    ndkVersion = "27.0.12077973" // ✅ UPDATE SESUAI PERMINTAAN BUILDER

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.wa.tanpa.simpan.nomor"
        minSdk = 21
        targetSdk = 34
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            // Ganti ini jika nanti sudah punya signing config production
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // Opsional: mencegah error pada Android 12+ (jika pakai intent WA)
    packagingOptions {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

flutter {
    source = "../.."
}
