package com.myhero.fh.widget;

public interface NativeAdapter<T extends NativeData> {
  void processNativeData(T nativeData);
}
