package com.myhero.fh.widget;

import android.graphics.Color;
import android.os.Message;
import android.view.ViewGroup;
import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHandler;

public class FHCocos2dxHandler extends Cocos2dxHandler {
  public FHCocos2dxHandler(Cocos2dxActivity activity) {
    super(activity);
  }

  @Override protected void showEditBoxDialog(Message msg) {
    EditBoxMessage editBoxMessage = (EditBoxMessage)msg.obj;

    Cocos2dxActivity activity = mActivity.get();
    if (activity != null) {
      final InPlaceEditText editText = new InPlaceEditText(activity, null);
      editText.setBackgroundColor(Color.TRANSPARENT);
      //editText.setTextColor(Color.TRANSPARENT);
      editText.processNativeData(editBoxMessage);

      ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(
          ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
      activity.addContentView(editText, layoutParams);
    }
  }
}
