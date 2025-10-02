plugins {
    id("com.android.application")
    // Use the modern Kotlin Android plugin id
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.my_best_friend_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        // TODO: Cambia el applicationId por uno único para tu app (https://developer.android.com/studio/build/application-id.html)
        applicationId = "com.example.my_best_friend_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Configuración de Java / desugaring
    compileOptions {
        // Migrado a Java 17 (recomendado para AGP 8.x y Kotlin 2.1) para evitar warnings sobre Java 8 obsoleto.
        // Si encuentras algún plugin que no soporte 17, puedes retroceder a 11.
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Propiedad correcta en Kotlin DSL: isCoreLibraryDesugaringEnabled
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            // Firma temporal con debug para permitir `flutter run --release`
            signingConfig = signingConfigs.getByName("debug")
            // Para permitir shrinkResources (activado por el plugin) debemos activar minify (R8)
            isMinifyEnabled = true
            isShrinkResources = true
            // Archivo ProGuard / R8 (reglas adicionales). El archivo puede estar vacío si no necesitas reglas personalizadas.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // Desugaring libs (usar la versión indicada o la recomendada por el BOM si migras)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    // No es necesario declarar explícitamente kotlin-stdlib: lo añade el plugin Kotlin
}

flutter {
    source = "../.."
}
