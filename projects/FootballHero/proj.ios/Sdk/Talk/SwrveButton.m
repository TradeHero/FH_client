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
#import "SwrveButton.h"
#import "SwrveCampaign.h"
#import "SwrveMessageFormat.h"
#import "SwrveMessage.h"
#import <QuartzCore/CALayer.h>

@interface SwrveButton()

@end

@implementation SwrveButton

@synthesize image, size;
@synthesize center;

static CGPoint scaled(CGPoint point, float scale)
{
    return CGPointMake(point.x * scale, point.y * scale);
}

-(id)init
{
    self = [super init];
    self.image        = @"buttonup.png";
    self.actionString = @"";
    self.appID       = 0;
    self.actionType   = kSwrveActionDismiss;
    self.center   = CGPointMake(100, 100);
    self.size     = CGSizeMake(100, 20);
    return self;
}

-(UIButton*)createButtonWithOrientation:(UIInterfaceOrientation)orientation
                            andDelegate:(id)delegate
                            andSelector:(SEL)selector
                        andDebugDisplay:(bool)debugDisplay
                               andScale:(float)scale
{
    (void)orientation;
            
    NSString* cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString* swrve_folder = @"com.ngt.msgs";
    
    NSURL* url_up = [NSURL fileURLWithPathComponents:[NSArray arrayWithObjects:cache, swrve_folder, image, nil]];
    UIImage* up   = [UIImage imageWithData:[NSData dataWithContentsOfURL:url_up]];

    UIButton* result;
    if (up) {
        result = [UIButton buttonWithType:UIButtonTypeCustom];
        [result setBackgroundImage:up   forState:UIControlStateNormal];
    }
    else {
        result = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    }
    
    [result  addTarget:delegate action:selector forControlEvents:UIControlEventTouchUpInside];
    
    CALayer* layer = result.layer;
    CGFloat width  = self.size.width;
    CGFloat height = self.size.height;

    if (up) {
        width  = [up size].width;
        height = [up size].height;
    }

    [result setFrame:CGRectMake(0, 0, width  * scale,
                                       height * scale)];

    [result setCenter: scaled(self.center, scale)];

    if (debugDisplay) {
        result.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
        layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
        layer.borderWidth = 1;

        UILabel* sizeDesc = [SwrveMessageFormat createDebugLabel:(size.width * scale) forSize:self.size andCenter:self.center];
        [result addSubview:sizeDesc];
    }

    return result;
}

-(void)wasPressedByUser
{
    [self.controller buttonWasPressedByUser:self];
}

@end
