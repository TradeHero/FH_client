package com.myhero.fh.auth;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import com.facebook.*;
import com.facebook.android.Facebook;
import com.facebook.android.FacebookError;

import java.lang.ref.WeakReference;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Locale;
import java.util.SimpleTimeZone;

public class FacebookAuth implements Auth {
  public static final DateFormat PRECISE_DATE_FORMAT =
      new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.getDefault());

  private Facebook facebook;
  private Session session;
  private SessionDefaultAudience defaultAudience;
  private final String applicationId;
  private int activityCode;
  private WeakReference<Activity> baseActivity;
  private Context applicationContext;
  private Collection<String> permissions;
  private AuthenticationCallback currentOperationCallback;
  private String userId;

  public FacebookAuth(Context context, String applicationId, Collection<String> permissions) {
    PRECISE_DATE_FORMAT.setTimeZone(new SimpleTimeZone(0, "GMT"));

    this.activityCode = 32665;
    this.baseActivity = new WeakReference<Activity>(null);
    this.permissions = permissions;

    this.applicationId = applicationId;
    if (context != null) {
      this.applicationContext = context.getApplicationContext();
    }

    if (applicationId != null) {
      this.facebook = new Facebook(applicationId);
    }
  }

  public synchronized void extendAccessToken(Context context, AuthenticationCallback callback) {
    this.currentOperationCallback = callback;
    boolean result = this.facebook.extendAccessToken(context, new Facebook.ServiceListener() {
      @Override public void onComplete(Bundle values) {
        createAndExecuteMeRequest(session);
      }

      @Override public void onFacebookError(FacebookError e) {
        FacebookAuth.this.handleError(e);
      }

      @Override public void onError(Error e) {
        FacebookAuth.this.handleError(e);
      }
    });
  }

  @Override public synchronized void authenticate(AuthenticationCallback callback) {
    this.currentOperationCallback = callback;
    final Activity activity = this.baseActivity == null ? null : this.baseActivity.get();
    if (activity == null) {
      throw new IllegalStateException(
          "Activity must be non-null for Facebook authentication to proceed.");
    }
    int activityCode = this.activityCode;
    this.session = new Session.Builder(activity).setApplicationId(this.applicationId)
        .setTokenCachingStrategy(new SharedPreferencesTokenCachingStrategy(activity))
        .build();

    callback.onStart();
    Session.OpenRequest openRequest = new Session.OpenRequest(activity);
    openRequest.setRequestCode(activityCode);
    if (this.defaultAudience != null) {
      openRequest.setDefaultAudience(this.defaultAudience);
    }
    if (this.permissions != null) {
      openRequest.setPermissions(new ArrayList<String>(this.permissions));
    }
    openRequest.setCallback(new Session.StatusCallback() {
      @Override
      public void call(Session session, SessionState state, Exception exception) {
        if (state == SessionState.OPENING) {
          return;
        }
        if (state.isOpened()) {
          if (FacebookAuth.this.currentOperationCallback == null) {
            return;
          }
          if (facebook.isSessionValid()) {
            extendAccessToken(activity, currentOperationCallback);
            return;
          }
          createAndExecuteMeRequest(session);
        } else if (exception != null) {
          FacebookAuth.this.handleError(exception);
        } else {
          // nothing for now
        }
      }
    });
    this.session.openForRead(openRequest);
  }

  private void createAndExecuteMeRequest(Session session) {
    Request meRequest = Request.newGraphPathRequest(session, "me", new Request.Callback() {
      @Override
      public void onCompleted(Response response) {
        if (response.getError() != null) {
          if (response.getError().getException() != null) {
            FacebookAuth.this.handleError(response.getError().getException());
          } else {
            FacebookAuth.this.handleError(
                new Exception("An error occurred while fetching the Facebook user's identity."));
          }
        } else {
          FacebookAuth.this.handleSuccess((String) response.getGraphObject().getProperty("id"));
        }
      }
    });
    meRequest.getParameters().putString("fields", "id");
    meRequest.executeAsync();
  }

  public void onActivityResult(int requestCode, int resultCode, Intent data) {
    Activity activity = this.baseActivity.get();
    if (activity != null && session != null) {
      this.session.onActivityResult(activity, requestCode, resultCode, data);
    }
  }

  public int getActivityCode() {
    return this.activityCode;
  }

  @Override public String getAccessToken() {
    return this.session.getAccessToken();
  }

  public Facebook getFacebook() {
    return this.facebook;
  }

  public Session getSession() {
    return this.session;
  }

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
      this.currentOperationCallback.onSuccess(this.session.getAccessToken());
    } finally {
      this.currentOperationCallback = null;
    }
  }

  public synchronized void setActivity(Activity activity) {
    this.baseActivity = new WeakReference<Activity>(activity);
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
}
