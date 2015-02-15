

class QuickBloxChatHandler
{
    
public:
    static QuickBloxChatHandler* getInstance();
    
    void login(const char* userName, const char* profileImg, int userId);
    void logout();
    void loginResult(const char* token);
    
    void joinChatRoom(const char* jid);
    void sendMessage(const char* message);
    
    void newMessageHandler(const char* sender, const char* message, int timestamp);
};
