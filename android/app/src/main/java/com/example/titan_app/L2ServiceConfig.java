package com.example.titan_app;

import android.content.Context;
import android.content.SharedPreferences;

public class L2ServiceConfig {
    final SharedPreferences mPref;

    public L2ServiceConfig(Context context) {
        this.mPref = context.getSharedPreferences("titan_jni_l2service", Context.MODE_PRIVATE);
    }

    public boolean isAutoStartOnBoot() {
        return mPref.getBoolean("auto_start_on_boot", true);
    }

    public void setAutoStartOnBoot(boolean value) {
        mPref.edit().putBoolean("auto_start_on_boot", value).apply();
    }

    public boolean isForeground() {
        return mPref.getBoolean("is_foreground", true);
    }

    public void setIsForeground(boolean value) {
        mPref.edit().putBoolean("is_foreground", value).apply();
    }

    public long getBackgroundHandle() {
        return mPref.getLong("background_handle", 0);
    }

    public void setBackgroundHandle(long value) {
        mPref.edit().putLong("background_handle", value).apply();
    }

    public String getInitialNotificationTitle() {
        return mPref.getString("initial_notification_title", "Titan Edge Service");
    }

    public void setInitialNotificationTitle(String value) {
        mPref.edit().putString("initial_notification_title", value).apply();
    }

    public String getInitialNotificationContent() {
        return mPref.getString("initial_notification_content", "In Serving ...");
    }

    public void setInitialNotificationContent(String value) {
        mPref.edit().putString("initial_notification_content", value).apply();
    }

    public String getNotificationChannelId() {
        return mPref.getString("notification_channel_id", null);
    }

    public void setNotificationChannelId(String value) {
        mPref.edit().putString("notification_channel_id", value).apply();
    }

    public int getForegroundNotificationId() {
        return mPref.getInt("foreground_notification_id", 112233);
    }

    public void setForegroundNotificationId(int value) {
        mPref.edit().putInt("foreground_notification_id", value).apply();
    }

    public String getServiceStartupCmd() {
        return mPref.getString("l2_service_startup_cmd", "");
    }

    public void setServiceStartupCmd(String value) {
        mPref.edit().putString("l2_service_startup_cmd", value).apply();
    }

    public String getLocaleString() {
        return mPref.getString("l2_service_locale", "en");
    }

    public void setLocaleString(String value) {
        mPref.edit().putString("l2_service_locale", value).apply();
    }
}
