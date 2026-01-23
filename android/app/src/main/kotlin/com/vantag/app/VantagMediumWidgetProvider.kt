package com.vantag.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Medium Widget (4x2) - Daily Spending + Pursuit Progress
 * Shows: Today's spending in work time + pursuit goal progress
 */
class VantagMediumWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_medium)

            // Get data from SharedPreferences (saved by Flutter)
            val prefs = HomeWidgetPlugin.getData(context)

            val formattedTime = prefs.getString("formattedTime", "--") ?: "--"
            val formattedAmount = prefs.getString("formattedAmount", "--") ?: "--"
            val spendingLevel = prefs.getString("spendingLevel", "low") ?: "low"
            val locale = prefs.getString("locale", "en") ?: "en"
            val hasPursuit = prefs.getBoolean("hasPursuit", false)
            val pursuitName = prefs.getString("pursuitName", "") ?: ""
            val pursuitProgressText = prefs.getString("pursuitProgressText", "") ?: ""
            val pursuitProgress = prefs.getFloat("pursuitProgress", 0f)
            val pursuitTarget = prefs.getFloat("pursuitTarget", 0f)

            // Set spending section text values
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

            // Handle pursuit section
            if (hasPursuit && pursuitName.isNotEmpty()) {
                views.setViewVisibility(R.id.widget_pursuit_section, View.VISIBLE)
                views.setViewVisibility(R.id.widget_no_pursuit_section, View.GONE)

                views.setTextViewText(R.id.widget_pursuit_name, pursuitName)
                views.setTextViewText(R.id.widget_pursuit_progress_text, pursuitProgressText)

                // Calculate progress bar width (percentage)
                val progressPercent = if (pursuitTarget > 0) {
                    ((pursuitProgress / pursuitTarget) * 100).coerceIn(0f, 100f).toInt()
                } else {
                    0
                }
                views.setProgressBar(R.id.widget_pursuit_progress_bar, 100, progressPercent, false)
            } else {
                views.setViewVisibility(R.id.widget_pursuit_section, View.GONE)
                views.setViewVisibility(R.id.widget_no_pursuit_section, View.VISIBLE)

                // Set "Set a goal" label based on locale
                val setGoalLabel = if (locale == "tr") "Hedef belirle" else "Set a goal"
                views.setTextViewText(R.id.widget_set_goal_label, setGoalLabel)
            }

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
