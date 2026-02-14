# Add project specific ProGuard rules here.
# By default, the flags in this file are appended after configuration from
# the Android Gradle plugin.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class com.google.android.gms.internal.** { *; }
-keep class com.google.android.gms.common.internal.safeparcel.SafeParcelable {
    public static final *** NULL;
}

# Keep your application classes
-keep class com.abdullahmanzoor.mynotes.** { *; }

# Flutter standard ProGuard rules
-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.android.gms.maps.model.** { *; }

# Google ML Kit & Maps
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-dontwarn com.google.mlkit.**
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Play Core (Deferred Components)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.tasks.**
-keep class com.google.android.play.core.** { *; }

# Flutter Deferred Components
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**


# SQFLite & SQLite
-keep class com.tekartik.sqflite.** { *; }
-keep class io.requery.android.database.sqlite.** { *; }
-dontwarn com.tekartik.sqflite.**


# Flutter Plugins general
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# Prevent R8 from being too aggressive with optimization that might cause OOM
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
-keepattributes Signature,Annotation,Exceptions

# Apache Tika / javax.xml.stream
-dontwarn javax.xml.stream.**
-dontwarn javax.xml.namespace.QName
-dontwarn org.apache.tika.**
-dontwarn org.apache.pdfbox.**
-dontwarn org.apache.poi.**


