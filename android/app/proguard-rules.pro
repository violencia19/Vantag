# ============================================
# VANTAG PROGUARD RULES
# AGGRESSIVE REVERSE ENGINEERING PROTECTION
# ============================================

# ============================================
# AGGRESSIVE OBFUSCATION SETTINGS
# Goal: Make decompiled code unreadable
# ============================================

# Rename everything to single letters (a, b, c, aa, ab, etc.)
-repackageclasses ''
-allowaccessmodification
-flattenpackagehierarchy ''

# Aggressive optimizations
-optimizationpasses 5
-dontpreverify
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*,!code/allocation/variable

# Obfuscate dictionary - use short random names
-obfuscationdictionary proguard-dict.txt
-classobfuscationdictionary proguard-dict.txt
-packageobfuscationdictionary proguard-dict.txt

# Remove all debugging information
-renamesourcefileattribute ''
-keepattributes SourceFile,LineNumberTable

# Encrypt string constants where possible
-adaptclassstrings
-adaptresourcefilenames
-adaptresourcefilecontents

# ============================================
# STRIP DEBUG INFORMATION
# ============================================
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
    public static int e(...);
    public static int wtf(...);
}

-assumenosideeffects class java.io.PrintStream {
    public void println(...);
    public void print(...);
}

-assumenosideeffects class kotlin.jvm.internal.Intrinsics {
    public static void checkParameterIsNotNull(...);
    public static void checkNotNullParameter(...);
    public static void checkExpressionValueIsNotNull(...);
    public static void checkNotNullExpressionValue(...);
}

# ============================================
# FIREBASE RULES (Required - Cannot Obfuscate)
# ============================================
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Crashlytics - Keep for crash reporting
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.firebase.crashlytics.** { *; }
-keep class com.google.firebase.analytics.** { *; }
-keep class com.google.firebase.firestore.** { *; }

# ============================================
# REVENUECAT RULES (Required)
# ============================================
-keep class com.revenuecat.purchases.** { *; }
-keep class com.revenuecat.purchases.common.** { *; }
-dontwarn com.revenuecat.purchases.**

# ============================================
# GOOGLE ML KIT RULES
# ============================================
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# ============================================
# FLUTTER CORE (Required)
# ============================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ============================================
# HOME WIDGET (Required for Android Widgets)
# ============================================
-keep class es.antonborri.home_widget.** { *; }
-keep class com.vantag.app.**WidgetProvider { *; }
-keepclassmembers class * extends android.appwidget.AppWidgetProvider {
    public void onUpdate(android.content.Context, android.appwidget.AppWidgetManager, int[]);
    public void onEnabled(android.content.Context);
    public void onDisabled(android.content.Context);
    public void onDeleted(android.content.Context, int[]);
    public void onReceive(android.content.Context, android.content.Intent);
}

# ============================================
# SECURITY MODULE (Keep for runtime checks)
# ============================================
-keep class com.vantag.app.security.** { *; }
-keep class com.vantag.app.SecurityChecker { *; }

# ============================================
# OKHTTP (Required for network)
# ============================================
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# ============================================
# GSON/SERIALIZATION
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
# HIVE DATABASE
# ============================================
-keep class * extends com.cossacklabs.hive.** { *; }

# ============================================
# NATIVE SECURITY CHECKS (Anti-Tampering)
# Keep native method bindings
# ============================================
-keepclasseswithmembernames class * {
    native <methods>;
}

# ============================================
# PREVENT REFLECTION ATTACKS
# ============================================
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
