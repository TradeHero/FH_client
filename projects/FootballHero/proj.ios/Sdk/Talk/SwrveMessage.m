/*
 * SWRVE CONFIDENTIAL
 *
 * (c) Copyright 2010-2014 Swrve New Media, Inc. and its licensors.
 * All Rights Reserved.
 *
 * NOTICE: All information contained herein is and remains the property of Swrve
 * New Media, Inc or its licensors.  The intellectual property and technical
 * concepts contained herein are proprietary to Swrve New Media, Inc. or its
 * licensors and are protected by trade secret and/or copyright law.
 * Dissemination of this information or reproduction of this material is
 * strictly forbidden unless prior written permission is obtained from Swrve.
 */

#import "SwrveMessageController.h"
#import "SwrveCampaign.h"
#import "SwrveMessage.h"
#import "SwrveButton.h"
#import "SwrveImage.h"
#import "SwrveMessageViewController.h"
#import "SwrveMessageFormat.h"
#import "SwrveInterfaceOrientation.h"


@interface SwrveMessage()

@property (nonatomic, unsafe_unretained) SwrveMessageController* controller;

@end

@implementation SwrveMessage

@synthesize messageID, debugDisplay;
@synthesize name;
@synthesize priority;
@synthesize createdAt;
@synthesize createdBy;
@synthesize formats;

-(void)downloadURL:(NSString*)hash toCache:(NSString*)cache inFolder:(NSString*)folder
{
    ///[self.controller.cdn_root]
    NSURL* cdn_base = [NSURL URLWithString:@"https://swrve-content.s3.amazonaws.com/messaging/message_image/"];
    NSURL* image_url = [NSURL URLWithString:hash relativeToURL:cdn_base];
    NSURL* target = [NSURL fileURLWithPathComponents:[NSArray arrayWithObjects:cache, folder, hash, nil]];
       
    if ([[NSFileManager defaultManager] fileExistsAtPath:[target path]]) {
    } else {
        NSData* image = [NSData dataWithContentsOfURL:image_url];
        [image writeToURL:target atomically:YES];
    }

}

-(SwrveMessageFormat*)getBestFormatFor:(UIInterfaceOrientation)orientation
{    
    for (SwrveMessageFormat* format in formats)
    {
        bool format_is_landscape = format.orientation == SWRVE_ORIENTATION_LANDSCAPE;
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            // device is landscape
            if (format_is_landscape) return format;
        }
        else
        {
            // device is portrait
            if(!format_is_landscape) return format;
        }
    }
    return nil;
}

-(BOOL)supportsOrientation:(UIInterfaceOrientation)orientation
{
    return (nil != [self getBestFormatFor:orientation]);
}

-(void)download
{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    NSString* cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString* swrve_folder = @"com.ngt.msgs";
    
    NSError* error;
    NSURL* target = [NSURL fileURLWithPathComponents:[NSArray arrayWithObjects:cache, swrve_folder, nil]];
    if (![manager createDirectoryAtURL:target
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error])
    {
        NSLog(@"Error creating %@: %@", target, error);
    }
    
    for (SwrveMessageFormat* format in self.formats)
    {
        for (SwrveButton* button in format.buttons)
        {
            [self downloadURL:button.image   toCache:cache inFolder:swrve_folder];
        }
        for (SwrveImage* image in format.images)
        {
            [self downloadURL:image.file   toCache:cache inFolder:swrve_folder];
        }
    }
    
}

-(SwrveMessage*)updateWithJSON:(NSDictionary*)json
                 forCampaign:(SwrveCampaign*)campaign
                 forController:(SwrveMessageController*)controller
{
    self.campaign     = campaign;
    self.controller   = controller;
    self.messageID    = [json objectForKey:@"id"];
    self.name         = [json objectForKey:@"name"];
    if ([json objectForKey:@"name"]) {
        self.priority     = [json objectForKey:@"priority"];
    } else {
        self.priority = [NSNumber numberWithInt:9999];
    }
    
    self.createdAt    = [json objectForKey:@"created_at"];
    self.createdBy    = [json objectForKey:@"created_by"];
    self.debugDisplay = false;

    NSDictionary* messageTemplate = (NSDictionary*)[json objectForKey:@"template"];
    
    NSArray* jsonFormats = [messageTemplate objectForKey:@"formats"];
    
    NSMutableArray* loadedFormats = [[NSMutableArray alloc] init];
    
    for (NSDictionary* jsonFormat in jsonFormats)
    {
        SwrveMessageFormat* format = [[SwrveMessageFormat alloc] initFromJson:jsonFormat
                                                                forController:controller
                                                                   forMessage:self];
        [loadedFormats addObject:format];
    }
    
    [loadedFormats sortUsingComparator:^NSComparisonResult(SwrveMessageFormat* a, SwrveMessageFormat* b){
        NSLog(@"Sorting %@ and %@", a.name, b.name);
        if ([b screenArea] >= [a screenArea]) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];

    for (SwrveMessageFormat* format in loadedFormats){
        NSLog(@"Sorted Format Area: %f", [format screenArea]);
    }

    self.formats = [[NSArray alloc] initWithArray:loadedFormats];
    return self;
}

+(SwrveMessage*)fromJSON:(NSDictionary*)json forCampaign:(SwrveCampaign*)campaign forController:(SwrveMessageController*)controller
{
    return [[[SwrveMessage alloc] init] updateWithJSON:json
                                         forCampaign: campaign
                                         forController:controller];
}


-(UIViewController*)createViewControllerThatCalls:(SwrveMessageResult)block
{
    // Check that message has a format for the current orientation
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ( [self supportsOrientation:currentOrientation] ) {
        SwrveMessageViewController* controller = [[SwrveMessageViewController alloc] init];
        controller.message = self;
        controller.block = block;
        return controller;
    } else {
        NSLog(@"The message doesn't support the current orientation");
    }
    return nil;
}

static bool in_cache(NSString* file, NSSet* set){
    return [file length] == 0 || [set containsObject:file];
}

-(BOOL)isDownloaded:(NSSet*)assets
{
    for (SwrveMessageFormat* format in self.formats) {

        for (SwrveButton* button in format.buttons) {

            if (!in_cache(button.image, assets)){
                NSLog(@"Button Asset not yet downloaded: %@", button.image);
                return false;
            }
        }

        for (SwrveImage* image in format.images) {
            if (!in_cache(image.file, assets)){
                NSLog(@"Image Asset not yet downloaded: %@", image.file);
                return false;
            }
        }
    }

    return true;
}

-(void)wasShownToUser
{
    [self.controller messageWasShownToUser:self];
}

@end
