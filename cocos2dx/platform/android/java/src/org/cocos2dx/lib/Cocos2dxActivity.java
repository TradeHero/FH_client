/****************************************************************************
 Copyright (c) 2010-2013 cocos2d-x.org

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
package org.cocos2dx.lib;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.MotionEvent;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import com.myhero.fh.util.MiscUtil;
import com.myhero.fh.widget.FHCocos2dxHandler;
import org.cocos2dx.lib.Cocos2dxHelper.Cocos2dxHelperListener;

public abstract class Cocos2dxActivity extends FragmentActivity implements Cocos2dxHelperListener {
  // ===========================================================
  // Constants
  // ===========================================================

  private static final String TAG = Cocos2dxActivity.class.getSimpleName();

  // ===========================================================
  // Fields
  // ===========================================================

  private Cocos2dxGLSurfaceView mGLSurfaceView;
  private Handler mHandler;
  private String m_deepLink = null;
  private static Context sContext = null;

  public static Context getContext() {
    return sContext;
  }

  public String getDeepLink() { return m_deepLink; }

  // ===========================================================
  // Constructors
  // ===========================================================

  @Override
  protected void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    sContext = this;

    // TODO use FHCocos2dxHandler. Dependency injection can be helpful here.
    this.mHandler = new FHCocos2dxHandler(this);

    this.init();

    Cocos2dxHelper.init(this, this);

    Intent intent = getIntent();
    String action = intent.getAction();
    Uri data = intent.getData();

    Log.v("###", "Get intent with action: " + action);
    if (data != null)
    {
      Log.v("###", "Get intent with data: " + data.toString());
      m_deepLink = data.getPath();
      MiscUtil.notifyDeepLink(m_deepLink);
    }
  }

  @Override public boolean dispatchTouchEvent(MotionEvent event) {
    if (event.getAction() == MotionEvent.ACTION_DOWN) {
      FHCocos2dxHandler.unfocusIfNecessary(getCurrentFocus(), event);
    }
    return super.dispatchTouchEvent(event);
  }

  // ===========================================================
  // Getter & Setter
  // ===========================================================

  // ===========================================================
  // Methods for/from SuperClass/Interfaces
  // ===========================================================

  @Override
  protected void onResume() {
    super.onResume();

    Cocos2dxHelper.onResume();
    this.mGLSurfaceView.onResume();
  }

  @Override
  protected void onPause() {
    super.onPause();

    Cocos2dxHelper.onPause();
    this.mGLSurfaceView.onPause();
  }

  @Override
  public void showDialog(final String pTitle, final String pMessage) {
    Message msg = new Message();
    msg.what = Cocos2dxHandler.HANDLER_SHOW_DIALOG;
    msg.obj = new Cocos2dxHandler.DialogMessage(pTitle, pMessage);
    this.mHandler.sendMessage(msg);
  }

  @Override
  public void showEditTextDialog(final long source, final String pTitle, final String pContent,
      final int pInputMode,
      final int pInputFlag, final int pReturnType, final int pMaxLength, float x, float y,
      float width, float height, int color) {
    Message msg = new Message();
    msg.what = Cocos2dxHandler.HANDLER_SHOW_EDITBOX_DIALOG;
    msg.obj =
        new Cocos2dxHandler.EditBoxMessage(source, pTitle, pContent, pInputMode, pInputFlag,
            pReturnType, pMaxLength, x, y, width, height, color);
    this.mHandler.sendMessage(msg);
  }

  @Override
  public void runOnGLThread(final Runnable pRunnable) {
    this.mGLSurfaceView.queueEvent(pRunnable);
  }

  // ===========================================================
  // Methods
  // ===========================================================
  public void init() {

    // FrameLayout
    ViewGroup.LayoutParams framelayout_params =
        new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT);
    FrameLayout framelayout = new FrameLayout(this);
    framelayout.setLayoutParams(framelayout_params);

    // Cocos2dxEditText layout
    ViewGroup.LayoutParams edittext_layout_params =
        new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT);
    Cocos2dxEditText edittext = new Cocos2dxEditText(this);
    edittext.setLayoutParams(edittext_layout_params);

    // ...add to FrameLayout
    framelayout.addView(edittext);

    // Cocos2dxGLSurfaceView
    this.mGLSurfaceView = this.onCreateView();

    // ...add to FrameLayout
    framelayout.addView(this.mGLSurfaceView);

    // Switch to supported OpenGL (ARGB888) mode on emulator
    if (isAndroidEmulator()) this.mGLSurfaceView.setEGLConfigChooser(8, 8, 8, 8, 16, 0);

    this.mGLSurfaceView.setCocos2dxRenderer(new Cocos2dxRenderer());
    this.mGLSurfaceView.setCocos2dxEditText(edittext);

    // Set framelayout as the content view
    setContentView(framelayout);
  }

  public Cocos2dxGLSurfaceView onCreateView() {
    return new Cocos2dxGLSurfaceView(this);
  }

  private final static boolean isAndroidEmulator() {
    String model = Build.MODEL;
    Log.d(TAG, "model=" + model);
    String product = Build.PRODUCT;
    Log.d(TAG, "product=" + product);
    boolean isEmulator = false;
    if (product != null) {
      isEmulator = product.equals("sdk")
          || product.contains("_sdk")
          || product.contains("sdk_")
          || product.contains("vbox");
    }
    Log.d(TAG, "isEmulator=" + isEmulator);
    return isEmulator;
  }

  public static void sendMail(Intent intent) throws ActivityNotFoundException {
    Cocos2dxActivity activity = ((Cocos2dxActivity) sContext);
    activity.startActivityForResult(intent, MiscUtil.REQUEST_CODE_SEND_EMAIL);
    activity.setResult(RESULT_OK);
  }

  public static void sendSms(Intent intent) throws ActivityNotFoundException {
    Cocos2dxActivity activity = ((Cocos2dxActivity) sContext);
    activity.startActivityForResult(intent, MiscUtil.REQUEST_CODE_SEND_SMS);
    activity.setResult(RESULT_OK);
  }

    public static void openUrl(Intent intent) throws ActivityNotFoundException {
        Cocos2dxActivity activity = ((Cocos2dxActivity) sContext);
        activity.startActivity(intent);
    }

    public static void selectImage(Intent intent) throws  ActivityNotFoundException {
        Cocos2dxActivity activity = (Cocos2dxActivity) sContext;
        activity.startActivityForResult(intent, MiscUtil.REQUEST_CODE_SELECT_IMAGE);
    }

  @Override protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    super.onActivityResult(requestCode, resultCode, data);

    MiscUtil.onActivityResult(requestCode, resultCode, data);
  }

  // ===========================================================
  // Inner and Anonymous Classes
  // ===========================================================
}
