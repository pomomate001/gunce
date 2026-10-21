# Room databases are created by reflection (WorkManager's WorkDatabase_Impl, used by the
# Google Mobile Ads SDK). R8 full mode removed it and the app crashed on start.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }

# flutter_local_notifications stores scheduled reminders with Gson generics.
-keepattributes Signature, *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Newer Flutter plugins (shared_preferences, path_provider, ...) are called from Dart through
# JNI by method name, so R8 must not rename or strip them.
-keep class io.flutter.plugins.** { *; }
-keep class com.github.dart_lang.jni.** { *; }
-keep class kotlin.** { *; }
-keep class kotlinx.coroutines.** { *; }
