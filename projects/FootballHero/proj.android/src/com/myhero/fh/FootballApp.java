package com.myhero.fh;

import android.app.Application;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.util.Base64;
import android.util.Log;
import com.myhero.fh.metrics.Analytics;
import java.security.MessageDigest;

/**
 * Created by trdehero on 14-8-4.
 */
public class FootballApp extends Application {
  @Override
  public void onCreate() {
    showDeveloperKeyHash();
    super.onCreate();

    // initialize analytics instance
    Analytics.of(this);
  }

  public void showDeveloperKeyHash() {
    if (!Constants.RELEASE) {
      try {
        PackageInfo info =
            getPackageManager().getPackageInfo("com.myhero.fh", PackageManager.GET_SIGNATURES);
        for (Signature signature : info.signatures) {
          MessageDigest md = MessageDigest.getInstance("SHA");
          md.update(signature.toByteArray());
          Log.d("KeyHash", "KeyHash: " + Base64.encodeToString(md.digest(), Base64.DEFAULT));
        }
      } catch (Exception e) {
        Log.d("KeyHash", "Error");
        e.printStackTrace();
      }
    }
  }
}
