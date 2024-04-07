package com.example.titan_app;

import static android.os.Build.VERSION.SDK_INT;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.os.Binder;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.app.ServiceCompat;

import java.util.concurrent.atomic.AtomicBoolean;

public class L2Service extends Service {
    private static final String TAG = "L2Service";
    // Binder given to clients.
    private final IBinder mBinder = new LocalBinder();
    private final boolean mIsManuallyStopped = false;
    AtomicBoolean mIsRunning = new AtomicBoolean(false);
    private L2ServiceConfig mConfig;
    private String mNotificationContent;
    private String mNotificationTitle;
    private String mNotificationChannelId;
    private int mNotificationId;
    private int mLastShownNotificationId;

    public static NotificationCompat.Builder getNotificationBuilder(Context context, String channelId, int importance) {
        NotificationCompat.Builder builder;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            prepareChannel(context, channelId, importance);
        }

        builder = new NotificationCompat.Builder(context, channelId);

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            builder.setForegroundServiceBehavior(Notification.FOREGROUND_SERVICE_IMMEDIATE);
        }

        return builder;
    }

    @TargetApi(26)
    private static void prepareChannel(Context context, String id, int importance) {
        CharSequence name = "Titan edge Service";
        String description = "Titan edge is running on background";
        final NotificationManager nm = (NotificationManager) context.getSystemService(Activity.NOTIFICATION_SERVICE);
        //NotificationManager notificationManager = getSystemService(NotificationManager.class);

        if (nm != null) {
            NotificationChannel nChannel = nm.getNotificationChannel(id);

            if (nChannel == null) {
                nChannel = new NotificationChannel(id, name, importance);
                nChannel.setDescription(description);
                nm.createNotificationChannel(nChannel);
            }
        }
    }

    public String jsonCall(String args) {
        return HelloJni.JSONCall(args);
    }

    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        return super.onUnbind(intent);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        mConfig = new L2ServiceConfig(this);

        String mNotificationChannelId = mConfig.getNotificationChannelId();
        if (mNotificationChannelId == null) {
            this.mNotificationChannelId = "TITAN_EDGE_SERVICE";
            //createNotificationChannel();
        } else {
            this.mNotificationChannelId = mNotificationChannelId;
        }

        mNotificationTitle = mConfig.getInitialNotificationTitle();
        mNotificationContent = mConfig.getInitialNotificationContent();
        mNotificationId = mConfig.getForegroundNotificationId();

        runService();
    }

    @Override
    public void onDestroy() {
        if (!mIsManuallyStopped) {
            // TODO
            // WatchdogReceiver.enqueue(this);
        } else {
            mConfig.setManuallyStopped(true);
        }

        stopForeground(STOP_FOREGROUND_REMOVE);
        mIsRunning.set(false);

        super.onDestroy();
    }

    private void updateNotificationInfo() {
        if (mConfig.isForeground()) {
            createAndShowForegroundNotification(mNotificationId);
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        mConfig.setManuallyStopped(false);

        Bundle extras = intent.getExtras();
        if (extras != null) {
            String notify = extras.getString("notify");
            if (notify != null && notify.equalsIgnoreCase("permission_changed")) {
                updateNotificationInfo();
            }
        }

        // WatchdogReceiver.enqueue(this);
        return START_STICKY;
    }

    private void runService() {
        if (mIsRunning.get()) {
            Log.v(TAG, "Service already running, using existing service");
            return;
        }

        updateNotificationInfo();

        mIsRunning.set(true);
    }

    private void createAndShowForegroundNotification(int mNotificationId) {

        final NotificationCompat.Builder builder = getNotificationBuilder(this, mNotificationChannelId, // Channel id
                NotificationManagerCompat.IMPORTANCE_LOW); //Low importance prevent visual appearance for this notification channel on top

        String packageName = getApplicationContext().getPackageName();
        Intent i = getPackageManager().getLaunchIntentForPackage(packageName);
        int flags = PendingIntent.FLAG_CANCEL_CURRENT;
        if (SDK_INT >= Build.VERSION_CODES.S) {
            flags |= PendingIntent.FLAG_MUTABLE;
        }

        PendingIntent pi = PendingIntent.getActivity(L2Service.this, 11, i, flags);

        builder.setOngoing(true).setSmallIcon(R.mipmap.ic_launcher_round).setContentTitle(mNotificationTitle).setContentText(mNotificationContent).setContentIntent(pi);

        Notification notification = builder.build();

        try {
            ServiceCompat.startForeground(this, mNotificationId, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MANIFEST);
        } catch (SecurityException e) {
            Log.w(TAG, "Failed to start foreground service due to SecurityException" + " - have you forgotten to request a permission? - " + e.getMessage());
        }

        if (mNotificationId != mLastShownNotificationId) {
            // Cancel previous notification
            final NotificationManager nm = (NotificationManager) this.getSystemService(Activity.NOTIFICATION_SERVICE);
            nm.cancel(mLastShownNotificationId);
        }
        mLastShownNotificationId = mNotificationId;
    }

    /**
     * Class used for the client Binder.  Because we know this service always
     * runs in the same process as its clients, we don't need to deal with IPC.
     */
    public class LocalBinder extends Binder {
        L2Service getService() {
            // Return this instance of L2Service so clients can call public methods.
            return L2Service.this;
        }
    }
}
