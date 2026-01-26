package com.vantag.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Medium Widget (4x2) - Daily Spending + Pursuit Progress
 * Shows: Today's spending in work time + pursuit goal progress
 */
class VantagMediumWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "VantagMediumWidget"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.widget_medium)

                // Get data from SharedPreferences (saved by Flutter)
                val prefs: SharedPreferences? = try {
                    HomeWidgetPlugin.getData(context)
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to get HomeWidget data: ${e.message}")
                    null
                }

                // Use safe defaults if prefs is null
                val formattedTime = prefs?.getString("formattedTime", "0h 0m") ?: "0h 0m"
                val formattedAmount = prefs?.getString("formattedAmount", "₺0") ?: "₺0"
                val spendingLevel = prefs?.getString("spendingLevel", "low") ?: "low"
                val locale = prefs?.getString("locale", "tr") ?: "tr"
                val hasPursuit = prefs?.getBoolean("hasPursuit", false) ?: false
                val pursuitName = prefs?.getString("pursuitName", "") ?: ""
                val pursuitProgressText = prefs?.getString("pursuitProgressText", "") ?: ""
                val pursuitProgress = prefs?.getFloat("pursuitProgress", 0f) ?: 0f
                val pursuitTarget = prefs?.getFloat("pursuitTarget", 0f) ?: 0f

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
                Log.d(TAG, "Widget $appWidgetId updated successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to update widget $appWidgetId: ${e.message}")
                // Show error state with default values
                try {
                    val errorViews = RemoteViews(context.packageName, R.layout.widget_medium)
                    errorViews.setTextViewText(R.id.widget_time_value, "0h 0m")
                    errorViews.setTextViewText(R.id.widget_amount_value, "₺0")
                    errorViews.setTextViewText(R.id.widget_today_label, "Bugün")
                    errorViews.setViewVisibility(R.id.widget_pursuit_section, View.GONE)
                    errorViews.setViewVisibility(R.id.widget_no_pursuit_section, View.VISIBLE)
                    errorViews.setTextViewText(R.id.widget_set_goal_label, "Hedef belirle")
                    appWidgetManager.updateAppWidget(appWidgetId, errorViews)
                } catch (fallbackError: Exception) {
                    Log.e(TAG, "Fallback also failed: ${fallbackError.message}")
                }
            }
        }
    }

    override fun onEnabled(context: Context) {
        Log.d(TAG, "Widget enabled")
    }

    override fun onDisabled(context: Context) {
        Log.d(TAG, "Widget disabled")
    }
}
