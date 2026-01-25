# Google ML Kit Text Recognition
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
