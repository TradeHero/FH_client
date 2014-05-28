

#include "WebviewController.h"
#import "AppController.h"
#import "RootViewController.h"

static WebviewController* instance;
UIWebView *webView;

#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] hasPrefix: @"iPhone" ] )
#define IS_IPAD   ( [ [ [ UIDevice currentDevice ] model ] hasPrefix: @"iPad" ] )

WebviewController* WebviewController::getInstance()
{
    if (instance == NULL)
    {
        instance = new WebviewController();
    }
    return instance;
}

void WebviewController::openWebpage(const char* url, int x, int y, int w, int h)
{
    if (webView == nil)
    {
        AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
        UIView *mainView = [app getViewController].view;
        NSString *m = [[UIDevice currentDevice] model];
        if (IS_IPHONE)
        {
            webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 40, 320, 528)];
        }
        else if (IS_IPAD)
        {
            webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 80, 768, 984)];
        }
        
        [mainView addSubview:webView];
        
       
    }
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:url]]];
    
    [webView loadRequest:request];
}

void WebviewController::closeWebpage()
{
    [webView removeFromSuperview];
    [webView release];
    webView = nil;
}