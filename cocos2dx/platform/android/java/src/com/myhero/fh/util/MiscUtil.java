package com.myhero.fh.util;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import org.cocos2dx.lib.Cocos2dxActivity;

public class MiscUtil {
  private static final String TAG = MiscUtil.class.getSimpleName();

  public static final int REQUEST_CODE_SEND_EMAIL = 1;
  public static final int REQUEST_CODE_SEND_SMS = 2;

  public static void sendMail(String receiver, String subject, String body) {
    Intent intent = new Intent(Intent.ACTION_SEND);
    intent.setType("plain/text");
    intent.putExtra(Intent.EXTRA_EMAIL, new String[] { receiver });
    intent.putExtra(Intent.EXTRA_SUBJECT, subject);
    intent.putExtra(Intent.EXTRA_TEXT, body);
    try {
      Cocos2dxActivity.sendMail(Intent.createChooser(intent, ""));
    }
    catch (ActivityNotFoundException ignored) {
      sendMailResult(-1);
    }
  }

  public static void sendSms(String body) {
    Uri smsUri = Uri.parse("tel:");
    Intent intent = new Intent(Intent.ACTION_VIEW, smsUri);
    intent.putExtra("sms_body", body);
    intent.setType("vnd.android-dir/mms-sms");

    try {
      Cocos2dxActivity.sendSms(intent);
    }
    catch (ActivityNotFoundException ignored) {
      sendMailResult(-1);
    }
  }

  public static void onActivityResult(int requestCode, int resultCode, Intent data) {
    Log.d(TAG, String.format("requestCode(%d), resultCode(%d), data(%s)", requestCode,
        resultCode, data));


    // There isn't a way to know about the result of email/sms sending request
    switch (requestCode) {
      case REQUEST_CODE_SEND_EMAIL:
        //if (resultCode == Activity.RESULT_OK) {
        sendMailResult(1);
        //} else {
        //  sendMailResult(-1);
        //}
        break;
      case REQUEST_CODE_SEND_SMS:
        //if (resultCode == Activity.RESULT_OK) {
        sendSmsResult(1);
        //} else {
        //  sendSmsResult(-1);
        //}
        break;
    }
  }

  public static native void sendMailResult(int resultCode);
  public static native void sendSmsResult(int resultCode);
}
