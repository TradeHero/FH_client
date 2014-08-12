package com.myhero.fh.widget;

import android.graphics.Color;
import android.os.Message;
import android.view.View;
import android.view.ViewGroup;
import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;
import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHandler;

public class FHCocos2dxHandler extends Cocos2dxHandler {
  private static Map<Long, WeakReference<View>> cachedBindingView = new HashMap<Long,
      WeakReference<View>>();

  public FHCocos2dxHandler(Cocos2dxActivity activity) {
    super(activity);
  }

  @Override protected void showEditBoxDialog(Message msg) {
    EditBoxMessage editBoxMessage = (EditBoxMessage)msg.obj;

    Cocos2dxActivity activity = mActivity.get();
    if (activity != null && editBoxMessage.getSource() != 0) {
      WeakReference<View> cachedViewWeak = cachedBindingView.get(editBoxMessage.getSource());
      InPlaceEditText editText = null;
      if (cachedViewWeak != null) {
        View cachedView = cachedViewWeak.get();
        if (cachedView instanceof InPlaceEditText) {
          editText = (InPlaceEditText) cachedView;
          editText.setVisibility(View.VISIBLE);
        }
      }
      if (editText == null) {
        editText = spawnAndroidEditText(activity);
        cachedBindingView.put(editBoxMessage.getSource(), new WeakReference<View>(editText));
      }
      editText.processNativeData(editBoxMessage);
    }
  }

  private InPlaceEditText spawnAndroidEditText(Cocos2dxActivity activity) {
    final InPlaceEditText editText = new InPlaceEditText(activity, null);
    editText.setBackgroundColor(Color.TRANSPARENT);

    ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(
        ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
    activity.addContentView(editText, layoutParams);
    //editText.setTextColor(Color.TRANSPARENT);
    return editText;
  }
}
