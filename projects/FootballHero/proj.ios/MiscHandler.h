

class MiscHandler
{
    
public:
    static MiscHandler* getInstance();
    
    void copyToPasteboard(const char* content);
    
    void selectImage(char* content);
    
    void selectImageResult(bool success);
    
    
    // Getter and setter for local varibles.
    char* getImagePath() { return imagePath; }
    
    void setImagePath(char* path) { imagePath = path; }
    
private:
    char* imagePath;
};
