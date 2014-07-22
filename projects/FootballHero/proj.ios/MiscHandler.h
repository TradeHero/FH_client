

class MiscHandler
{
    
public:
    static MiscHandler* getInstance();
    
    void copyToPasteboard(const char* content);
    
    void selectImage(char* content);
    
    void selectImageResult(bool success);
    
    bool sendMail(char* receiver, char* subject, char* body);
    
    
    // Getter and setter for local varibles.
    char* getImagePath() { return imagePath; }
    
    void setImagePath(char* path) { imagePath = path; }
    
private:
    char* imagePath;
};
