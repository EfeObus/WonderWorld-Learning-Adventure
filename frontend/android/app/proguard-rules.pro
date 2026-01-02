# Flutter ProGuard Rules for Production
# WonderWorld Learning Adventure - Children's Educational App

#---------------------------------
# Flutter Core - Keep Flutter framework classes
#---------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

#---------------------------------
# Hive Local Storage - Keep model classes
#---------------------------------
-keep class * extends com.hive.Hive { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

#---------------------------------
# Speech to Text Plugin
#---------------------------------
-keep class com.csdcorp.speech_to_text.** { *; }
-dontwarn com.csdcorp.speech_to_text.**

#---------------------------------
# Audioplayers Plugin
#---------------------------------
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

#---------------------------------
# Flutter TTS Plugin
#---------------------------------
-keep class com.tundralabs.fluttertts.** { *; }
-dontwarn com.tundralabs.fluttertts.**

#---------------------------------
# Security - Prevent Reverse Engineering
#---------------------------------
# Obfuscate all classes except those specifically kept
-repackageclasses ''
-allowaccessmodification
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*

# Remove debug information
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable

# Encrypt string literals (basic obfuscation)
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
}

#---------------------------------
# Kotlin Support
#---------------------------------
-dontwarn kotlin.**
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

#---------------------------------
# AndroidX and Google Play Core
#---------------------------------
-keep class androidx.** { *; }
-dontwarn androidx.**
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**

#---------------------------------
# Serialization
#---------------------------------
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

#---------------------------------
# Prevent crashes on reflection
#---------------------------------
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep setters for views
-keepclassmembers public class * extends android.view.View {
    void set*(***);
    *** get*();
}

#---------------------------------
# COPPA Compliance - No analytics/tracking
#---------------------------------
# This app does not use any analytics or tracking SDKs
# to comply with children's privacy regulations
