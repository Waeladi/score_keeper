package com.waelapps.score_keeper

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.util.Log

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d(TAG, "onCreate ENTERED")
        super.onCreate(savedInstanceState)
        
        val smallestScreenWidthDp = resources.configuration.smallestScreenWidthDp
        Log.d(TAG, "Smallest Screen Width (dp): $smallestScreenWidthDp")
        
        if (smallestScreenWidthDp < 600) {
            Log.d(TAG, "Device detected as phone, locking to portrait.")
            requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        } else {
            Log.d(TAG, "Device detected as tablet, allowing rotation.")
        }
    }
} 