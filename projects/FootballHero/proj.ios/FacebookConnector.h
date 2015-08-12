

class FacebookConnector
{

public:
    static FacebookConnector* getInstance();
    
    void initSession();
    void login();
    void grantPublishPermission(const char* permission);
    void gameRequest(const char* title, const char* message);
};
