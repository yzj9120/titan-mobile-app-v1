package com.example.titan_app;

import android.util.Log;

public class HelloJni {
    private static final String TAG = "HelloJni";

    /* this is used to load the 'hello-jni' library on application
     * startup. The library has already been unpacked into
     * /data/data/com.example.hellojni/lib/libhello-jni.so at
     * installation time by the package manager.
     */
    static {
        try {
            System.loadLibrary("gol2");
            Log.d("huangzhen:", "gol2:ok ");
        } catch (UnsatisfiedLinkError e) {
            Log.d("huangzhen:", "gol2 failed to load.\n" + e);

            Log.d(TAG, "gol2 failed to load.\n" + e);
        }

        try {
            System.loadLibrary("hello-jni");
            Log.d("huangzhen:", "hello-jni " );

        } catch (UnsatisfiedLinkError e) {
            Log.d("huangzhen:", "hello-jni failed to load.\n" + e );
            Log.e(TAG, "hello-jni failed to load.\n" + e);
        }
    }

    public static native String JSONCall(String args);
}
