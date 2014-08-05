package com.myhero.fh;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import com.myhero.fh.auth.AuthenticationCallback;
import com.myhero.fh.auth.FacebookAuth;

import java.util.Arrays;

/**
 * Created by trdehero on 14-8-4.
 */
public class FacebookTestActivity extends Activity {
  private static final String TAG = "FacebookTestActivity";
  private FacebookAuth facebookAuth;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    facebookAuth = new FacebookAuth(this, "788386747851675",
        Arrays.asList("public_profile", "user_friends", "email", "user_birthday"));
    facebookAuth.setActivity(this);

    setContentView(R.layout.facebook_view);

    Button clickMeButton = (Button) findViewById(R.id.click_me);
    clickMeButton.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        facebookAuth.authenticate(new FacebookAuthenticationCallback());
      }
    });
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    facebookAuth.onActivityResult(requestCode, resultCode, data);
    super.onActivityResult(requestCode, resultCode, data);
  }

  private class FacebookAuthenticationCallback implements AuthenticationCallback {
    @Override
    public void onStart() {

    }

    @Override
    public void onSuccess(String authenticationToken) {
      Log.d(TAG, "authToken: " + authenticationToken);
    }

    @Override
    public void onError(Throwable error) {
      Log.e(TAG, error.getMessage());
    }
  }
}
