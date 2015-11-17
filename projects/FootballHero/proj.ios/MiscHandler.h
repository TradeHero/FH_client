

class MiscHandler
{
    
public:
    static MiscHandler* getInstance();
    
    void copyToPasteboard(const char* content);
    
    void selectImage(char* content, int width, int height);
    
    void selectImageResult(bool success);
    
    void sendMail(char* receiver, char* subject, char* body);
    
    void sendMailResult(int resultCode);
    
    void sendSMS(char* body);
    
    void sendSMSResult(int resultCode);
    
    void getUADeviceToken();
    
    void addUATags(const char* tagsString);
    
    void removeUATags(const char* tagsString);
    
    void responseUADeviceToken(const char* token);
    
    void requestPushNotification();
    
    void openUrl(char* url);
    
    const char* getDeepLink();
    
    const char* getDeviceID();
    
    void notifyDeepLink(const char* deepLink);
    
    void openRate();
    
    
    // Getter and setter for local varibles.
    char* getImagePath() { return imagePath; }
    
    void setImagePath(char* path) { imagePath = path; }
    
    int getImageWidth() { return imageWidth; }
    
    void setImageWidth(int width) { imageWidth = width; }
    
    int getImageHeight() { return imageHeight; }
    
    void setImageHeight(int height) { imageHeight = height; }
    
private:
    char* imagePath;
    int imageWidth;
    int imageHeight;
};
