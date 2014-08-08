package com.myhero.fh;

import android.content.Context;
import android.view.KeyEvent;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

class LuaGLSurfaceView extends Cocos2dxGLSurfaceView {

  public LuaGLSurfaceView(Context context) {
    super(context);
  }

  public boolean onKeyDown(int keyCode, KeyEvent event) {
    // exit program when key back is entered
    if (keyCode == KeyEvent.KEYCODE_BACK) {
      android.os.Process.killProcess(android.os.Process.myPid());
    }
    return super.onKeyDown(keyCode, event);
  }
}
