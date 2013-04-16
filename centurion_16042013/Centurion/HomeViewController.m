//
//  HomeViewController.m
//  Centurion
//
//  Created by costrategix technologies on 11/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "CreateNewEstimateViewController.h"
#import "ViewEstimatesViewController.h"
#import "AppDelegate.h"
#import "SettingsPopViewController.h"
#import "SurveyViewController.h"
#import "UICircularSlider.h"
#import "QuartzCore/QuartzCore.h"
#import "SKDatabase.h"
#import "RevSyncController.h"
#import "SyncController.h"
#import <QuartzCore/QuartzCore.h>

@interface HomeViewController ()
@property (unsafe_unretained, nonatomic) IBOutlet UISlider *slider;
@property (unsafe_unretained, nonatomic) IBOutlet UICircularSlider *circularSlider;
@property (unsafe_unretained, nonatomic) IBOutlet UICircularSlider *circularSlider_bg;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *view_forCircularSlider ;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imgView_screenshot_slider;
@end

@implementation HomeViewController

@synthesize lbl_Percent;
@synthesize slider = _slider;
@synthesize circularSlider = _circularSlider;
@synthesize circularSlider_bg = _circularSlider_bg;
@synthesize str_EstimatorID;
@synthesize sliderColor = _sliderColor;

-(void)dealloc {
    
    [super dealloc];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    vw_Loading.layer.cornerRadius = 10;
    self.sliderColor = [UIColor colorWithRed:(132/255.f) green:(180/255.f) blue:(0/255.f) alpha:1.0f];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Home" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: newBackButton];
    [newBackButton release];

    lbl_UserName.text = [NSString stringWithFormat:@"Welcome, %@",[appDelegate.dict_GlobalInfo objectForKey:@"username"]];

}

- (BOOL) connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

-(void)checkLogout
{
    [popoverController dismissPopoverAnimated:NO];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showSpinner
{
    [spinner startAnimating];
    [self.view bringSubviewToFront:vw_Loading];
    [vw_Loading bringSubviewToFront:spinner];
    vw_Loading.hidden = FALSE;
}

- (void)hideSpinner
{
    [spinner stopAnimating];
    [self.view sendSubviewToBack:vw_Loading];
    vw_Loading.hidden = TRUE;
}

-(void)checkSync
{
    [popoverController dismissPopoverAnimated:NO];
    
    if(![self connected])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection." message:nil delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else
    {
        lbl_loading.text = @"Sending Data to Server....";
        [self showSpinner];
        
        [self performSelector:@selector(startRevSync) withObject:nil afterDelay:0.0];
    }
}

-(void)startRevSync
{
    RevSyncController *revSyncController = [[RevSyncController alloc] init];
    [revSyncController fetchRecords];
}

-(void)RevSyncCompleted
{
    lbl_loading.text = @"Fetching Data to Server....";

    SyncController *sync = [[SyncController alloc]init];
    [sync startSync];
}

-(void)syncDone
{
    [self hideSpinner];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:appDelegate.strResponseMessage message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = TRUE;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newEstimateCreated:)
                                                 name:@"refreshData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLogout) name:@"CheckLogout" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSync) name:@"CheckSync" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(CustomSlider:)
                                                 name:@"UpdateCustomSlider"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RevSyncCompleted) name:@"StartRevSync" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncDone)
                                                 name:@"startSync"
                                               object: nil];
    
    [self hideSpinner];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark -
#pragma mark Class Method Implementation

-(void)newEstimateCreated:(NSNotification *) notification
{
    SurveyViewController *obj_SurvayPageViewController = [[SurveyViewController alloc] initWithNibName:@"SurveyViewController" bundle:nil];
    obj_SurvayPageViewController.dict_Details = notification.userInfo;
    [self.navigationController pushViewController:obj_SurvayPageViewController animated:YES];
    [obj_SurvayPageViewController release];
    obj_SurvayPageViewController = nil;

}

#pragma mark -
#pragma mark IBAction
-(IBAction)CreateEstimatePressed:(id)sender
{
    // for displaying create estimate popup
    CreateNewEstimateViewController *obj_CreateNewEstimateViewController = [[CreateNewEstimateViewController alloc] initWithNibName:@"CreateNewEstimateViewController" bundle:nil];
    obj_CreateNewEstimateViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:obj_CreateNewEstimateViewController animated:YES];
    [obj_CreateNewEstimateViewController release];
    obj_CreateNewEstimateViewController = nil;
}

-(IBAction)SavedEstimatesPressed:(id)sender
{
    ViewEstimatesViewController *obj_ViewEstimatesViewController = [[ViewEstimatesViewController alloc] initWithNibName:@"ViewEstimatesViewController" bundle:nil];
    [self.navigationController pushViewController:obj_ViewEstimatesViewController animated:YES];
    [obj_ViewEstimatesViewController release];
    obj_ViewEstimatesViewController = nil;
}

