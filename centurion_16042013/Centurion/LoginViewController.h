//
//  LoginViewController.h
//  Centurion
//
//  Created by costrategix technologies on 11/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

@class AppDelegate,SyncController;
@interface LoginViewController : UIViewController <UITextFieldDelegate>
{
    AppDelegate *appDelegate;
    SyncController *sync;
    
    IBOutlet UITextField *txt_UserName;
    IBOutlet UITextField *txt_Password;
    IBOutlet UIActivityIndicatorView *actv;
    int kOFFSET_FOR_KEYBOARD;
    
    NSMutableDictionary *dict_Response;
    
    //Loading View
    IBOutlet UIView *vw_Loading;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UILabel *lbl_loading;
}
-(IBAction)LoginPressed:(id)sender;
//-(IBAction)ForgotPasswordPressed:(id)sender;
-(void)setViewMovedUp:(BOOL)movedUp;

- (NSString *) md5:(NSString *) input;  //Function to convert text into MD5
- (BOOL) connected;
- (BOOL) onlineLogin;
- (BOOL) offlineLogin;
- (void) showSpinner;
- (void) hideSpinner;
- (void) loginProcess;
- (void) syncComplete:(NSNotification *)notification;
@end
