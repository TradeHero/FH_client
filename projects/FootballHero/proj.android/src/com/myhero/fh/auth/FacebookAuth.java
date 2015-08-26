package com.myhero.fh.auth;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import android.util.Log;
import android.app.Activity;
import android.content.Intent;

import com.facebook.*;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.share.model.AppInviteContent;
import com.facebook.share.widget.AppInviteDialog;
import com.facebook.share.widget.ShareDialog;
import com.facebook.share.widget.GameRequestDialog;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Locale;
import java.util.SimpleTimeZone;

public class FacebookAuth implements Auth {
  public static final DateFormat PRECISE_DATE_FORMAT =
      new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.getDefault());
  private static final String TAG = FacebookAuth.class.getSimpleName();

  private final String applicationId;
  private int activityCode;
  private Collection<String> permissions;
  private AuthenticationCallback currentOperationCallback;
  private String userId;

   private static FacebookAuth sInstance;
  private static int sCallIndex;
  private CallbackManager mCallbackManager;
  private Activity mActivity;
  private String mStrPicPath;
  private ShareDialog mShareDialog;
  private GameRequestDialog mRequestDialog;

  public FacebookAuth(Activity activity, String applicationId, Collection<String> permissions) {
    PRECISE_DATE_FORMAT.setTimeZone(new SimpleTimeZone(0, "GMT"));

    this.activityCode = 32665;
    this.mActivity = activity;
    this.permissions = permissions;

    this.applicationId = applicationId;

    sInstance = this;

    FacebookSdk.sdkInitialize(activity.getApplicationContext());

    mCallbackManager = CallbackManager.Factory.create();
    LoginManager.getInstance().registerCallback(mCallbackManager, new FacebookCallback<LoginResult>() {

      @Override
      public void onSuccess(LoginResult result) {
        runNativeCallback(sCallIndex, "");
    //    handlePendingAction();
      }

      @Override
      public void onCancel() {
        runNativeCallback(sCallIndex, "");
      }

      @Override
      public void onError(FacebookException error) {
        runNativeCallback(sCallIndex, "");
      }
    });

    mShareDialog = new ShareDialog(activity);

    mRequestDialog = new GameRequestDialog(activity);
    mRequestDialog.registerCallback(mCallbackManager, new FacebookCallback<GameRequestDialog.Result>() {
      public void onSuccess(GameRequestDialog.Result result) {
      //     Log.i(TAG, "Game Request Result: " + result.toString());
      }

      public void onCancel() {}

      public void onError(FacebookException error) {}
    });
  }

  public static native void nativeCallback(int cbIndex, String params);

  public static void runNativeCallback(final int cbIndex, final String params) {
    Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
      @Override public void run() {
        nativeCallback(cbIndex, params);
      }
    });
  }

//  public synchronized void extendAccessToken(Context context, AuthenticationCallback callback) {
//    this.currentOperationCallback = callback;
//    boolean result = this.facebook.extendAccessToken(context, new Facebook.ServiceListener() {
//      @Override public void onComplete(Bundle values) {
//        createAndExecuteMeRequest(session);
//      }
//
//      @Override public void onFacebookError(FacebookError e) {
//        FacebookAuth.this.handleError(e);
//      }
//
//      @Override public void onError(Error e) {
//        FacebookAuth.this.handleError(e);
//      }
//    });
//  }

  @Override public synchronized void authenticate(AuthenticationCallback callback) {
    this.currentOperationCallback = callback;
    final Activity activity = mActivity;
    if (activity == null) {
      throw new IllegalStateException(
          "Activity must be non-null for Facebook authentication to proceed.");
    }
//    int activityCode = this.activityCode;
//    this.session = new Session.Builder(activity).setApplicationId(this.applicationId)
//        .setTokenCachingStrategy(new SharedPreferencesTokenCachingStrategy(activity))
//        .build();
//
//    callback.onStart();
//    Session.OpenRequest openRequest = new Session.OpenRequest(activity);
//    openRequest.setRequestCode(activityCode);
//    if (this.defaultAudience != null) {
//      openRequest.setDefaultAudience(this.defaultAudience);
//    }
//    if (this.permissions != null) {
//      openRequest.setPermissions(new ArrayList<String>(this.permissions));
//    }
//    openRequest.setCallback(new Session.StatusCallback() {
//      @Override
//      public void call(Session session, SessionState state, Exception exception) {
//        if (state == SessionState.OPENING) {
//          return;
//        }
//        if (state == SessionState.CLOSED_LOGIN_FAILED || state == SessionState.CLOSED) {
//            FacebookAuth.this.currentOperationCallback.onSuccess(null);
//            return;
//        }
//        if (state.isOpened()) {
//          if (FacebookAuth.this.currentOperationCallback == null) {
//            return;
//          }
//          if (facebook.isSessionValid()) {
//            extendAccessToken(activity, currentOperationCallback);
//            return;
//          }
//          createAndExecuteMeRequest(session);
//        } else if (exception != null) {
//          FacebookAuth.this.handleError(exception);
//        } else {
//          // nothing for now
//        }
//      }
//    });
//    this.session.openForRead(openRequest);
  }

