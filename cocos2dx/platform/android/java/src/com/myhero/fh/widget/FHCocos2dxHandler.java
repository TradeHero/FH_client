package com.myhero.fh.widget;

import android.graphics.Color;
import android.graphics.Rect;
import android.os.Message;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import com.myhero.fh.util.DeviceUtil;
import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;
import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHandler;

public class FHCocos2dxHandler extends Cocos2dxHandler {
  // TODO make this private, singleton ... for now, it is public :(
  public static Map<Long, WeakReference<View>> cachedBindingView = new HashMap<Long,
      WeakReference<View>>();

  public FHCocos2dxHandler(Cocos2dxActivity activity) {
    super(activity);
  }

  public static void unfocusIfNecessary(View currentFocusedView, MotionEvent event) {
    boolean hasNewFocus = false;
    for (WeakReference<View> weakView: cachedBindingView.values()) {
      View focusedView = weakView.get();
      if (focusedView != null && focusedView.getVisibility() == View.VISIBLE) {
        Rect outRect = new Rect();
        focusedView.getGlobalVisibleRect(outRect);
        if (!outRect.contains((int) event.getRawX(), (int) event.getRawY())) {
          focusedView.clearFocus();
        } else {
          hasNewFocus = true;
        }
      }
    }

    if (!hasNewFocus) {
      DeviceUtil.hideKeyboard(currentFocusedView);
    }
  }

  @Override protected void showEditBoxDialog(Message msg) {
    EditBoxMessage editBoxMessage = (EditBoxMessage)msg.obj;

    Cocos2dxActivity activity = mActivity.get();
    if (activity != null && editBoxMessage.getSource() != 0) {
      WeakReference<View> cachedViewWeak = cachedBindingView.get(editBoxMessage.getSource());
      OverlayEditText editText = null;
      if (cachedViewWeak != null) {
        View cachedView = cachedViewWeak.get();
        if (cachedView instanceof OverlayEditText) {
          editText = (OverlayEditText) cachedView;
          editText.setVisibility(View.VISIBLE);
        }
      }
      if (editText == null) {
        editText = spawnAndroidEditText(activity);
        cachedBindingView.put(editBoxMessage.getSource(), new WeakReference<View>(editText));
      }
      editText.processNativeData(editBoxMessage);
      editText.requestFocus();
      DeviceUtil.showKeyboard(editText);

      hackToPushScreenUp(editText);
    }
  }

  /**
   * Simulate entering text action to current focused EditTextView, so that the system will move the
   * screen up
   * @param editText current focused EditText view
   */
  private void hackToPushScreenUp(OverlayEditText editText) {
    if (editText.getText().toString().length() == 0) {
      final OverlayEditText finalEditText = editText;
      editText.postDelayed(new Runnable() {
        @Override public void run() {
          if (finalEditText.getVisibility() == View.VISIBLE) {
            finalEditText.dispatchKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_0));
            finalEditText.setText("");
          }
        }
      }, 500);
    }
  }

  private OverlayEditText spawnAndroidEditText(Cocos2dxActivity activity) {
    final OverlayEditText editText = new OverlayEditText(activity, null);
    editText.setBackgroundColor(Color.TRANSPARENT);
    // TODO get text color from Cocos2Dx
    editText.setTextColor(activity.getResources().getColor(android.R.color.white));
    editText.setImeOptions(EditorInfo.IME_FLAG_NO_EXTRACT_UI);

    ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(
        ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
    ((ViewGroup) activity.getWindow().getDecorView()).addView(editText,
        layoutParams);
    return editText;
  }

  public static void destroyBindingView(long source) {
    WeakReference<View> weakView = cachedBindingView.get(source);
    if (weakView != null) {
      View view = weakView.get();
      if (view != null && view.getParent() instanceof ViewGroup) {
        ViewGroup vg = (ViewGroup)(view.getParent());
        vg.removeView(view);
        cachedBindingView.remove(source);
      }
    }
  }
}
