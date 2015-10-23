

class WebviewController
{
    
public:
    static WebviewController* getInstance();
    
    void openWebpage(const char* url, int x, int y, int w, int h);
    void openWebpage(const char* url);
    
    void closeWebpage();
};
