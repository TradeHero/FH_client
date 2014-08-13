/****************************************************************************
 Copyright (c) 2010-2012 cocos2d-x.org

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
package com.myhero.fh;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import com.crashlytics.android.Crashlytics;
import com.myhero.fh.auth.AuthenticationCallback;
import com.myhero.fh.auth.FacebookAuth;
import com.myhero.fh.widget.FHCocos2dxHandler;
import java.util.Arrays;
import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

public class MainActivity extends Cocos2dxActivity {
  private static final String TAG = "FacebookTestActivity";
  private static FacebookAuth facebookAuth;

  static {
    System.loadLibrary("cocos2dlua");
  }

  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Crashlytics.start(this);

    facebookAuth = new FacebookAuth(this, "788386747851675",
        Arrays.asList("public_profile", "user_friends", "email", "user_birthday"));
    facebookAuth.setActivity(this);
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    facebookAuth.onActivityResult(requestCode, resultCode, data);
    super.onActivityResult(requestCode, resultCode, data);
  }

  public Cocos2dxGLSurfaceView onCreateGLSurfaceView() {
    return new LuaGLSurfaceView(this);
  }

  public Cocos2dxGLSurfaceView onCreateView() {
    Cocos2dxGLSurfaceView glSurfaceView = new Cocos2dxGLSurfaceView(this);
    glSurfaceView.setEGLConfigChooser(5, 6, 5, 0, 16, 8);
    return glSurfaceView;
  }

  public static native void loginResult(String accessToken);

  public static void login() {
    facebookAuth.authenticate(new FacebookAuthenticationCallback());
  }

  @Override public void destroyBindingView(final long source) {
    runOnUiThread(new Runnable() {
      @Override public void run() {
        FHCocos2dxHandler.destroyBindingView(source);
      }
    });
  }

  private static class FacebookAuthenticationCallback implements AuthenticationCallback {
    @Override
    public void onStart() {

    }

    @Override
    public void onSuccess(String authenticationToken) {
      Log.d(TAG, "authToken: " + authenticationToken);
      loginResult(authenticationToken);
    }

    @Override
    public void onError(Throwable error) {
      Log.e(TAG, error.getMessage());
    }
  }
}

