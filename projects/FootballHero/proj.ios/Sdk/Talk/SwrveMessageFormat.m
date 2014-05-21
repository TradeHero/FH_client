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

#import <QuartzCore/CALayer.h>
#import "SwrveMessageFormat.h"
#import "SwrveMessageController.h"
#import "SwrveButton.h"
#import "SwrveImage.h"
#import "SwrveCampaign.h"

@implementation SwrveMessageFormat

@synthesize images, text, size, buttons, name, scale;

+(UILabel*)createDebugLabel:(CGFloat)width
                    forSize:(CGSize)size
                  andCenter:(CGPoint)center
{
    UILabel* label = [[UILabel alloc] init];
    [label setText:[NSString stringWithFormat:@"s:%gx%g\nc:%gx%g",
                       size.width,
                       size.height,
                       center.x,
                       center.y]];

    label.numberOfLines = 2;

    CGRect frame = CGRectMake(0, 0, width, 24);
    [label setFrame:frame];
    [label setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.35]];
    [label setTextColor:[UIColor whiteColor]];

    [label setFont:[UIFont fontWithName:@"Courier" size:10]];
    return label;
}

+(CGPoint)getCenterFrom:(NSDictionary*)data
{
    NSNumber* x = [[data objectForKey:@"x"] objectForKey:@"value"];
    NSNumber* y = [[data objectForKey:@"y"] objectForKey:@"value"];
    return CGPointMake(x.floatValue, y.floatValue);
}

+(CGSize)getSizeFrom:(NSDictionary*)data
{
    NSNumber* w = [[data objectForKey:@"w"] objectForKey:@"value"];
    NSNumber* h = [[data objectForKey:@"h"] objectForKey:@"value"];
    return CGSizeMake(w.floatValue, h.floatValue);
}

+(float)getFontSizeFrom:(NSDictionary*)json
{
    id fontSize = [json objectForKey:@"font_size"];
    id value    = [fontSize objectForKey:@"value"];
    return [value floatValue];
}

+(SwrveImage*)createImage:(NSDictionary*)imageData
{
    SwrveImage* image = [[SwrveImage alloc] init];
    image.file = [[imageData objectForKey:@"image"] objectForKey:@"value"];
    image.center = [SwrveMessageFormat getCenterFrom:imageData];
    image.size   = [SwrveMessageFormat getSizeFrom:imageData];

    NSLog(@"Image Loaded: Asset: \"%@\" (w: %g h: %g x: %g y: %g)",
          image.file,
          image.size.width,
          image.size.height,
          image.center.x,
          image.center.y);

    return image;
}

+(SwrveButton*)createButton:(NSDictionary*)buttonData
              forController:(SwrveMessageController*)controller
                 forMessage:(SwrveMessage*)message
{
    SwrveButton* button = [[SwrveButton alloc] init];
    button.controller = controller;
    button.message = message;
    
    button.center     = [SwrveMessageFormat getCenterFrom:buttonData];
    button.size       = [SwrveMessageFormat getSizeFrom:buttonData];
    button.image      = [[buttonData objectForKey:@"image_up"] objectForKey:@"value"];
    button.messageID  = [message.messageID integerValue];


    // Set up the action for the button.
    button.actionType   = kSwrveActionDismiss;
    button.appID       = 0;
    button.actionString = @"";

    NSString* buttonType = [[buttonData objectForKey:@"type"] objectForKey:@"value"];
    if ([buttonType isEqualToString:@"INSTALL"]){
        button.actionType   = kSwrveActionInstall;
        button.appID       = [[[buttonData objectForKey:@"game_id"] objectForKey:@"value"] integerValue];
        button.actionString = [controller getAppStoreURLForGame:button.appID];

    } else if ([buttonType isEqualToString:@"CUSTOM"]) {
        button.actionType   = kSwrveActionCustom;
        button.actionString = [[buttonData objectForKey:@"action"] objectForKey:@"value"];
    }

    return button;
}

