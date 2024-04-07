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

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Timer;
import java.util.TimerTask;

public class L2Service extends Service {
    private static final String TAG = "L2Service";
    private static final int QUERY_NATIVEL2_INTERVAL = 5000;

    // Binder given to clients.
    private final IBinder mBinder = new LocalBinder();
    private final boolean mIsManuallyStopped = false;
    AtomicBoolean mIsRunning = new AtomicBoolean(false);
    private L2ServiceConfig mConfig;
    private String mNotificationTitle;
    private String mNotificationChannelId;
    private int mNotificationId;
    private int mLastShownNotificationId;
    private boolean mIsNativeL2Online = false;
    private long mNativeL2StateUpdateTime = 0;
    private static Timer timer = new Timer(); 

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
        Log.v(TAG, "jsonCall:" + args);
        String result = HelloJni.JSONCall(args);

        // hook
        if (args.contains("{\"method\":\"state\"")) {
            boolean old = mIsNativeL2Online;
            parseAndUpdateNativeL2State(result);
            if (old != mIsNativeL2Online) {
                updateNotificationInfo();
            }

            mNativeL2StateUpdateTime = System.currentTimeMillis();
        }

        return result;
    }

    public void setServiceStartupCmd(String args) {
        Log.v(TAG, "setServiceStartupCmd:" + args);
        mConfig.setServiceStartupCmd(args);
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
        mNotificationId = mConfig.getForegroundNotificationId();

        runService();

        Log.v(TAG, "Service onCreate");
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
        timer.cancel();
        mIsRunning.set(false);

        super.onDestroy();

        Log.v(TAG, "Service onDestroy");
    }

    private void updateNotificationInfo() {
        if (mConfig.isForeground()) {
            createAndShowForegroundNotification(mNotificationId);
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        mConfig.setManuallyStopped(false);

        boolean isStartbySystem = true;
        Bundle extras = intent.getExtras();
        if (extras != null) {
            String notify = extras.getString("titan");
            if (notify != null) {
                isStartbySystem = false;
                if (notify.equalsIgnoreCase("permission_changed")) {
                    updateNotificationInfo();
                } else if (notify.equalsIgnoreCase("startby_titan_app")) {
                    Log.v(TAG, "Service start titan app");
                }
            }
        }

        if (isStartbySystem) {
            // check whether need to execute or not startup command
            String cmd = mConfig.getServiceStartupCmd();
            if (cmd != "") {
                String result = jsonCall(cmd);
                Log.v(TAG, "L2Service start by system, execute startup cmd:" + cmd + ", result:" + result);
            } else {
                 Log.v(TAG, "L2Service start by system, startup cmd is empty");
            }
        }

        // WatchdogReceiver.enqueue(this);
        return START_STICKY;
    }

    private TimerTask mQueryNativeL2StateTask = new TimerTask() {
        public void run() {
            long now = System.currentTimeMillis();
            if ((now - mNativeL2StateUpdateTime) >= QUERY_NATIVEL2_INTERVAL) {
                boolean old = mIsNativeL2Online;
                queryNativeL2State();
                mNativeL2StateUpdateTime = System.currentTimeMillis();

                if (old != mIsNativeL2Online) {
                    updateNotificationInfo();
                }
            }
        }
    };

    private void runService() {
        if (mIsRunning.get()) {
            Log.v(TAG, "Service already running, using existing service");
            return;
        }

        updateNotificationInfo();

        // every 5 seconds
        timer.schedule(mQueryNativeL2StateTask, QUERY_NATIVEL2_INTERVAL, QUERY_NATIVEL2_INTERVAL);

        mIsRunning.set(true);
    }

    private String buildNotificationContent() {
        if (mIsNativeL2Online) {
            return "your node is online";
        } else {
            return "your node is offline";
        }
    }

    private void queryNativeL2State() {
        String args = "{\"method\":\"state\",\"JSONParams\":\"\"}";
        String result = HelloJni.JSONCall(args);

        parseAndUpdateNativeL2State(result);
    }

    private void parseAndUpdateNativeL2State(String j) {
        try {
            JSONObject jObject = new JSONObject(j);
            // Pulling items from the array
            int code = jObject.getInt("code");
            if (code == 0) {
                String dataStr = jObject.getString("data");
                JSONObject jdata = new JSONObject(dataStr);
                mIsNativeL2Online = jdata.getBoolean("online");
            } else {
                mIsNativeL2Online = false;
            }
        } catch (JSONException e) {
            Log.e(TAG, "queryNativeL2State json exception:" + e.getMessage());
        }
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
        String notificationContent = buildNotificationContent();
        builder.setOngoing(true).setSmallIcon(R.mipmap.ic_launcher_round).setContentTitle(mNotificationTitle).setContentText(notificationContent).setContentIntent(pi);

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