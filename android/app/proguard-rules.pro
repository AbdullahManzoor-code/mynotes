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

# WebView
-keep class android.webkit.** { *; }

# Sqflite
-keep class com.tekartik.sqflite.** { *; }