-(id)initFromJson:(NSDictionary*)json forController:(SwrveMessageController*)controller forMessage:(SwrveMessage*)message
{
    self = [super init];

    self.name     = [json objectForKey:@"name"];
    self.language = [json objectForKey:@"language"];
    
    NSString* orientation = [json objectForKey:@"orientation"];
    if (orientation)
    {
        self.orientation = ([orientation caseInsensitiveCompare:@"landscape"] == NSOrderedSame)? SWRVE_ORIENTATION_LANDSCAPE : SWRVE_ORIENTATION_PORTRAIT;
    }
    
    // If doesn't exist default to 1.0
    NSNumber * jsonScale = [json objectForKey:@"scale"];
    if (jsonScale)
    {
        self.scale = [jsonScale floatValue];
    }
    else
    {
        self.scale = 1.0;
    }
    
    self.size = [SwrveMessageFormat getSizeFrom:[json objectForKey:@"size"]];

    NSLog(@"Format %@ Scale: %g  Size: %gx%g", self.name, self.scale, self.size.width, self.size.height);
    
    NSArray* jsonButtons = [json objectForKey:@"buttons"];
    NSMutableArray* loadedButtons = [[NSMutableArray alloc] init];
    
    for (NSDictionary* jsonButton in jsonButtons)
    {
        [loadedButtons addObject:[SwrveMessageFormat createButton:jsonButton forController:controller forMessage:message]];
    }

    self.buttons = [NSArray arrayWithArray:loadedButtons];

    self.text = [[NSArray alloc]init];

    NSMutableArray* loadedImages = [[NSMutableArray alloc] init];

    NSArray* jsonImages = [json objectForKey:@"images"];
    for (NSDictionary* jsonImage in jsonImages) {

        [loadedImages addObject:[SwrveMessageFormat createImage:jsonImage]];
    }

    self.images = [NSArray arrayWithArray:loadedImages];

    return self;
}

static UIView* offset_by(UIView* view, CGFloat x, CGFloat y)
{
    CGPoint button_center = [view center];
    [view setCenter: CGPointMake(button_center.x + x,
                                 button_center.y + y)];
    return view;
}


-(UIView*)createViewWithOrientation:(UIInterfaceOrientation)orientation
                              toFit:(UIView*)view
                    thatDelegatesTo:(UIViewController*)delegate
                   withDebugDisplay:(bool)debugDisplay
{
    CGSize size_screen  = view.bounds.size;
    //CGSize size_message = self.size;
    
    // Find the center point of the view
    CGFloat half_screen_width = size_screen.width/2;
    CGFloat half_screen_height = size_screen.height/2;
    
    // Adjust scale, accounting for retina devices
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGFloat renderScale = self.scale / screenScale;
    
    NSLog(@"MessageViewFormat scale :%g", self.scale);
    NSLog(@"UI scale :%g", screenScale);
    
    NSString* cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString* swrve_folder = @"com.ngt.msgs";

    for (SwrveImage* backgroundImage in self.images)
    {
        NSURL* bgurl = [NSURL fileURLWithPathComponents:[NSArray arrayWithObjects:cache, swrve_folder, backgroundImage.file, nil]];
        UIImage* background = [UIImage imageWithData:[NSData dataWithContentsOfURL:bgurl]];

        CGRect frame = CGRectMake(0, 0,
                                  background.size.width * renderScale,
                                  background.size.height * renderScale);
        
        
        UIImageView* backgroundView = [[UIImageView alloc] initWithFrame:frame];
        backgroundView.image = background;
        [backgroundView setCenter:CGPointMake(half_screen_width + (backgroundImage.center.x * renderScale),
                                               half_screen_height + (backgroundImage.center.y * renderScale))];
        
        if (debugDisplay) {
            backgroundView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
            backgroundView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor;
            backgroundView.layer.borderWidth = 2;
        }
        [view addSubview:backgroundView];
    }

    // Add the message.
    SEL selector = @selector(onButtonPressed:);

    int tag = 0;
    for (SwrveButton* button in self.buttons)
    {
        UIButton* b = [button createButtonWithOrientation:orientation
                                              andDelegate:delegate
                                              andSelector:selector
                                              andDebugDisplay:debugDisplay
                                                 andScale:renderScale];
        b.tag = tag;
        
        NSString * buttonType;
        switch (button.actionType) {
            case kSwrveActionInstall:
                buttonType = @"Install";
                break;
            case kSwrveActionDismiss:
                buttonType = @"Dismiss";
                break;
            default:
                buttonType = @"Custom";
        }
        
        b.accessibilityLabel = [NSString stringWithFormat:@"TalkButton_%d_%@", tag, buttonType];
        
        [view addSubview: offset_by(b, half_screen_width, half_screen_height)];
        
        tag++;
    }

    return view;
}

-(CGFloat)screenArea
{
    return self.size.width * self.size.height;
}


@end
