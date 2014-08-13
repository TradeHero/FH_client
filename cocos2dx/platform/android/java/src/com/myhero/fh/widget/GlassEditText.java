package com.myhero.fh.widget;

import android.content.Context;
import android.text.InputType;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import org.cocos2dx.lib.Cocos2dxHandler;
import org.cocos2dx.lib.Cocos2dxHelper;

public class GlassEditText extends EditText
  implements NativeAdapter<Cocos2dxHandler.EditBoxMessage> {
  private static final String TAG = "InPlaceEditText";
  /**
   * The user is allowed to enter any text, including line breaks.
   */
  private final int kEditBoxInputModeAny = 0;

  /**
   * The user is allowed to enter an e-mail address.
   */
  private final int kEditBoxInputModeEmailAddr = 1;

  /**
   * The user is allowed to enter an integer value.
   */
  private final int kEditBoxInputModeNumeric = 2;

  /**
   * The user is allowed to enter a phone number.
   */
  private final int kEditBoxInputModePhoneNumber = 3;

  /**
   * The user is allowed to enter a URL.
   */
  private final int kEditBoxInputModeUrl = 4;

  /**
   * The user is allowed to enter a real number value. This extends kEditBoxInputModeNumeric by allowing a decimal point.
   */
  private final int kEditBoxInputModeDecimal = 5;

  /**
   * The user is allowed to enter any text, except for line breaks.
   */
  private final int kEditBoxInputModeSingleLine = 6;

  /**
   * Indicates that the text entered is confidential data that should be obscured whenever possible. This implies EDIT_BOX_INPUT_FLAG_SENSITIVE.
   */
  private final int kEditBoxInputFlagPassword = 0;

  /**
   * Indicates that the text entered is sensitive data that the implementation must never store into a dictionary or table for use in predictive, auto-completing, or other accelerated input schemes. A credit card number is an example of sensitive data.
   */
  private final int kEditBoxInputFlagSensitive = 1;

  /**
   * This flag is a hint to the implementation that during text editing, the initial letter of each word should be capitalized.
   */
  private final int kEditBoxInputFlagInitialCapsWord = 2;

  /**
   * This flag is a hint to the implementation that during text editing, the initial letter of each sentence should be capitalized.
   */
  private final int kEditBoxInputFlagInitialCapsSentence = 3;

  /**
   * Capitalize all characters automatically.
   */
  private final int kEditBoxInputFlagInitialCapsAllCharacters = 4;

  private final int kKeyboardReturnTypeDefault = 0;
  private final int kKeyboardReturnTypeDone = 1;
  private final int kKeyboardReturnTypeSend = 2;
  private final int kKeyboardReturnTypeSearch = 3;
  private final int kKeyboardReturnTypeGo = 4;

  private NativeData nativeData;

  public GlassEditText(Context context, AttributeSet attrs) {
    super(context, attrs);

    super.setOnFocusChangeListener(new View.OnFocusChangeListener() {
      @Override public void onFocusChange(View v, boolean hasFocus) {
        if (!hasFocus) {
          invalidateNative();
        }
      }
    });
  }

  private void invalidateNative() {
    Cocos2dxHelper.setEditTextDialogResult(nativeData.getSource(), getText().toString());
    setVisibility(GONE);
  }

  @Override public final void setOnFocusChangeListener(OnFocusChangeListener l) {
    throw new IllegalAccessError("This method is not supposed to be called");
  }

  @Override public void clearFocus() {
    super.clearFocus();
    invalidateNative();
  }

  @Override public void processNativeData(Cocos2dxHandler.EditBoxMessage editBoxMessage) {
    Log.d(TAG, String.format("Data [%s]", editBoxMessage));
    nativeData = editBoxMessage;

    setText(editBoxMessage.content);
    setHint(editBoxMessage.title);

    // populate UI properties
    // TODO
    setX(editBoxMessage.x);
    setY(editBoxMessage.y);
    setWidth((int) editBoxMessage.width);
    setHeight((int) editBoxMessage.height);

    setSingleLine();
    setPadding(0, 0, 0, 0);

    // and editing options
    int inputModeConstraints = 0;
    switch (editBoxMessage.inputMode) {
      case kEditBoxInputModeAny:
        inputModeConstraints |= InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_MULTI_LINE;
        break;
      case kEditBoxInputModeEmailAddr:
        inputModeConstraints |= InputType.TYPE_CLASS_TEXT | InputType
            .TYPE_TEXT_VARIATION_EMAIL_ADDRESS;
        break;
      case kEditBoxInputModeNumeric:
        inputModeConstraints |= InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_SIGNED;
        break;
      case kEditBoxInputModePhoneNumber:
        inputModeConstraints |= InputType.TYPE_CLASS_PHONE;
        break;
      case kEditBoxInputModeUrl:
        inputModeConstraints |= InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_URI;
        break;
      case kEditBoxInputModeDecimal:
        inputModeConstraints |= InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL
            | InputType.TYPE_NUMBER_FLAG_SIGNED;
        break;
      case kEditBoxInputModeSingleLine:
        inputModeConstraints |= InputType.TYPE_CLASS_TEXT;
        break;
    }

    int inputFlagConstraints = 0;
    switch (editBoxMessage.inputFlag) {
      case kEditBoxInputFlagPassword:
        inputFlagConstraints |= InputType.TYPE_CLASS_TEXT | InputType
          .TYPE_TEXT_VARIATION_PASSWORD;
        break;
      case kEditBoxInputFlagSensitive:
        inputFlagConstraints |= InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS;
        break;
      case kEditBoxInputFlagInitialCapsWord:
        inputFlagConstraints |= InputType.TYPE_TEXT_FLAG_CAP_WORDS;
        break;
      //case kEditBoxInputFlagInitialCapsSentence:
      //  inputFlagConstraints |= InputType.TYPE_TEXT_FLAG_CAP_SENTENCES;
      //  break;
      //case kEditBoxInputFlagInitialCapsAllCharacters:
      //  inputFlagConstraints |= InputType.TYPE_TEXT_FLAG_CAP_CHARACTERS;
      //  break;
    }

    setInputType(inputModeConstraints | inputFlagConstraints);
  }
}
