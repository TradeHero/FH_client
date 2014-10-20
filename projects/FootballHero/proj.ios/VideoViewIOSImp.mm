//
// Created by liangwei on 14-7-21.
//
#include "VideoView.h"
#include "CCLuaEngine.h"
#import "VideoViewIOSImp.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation VideoViewIOSImp

-(void) doMovieFinishedNotification:(NSNotification*)aNotification{
    MPMoviePlayerController *player = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];

    [player.view removeFromSuperview];
    [player release];

    movieFinishedCallback(luaFuncID);
    [self release];

}

-(void) playVideo:(const char*) filename luaFuncID:(int) funcID callback:(void (*)(int)) callback{

    movieFinishedCallback = callback;
    luaFuncID = funcID;

    MPMoviePlayerController *player2 = [ [ MPMoviePlayerController alloc]initWithContentURL:[NSURL fileURLWithPath:[NSString stringWithUTF8String:filename]]];

    bool showControls= false;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doMovieFinishedNotification:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player2];

    UIView* currentView = [UIApplication sharedApplication].keyWindow;

    if ([player2 respondsToSelector:@selector(setFullscreen:animated:)]) {
        player2.fullscreen = true;
        player2.controlStyle = showControls ? MPMovieControlStyleFullscreen : MPMovieControlStyleNone;
        CGRect bounds = [[UIScreen mainScreen] bounds];
        [player2.view setBounds:CGRectMake(0, 0, bounds.size.height, bounds.size.width)];
        [player2.view setCenter:CGPointMake(bounds.size.width/2, bounds.size.height/2)];
        [player2.view setTransform:CGAffineTransformMakeRotation(M_PI / 2)];

        player2.movieSourceType = MPMovieSourceTypeFile;
        [player2 prepareToPlay];
    } else {
        // Use the old 2.0 style API
        player2.controlStyle = showControls ? MPMovieControlStyleDefault : MPMovieControlStyleNone;
    }

    if ([player2 respondsToSelector:@selector(view)]) {

        [currentView addSubview:player2.view];
        player2.shouldAutoplay=TRUE;
    }
    [player2 play];
}
@end

extern "C"  {
void doLuaFinishCallback(int handle)
{
    CCLuaEngine::defaultEngine()->getLuaStack()->executeFunctionByHandler(handle, 0);
}
}

void VideoView::playVideo(const char* filename,int funcID)
{
    std::string filePath = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(filename);
    VideoViewIOSImp* ply =[[VideoViewIOSImp alloc] init];
    [ply playVideo : filePath.c_str() luaFuncID:funcID callback:doLuaFinishCallback];
}



