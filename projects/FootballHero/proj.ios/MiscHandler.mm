
#include "MiscHandler.h"
#include "Misc.h"
#import "AppController.h"
#import "RootViewController.h"
#import "UAPush.h"
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

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


void MiscHandler::selectImage(char* path, int width, int height)
{
    setImagePath(path);
    setImageWidth(width);
    setImageHeight(height);
    
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

void MiscHandler::addUATags(const char *tagsString)
{
    NSError *error = nil;
    NSData *jsonData = [[NSString stringWithUTF8String:tagsString] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSArray *tags = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (error == NULL)
    {
        [[UAPush shared] addTagsToCurrentDevice:tags];
        
        NSArray* t = [[UAPush shared] tags];
        NSLog(@"UA tags: %@", t);
    }
}

void MiscHandler::removeUATags(const char *tagsString)
{
    NSError *error = nil;
    NSData *jsonData = [[NSString stringWithUTF8String:tagsString] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSArray *tags = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (error == NULL)
    {
        [[UAPush shared] removeTagsFromCurrentDevice:tags];
    }
}

void MiscHandler::responseUADeviceToken(const char* token)
{
    Utils::Misc::sharedDelegate()->responseUADeviceToken(token);
}

void MiscHandler::requestPushNotification()
{
    [[UAPush shared] setPushEnabled:YES];
}

void MiscHandler::openUrl(char *url)
{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithUTF8String:url]]];
}

const char* MiscHandler::getDeepLink()
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    return [[app getDeepLink] UTF8String];
}

void MiscHandler::notifyDeepLink(const char* deepLink)
{
    Utils::Misc::sharedDelegate()->notifyDeepLink(deepLink);
}

/**
 *  IOS7 return UDID
 */
NSString* MISC_UDID_iOS7(){
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
}


/**
 *  IOS6 return mac address
 */
NSString* MISC_UDID_iOS6(){
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = nil;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = (char *)malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        if (msgBuffer) {
            free(msgBuffer);
        }
        
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    
    return macAddressString;
}

const char* MiscHandler::getDeviceID()
{
    NSString *udid;
    NSString *sysVersion = [UIDevice currentDevice].systemVersion;
    CGFloat version = [sysVersion floatValue];
    if (version >= 7.0) {
        udid = MISC_UDID_iOS7();
    } else if (version >= 2.0) {
        udid = MISC_UDID_iOS6();
    } else {
        return "";
    }
    return [udid UTF8String];
}

void MiscHandler::openRate()
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=859894802"]];
}
