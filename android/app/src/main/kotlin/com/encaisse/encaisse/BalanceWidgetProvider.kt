package com.encaisse.encaisse

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class BalanceWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val title = widgetData.getString("widget_title", null)
        val body = widgetData.getString("widget_body", null)
        val updated = widgetData.getString("widget_updated", null)

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.balance_widget).apply {
                if (!title.isNullOrBlank()) setTextViewText(R.id.widget_title, title)
                if (!body.isNullOrBlank()) setTextViewText(R.id.widget_body, body)
                if (updated.isNullOrBlank()) {
                    setViewVisibility(R.id.widget_updated, View.GONE)
                } else {
                    setViewVisibility(R.id.widget_updated, View.VISIBLE)
                    setTextViewText(R.id.widget_updated, updated)
                }
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
