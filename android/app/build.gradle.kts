
android {
    ndkVersion = "27.0.12077973"
    namespace = "com.app.myapp"
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.app.myapp"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0 "
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
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
    // ✅ Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))

    // ✅ Add the Firebase dependencies you need:
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")



}
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services") // ✅ Required for Firebase
}