//  private void createAndExecuteMeRequest(Session session) {
//    Request meRequest = Request.newGraphPathRequest(session, "me", new Request.Callback() {
//      @Override
//      public void onCompleted(Response response) {
//        if (response.getError() != null) {
//          if (response.getError().getException() != null) {
//            FacebookAuth.this.handleError(response.getError().getException());
//          } else {
//            FacebookAuth.this.handleError(
//                new Exception("An error occurred while fetching the Facebook user's identity."));
//          }
//        } else {
//          FacebookAuth.this.handleSuccess((String) response.getGraphObject().getProperty("id"));
//        }
//      }
//    });
//    meRequest.getParameters().putString("fields", "id");
//    meRequest.executeAsync();
//  }

  public void onActivityResult(int requestCode, int resultCode, Intent data) {
    Activity activity = mActivity;
//    if (activity != null && session != null) {
//      this.session.onActivityResult(activity, requestCode, resultCode, data);
//    }
  }

  public int getActivityCode() {
    return this.activityCode;
  }

  @Override public String getAccessToken() {
    return "";
  }
//    return this.session.getAccessToken();
//  }

//  public Facebook getFacebook() {
//    return this.facebook;
//  }
//
//  public Session getSession() {
//    return this.session;
//  }

  private void handleError(Throwable error) {
    if (this.currentOperationCallback == null) {
      return;
    }
    try {
      this.currentOperationCallback.onError(error);
    } finally {
      this.currentOperationCallback = null;
    }
  }

  private void handleSuccess(String userId) {
    if (this.currentOperationCallback == null) {
      return;
    }

    try {
      //this.currentOperationCallback.onSuccess(this.session.getAccessToken());
    } finally {
      this.currentOperationCallback = null;
    }
  }

  public synchronized void setActivity(Activity activity) {
    this.mActivity = activity;
  }

  public synchronized void setActivityCode(int activityCode) {
    this.activityCode = activityCode;
  }

  public synchronized void setPermissions(Collection<String> permissions) {
    this.permissions = permissions;
  }

  public String getUserId() {
    return this.userId;
  }

  public void requestPublishPermissions(final String newPermission) {
    Activity activity = mActivity;
//    if (activity != null && session != null) {
//      // already has this permission
//      if (session.getPermissions().contains(newPermission)) {
//        FacebookAuth.permissionUpdate("", true);
//        Log.d(TAG, "Already has requesting permission");
//        return;
//      }
//      // request for permissions
//      session.addCallback(new Session.StatusCallback() {
//        @Override public void call(Session session, SessionState state, Exception exception) {
//          boolean granted = session.getPermissions().contains(newPermission);
//          FacebookAuth.permissionUpdate(session.getAccessToken(), granted);
//          Log.d(TAG, String.format("Granted?: %b", granted));
//        }
//      });
//      session.requestNewPublishPermissions(new Session.NewPermissionsRequest(activity, newPermission));
//    } else {
//      // unexpected
//      Log.d(TAG, String.format("Unexpected: activity=%s, session=%s", activity, session));
//      FacebookAuth.permissionUpdate("", false);
//    }
  }

  public void inviteFriend(final String appLinkUrl) {
    sCallIndex = 0;
    sInstance.mActivity.runOnUiThread(new Runnable() {
      @Override
      public void run() {
        if (AppInviteDialog.canShow()) {
          AppInviteContent content = new AppInviteContent.Builder()
                  .setApplinkUrl(appLinkUrl)
                  .build();
          AppInviteDialog.show(sInstance.mActivity, content);
        }
      }
    });
  }

  // Native callback for Cocos2D
  public static native void accessTokenUpdate(String accessToken);
  public static native void permissionUpdate(String accessToken, boolean granted);
}
