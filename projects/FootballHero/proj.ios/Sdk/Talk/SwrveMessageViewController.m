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
#import "SwrveMessageViewController.h"
#import "SwrveMessage.h"
#import "SwrveCampaign.h"
#import "SwrveMessageFormat.h"
#import "SwrveButton.h"
#import <QuartzCore/QuartzCore.h>

@interface SwrveMessageViewController ()

@property (nonatomic, retain) SwrveMessageFormat* current_format;
-(IBAction)onButtonPressed:(id)sender;

@end

@implementation SwrveMessageViewController

@synthesize block;
@synthesize message;
@synthesize current_format;

- (void)viewDidLoad
{
    current_format = nil;
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Do any additional setup after displaying the view.
    [self addAllViewsForOrientation:[self interfaceOrientation]];
    [self.message wasShownToUser];
}

-(void)removeAllViews
{
    for (UIView *view in self.view.subviews)
    {
        [view removeFromSuperview];
    }
}

-(void)addAllViewsForOrientation:(UIInterfaceOrientation)orientation
{
    current_format = [self.message getBestFormatFor:orientation];
    
    if (current_format) {
        NSLog(@"Selected message format: %@", current_format.name);

        [current_format createViewWithOrientation:orientation
                                        toFit:self.view
                              thatDelegatesTo:self
                             withDebugDisplay:self.message.debugDisplay];
    } else {
        NSLog(@"Couldn't find a format with the current orientation for message: %@", message.name);
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self removeAllViews];
}

-(IBAction)onButtonPressed:(id)sender
{
    UIButton* button = sender;

    SwrveButton* pressed = [current_format.buttons objectAtIndex:button.tag];

    [pressed wasPressedByUser];

    self.block(pressed.actionType, pressed.actionString, pressed.appID);
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self removeAllViews];
    [self addAllViewsForOrientation:toInterfaceOrientation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    BOOL portrait = [self.message supportsOrientation:UIInterfaceOrientationPortrait];
    BOOL landscape = [self.message supportsOrientation:UIInterfaceOrientationLandscapeLeft];
    
    if (portrait && landscape) {
        return UIInterfaceOrientationMaskAll;
    }
    
    if (landscape) {
        return UIInterfaceOrientationMaskLandscape | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
    
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Required for transition to work correctly when presenting the view
    // controller. See these articles for more info...
    // http://stackoverflow.com/questions/17937347/how-to-animate-view-after-using-uimodalpresentationcurrentcontext
    // http://stackoverflow.com/questions/11236367/display-clearcolor-uiviewcontroller-over-uiviewcontroller
    if (animated)
    {
        CATransition *slide = [CATransition animation];
        
        slide.type = kCATransitionPush;
        slide.subtype = kCATransitionFromTop;
        slide.duration = 0.4;
        slide.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        slide.removedOnCompletion = YES;
        
        [self.view.layer addAnimation:slide forKey:@"slidein"];
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    // Register for orientation changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    // Remove the orientation listener
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
