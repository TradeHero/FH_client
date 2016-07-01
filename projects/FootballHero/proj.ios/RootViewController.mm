/****************************************************************************
 Copyright (c) 2010-2011 cocos2d-x.org
 Copyright (c) 2010      Ricardo Quesada
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import "RootViewController.h"
#include "MiscHandler.h"
#include "FacebookConnector.h"
#import <TongDaoUILibrary/TongDaoUiCore.h>


@implementation RootViewController

- (void)selectImage
{
    UIActionSheet *myActionSheet = [[UIActionSheet alloc]
                                    initWithTitle:nil
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles: @"Select a photo",nil];
    
    [myActionSheet showInView:self.view];
    [myActionSheet release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self LocalPhoto];
            break;
        /*case 1:
            [self takePhoto];
            break;*/
        default:
            break;
    }
}

-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:true completion:Nil];
    [picker release];
}

-(void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:true completion:Nil];
        [picker release];
    }
    else
    {
        NSLog(@"You don't have a camera.");
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    
    [picker dismissModalViewControllerAnimated:YES];
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    
    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:[NSString stringWithUTF8String:MiscHandler::getInstance()->getImagePath()]];
    
    NSLog(@"%@", imageDocPath);
    
    if (image != nil)
    {
        CGSize size = CGSizeMake(MiscHandler::getInstance()->getImageWidth(), MiscHandler::getInstance()->getImageHeight());
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *data;
        if (UIImagePNGRepresentation(scaledImage))
        {
            data = UIImagePNGRepresentation(scaledImage);
        }
        else
        {
            data = UIImageJPEGRepresentation(scaledImage, 1.0);
        }

        [[NSFileManager defaultManager] createFileAtPath:imageDocPath contents:data attributes:nil];
        MiscHandler::getInstance()->selectImageResult(true);
    }
}


- (bool)sendMail:(NSString *)receiver withSubject:(NSString *)subject withBody:(NSString *)body
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:subject];
        [controller setToRecipients:[NSArray arrayWithObject:receiver]];
        [controller setMessageBody:body isHTML:NO];
        
        [self presentViewController:controller animated:YES completion:nil];
        [controller release];
        return true;
    }
    else
    {
        return false;
    }
}

- (bool) sendSMS:(NSString *)body
{
    if([MFMessageComposeViewController canSendText]){
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        
        picker.body = body;
        [self presentViewController:picker
                           animated:YES
                         completion:NULL];
        return true;
    }else{
        NSLog(@"Device not configured to send SMS.");
        return false;
    }
}

- (void)mailComposeController: (MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    if (result == MFMailComposeResultSent)
    {
        // NSLog(@"It's away!");
        MiscHandler::getInstance()->sendMailResult(1);
    }
    else
    {
        MiscHandler::getInstance()->sendMailResult(0);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MessageComposeResultCancelled:
            NSLog(@"Result: SMS sending canceled");
            MiscHandler::getInstance()->sendSMSResult(0);
            break;
        case MessageComposeResultSent:
            NSLog(@"Result: SMS sent");
            MiscHandler::getInstance()->sendSMSResult(1);
            break;
        case MessageComposeResultFailed:
            NSLog(@"Result: SMS sending failed");
            MiscHandler::getInstance()->sendSMSResult(0);
            break;
        default:
            NSLog(@"Result: SMS not sent");
            MiscHandler::getInstance()->sendSMSResult(0);
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)inviteFriend:(NSString *)appLinkUrl
{
    
    if ([[[FBSDKAppInviteDialog alloc] init] canShow]) {
        FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
        content.appLinkURL = [NSURL URLWithString:appLinkUrl];
        
        [FBSDKAppInviteDialog showWithContent:content
                                     delegate:self];
    }
}

/*!
 @abstract Sent to the delegate when the app invite completes without error.
 @param appInviteDialog The FBSDKAppInviteDialog that completed.
 @param results The results from the dialog.  This may be nil or empty.
 */
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"Result: appInviteDialog sending success:%@", results.debugDescription );
    if ([results objectForKey:@"completionGesture"] == nil) {
         FacebookConnector::getInstance()->inviteFriendResult(true);
    } else {
        FacebookConnector::getInstance()->inviteFriendResult(false);
    }
 }

/*!
 @abstract Sent to the delegate when the app invite encounters an error.
 @param appInviteDialog The FBSDKAppInviteDialog that completed.
 @param error The error.
 */
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error
{
    NSLog(@"Result: appInviteDialog sending failed");
    NSLog(@" error => %@ ", [error userInfo] );
    NSLog(@" error => %@ ", [error localizedDescription] );
    NSLog(@"%@", error);
    FacebookConnector::getInstance()->inviteFriendResult(false);
}

- (void)shareTimeline:(NSString *)title withDescription:(NSString *)description withAppLinkUrl:(NSString *)appLinkUrl
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentTitle = title;
    content.contentDescription= description;
    content.contentURL = [NSURL URLWithString:appLinkUrl];
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:self];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"Result: shareTimeline sending success:%@", results.debugDescription );
    if ([results objectForKey:@"postId"] == nil) {
        FacebookConnector::getInstance()->shareTimelineResult(false);
    } else {
        FacebookConnector::getInstance()->shareTimelineResult(true);
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    NSLog(@"Result: shareTimeline sending failed");
    NSLog(@" error => %@ ", [error userInfo] );
    NSLog(@" error => %@ ", [error localizedDescription] );
    NSLog(@"%@", error);
    FacebookConnector::getInstance()->shareTimelineResult(false);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"Result: shareTimeline sending canceled %@" , [sharer debugDescription]);
    FacebookConnector::getInstance()->shareTimelineResult(false);
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
 
*/
// Override to allow orientations other than the default portrait orientation.
// This method is deprecated on ios6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape( interfaceOrientation );
}

// For ios6, use supportedInterfaceOrientations & shouldAutorotate instead
- (NSUInteger) supportedInterfaceOrientations{
#ifdef __IPHONE_6_0
    return UIInterfaceOrientationMaskAllButUpsideDown;
#endif
}

- (BOOL) shouldAutorotate {
    return YES;
}

//fix not hide status on ios7
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[TongDaoUiCore sharedManager] onSessionStart:self];
    [[TongDaoUiCore sharedManager] displayInAppMessage:self.view];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[TongDaoUiCore sharedManager] onSessionEnd:self];
}

@end
