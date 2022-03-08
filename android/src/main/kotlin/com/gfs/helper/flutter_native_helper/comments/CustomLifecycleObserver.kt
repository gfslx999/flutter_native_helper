package com.gfs.helper.flutter_native_helper.comments

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent

interface CustomLifecycleObserver : LifecycleObserver {

    @OnLifecycleEvent(Lifecycle.Event.ON_START)
    fun onStart() {}

    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    fun onResume() {}

    @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
    fun onPause() {}

    @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
    fun onStop() {}

}