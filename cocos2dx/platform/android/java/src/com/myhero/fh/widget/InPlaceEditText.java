package com.myhero.fh.widget;

import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import org.cocos2dx.lib.Cocos2dxHandler;
import org.cocos2dx.lib.Cocos2dxHelper;

public class InPlaceEditText extends EditText
  implements NativeAdapter<Cocos2dxHandler.EditBoxMessage> {
  private static final String TAG = "InPlaceEditText";
  private NativeData nativeData;

  public InPlaceEditText(Context context, AttributeSet attrs) {
    super(context, attrs);

    super.addTextChangedListener(new TextWatcher() {
      @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        Cocos2dxHelper.setEditTextDialogResult(nativeData.getSource(), " ");
      }

      @Override public void onTextChanged(CharSequence s, int start, int before, int count) {
      }

      @Override public void afterTextChanged(Editable s) {
      }
    });
    super.setOnFocusChangeListener(new View.OnFocusChangeListener() {
      @Override public void onFocusChange(View v, boolean hasFocus) {
        if (!hasFocus) {
          Cocos2dxHelper.setEditTextDialogResult(nativeData.getSource(), getText().toString());
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
    nativeData = editBoxMessage;

    setText(editBoxMessage.content);
    setHint(editBoxMessage.title);

    // TODO
    setX(editBoxMessage.x);
    setY(editBoxMessage.y);
    setWidth((int) editBoxMessage.width);
    setHeight((int) editBoxMessage.height);

    setSingleLine();
    setPadding(0, 0, 0, 0);
  }
}
