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

import android.content.*;
import android.graphics.PointF;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.content.LocalBroadcastManager;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.widget.ProgressBar;
import cn.sharesdk.ShareSDKUtils;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.myhero.fh.metrics.events.ParamStringEvent;

import com.crashlytics.android.Crashlytics;
import com.mobileapptracker.MobileAppTracker;
import com.google.android.gms.ads.identifier.AdvertisingIdClient;
import com.google.android.gms.ads.identifier.AdvertisingIdClient.Info;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import android.provider.Settings.Secure;
import com.myhero.fh.auth.AuthenticationCallback;
import com.myhero.fh.auth.FacebookAuth;
import com.myhero.fh.util.QuickBloxChat;
import com.myhero.fh.widget.FHCocos2dxHandler;

import java.io.IOException;
import java.util.*;

import com.tongdao.sdk.enums.TdGender;
import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import android.app.Activity;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;

import com.localytics.android.LocalyticsAmpSession;
import com.localytics.android.LocalyticsActivityLifecycleCallbacks;

import com.appsflyer.AppsFlyerLib;
import com.flurry.android.FlurryAgent;
import org.json.*;
import org.json.JSONException;

import com.tongdao.sdk.TongDao;



public class MainActivity extends Cocos2dxActivity {
  private static FacebookAuth facebookAuth;
  public MobileAppTracker mobileAppTracker = null;

  private static Activity actInstance;
  private LinearLayout m_webLayout;
  private WebView m_webView;
  private ClipboardManager m_clipboard;

  private LocalyticsAmpSession localyticsSession;

  private static GooglePlayIABPlugin mGooglePlayIABPlugin;
    private BroadcastReceiver mRegistrationBroadcastReceiver;

    private boolean isReceiverRegistered;



  static {
    System.loadLibrary("cocos2dlua");
  }

  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Crashlytics.start(this);

