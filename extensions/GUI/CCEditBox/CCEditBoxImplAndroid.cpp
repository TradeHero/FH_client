/****************************************************************************
 Copyright (c) 2010-2012 cocos2d-x.org
 Copyright (c) 2012 James Chen
 
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

#include "CCEditBoxImplAndroid.h"
#include "CCEditBoxImplAndroidJNI.h"
#include "../Android/DeviceJNI.h"
 
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

#include "CCEditBox.h"
#include "jni/Java_org_cocos2dx_lib_Cocos2dxBitmap.h"
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"


NS_CC_EXT_BEGIN

CCEditBoxImpl* __createSystemEditBox(CCEditBox* pEditBox)
{
    return new CCEditBoxImplAndroid(pEditBox);
}

CCEditBoxImplAndroid::CCEditBoxImplAndroid(CCEditBox* pEditText)
: CCEditBoxImpl(pEditText)
, m_pLabel(NULL)
, m_pLabelPlaceHolder(NULL)
, m_eEditBoxInputMode(kEditBoxInputModeSingleLine)
, m_eEditBoxInputFlag(kEditBoxInputFlagInitialCapsAllCharacters)
, m_eKeyboardReturnType(kKeyboardReturnTypeDefault)
, m_colText(ccWHITE)
, m_colPlaceHolder(ccGRAY)
, m_nMaxLength(-1)
{
    
}

CCEditBoxImplAndroid::~CCEditBoxImplAndroid()
{
	
}

void CCEditBoxImplAndroid::doAnimationWhenKeyboardMove(float duration, float distance)
{ // don't need to be implemented on android platform.
	
}

static const int CC_EDIT_BOX_PADDING = 5;

bool CCEditBoxImplAndroid::initWithSize(const CCSize& size)
{
    int fontSize = getFontSizeAccordingHeightJni(size.height-12);
    m_pLabel = CCLabelTTF::create("", "", size.height-12);
	// align the text vertically center
    m_pLabel->setAnchorPoint(ccp(0, 0.5f));
    m_pLabel->setPosition(ccp(CC_EDIT_BOX_PADDING, size.height / 2.0f));
    m_pLabel->setColor(m_colText);
    m_pEditBox->addChild(m_pLabel);
	
    m_pLabelPlaceHolder = CCLabelTTF::create("", "", size.height-12);
	// align the text vertically center
    m_pLabelPlaceHolder->setAnchorPoint(ccp(0, 0.5f));
    m_pLabelPlaceHolder->setPosition(ccp(CC_EDIT_BOX_PADDING, size.height / 2.0f));
    m_pLabelPlaceHolder->setVisible(false);
    m_pLabelPlaceHolder->setColor(m_colPlaceHolder);
    m_pEditBox->addChild(m_pLabelPlaceHolder);
    
    m_EditSize = size;
    return true;
}

void CCEditBoxImplAndroid::setFont(const char* pFontName, int fontSize)
{
	if(m_pLabel != NULL) {
		m_pLabel->setFontName(pFontName);
		m_pLabel->setFontSize(fontSize);
	}
	
	if(m_pLabelPlaceHolder != NULL) {
		m_pLabelPlaceHolder->setFontName(pFontName);
		m_pLabelPlaceHolder->setFontSize(fontSize);
	}
}

const char* CCEditBoxImplAndroid::getFontName()
{
	if (m_pLabel != NULL) {
		return m_pLabel->getFontName();
	}

	if (m_pLabelPlaceHolder != NULL) {
		return m_pLabelPlaceHolder->getFontName();
	}
	return NULL;
}
float CCEditBoxImplAndroid::getFontSize()
{
	if (m_pLabel != NULL) {
		return m_pLabel->getFontSize();
	}

	if (m_pLabelPlaceHolder != NULL) {
		return m_pLabelPlaceHolder->getFontSize();
	}
	return 0;
}

void CCEditBoxImplAndroid::setFontColor(const ccColor3B& color)
{
    m_colText = color;
    m_pLabel->setColor(color);
}

void CCEditBoxImplAndroid::setPlaceholderFont(const char* pFontName, int fontSize)
{
	if(m_pLabelPlaceHolder != NULL) {
		m_pLabelPlaceHolder->setFontName(pFontName);
		m_pLabelPlaceHolder->setFontSize(fontSize);
	}
}

void CCEditBoxImplAndroid::setPlaceholderFontColor(const ccColor3B& color)
{
    m_colPlaceHolder = color;
    m_pLabelPlaceHolder->setColor(color);
}

void CCEditBoxImplAndroid::setInputMode(EditBoxInputMode inputMode)
{
    m_eEditBoxInputMode = inputMode;
}

void CCEditBoxImplAndroid::setMaxLength(int maxLength)
{
    m_nMaxLength = maxLength;
}

int CCEditBoxImplAndroid::getMaxLength()
{
    return m_nMaxLength;
}

void CCEditBoxImplAndroid::setInputFlag(EditBoxInputFlag inputFlag)
{
    m_eEditBoxInputFlag = inputFlag;
}

void CCEditBoxImplAndroid::setReturnType(KeyboardReturnType returnType)
{
    m_eKeyboardReturnType = returnType;
}

bool CCEditBoxImplAndroid::isEditing()
{
    return false;
}

void CCEditBoxImplAndroid::setText(const char* pText)
{
    if (pText != NULL)
    {
        m_strText = pText;
		
        if (m_strText.length() > 0)
        {
            m_pLabelPlaceHolder->setVisible(false);
			
            std::string strToShow;
			
            if (kEditBoxInputFlagPassword == m_eEditBoxInputFlag)
            {
                long length = cc_utf8_strlen(m_strText.c_str());
                for (long i = 0; i < length; i++)
                {
                    strToShow.append("\u25CF");
                }
            }
            else
            {
                strToShow = m_strText;
            }

			m_pLabel->setString(strToShow.c_str());

			// Clip the text width to fit to the text box
			float fMaxWidth = m_EditSize.width - CC_EDIT_BOX_PADDING * 2;
			CCRect clippingRect = m_pLabel->getTextureRect();
			if(clippingRect.size.width > fMaxWidth) {
				clippingRect.size.width = fMaxWidth;
				m_pLabel->setTextureRect(clippingRect);
			}

        }
        else
        {
            m_pLabelPlaceHolder->setVisible(true);
            m_pLabel->setString("");
        }
		
    }
}

const char*  CCEditBoxImplAndroid::getText(void)
{
    return m_strText.c_str();
}

void CCEditBoxImplAndroid::setPlaceHolder(const char* pText)
{
    if (pText != NULL)
    {
        m_strPlaceHolder = pText;
        if (m_strPlaceHolder.length() > 0 && m_strText.length() == 0)
        {
            m_pLabelPlaceHolder->setVisible(true);
        }
		
        m_pLabelPlaceHolder->setString(m_strPlaceHolder.c_str());
    }
}

void CCEditBoxImplAndroid::setPosition(const CCPoint& pos)
{ // don't need to be implemented on android platform.
	
}

void CCEditBoxImplAndroid::setVisible(bool visible)
{ // don't need to be implemented on android platform.

}

void CCEditBoxImplAndroid::setContentSize(const CCSize& size)
{ // don't need to be implemented on android platform.
	
}

void CCEditBoxImplAndroid::setAnchorPoint(const CCPoint& anchorPoint)
{ // don't need to be implemented on android platform.
	
}

void CCEditBoxImplAndroid::visit(void)
{ // don't need to be implemented on android platform.
    
}

void CCEditBoxImplAndroid::onEnter(void)
{ // don't need to be implemented on android platform.
    
}

void CCEditBoxImplAndroid::onExit(void)
{    
    // signal to destroy binded view
    destroyEditTextJNI((void*) this);
}

static void editBoxCallbackFunc(const char* pText, void* ctx)
{
    CCEditBoxImplAndroid* thiz = (CCEditBoxImplAndroid*)ctx;
    thiz->updateText(pText);
}

void CCEditBoxImplAndroid::updateText(const char* pText) 
{
    setText(pText);
    m_pLabelPlaceHolder->setVisible(strlen(pText) == 0);
    m_pLabel->setVisible(true);
    
    if (m_pDelegate != NULL)
    {
        m_pDelegate->editBoxTextChanged(m_pEditBox, pText);
        m_pDelegate->editBoxEditingDidEnd(m_pEditBox);
        m_pDelegate->editBoxReturn(m_pEditBox);
    }
    
    if (NULL != m_pEditBox && 0 != m_pEditBox->getScriptEditBoxHandler())
    {
        cocos2d::CCScriptEngineProtocol* pEngine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
        pEngine->executeEvent(m_pEditBox->getScriptEditBoxHandler(), "changed", m_pEditBox);
        pEngine->executeEvent(m_pEditBox->getScriptEditBoxHandler(), "ended", m_pEditBox);
        pEngine->executeEvent(m_pEditBox->getScriptEditBoxHandler(), "return", m_pEditBox);
    }
}

void CCEditBoxImplAndroid::openKeyboard()
{
    if (m_pDelegate != NULL)
    {
        m_pDelegate->editBoxEditingDidBegin(m_pEditBox);
    }
    CCEditBox* pEditBox = this->getCCEditBox();
    if (NULL != pEditBox && 0 != pEditBox->getScriptEditBoxHandler())
    {
        cocos2d::CCScriptEngineProtocol* pEngine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
        pEngine->executeEvent(pEditBox->getScriptEditBoxHandler(), "began",pEditBox);
    }
	
	CCSize contentSize = m_pEditBox->getContentSize();
	CCRect rect = CCRectMake(0, 0, contentSize.width, contentSize.height);
    rect = CCRectApplyAffineTransform(rect, m_pEditBox->nodeToWorldTransform());
	
	CCPoint designCoord = ccp(rect.origin.x, rect.origin.y + rect.size.height);
    
    CCEGLViewProtocol* eglView = CCEGLView::sharedOpenGLView();
    float viewH = getScreenHeightJNI();
    
    CCPoint visiblePos = ccp(designCoord.x * eglView->getScaleX(), designCoord.y * eglView->getScaleY());
    CCPoint screenGLPos = ccpAdd(visiblePos, eglView->getViewPortRect().origin);
    
	ccColor3B textColor = m_pEditBox->getFontColor();
	int textColorValue = (0xff << 24) + (textColor.r << 16) + (textColor.g << 8) + textColor.b;
	CCLOG("New app installed. %d", textColorValue);

	m_pLabelPlaceHolder->setVisible(false);
    m_pLabel->setVisible(false);
    showEditTextDialogJNI(m_strPlaceHolder.c_str(),
						  m_strText.c_str(),
						  m_eEditBoxInputMode,
						  m_eEditBoxInputFlag,
						  m_eKeyboardReturnType,
						  m_nMaxLength,
						  screenGLPos.x, 
						  viewH - screenGLPos.y,
                          rect.size.width * eglView->getScaleX(), 
                          rect.size.height * eglView->getScaleY(),
						  textColorValue,
						  editBoxCallbackFunc,
						  (void*)this  );
	
}

void CCEditBoxImplAndroid::closeKeyboard()
{
    closeKeyboardJNI((void *) this);
}

NS_CC_EXT_END

#endif /* #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) */

