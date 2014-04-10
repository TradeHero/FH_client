#include "HttpRequestForLua.h"
#include "CCLuaEngine.h"

USING_NS_CC;
USING_NS_CC_EXT;

HttpRequestForLua::HttpRequestForLua()
{
}


HttpRequestForLua::~HttpRequestForLua()
{
}

HttpRequestForLua * HttpRequestForLua::create(CCHttpRequest::HttpRequestType type, const char* contentType, const char* fhToken)
{
	HttpRequestForLua* requestForLua = new HttpRequestForLua();

	if (requestForLua)
	{
		requestForLua->autorelease();

		CCHttpRequest* request = new CCHttpRequest();
		request->setRequestType(type);

		std::string header = "";
		if (contentType != NULL)
		{
			header.append("Content-Type=");
			header.append(contentType);
		}
		if (fhToken != NULL)
		{
			header.append("FH-Token=");
			header.append(fhToken);
		}
		std::vector<std::string> headers;
		headers.push_back(header);
		request->setHeaders(headers);

		requestForLua->setRequest(request);
	}
	else
	{
		CC_SAFE_DELETE(requestForLua);
	}

	return requestForLua;
}

void HttpRequestForLua::sendHttpRequest(const char* url, int callbackFunc)
{
	mCallbackFunc = callbackFunc;
	getRequest()->setUrl(url);
	getRequest()->setResponseCallback(this, callfuncND_selector(HttpRequestForLua::onHttpRequestCompleted));
	
	CCHttpClient::getInstance()->send(getRequest());
	getRequest()->release();
}

void HttpRequestForLua::onHttpRequestCompleted(cocos2d::CCNode *sender, void *data)
{
	CCHttpResponse *response = (CCHttpResponse*)data;

	if (!response)
	{
		return;
	}
  
	if (0 != strlen(response->getHttpRequest()->getTag()))
	{
		CCLog("%s completed", response->getHttpRequest()->getTag());
	}
	
	int statusCode = response->getResponseCode();
	CCLog("response code: %d", statusCode);

	if (!response->isSucceed())
	{
		CCLog("response failed");
		CCLog("error buffer: %s", response->getErrorBuffer());
		return;
	}

	// dump data

	CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
	cocos2d::CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
	if (pLuaEngine == NULL)
	{
		assert(false);
		return;
	}

	CCLuaStack* pStack = pLuaEngine->getLuaStack();
	bool isSucceed = response->isSucceed();
	int status = response->getResponseCode();
	const char* errorBuffer = response->getErrorBuffer();
	std::vector<char>* headerBuffer = response->getResponseHeader();
	std::vector<char>* bodyBuffer = response->getResponseData();
	std::string header(headerBuffer->begin(), headerBuffer->end());
	std::string body(bodyBuffer->begin(), bodyBuffer->end());
	//pStack->pushCCObject(response->getHttpRequest(), "CCHttpRequest");
	pStack->pushBoolean(isSucceed);  
	pStack->pushString(body.c_str(), body.size());
	pStack->pushString(header.c_str()); 
	pStack->pushInt(status);
	pStack->pushString(errorBuffer);
	pStack->executeFunctionByHandler(mCallbackFunc, 5);
	pStack->clean();

}