    // Gets a handler to the clipboard
    m_clipboard = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);

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

    // @@ADD Vincent: Webview
    actInstance = this;
    m_webLayout = new LinearLayout(this);
    this.addContentView(m_webLayout, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));

    // Instantiate the object
    this.localyticsSession = new LocalyticsAmpSession(
              getApplicationContext() );  // Context used to access device resources


    // Register LocalyticsActivityLifecycleCallbacks
    getApplication().registerActivityLifecycleCallbacks(
              new LocalyticsActivityLifecycleCallbacks(this.localyticsSession));
    this.localyticsSession.setLoggingEnabled(true);

    AppsFlyerLib.setAppsFlyerKey("pEuxjZE2GpyRXXwFjHHRRU");
    AppsFlyerLib.sendTracking(getApplicationContext());

    QuickBloxChat.init(this);

    ShareSDKUtils.prepare();

    // configure Flurry
    FlurryAgent.setLogEnabled(false);

    // init Flurry
    FlurryAgent.init(this, "DXBRPTBZ6P8B4YGK98ZW");

      //init Tongdao
      TongDao.init(this, Constants.TONGDAO_APP_KEY);

    // 初始化iab
      mGooglePlayIABPlugin = new GooglePlayIABPlugin(this);
      mGooglePlayIABPlugin.onCreate(savedInstanceState);

      mRegistrationBroadcastReceiver = new BroadcastReceiver() {
          @Override
          public void onReceive(Context context, Intent intent) {
              SharedPreferences sharedPreferences =
                      PreferenceManager.getDefaultSharedPreferences(context);
              boolean sentToken = sharedPreferences
                      .getBoolean(QuickstartPreferences.SENT_TOKEN_TO_SERVER, false);
              if (sentToken) {
                  Log.v("GCM", "GCM sent");
              } else {
                  Log.v("GCM", "GCM not sent");
              }
          }
      };
      registerReceiver();

      if (checkPlayServices()) {
          // Start IntentService to register this application with GCM.
          Intent intent = new Intent(this, RegistrationIntentService.class);
          startService(intent);
      }
  }

    private void registerReceiver(){
        if(!isReceiverRegistered) {
            LocalBroadcastManager.getInstance(this).registerReceiver(mRegistrationBroadcastReceiver,
                    new IntentFilter(QuickstartPreferences.REGISTRATION_COMPLETE));
            isReceiverRegistered = true;
        }
    }

    private boolean checkPlayServices() {
        GoogleApiAvailability apiAvailability = GoogleApiAvailability.getInstance();
        int resultCode = apiAvailability.isGooglePlayServicesAvailable(this);
        if (resultCode != ConnectionResult.SUCCESS) {
            if (apiAvailability.isUserResolvableError(resultCode)) {
                apiAvailability.getErrorDialog(this, resultCode, 9000)
                        .show();
            } else {
                Log.i("CheckPlayService", "This device is not supported.");
                finish();
            }
            return false;
        }
        return true;
    }
    @Override
    protected void onNewIntent(Intent intent)
    {
        super.onNewIntent(intent);
        setIntent(intent);
    }

    @Override
    public void onResume() {
        super.onResume();
        // Get source of open for app re-engagement
        mobileAppTracker.setReferralSources(this);
        // MAT will not function unless the measureSession call is included
        mobileAppTracker.measureSession();
        registerReceiver();

        Log.v("###", "onResume");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mGooglePlayIABPlugin.onDestroy();
        Log.v("###", "onDestroy");
    }

    @Override
    public void onRestart() {
        Log.v("###", "onRestart");
        super.onRestart();

        ShareSDKUtils.appResume();
    }

    @Override
    public void onPause() {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(mRegistrationBroadcastReceiver);
        isReceiverRegistered = false;
        Log.v("###", "onPause");
        super.onPause();
    }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    facebookAuth.onActivityResult(requestCode, resultCode, data);
    if (mGooglePlayIABPlugin != null && mGooglePlayIABPlugin.handleActivityResult(requestCode, resultCode, data)) {
        Log.d(GooglePlayIABPlugin.TAG, "onActivityResult handled by GooglePlayIABPlugin (" + requestCode + "," + resultCode + "," + data);
    }
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
  public static void inviteFriend(String appLinkUrl) {
    facebookAuth.inviteFriend(appLinkUrl);
  }
  public static void shareTimeline(String title, String description, String appLinkUrl) {
    facebookAuth.shareTimeline(title, description, appLinkUrl);
  }

    public static void buy(String id){
        mGooglePlayIABPlugin.PayStart(id, null);
    }

    public static void requestProducts(String jStr){
        Log.d("IAB", "req products:" +  jStr);
        try {
            JSONArray array = new JSONArray(jStr);
            String ids = "";
            for (int i = 0; i < array.length(); i++) {
                ids += array.getString(i) + " ";
            }
            mGooglePlayIABPlugin.ReqItemInfo(ids);
        }
        catch (JSONException exception)
        {
            exception.printStackTrace();
        }
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
      Log.d(this.getClass().getName(), "authToken: " + authenticationToken);
      FacebookAuth.accessTokenUpdate(authenticationToken);
    }

    @Override
    public void onError(Throwable error) {
      Log.e(this.getClass().getName(), error.getMessage());
    }
  }

    public static Object getJavaActivity() {
        return actInstance;
    }
  
    public void openWebPage(final String url, final int x, final int y, final int width, final int height) {

        this.runOnUiThread(new Runnable() {
            public void run() {
              m_webView = new WebView(actInstance);
              m_webLayout.addView(m_webView);

              DisplayMetrics metrics = new DisplayMetrics();
              getWindowManager().getDefaultDisplay().getMetrics(metrics);

              PointF ratio = new PointF();
              ratio.x = (float)metrics.heightPixels / 1136;
              ratio.y = (float)metrics.widthPixels / 640;
              Log.d(this.getClass().getName(), "height = " + metrics.heightPixels + " width = " + metrics.widthPixels +
                      " ratio = (" + ratio.x + ", " + ratio.y + ")");

              LinearLayout.LayoutParams linearParams = (LinearLayout.LayoutParams) m_webView.getLayoutParams();
              linearParams.leftMargin = (int) (x * ratio.x);
              linearParams.topMargin = (int) (y * ratio.y);
              linearParams.width = (int) (width * ratio.x);
              linearParams.height = (int) (height * ratio.y);
              m_webView.setLayoutParams(linearParams);

              m_webView.setBackgroundColor(0);
              m_webView.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
              m_webView.getSettings().setAppCacheEnabled(false);
              m_webView.setOverScrollMode(View.OVER_SCROLL_NEVER);
              m_webView.setWebViewClient(new WebViewClient(){
                @Override
                public boolean shouldOverrideUrlLoading(WebView view, String url){
                  return false;
                }
              });
              m_webView.getSettings().setJavaScriptEnabled(true);

              m_webView.loadUrl(url);
            }
        });
    }
    
    public void closeWebPage() {
        this.runOnUiThread(new Runnable() {
            public void run() {
                if (m_webView != null) {
                    m_webLayout.removeView(m_webView);
                    m_webView.destroy();
                }
            }
        });
    }

    private static HashMap<String, Object> parseJson2HashMap(String paramString){
        HashMap<String, Object> paramMap = new HashMap<>();
        if (paramString != null) {
            try {
                JSONObject paramObject = new JSONObject(paramString);

                Iterator<String> iterator = paramObject.keys();
                String key = null;
                String value = null;
                while (iterator.hasNext()) {
                    key = iterator.next();
                    value = paramObject.getString(key);
                    paramMap.put(key, value);
                }
            } catch (JSONException exception) {
                exception.printStackTrace();
            }
        }
        return paramMap;
    }

    private static Map<String, String> parseJson2Map(String paramString) {
        Map<String, String> paramMap = new HashMap<>();
        if (paramString != null) {
            try {
                JSONObject paramObject = new JSONObject(paramString);

                Iterator<String> iterator = paramObject.keys();
                String key = null;
                String value = null;
                while (iterator.hasNext()) {
                    key = iterator.next();
                    value = paramObject.getString(key);
                    paramMap.put(key, value);
                }
            } catch (JSONException exception) {
                exception.printStackTrace();
            }
        }
        return paramMap;
    }

        //@@ADD Vincent: copy to paste board function for Android
    public void copyToPasteBoard(String content)
    {
        // Vincent: does not work here.. libc crashes
        //ClipboardManager clipboard = (android.content.ClipboardManager) this.getSystemService(Context.CLIPBOARD_SERVICE);
        ClipData clip = ClipData.newPlainText("copied content", content);
        m_clipboard.setPrimaryClip(clip);
    }

    public void tagLocalyticsEvent(String eventName, String paramString) {
        ParamStringEvent event = new ParamStringEvent(eventName, paramString);
        localyticsSession.tagEvent( eventName, event.getAttributes() );
    }

    //log flurry event
    public static void logFlurryEvent(String eventName, String paramString){
         FlurryAgent.logEvent( eventName,  parseJson2Map(paramString) );
    }

    //log tongdao event
    public static void logTongdaoEvent(String eventName, String paramString){
        if (paramString == null || paramString.isEmpty()){
            Log.d("Tongdao", "Event:"+ eventName);
            TongDao.track(eventName);
        } else {
            Log.d("Tongdao", "Event:"+ eventName +" Params:" + paramString);
            TongDao.track(eventName, parseJson2HashMap(paramString));
        }
    }

    //tongdao login
    public static void loginTongdao(String userId){
        Log.d("Tongdao", "Lgoin:"+ userId);
        TongDao.setUserId((Activity)getJavaActivity(), userId);
    }

    //tongdao logout
    public static void logoutTongdao(){
        Log.d("Tongdao", "Logout");
        TongDao.setUserId((Activity)getJavaActivity(), null);
    }

    //log tongdao event
    public static void trackTongdaoAttr(String attrName, String value){
        Log.d("Tongdao", "Attr Name:"+ attrName + " Value:" + value);
        if (attrName.equals("UserName")){
            TongDao.identifyUserName(value);
        } else if (attrName.equals("Email")){
            TongDao.identifyEmail(value);
        } else if (attrName.equals("Phone")){
            TongDao.identifyPhone(value);
        } else if (attrName.equals("Gender")){
            TongDao.identifyGender(TdGender.valueOf(value));
        } else if (attrName.equals("Avatar")){
            TongDao.identifyAvatar(value);
        } else if (attrName.equals("identifyFullName")) {
            TongDao.identifyFullName(value);
        } else {
            TongDao.identify(attrName, value);
        }
    }

    //track tongdao attributes
    public static void trackTongdaoAttrs(String paramString){
        Log.d("Tongdao", "Attr Name:"+ paramString);
        TongDao.identify(parseJson2HashMap(paramString));
    }

    //track tongdao Order
    public static void trackTongdaoOrder(String orderName, float price, String currencyCode){
        Log.d("Tongdao", "Order Name:"+ orderName + " Price:" + price + " Currency:" + currencyCode);
        Currency currency = Currency.getInstance(currencyCode);
        TongDao.trackPlaceOrder(orderName, price, currency);
    }

    //track tongdao Session Start
    public static void trackTongdaoSessionStart(String pageName){
        TongDao.onSessionStart(pageName);
    }

    //track tongdao Session End
    public static void trackTongdaoSessionEnd(String pageName){
        TongDao.onSessionEnd(pageName);
    }


    //track tongdao Registration
    public static void trackTongdaoRegistration(){
        Log.d("Tongdao", "trackTongdaoRegistration");
        TongDao.trackRegistration();
    }
}

