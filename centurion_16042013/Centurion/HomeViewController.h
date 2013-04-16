//
//  HomeViewController.h
//  Centurion
//
//  Created by costrategix technologies on 11/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

@class AppDelegate;
@class SettingsPopViewController;

@interface HomeViewController : UIViewController
{
    AppDelegate *appDelegate;
    
    IBOutlet UILabel *lbl_UserName;
    SettingsPopViewController *obj_settingsPoP;
    UIPopoverController *popoverController;
    
    //Loading View
    IBOutlet UIView *vw_Loading;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UILabel *lbl_loading;
}
- (IBAction)CreateEstimatePressed:(id)sender;
- (IBAction)SavedEstimatesPressed:(id)sender;
- (IBAction)LogoutPressed:(id)sender;
- (void)checkLogout;
- (void)checkSync;
- (void)startRevSync;
- (void)RevSyncCompleted;
- (void)syncDone;
- (void) showSpinner;
- (void) hideSpinner;
- (BOOL) connected;

@property (nonatomic, retain) UIColor *sliderColor;
@property (retain, nonatomic) IBOutlet UILabel *lbl_Percent;
@property (retain, nonatomic) NSString *str_EstimatorID;
@end
