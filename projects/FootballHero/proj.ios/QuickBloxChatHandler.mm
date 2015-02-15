

#include "QuickBloxChatHandler.h"
#include "QuickBloxChat.h"
#import "AppController.h"
#import <Quickblox/Quickblox.h>
#import "ChatService.h"


static QuickBloxChatHandler* instance;

QuickBloxChatHandler* QuickBloxChatHandler::getInstance()
{
    if (instance == NULL)
    {
        instance = new QuickBloxChatHandler();
    }
    return instance;
}

void QuickBloxChatHandler::login(const char *userName, const char* profileImg, int userId)
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [app signin:[NSString stringWithUTF8String:userName] withProfileImg:[NSString stringWithUTF8String:profileImg] andUserId:userId];
}

void QuickBloxChatHandler::logout()
{
    [[ChatService instance] logout];
}

void QuickBloxChatHandler::loginResult(const char *token)
{
    Utils::QuickBloxChat::sharedDelegate()->loginResult(token);
}

void QuickBloxChatHandler::joinChatRoom(const char* jid)
{
    QBChatRoom* room = [[QBChatRoom alloc] init];
    [room initWithRoomJID:[NSString stringWithUTF8String:jid]];
    [[ChatService instance] joinRoom:room completionBlock:^(QBChatRoom *joinedChatRoom) {
        NSLog(@"%@", joinedChatRoom);
        Utils::QuickBloxChat::sharedDelegate()->joinChatRoomResult(true);
    }];
}

void QuickBloxChatHandler::sendMessage(const char* text)
{
    // create a message
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = [NSString stringWithUTF8String:text];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [message setCustomParameters:params];
    
    [[ChatService instance] sendMessageToCurrentRoom:message];
}

void QuickBloxChatHandler::newMessageHandler(const char* sender, const char* message, int timestamp)
{
    Utils::QuickBloxChat::sharedDelegate()->newMessageHandler(sender, message, timestamp);
}


