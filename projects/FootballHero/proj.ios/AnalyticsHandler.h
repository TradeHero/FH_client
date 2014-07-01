

class AnalyticsHandler
{
    
public:
    static AnalyticsHandler* getInstance();
    
    void postEvent(const char* eventName, const char* key, const char* value);
    
};
