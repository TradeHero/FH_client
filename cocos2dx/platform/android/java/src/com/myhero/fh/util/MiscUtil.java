package com.myhero.fh.util;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.*;
import android.net.Uri;
import android.provider.Settings;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.provider.MediaStore;
import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHelper;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

public class MiscUtil {
  private static final String TAG = MiscUtil.class.getSimpleName();

  public static final int REQUEST_CODE_SEND_EMAIL = 1;
  public static final int REQUEST_CODE_SEND_SMS = 2;
  public static final int REQUEST_CODE_SELECT_IMAGE = 3;

  private static String mImagePath = "";
  private static int mImageWidth = 0;
  private static int mImageHeight = 0;

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

  public static void openUrl(String url) {
      try {
          Uri uri = Uri.parse(url);
          Intent intent = new Intent (Intent.ACTION_VIEW, uri);
          Cocos2dxActivity.openUrl(intent);
      }
      catch (ActivityNotFoundException ignored) {

      }
  }

    public static void selectImage(String path, int width, int height) {
        mImagePath = Cocos2dxHelper.getCocos2dxWritablePath() + "/" + path;
        mImageWidth = width;
        mImageHeight = height;
        try {
            Intent intent = new Intent();
            intent.setType("image/*");
            intent.setAction(Intent.ACTION_GET_CONTENT);
            Cocos2dxActivity.selectImage(intent);
        }
        catch (ActivityNotFoundException ignored) {

        }
    }

    public static void getDeepLink() {
        String deepLink = ((Cocos2dxActivity)Cocos2dxActivity.getContext()).getDeepLink();
        notifyDeepLink(deepLink);
    }

    public static void openRate() {
        Cocos2dxActivity activity = ((Cocos2dxActivity)Cocos2dxActivity.getContext());
        try {
            final String pkgName = activity.getPackageName();
            activity.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + pkgName)));
        } catch (Exception e) {
            e.printStackTrace();
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

        case REQUEST_CODE_SELECT_IMAGE:
            if(data == null)
            {
                selectImageResult(false);
                return;
            }
            Uri photoUri = data.getData();
            if(photoUri == null )
            {
                selectImageResult(false);
                return;
            }

            Log.d(TAG, String.format("Select image url(%s)", photoUri.toString())); // content://media/external/images/media/130852
            String[] pojo = {MediaStore.Images.Media.DATA};
            Cursor cursor = Cocos2dxActivity.getContext().getContentResolver().query(photoUri, pojo, null, null, null);
            if(cursor != null && cursor.moveToFirst())
            {
                int columnIndex = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
                String imagePath = cursor.getString(columnIndex);
                cursor.close();
                Log.i(TAG, "imagePath = " + imagePath);  // /storage/sdcard0/Nikon_WU/Card/D20130928_001/100NIKON/DSCN2559.JPG

                Bitmap originBitmap = BitmapFactory.decodeFile(imagePath);
                Bitmap scaledBitmap = Bitmap.createBitmap(mImageWidth, mImageHeight, Bitmap.Config.ARGB_8888);
                Canvas canvas = new Canvas(scaledBitmap);
                canvas.drawBitmap(originBitmap, null, new Rect(0, 0, mImageWidth, mImageHeight), null);
                File saveFile = new File(mImagePath);
                if(saveFile.exists()){
                    saveFile.delete();
                }
                FileOutputStream out = null;
                try {
                    File f = new File(mImagePath);
                    out = new FileOutputStream(f);
                    scaledBitmap.compress(Bitmap.CompressFormat.JPEG, 80, out);
                    out.flush();
                    MediaStore.Images.Media.insertImage(Cocos2dxActivity.getContext().getContentResolver(), f.getAbsolutePath(), f.getName(), f.getName());
                    selectImageResult(true);
                }
                catch(Exception e)
                {
                    selectImageResult(false);
                }
                finally {
                    try {
                        if (out != null) {
                            out.close();
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
            else
            {
                selectImageResult(false);
            }
            break;
    }
  }

    public static String getSerialNumber() {
        return android.os.Build.SERIAL;
    }

    public static String getDeviceID(){
        TelephonyManager tm = (TelephonyManager) Cocos2dxActivity.getContext().getSystemService(Cocos2dxActivity.TELEPHONY_SERVICE);
        return tm.getDeviceId();
    }

    public static String getAndroidID(){
        return Settings.System.getString(Cocos2dxActivity.getContext().getContentResolver(), Settings.Secure.ANDROID_ID);
    }

    public static native void sendMailResult(int resultCode);
    public static native void sendSmsResult(int resultCode);
    public static native void selectImageResult(boolean success);
    public static native void notifyDeepLink(String deepLink);
}
