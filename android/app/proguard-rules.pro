# Flutter - Deferred components / Play Core (no usamos deferred components)
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Modelos
-keep class com.medident.medident.model.** { *; }
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
