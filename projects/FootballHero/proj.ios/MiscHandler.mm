
#include "MiscHandler.h"
#include "Misc.h"
#import "AppController.h"
#import "RootViewController.h"
#import "UAPush.h"

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

void MiscHandler::sendMail(char* receiver, char* subject, char* body)
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    bool result = [[app getViewController] sendMail:[NSString stringWithUTF8String:receiver] withSubject:[NSString stringWithUTF8String:subject] withBody:[NSString stringWithUTF8String:body]];
    // The phone dose not support sending mail.
    if (result == false)
    {
        sendMailResult( -1 );
    }
}

void MiscHandler::sendMailResult(int resultCode)
{
    Utils::Misc::sharedDelegate()->sendMailResult(resultCode);
}

void MiscHandler::sendSMS(char *body)
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    bool result = [[app getViewController] sendSMS:[NSString stringWithUTF8String:body]];
    if (result == false)
    {
        sendSMSResult( -1 );
    }
}

void MiscHandler::sendSMSResult(int resultCode)
{
    Utils::Misc::sharedDelegate()->sendSMSResult(resultCode);
}

void MiscHandler::getUADeviceToken()
{
    NSString* token = [UAPush shared].deviceToken;
    
    Utils::Misc::sharedDelegate()->responseUADeviceToken([token UTF8String]);
}

void MiscHandler::requestPushNotification()
{
    [[UAPush shared] setPushEnabled:YES];
}
