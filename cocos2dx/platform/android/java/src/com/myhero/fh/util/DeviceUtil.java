package com.myhero.fh.util;

import android.content.Context;
import android.view.View;
import android.view.inputmethod.InputMethodManager;

public class DeviceUtil {
  public static void hideKeyboard(View focusedView) {
    InputMethodManager imm = (InputMethodManager) focusedView.getContext().getSystemService
        (Context.INPUT_METHOD_SERVICE);
    imm.hideSoftInputFromWindow(focusedView.getWindowToken(), 0);
  }
}
