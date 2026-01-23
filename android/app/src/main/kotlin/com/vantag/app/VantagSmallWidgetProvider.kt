package com.vantag.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Small Widget (2x2) - Daily Spending Summary
 * Shows: Today's spending in work time + currency amount
 */
class VantagSmallWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_small)

            // Get data from SharedPreferences (saved by Flutter)
            val prefs = HomeWidgetPlugin.getData(context)

            val formattedTime = prefs.getString("formattedTime", "--") ?: "--"
            val formattedAmount = prefs.getString("formattedAmount", "--") ?: "--"
            val spendingLevel = prefs.getString("spendingLevel", "low") ?: "low"
            val locale = prefs.getString("locale", "en") ?: "en"

            // Set text values
            views.setTextViewText(R.id.widget_time_value, formattedTime)
            views.setTextViewText(R.id.widget_amount_value, formattedAmount)

            // Set "Today" label based on locale
            val todayLabel = if (locale == "tr") "Bugün" else "Today"
            views.setTextViewText(R.id.widget_today_label, todayLabel)

            // Set spending level indicator color
            val indicatorColor = when (spendingLevel) {
                "low" -> 0xFF2ECC71.toInt()    // Green
                "medium" -> 0xFFFF8C00.toInt() // Orange
                "high" -> 0xFFE74C3C.toInt()   // Red
                else -> 0xFF2ECC71.toInt()
            }
            views.setInt(R.id.widget_level_indicator, "setBackgroundColor", indicatorColor)

            // Update widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onEnabled(context: Context) {
        // Called when first widget is created
    }

    override fun onDisabled(context: Context) {
        // Called when last widget is removed
    }
}
