package com.myhero.fh.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import org.cocos2dx.lib.Cocos2dxHandler;
import org.cocos2dx.lib.Cocos2dxHelper;

public class InPlaceEditText extends EditText
  implements NativeAdapter<Cocos2dxHandler.EditBoxMessage> {
  private static final String TAG = "InPlaceEditText";

  public InPlaceEditText(Context context, AttributeSet attrs) {
    super(context, attrs);

    super.setOnFocusChangeListener(new View.OnFocusChangeListener() {
      @Override public void onFocusChange(View v, boolean hasFocus) {
        if (!hasFocus) {
          Cocos2dxHelper.setEditTextDialogResult(getText().toString());
          setVisibility(GONE);
        }
      }
    });
  }

  @Override public final void setOnFocusChangeListener(OnFocusChangeListener l) {
    throw new IllegalAccessError("This method is not supposed to be called");
  }

  @Override public void processNativeData(Cocos2dxHandler.EditBoxMessage editBoxMessage) {
    Log.d(TAG, String.format("Data [%s]", editBoxMessage));

    setText(editBoxMessage.content);
    setHint(editBoxMessage.title);

    // TODO
    setX(editBoxMessage.x);
    setY(editBoxMessage.y);
  }

  @Override protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
    super.onLayout(changed, left, top, right, bottom);
  }
}
