package com.myhero.fh.auth;
import com.facebook.share.model.ShareLinkContent;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import android.util.Log;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

import com.facebook.*;
import com.facebook.share.model.AppInviteContent;
import com.facebook.share.widget.AppInviteDialog;
import com.facebook.share.widget.ShareDialog;
import com.facebook.share.Sharer;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Locale;
import java.util.SimpleTimeZone;

public class FacebookAuth implements Auth {
    public static final DateFormat PRECISE_DATE_FORMAT =
            new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.getDefault());

    private static final String TAG = FacebookAuth.class.getSimpleName();
    private static final int CB_INVITE_FRIENDS = 1;
    private static final int CB_SHARE_TIMELINE = 2;


    private static FacebookAuth sInstance;
    private Activity mActivity;
    private CallbackManager mCallbackManager;


    public FacebookAuth(Activity activity, String applicationId, Collection<String> permissions) {
        PRECISE_DATE_FORMAT.setTimeZone(new SimpleTimeZone(0, "GMT"));

        this.mActivity = activity;
        sInstance = this;
        mCallbackManager = CallbackManager.Factory.create();

//        this.activityCode = 32665;
//        this.permissions = permissions;
//        this.applicationId = applicationId;

        FacebookSdk.sdkInitialize(activity.getApplicationContext());
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        mCallbackManager.onActivityResult(requestCode, resultCode, data);
    }


    @Override
    public synchronized void authenticate(AuthenticationCallback callback) {
        final Activity activity = mActivity;
        if (activity == null) {
            throw new IllegalStateException(
                    "Activity must be non-null for Facebook authentication to proceed.");
        }
    }

    @Override
    public String getAccessToken() {
        return "";
    }

    public synchronized void setActivity(Activity activity) {
        this.mActivity = activity;
    }

    public void requestPublishPermissions(final String newPermission) {
    }

    public void inviteFriend(final String appLinkUrl) {
        sInstance.mActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AppInviteDialog dialog = new AppInviteDialog(mActivity);
                dialog.registerCallback(mCallbackManager, new FacebookCallback<AppInviteDialog.Result>() {
                    @Override
                    public void onSuccess(AppInviteDialog.Result result) {
                        runNativeCallback(CB_INVITE_FRIENDS, true);
                    }

                    @Override
                    public void onCancel() {
                        runNativeCallback(CB_INVITE_FRIENDS, false);
                    }

                    @Override
                    public void onError(FacebookException error) {
                        runNativeCallback(CB_INVITE_FRIENDS, false);
                        Log.i(TAG, "MyHeroShare AppInviteDialog Error: " + error.toString() );
                    }
                });
                if (dialog.canShow()) {
                    AppInviteContent content = new AppInviteContent.Builder()
                            .setApplinkUrl(appLinkUrl)
                            .build();
                    dialog.show(sInstance.mActivity, content);
                }
            }
        });
    }

    public void shareTimeline(final String title, final String description, final String appLinkUrl){
         sInstance.mActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                ShareDialog mShareDialog = new ShareDialog(mActivity);
                mShareDialog.registerCallback(mCallbackManager, new FacebookCallback<Sharer.Result>() {
                    @Override
                    public void onSuccess(Sharer.Result result) {
                        runNativeCallback(CB_SHARE_TIMELINE, true);
                    }

                    @Override
                    public void onCancel() {
                        runNativeCallback(CB_SHARE_TIMELINE, false);
                    }

                    @Override
                    public void onError(FacebookException error) {
                        runNativeCallback(CB_SHARE_TIMELINE, false);
                        Log.i(TAG, "MyHeroShare ShareDialog Error: " + error.toString() );
                    }
                });
                if (ShareDialog.canShow(ShareLinkContent.class)) {
                    ShareLinkContent linkContent = new ShareLinkContent.Builder()
                            .setContentTitle(title)
                            .setContentDescription(description)
                            .setContentUrl(Uri.parse(appLinkUrl))
                            .build();
                    mShareDialog.show(linkContent);
                }
            }
        });
    }

    public static void runNativeCallback(final int cbIndex, final boolean succeed) {
        Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
            @Override public void run() {
                switch (cbIndex){
                    case CB_INVITE_FRIENDS:
                        inviteFriendCallback(succeed);
                        return;
                    case CB_SHARE_TIMELINE:
                        shareTimelineCallback(succeed);
                        return;
                    default:
                        return;
                }
            }
        });
    }

    // Native callback for Cocos2D
    public static native void accessTokenUpdate(String accessToken);
    public static native void permissionUpdate(String accessToken, boolean granted);
    public static native void inviteFriendCallback(boolean succeed);
    public static native void shareTimelineCallback(boolean succeed);
}
