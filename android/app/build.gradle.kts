plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.app7"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.app7"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a"))
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
//val flutterOutDir = file("$buildDir/outputs/apk")
//val cliOutDir = file("${rootDir.parentFile}/build/app/outputs/flutter-apk")

//tasks.register<Copy>("syncFlutterApks") {
//    from(flutterOutDir)
//    into(cliOutDir)
//    doFirst {
//        cliOutDir.mkdirs()
//        println("[sync] Copying APKs from ${flutterOutDir} to ${cliOutDir}")
//    }
//}

//android.applicationVariants.all {
//    val cap = name.capitalize()
//    listOf("package${cap}", "assemble${cap}").forEach { tname ->
//        tasks.findByName(tname)?.let { task ->
//            task.finalizedBy("syncFlutterApks")
//        }
//    }
//}

//gradle.buildFinished {
//    if (flutterOutDir.exists() && flutterOutDir.listFiles()?.isNotEmpty() == true) {
//        cliOutDir.mkdirs()
//        copy {
//            from(flutterOutDir)
//            into(cliOutDir)
//        }
//        println("[sync] Build finished: synced APKs to ${cliOutDir}")
//    }
//}