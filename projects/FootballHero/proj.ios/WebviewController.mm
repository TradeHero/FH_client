

#include "WebviewController.h"
#import "AppController.h"
#import "RootViewController.h"

static WebviewController* instance;
UIWebView *webView;

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
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
        [[app getViewController].view addSubview:webView];
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