plugins {
    id "com.android.application"
    id "org.jetbrains.kotlin.android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"
}

android {
    namespace = "com.socials.app"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.socials.app"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled false
            shrinkResources false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation platform("com.google.firebase:firebase-bom:33.4.0")
    implementation "com.google.firebase:firebase-analytics"
    implementation "com.google.firebase:firebase-auth"

    implementation "androidx.core:core-ktx:1.12.0"
    implementation "androidx.appcompat:appcompat:1.6.1"
}

apply from: "twitter_login_patch.gradle"
