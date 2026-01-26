# ============================================
# VANTAG PROGUARD RULES
# Security hardening for production release
# ============================================

# ============================================
# FIREBASE RULES (Task 111-112)
# ============================================
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Auth
-keepattributes Signature
-keepattributes *Annotation*

# Firebase Crashlytics
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.firebase.crashlytics.** { *; }

# Firebase Analytics
-keep class com.google.firebase.analytics.** { *; }

# Firebase Firestore
-keep class com.google.firebase.firestore.** { *; }

# ============================================
# REVENUECAT RULES (Task 111-112)
# ============================================
-keep class com.revenuecat.purchases.** { *; }
-keep class com.revenuecat.purchases.common.** { *; }
-dontwarn com.revenuecat.purchases.**

# ============================================
# GOOGLE ML KIT RULES
# ============================================
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }

# Keep ML Kit common classes
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Home Widget Plugin - Required for Android widgets
-keep class es.antonborri.home_widget.** { *; }
-keep class es.antonborri.home_widget.HomeWidgetPlugin { *; }
-keep class es.antonborri.home_widget.HomeWidgetProvider { *; }

# Keep Vantag Widget Providers
-keep class com.vantag.app.VantagSmallWidgetProvider { *; }
-keep class com.vantag.app.VantagMediumWidgetProvider { *; }
-keep class com.vantag.app.**WidgetProvider { *; }

# Keep AppWidgetProvider methods
-keepclassmembers class * extends android.appwidget.AppWidgetProvider {
    public void onUpdate(android.content.Context, android.appwidget.AppWidgetManager, int[]);
    public void onEnabled(android.content.Context);
    public void onDisabled(android.content.Context);
    public void onDeleted(android.content.Context, int[]);
    public void onReceive(android.content.Context, android.content.Intent);
}

# ============================================
# GSON/JSON SERIALIZATION (Model Classes)
# ============================================
-keepattributes Signature
-keepattributes *Annotation*
-keep class * implements java.io.Serializable { *; }
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ============================================
# FLUTTER RULES
# ============================================
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ============================================
# HIVE DATABASE
# ============================================
-keep class * extends com.cossacklabs.hive.** { *; }

# ============================================
# OKHTTP/RETROFIT (HTTP CALLS)
# ============================================
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# ============================================
# SECURITY - Remove debug info in release
# ============================================
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
}

# ============================================
# PREVENT CLASS NAME LEAKING
# ============================================
-repackageclasses 'v'
-allowaccessmodification
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
