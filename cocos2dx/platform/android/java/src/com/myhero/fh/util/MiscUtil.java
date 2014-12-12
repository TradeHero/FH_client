package com.myhero.fh.util;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.*;
import android.net.Uri;
import android.util.Log;
import android.provider.MediaStore;
import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHelper;

import java.io.File;
import java.io.FileOutputStream;

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
                Bitmap scaledBitmap = Bitmap.createBitmap(mImageWidth, mImageHeight, Bitmap.Config.ARGB_4444);
                Canvas canvas = new Canvas(scaledBitmap);
                canvas.drawBitmap(originBitmap, null, new Rect(0, 0, mImageWidth, mImageHeight), new Paint(Paint.FILTER_BITMAP_FLAG));
                File saveFile = new File(mImagePath);
                if(saveFile.exists()){
                    saveFile.delete();
                }
                try {
                    FileOutputStream out = new FileOutputStream(new File(mImagePath));
                    scaledBitmap.compress(Bitmap.CompressFormat.JPEG, 100, out);
                    out.close();
                }
                catch(Exception e)
                {
                    selectImageResult(false);
                }
                selectImageResult(true);
            }
            else
            {
                selectImageResult(false);
            }
            break;
    }
  }

    public static native void sendMailResult(int resultCode);
    public static native void sendSmsResult(int resultCode);
    public static native void selectImageResult(boolean success);
}