-(IBAction)LogoutPressed:(id)sender
{
    // To display logout button
    UIButton *btn = (UIButton *)sender;
    
    if(!obj_settingsPoP)
    {
        obj_settingsPoP= [[SettingsPopViewController alloc] initWithNibName:@"SettingsPopViewController" bundle:nil];
        popoverController = [[[UIPopoverController alloc] initWithContentViewController:obj_settingsPoP] retain];
    }
    
    [popoverController setPopoverContentSize:CGSizeMake(200, 100)];
    
    [popoverController presentPopoverFromRect:CGRectMake(btn.center.x + 10, btn.center.y - 90, 100, 100) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(void)CustomSlider:(NSNotification *) notification
{
    NSDictionary *Dict_EstimatorID = notification.userInfo;
    
    NSArray *arr = [appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from costs where estimator_instance_id = %@",[Dict_EstimatorID objectForKey:@"EstimatorID"]]];
    
    if([arr count] == 0)
    {
        lbl_Percent.text = [NSString stringWithFormat:@"%d",[[Dict_EstimatorID objectForKey:@"centurion_fail_rate"] integerValue]];
        
        [self.circularSlider setMinimumValue:self.slider.minimumValue];
        [self.circularSlider_bg setMinimumValue:self.slider.minimumValue];
        
        [self.circularSlider setMaximumValue:self.slider.maximumValue];
        [self.circularSlider_bg setMaximumValue:self.slider.maximumValue];
        
        self.circularSlider.sliderStyle = UICircularSliderStyleCircle;
        self.circularSlider_bg.sliderStyle = UICircularSliderStyleCircle;
        self.circularSlider_bg.enabled = FALSE;
        self.slider.value = [[Dict_EstimatorID objectForKey:@"centurion_fail_rate"]integerValue];
        [self.circularSlider_bg setValue:[[Dict_EstimatorID objectForKey:@"centurion_fail_rate"]integerValue]];
        [self.circularSlider_bg setMinimumTrackTintColor:self.sliderColor];
        [self.circularSlider_bg setMaximumTrackTintColor:[UIColor grayColor]];
        
        [self.circularSlider setValue:[[Dict_EstimatorID objectForKey:@"centurion_fail_rate"]integerValue]];
        [self.slider setValue:[[Dict_EstimatorID objectForKey:@"centurion_fail_rate"]integerValue]];
        
    }else{
        lbl_Percent.text = [NSString stringWithFormat:@"%d",[[[arr objectAtIndex:0]objectForKey:@"sliderValue"] integerValue]];
        
        [self.circularSlider setMinimumValue:self.slider.minimumValue];
        [self.circularSlider_bg setMinimumValue:self.slider.minimumValue];
        
        [self.circularSlider setMaximumValue:self.slider.maximumValue];
        [self.circularSlider_bg setMaximumValue:self.slider.maximumValue];
        
        self.circularSlider.sliderStyle = UICircularSliderStyleCircle;
        self.circularSlider_bg.sliderStyle = UICircularSliderStyleCircle;
        self.circularSlider_bg.enabled = FALSE;
        self.slider.value = [[[arr objectAtIndex:0]objectForKey:@"sliderValue"]integerValue];
        [self.circularSlider_bg setValue:[[[arr objectAtIndex:0]objectForKey:@"current_fail_rate"]integerValue]];
        [self.circularSlider_bg setMinimumTrackTintColor:self.sliderColor];
        [self.circularSlider_bg setMaximumTrackTintColor:[UIColor grayColor]];
        
        [self.circularSlider setValue:[[[arr objectAtIndex:0]objectForKey:@"sliderValue"]integerValue]];
        [self.slider setValue:[[[arr objectAtIndex:0]objectForKey:@"sliderValue"]integerValue]];

    }
    UIGraphicsBeginImageContext(self.view_forCircularSlider.frame.size);
    [[self.view_forCircularSlider layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    self.imgView_screenshot_slider.image = screenshot;
    
//    NSArray* deletepath_forDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    NSString* deletedocumentsDirectoryfiles = [deletepath_forDirectory objectAtIndex:0];
//    
//    // Delete PNG file in DocumentDirectory
//    NSString *deleteHTMLPath = [deletedocumentsDirectoryfiles stringByAppendingPathComponent:@"Centurion.png"];
//    if([[NSFileManager defaultManager] fileExistsAtPath:deleteHTMLPath]) {
//        
//        [[NSFileManager defaultManager] removeItemAtPath:deleteHTMLPath error:NULL];
//    }
    
    NSData *pngData = UIImagePNGRepresentation(screenshot);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"Centurion.png"]; //Add the file name
    [pngData writeToFile:filePath atomically:YES];
}
@end
