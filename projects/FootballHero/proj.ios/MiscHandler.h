

class MiscHandler
{
    
public:
    static MiscHandler* getInstance();
    
    void copyToPasteboard(const char* content);
    
    void selectImage(char* content);
    
    void selectImageResult(bool success);
    
    void sendMail(char* receiver, char* subject, char* body);
    
    void sendMailResult(int resultCode);
    
    void sendSMS(char* body);
    
    void sendSMSResult(int resultCode);
    
    void getUADeviceToken();
    
    
    // Getter and setter for local varibles.
    char* getImagePath() { return imagePath; }
    
    void setImagePath(char* path) { imagePath = path; }
    
private:
    char* imagePath;
};
