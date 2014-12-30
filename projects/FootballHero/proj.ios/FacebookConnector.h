

class FacebookConnector
{

public:
    static FacebookConnector* getInstance();
    
    void initSession();
    void login();
    void grantPublishPermission(const char* permission);
    void like();
};
