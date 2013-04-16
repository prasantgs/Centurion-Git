//
//  LoginViewController.m
//  Centurion
//
//  Created by costrategix technologies on 11/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "AppDelegate.h"
#import "SKDatabase.h"
#import "JSONKit.h"
#import <CommonCrypto/CommonDigest.h>
#import "SyncController.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoginViewController

-(void)dealloc
{
    
    txt_UserName.delegate = nil;
    txt_Password.delegate = nil;
    
    [txt_UserName release];
    txt_UserName = nil;
    
    [txt_Password release];
    txt_Password = nil;
    
    [actv release];
    
    [super dealloc];
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
    
    self.navigationController.navigationBarHidden = TRUE;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    sync = [[SyncController alloc] init];
    
    vw_Loading.layer.cornerRadius = 10;
    
    CGRect frameRect = txt_UserName.frame;
    frameRect.size.height = 50;
    [txt_UserName setFrame:frameRect];
    frameRect = txt_Password.frame;
    frameRect.size.height = 50;
    [txt_Password setFrame:frameRect];
    txt_UserName.delegate = self; 
    txt_Password.delegate = self;
    
    txt_UserName.text = @"admin";
    txt_Password.text = @"centurion098";
    
    txt_UserName.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    txt_Password.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncComplete:)
                                                 name:@"startSync"
                                               object:nil];
    
    [self hideSpinner];
}

- (void)viewWillDisappear:(BOOL)animated
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

#pragma mark -
#pragma mark UITextField Delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == txt_UserName)
    {
        kOFFSET_FOR_KEYBOARD = 80;
        [self setViewMovedUp:YES];
    }
    else if(textField == txt_Password)
    {
        kOFFSET_FOR_KEYBOARD = 120;
        [self setViewMovedUp:YES];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self setViewMovedUp:FALSE];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txt_UserName)
        [txt_Password becomeFirstResponder];
    else
        [textField resignFirstResponder];

    return YES;
}

#pragma mark -
#pragma mark IBActions
-(IBAction)LoginPressed:(id)sender
{
    lbl_loading.text = @"Trying to Login....";
    [self showSpinner];
    
    [txt_UserName resignFirstResponder];
    [txt_Password resignFirstResponder];
    
    [self performSelector:@selector(loginProcess) withObject:nil afterDelay:0.0];
}

-(void) loginProcess
{
    BOOL success;  //TRUE shows successful login
    //If not connected to internet
    if(![self connected])
    {
        success = [self offlineLogin];
        if (success)
        {
            HomeViewController *obj_HomeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
            [self.navigationController pushViewController:obj_HomeViewController animated:YES];
            [obj_HomeViewController release];
            obj_HomeViewController = nil;
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error!" message:@"No internet connection." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    //if connected to internet
    else
    {
        success = [self onlineLogin];
        if (success)
        {
            lbl_loading.text = @"Synchronizing with server....";
            [self showSpinner];

            [sync startSync];
        }
        else
        {
            /*success = [self offlineLogin];
            if (success)
            {
                HomeViewController *obj_HomeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
                [self.navigationController pushViewController:obj_HomeViewController animated:YES];
                [obj_HomeViewController release];
                obj_HomeViewController = nil;
            }
            else
            {*/
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error!" message:@"Username and Password does not match" delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
                [alert show];
                [alert release];
            //}
        }
    }
}

- (void) syncComplete:(NSNotification *)notification
{
    [self hideSpinner];
    HomeViewController *obj_HomeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    [self.navigationController pushViewController:obj_HomeViewController animated:YES];
    [obj_HomeViewController release];
    obj_HomeViewController = nil;
}

- (BOOL) onlineLogin
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://centurion.new.cosdevx.com/api/v1/userAuthenticate?userName=%@&password=%@",txt_UserName.text,txt_Password.text]]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    NSURLResponse *response;
    dict_Response = [[NSMutableDictionary alloc]init];
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    NSString *strSuccess;
    Class jsonSerializationClass = NSClassFromString(@"NSJSONSerialization");
    if (!jsonSerializationClass)
    {
        //iOS < 5 didn't have the JSON serialization class
        
        JSONDecoder *decoder = [JSONDecoder decoderWithParseOptions:JKParseOptionStrict];
        dict_Response = [decoder objectWithData:POSTReply];
        strSuccess = [dict_Response objectForKey:@"success"];
        [strSuccess retain];
    }
    else
    {
        NSError *error;
        
        if ([POSTReply length] < 5)
        {
            strSuccess = @"0";
        }
        else
        {
            dict_Response = [NSJSONSerialization JSONObjectWithData:POSTReply options:NSJSONReadingMutableLeaves error:&error];
            strSuccess = [dict_Response objectForKey:@"success"];
            [strSuccess retain];
            
            if ([strSuccess isEqualToString:@"1"])
            {
                txt_Password.text = @"";
                [appDelegate.dict_GlobalInfo setObject:[dict_Response objectForKey:@"user_name"] forKey:@"username"];
                [appDelegate.dict_GlobalInfo setObject:[dict_Response objectForKey:@"password"] forKey:@"password"];
                [appDelegate.dict_GlobalInfo setObject:[dict_Response objectForKey:@"user_id"] forKey:@"id"];
                
                [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"insert or replace into user (id,username,password) values (%@,'%@','%@')",[dict_Response objectForKey:@"user_id"],[dict_Response objectForKey:@"user_name"],[dict_Response objectForKey:@"password"]] forTable:@"user"];
                [self hideSpinner];
                return TRUE;
            }
        }
    }
    [self hideSpinner];
    return FALSE;
}

- (BOOL) offlineLogin
{
    NSString *strCodedPassword = [self md5:txt_Password.text];
    NSArray *arr_Login = [appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from user where username = '%@' and password = '%@'",txt_UserName.text,strCodedPassword]];
    
    if(arr_Login)
    {
        if([arr_Login count] == 1)
        {
            txt_Password.text = @"";
            appDelegate.dict_GlobalInfo = [arr_Login objectAtIndex:0];
            [self hideSpinner];
            return TRUE;
        }
    }
    [self hideSpinner];
    return FALSE;
}

- (BOOL) connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

//Converts password into md5
- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

/*-(IBAction)ForgotPasswordPressed:(id)sender
{
    //get new login credentials using API
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Functionality Under Process" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}*/

#pragma mark - class method
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; 
    
    CGRect rect = self.view.frame;
    if (movedUp)
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
    else
        rect.origin.y = 0.0;
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

@end
