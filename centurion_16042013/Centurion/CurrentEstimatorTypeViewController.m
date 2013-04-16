//
//  CurrentEstimatorTypeViewController.m
//  Centurion
//
//  Created by c on 11/15/12.
//
//

#import "CurrentEstimatorTypeViewController.h"

@interface CurrentEstimatorTypeViewController ()

@end

@implementation CurrentEstimatorTypeViewController
@synthesize str_CurEstNavTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
  /*  UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonSystemItemAction target:self action:@selector(BackPressed:)];
    self.navigationItem.leftBarButtonItem = btnCancel;
    [btnCancel release];
    
    self.navigationItem.title = str_CurEstNavTitle;*/
    
    UIButton  *btn_Radio1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_Radio1 setBackgroundImage:[UIImage imageNamed:@"radio_button-grey-off.png"] forState:normal];
    [btn_Radio1 setBackgroundImage:[UIImage imageNamed:@"radio_button-white.png"] forState:UIControlStateSelected];
    btn_Radio1.frame = CGRectMake(326, 97, 30, 30);
    btn_Radio1.tag = 0;
    [self.view addSubview:btn_Radio1];
    [btn_Radio1 addTarget:self action:@selector(RadioButton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton  *btn_Radio2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_Radio2 setBackgroundImage:[UIImage imageNamed:@"radio_button-grey-off.png"] forState:normal];
    [btn_Radio2 setBackgroundImage:[UIImage imageNamed:@"radio_button-white.png"] forState:UIControlStateSelected];
    btn_Radio2.frame = CGRectMake(326, 138, 30, 30);
    btn_Radio2.tag = 1;
    [self.view addSubview:btn_Radio2];
    [btn_Radio2 addTarget:self action:@selector(RadioButton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    btn_Radio2.selected = TRUE;
    
    //str_ProductType = [[NSString alloc]init];
    str_ProductType = @"kit";
}

-(IBAction)BackPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)CancelPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)SaveButtonPressed:(id)sender
{
    
    NSMutableDictionary *dict_pro = [[NSMutableDictionary alloc]init];
    [dict_pro setObject:str_ProductType forKey:@"CenturionProductType"];
    [dict_pro setObject:[txt_centurionProCost.text stringByReplacingOccurrencesOfString:@"$" withString:@""] forKey:@"CenturionProductCost"];
    [dict_pro setObject:[txt_currentProCost.text stringByReplacingOccurrencesOfString:@"$" withString:@""] forKey:@"CurrentProductType"];
    [dict_pro setObject:[txt_hourlyPVI.text stringByReplacingOccurrencesOfString:@"$" withString:@""] forKey:@"HourlyPVI"];
    [self dismissModalViewControllerAnimated:YES];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddProducts" object:self userInfo:dict_pro];
}
-(IBAction)RadioButton_Clicked:(UIButton *)sender
{
    //UIButton *btn = (UIButton *)sender;
    for (UIButton *but in [self.view subviews]) {
        if ([but isKindOfClass:[UIButton class]] && ![but isEqual:sender]) {
            [but setSelected:NO];
        }
    }
    if (!sender.selected) {
        sender.selected = !sender.selected;
        
        if (sender.tag == 0) {
            str_ProductType = @"single strile item";
        }else{
            str_ProductType = @"kit";
        }
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
