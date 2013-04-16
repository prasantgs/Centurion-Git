//
//  SettingsPopViewController.m
//  Centurion
//
//  Created by c on 11/19/12.
//
//

#import "SettingsPopViewController.h"
#import "LoginViewController.h"

@interface SettingsPopViewController ()

@end

@implementation SettingsPopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)LogoutBtn_pressed:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CheckLogout" object:nil];
}

-(IBAction)syncBtn_pressed:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CheckSync" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
