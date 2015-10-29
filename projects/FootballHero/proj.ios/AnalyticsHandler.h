

class AnalyticsHandler
{
    
public:
    static AnalyticsHandler* getInstance();
    
    void postEvent(const char* eventName, const char* paramString);
    void postFlurryEvent(const char* eventName, const char* paramString);
    
};
