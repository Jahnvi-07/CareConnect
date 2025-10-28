# Keep Flutter and entry points
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class com.google.gson.** { *; }

# Supabase and Kotlin coroutines/generic reflective usage
-keep class kotlinx.** { *; }
-keep class kotlin.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn org.jetbrains.annotations.**
-dontwarn kotlinx.coroutines.**

# Keep model classes with JSON annotations
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Optional: reduce logs
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}



