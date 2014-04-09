#ifndef _HTTPREQUEST_FORLUA_H_
#define _HTTPREQUEST_FORLUA_H_

#include "cocos2d.h"
#include "HttpRequest.h"
#include "HttpClient.h"


NS_CC_EXT_BEGIN

class HttpRequestForLua : CCObject
{
public:
	HttpRequestForLua();
	~HttpRequestForLua();

	static HttpRequestForLua * create(CCHttpRequest::HttpRequestType type, const char* contentType, const char* fhToken);

	void sendHttpRequest(const char* url, int callbackFunc);
	void onHttpRequestCompleted(cocos2d::CCNode *sender, void *data);
	void setRequest(CCHttpRequest* request) { mRequest = request; }
	CCHttpRequest* getRequest() { return mRequest; }
	
protected:
	int mCallbackFunc;
	CCHttpRequest* mRequest;
};

NS_CC_EXT_END

#endif