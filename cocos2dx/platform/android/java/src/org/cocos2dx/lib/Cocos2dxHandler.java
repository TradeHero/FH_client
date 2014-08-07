/****************************************************************************
Copyright (c) 2010-2011 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 ****************************************************************************/

package org.cocos2dx.lib;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.graphics.Color;
import android.os.Handler;
import android.os.Message;
import android.view.ViewGroup;
import com.myhero.fh.widget.InPlaceEditText;
import com.myhero.fh.widget.NativeData;
import java.lang.ref.WeakReference;

public class Cocos2dxHandler extends Handler {
	// ===========================================================
	// Constants
	// ===========================================================
	public final static int HANDLER_SHOW_DIALOG = 1;
	public final static int HANDLER_SHOW_EDITBOX_DIALOG = 2;
	
	// ===========================================================
	// Fields
	// ===========================================================
	private WeakReference<Cocos2dxActivity> mActivity;
	
	// ===========================================================
	// Constructors
	// ===========================================================
	public Cocos2dxHandler(Cocos2dxActivity activity) {
		this.mActivity = new WeakReference<Cocos2dxActivity>(activity);
	}

	// ===========================================================
	// Getter & Setter
	// ===========================================================

	// ===========================================================
	// Methods for/from SuperClass/Interfaces
	// ===========================================================
	
	// ===========================================================
	// Methods
	// ===========================================================

	public void handleMessage(Message msg) {
		switch (msg.what) {
		case Cocos2dxHandler.HANDLER_SHOW_DIALOG:
			showDialog(msg);
			break;
		case Cocos2dxHandler.HANDLER_SHOW_EDITBOX_DIALOG:
			showEditBoxDialog(msg);
			break;
		}
	}
	
	private void showDialog(Message msg) {
		Cocos2dxActivity theActivity = this.mActivity.get();
		DialogMessage dialogMessage = (DialogMessage)msg.obj;
		new AlertDialog.Builder(theActivity)
		.setTitle(dialogMessage.titile)
		.setMessage(dialogMessage.message)
		.setPositiveButton("Ok", 
				new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						// TODO Auto-generated method stub
						
					}
				}).create().show();
	}
	
	private void showEditBoxDialog(Message msg) {
		EditBoxMessage editBoxMessage = (EditBoxMessage)msg.obj;

    final InPlaceEditText editText = new InPlaceEditText(mActivity.get(), null);
    editText.setBackgroundColor(Color.RED);
    editText.processNativeData(editBoxMessage);

    ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(
        ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
    mActivity.get().addContentView(editText, layoutParams);
	}
	
	// ===========================================================
	// Inner and Anonymous Classes
	// ===========================================================
	
	public static class DialogMessage {
		public String titile;
		public String message;
		
		public DialogMessage(String title, String message) {
			this.titile = title;
			this.message = message;
		}
	}
	
	public static class EditBoxMessage implements NativeData {
		public String title;
		public String content;
		public int inputMode;
		public int inputFlag;
		public int returnType;
		public int maxLength;
    public final float x;
    public final float y;
    public final float width;
    public final float height;

    public EditBoxMessage(String title, String content, int inputMode, int inputFlag, int returnType, int maxLength,
        float x, float y, float width, float height){
			this.content = content;
			this.title = title;
			this.inputMode = inputMode;
			this.inputFlag = inputFlag;
			this.returnType = returnType;
			this.maxLength = maxLength;
      this.x = x;
      this.y = y;
      this.width = width;
      this.height = height;
    }

    @Override public String toString() {
      return
          "\ncontent: " + content +
          "\ntitle: " + title +
          "\ninputMode: " + inputMode +
          "\ninputFlag: " + inputFlag +
          "\nreturnType: " + returnType +
          "\nmaxLength: " + maxLength +
          "\nx: " + x +
          "\ny: " + y +
          "\nwidth: " + width +
          "\nheight: " + height
          ;
    }
  }
}
