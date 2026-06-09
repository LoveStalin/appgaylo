package com.example.truyen_huyen_thoai

import android.app.Application

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Facebook SDK initialization is handled by the Flutter plugin
        // (flutter_facebook_auth). Leaving this empty avoids requiring
        // the native Facebook SDK as a compile-time dependency here.
    }
}
