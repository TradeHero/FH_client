

class AnalyticsHandler
{
    
public:
    static AnalyticsHandler* getInstance();
    
    void postEvent(const char* eventName, const char* paramString);
    void postFlurryEvent(const char* eventName, const char* paramString);
    void postTongdaoEvent(const char* eventName, const char* paramString);
    void loginTongdao(const char* userId);
    void trackTongdaoAttr(const char* attrName, const char* value);
    void trackTongdaoAttrs(const char* paramString);
    void trackTongdaoOrder(const char* orderName, const float* price, const char* currency);
};
