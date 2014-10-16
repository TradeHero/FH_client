

class ShareSDKConnector
{

public:
    static ShareSDKConnector* getInstance();
    
    void login();
    void share(const char* title, const char* content);
};
