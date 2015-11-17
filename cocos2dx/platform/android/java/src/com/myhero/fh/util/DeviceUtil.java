package com.myhero.fh.util;

import android.content.Context;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import com.myhero.fh.widget.FHCocos2dxHandler;
import java.lang.ref.WeakReference;

public class DeviceUtil {
  @SuppressWarnings("Unused")
  public static void hideKeyboard(long nativeSource) {
    WeakReference<View> weakView = FHCocos2dxHandler.cachedBindingView.get(nativeSource);
    if (weakView != null) {
      View view = weakView.get();
      if (view != null) {
        hideKeyboard(view);
      }
    }
  }

  public static void hideKeyboard(View focusedView) {
    InputMethodManager imm = (InputMethodManager) focusedView.getContext().getSystemService
        (Context.INPUT_METHOD_SERVICE);
    imm.hideSoftInputFromWindow(focusedView.getWindowToken(), 0);
  }

  public static void showKeyboard(View focusingView) {
    InputMethodManager imm = (InputMethodManager) focusingView.getContext().getSystemService
        (Context.INPUT_METHOD_SERVICE);
    imm.showSoftInput(focusingView, 0);
  }

}
