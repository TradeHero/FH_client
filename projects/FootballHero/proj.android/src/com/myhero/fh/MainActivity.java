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
import com.mobileapptracker.MobileAppTracker;
import com.mobileapptracker.MobileAppTracker;
import com.google.android.gms.ads.identifier.AdvertisingIdClient;
import com.google.android.gms.ads.identifier.AdvertisingIdClient.Info;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import android.provider.Settings.Secure;
import com.myhero.fh.auth.AuthenticationCallback;
import com.myhero.fh.auth.FacebookAuth;
import com.myhero.fh.widget.FHCocos2dxHandler;

import java.io.IOException;
import java.util.Arrays;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

public class MainActivity extends Cocos2dxActivity {
  private static final String TAG = "FacebookTestActivity";
  private static FacebookAuth facebookAuth;
  public MobileAppTracker mobileAppTracker = null;

  static {
    System.loadLibrary("cocos2dlua");
  }

  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Crashlytics.start(this);

      // Initialize MAT
    MobileAppTracker.init(getApplicationContext(), "19686", "c65b99d5b751944e3637593edd04ce01");
    mobileAppTracker = MobileAppTracker.getInstance();

      // Collect Google Play Advertising ID; REQUIRED for attribution of Android apps distributed via Google Play
      new Thread(new Runnable() {
          @Override public void run() {
              // See sample code at http://developer.android.com/google/play-services/id.html
              try {
                  Info adInfo = AdvertisingIdClient.getAdvertisingIdInfo(getApplicationContext());
                  mobileAppTracker.setGoogleAdvertisingId(adInfo.getId(), adInfo.isLimitAdTrackingEnabled());
              } catch (IOException e) {
                  // Unrecoverable error connecting to Google Play services (e.g.,
                  // the old version of the service doesn't support getting AdvertisingId).
                  mobileAppTracker.setAndroidId(Secure.getString(getContentResolver(), Secure.ANDROID_ID));
              } catch (GooglePlayServicesNotAvailableException e) {
                  // Google Play services is not available entirely.
                  mobileAppTracker.setAndroidId(Secure.getString(getContentResolver(), Secure.ANDROID_ID));
              } catch (GooglePlayServicesRepairableException e) {
                  // Encountered a recoverable error connecting to Google Play services.
                  mobileAppTracker.setAndroidId(Secure.getString(getContentResolver(), Secure.ANDROID_ID));
              } catch (NullPointerException e) {
                  // getId() is sometimes null
                  mobileAppTracker.setAndroidId(Secure.getString(getContentResolver(), Secure.ANDROID_ID));
              }
          }
      }).start();

    // Facebook init
    facebookAuth = new FacebookAuth(this, "788386747851675",
        Arrays.asList("public_profile", "user_friends", "email", "user_birthday"));
    facebookAuth.setActivity(this);
  }

    @Override
    public void onResume() {
        super.onResume();
        // Get source of open for app re-engagement
        mobileAppTracker.setReferralSources(this);
        // MAT will not function unless the measureSession call is included
        mobileAppTracker.measureSession();
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

  public static void login() {
    facebookAuth.authenticate(new FacebookAuthenticationCallback());
  }
  public static void requestPublishPermissions(String newPermission) {
    facebookAuth.requestPublishPermissions(newPermission);
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
      FacebookAuth.accessTokenUpdate(authenticationToken);
    }

    @Override
    public void onError(Throwable error) {
      Log.e(TAG, error.getMessage());
    }
  }
}

