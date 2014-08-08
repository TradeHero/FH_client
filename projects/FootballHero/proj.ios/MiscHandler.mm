
#include "MiscHandler.h"
#include "Misc.h"
#import "AppController.h"
#import "RootViewController.h"

static MiscHandler* instance;

MiscHandler* MiscHandler::getInstance()
{
    if (instance == NULL)
    {
        instance = new MiscHandler();
    }
    return instance;
}

void MiscHandler::copyToPasteboard(const char* content)
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithUTF8String:content];
}


void MiscHandler::selectImage(char* path)
{
    setImagePath(path);
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app getViewController] selectImage];
}

void MiscHandler::selectImageResult(bool success)
{
    Utils::Misc::sharedDelegate()->selectImageResult(success);
}

bool MiscHandler::sendMail(char* receiver, char* subject, char* body)
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    return [[app getViewController] sendMail:[NSString stringWithUTF8String:receiver] withSubject:[NSString stringWithUTF8String:subject] withBody:[NSString stringWithUTF8String:body]];
}