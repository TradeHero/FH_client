

class FacebookConnector
{

public:
    static FacebookConnector* getInstance();
    
    void initSession();
    void login();
    void share(const char* title, const char* content);
    void grantPublishPermission(const char* permission);
};
