

class FacebookConnector
{

public:
    static FacebookConnector* getInstance();
    
    void initSession();
    void login();
    void grantPublishPermission(const char* permission);
    void inviteFriend(const char* appLinkUrl);
    void shareTimeline(const char* title, const char* description, const char* appLinkUrl);
    
    void inviteFriendResult(bool success);
    void shareTimelineResult(bool success);
};
