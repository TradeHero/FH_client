

#include "WebviewController.h"
#import "AppController.h"
#import "RootViewController.h"
#include "CCEGLView.h"
#include "cocos2d.h"

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

void WebviewController::openFullScreenWebpage(const char* url)
{
    openWebpage(url, 0, 80, 768, 984);
}

void WebviewController::openWebpage(const char* url, int x, int y, int w, int h)
{
    if (webView == nil)
    {
        cocos2d::CCEGLView* eglView = cocos2d::CCEGLView::sharedOpenGLView();
        float scaleX = (float)[UIScreen mainScreen].bounds.size.width /(float)eglView->getDesignResolutionSize().width;
        float scaleY = (float)[UIScreen mainScreen].bounds.size.height /(float)eglView->getDesignResolutionSize().height;
        
        AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
        UIView *mainView = [app getViewController].view;
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(x * scaleX, y * scaleY, w * scaleX, h * scaleY)];
        [mainView addSubview:webView];
    }
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:url]]];
    
    [webView loadRequest:request];
}

void WebviewController::closeWebpage()
{
    if (webView != nil){
        [webView removeFromSuperview];
        [webView release];
        webView = nil;
    }
}