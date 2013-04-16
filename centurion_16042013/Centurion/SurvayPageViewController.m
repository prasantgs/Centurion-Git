//
//  SurvayPageViewController.m
//  Centurion
//
//  Created by costrategix technologies on 25/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SurvayPageViewController.h"
#import "AddEstimatorViewController.h"
#import "CreateNewEstimateViewController.h"
#import "NSDate+Date_NSDate.h"
#import "AppDelegate.h"
#import "SKDatabase.h"
#import "SurveyCustomCell.h"
#import "SurvayInfoPopViewController.h"
#import "JSONKit.h"
#import "JSON.h"
#import "UICircularSlider.h"
#import "CurrentEstimatorTypeViewController.h"

@interface SurvayPageViewController ()
@property (unsafe_unretained, nonatomic) IBOutlet UISlider *slider;
@property (unsafe_unretained, nonatomic) IBOutlet UICircularSlider *circularSlider;
@property (unsafe_unretained, nonatomic) IBOutlet UICircularSlider *circularSlider_bg;
@end

@implementation SurvayPageViewController
@synthesize dict_Details;
@synthesize slider = _slider;
@synthesize circularSlider = _circularSlider;
@synthesize circularSlider_bg = _circularSlider_bg;

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
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
    self.navigationController.navigationBarHidden = TRUE;
    
    str_FailRate = @"48";
    
    txt_OtherProducts = [[UITextField alloc] init];
    txt_OtherProducts.delegate = self;
    
    segView.hidden = TRUE;
    lbl_CurrentEstTitle.hidden = TRUE;
    imgview_header.hidden = TRUE;
    tbl_EstimatorList.hidden = TRUE;
    
    heightForElement = 0;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
	segView.tintColor = [UIColor colorWithRed:.0 green:.6 blue:.0 alpha:1.0];
    
    lbl_LocationName.text = appDelegate.str_LocationName;
    
    str_EstimateID = [[[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate where create_dt_tm = '%@'",[dict_Details objectForKey:@"create_dt_tm"]]] objectAtIndex:0] objectForKey:@"id"];
    [str_EstimateID retain];
    
	if([[dict_Details objectForKey:@"status"] isEqualToString:@"newEstimate"])
    {
        lbl_EstimateName.text = [dict_Details objectForKey:@"name"];
        lbl_LastUpdatedTime.text = [NSString stringWithFormat:@"Updated %@",[NSDate formattedString:[dict_Details objectForKey:@"update_dt_tm"]]];
        lbl_EstimatedAmount.text = @"-$0";
        lbl_EstimatedAmount.textColor = [UIColor greenColor];
        
        [btn_AddEditEstimator addTarget:self action:@selector(AddEstimatePressed:) forControlEvents:UIControlEventTouchDown];
    }
    else
    {
        lbl_EstimateName.text = [dict_Details objectForKey:@"name"];
        lbl_LastUpdatedTime.text = [NSString stringWithFormat:@"Updated %@",[NSDate formattedString:[dict_Details objectForKey:@"update_dt_tm"]]];
        lbl_EstimatedAmount.text = @"-$0";
        lbl_EstimatedAmount.textColor = [UIColor greenColor];
        
        [btn_AddEditEstimator addTarget:self action:@selector(AddEstimatePressed:) forControlEvents:UIControlEventTouchDown];
        [self RefreshEstimatorList];
        [self refreshServerpage];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(EstimateEdited:) 
                                                 name:@"refreshDataSurvayPage"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateEstimatorList:) 
                                                 name:@"updateEstimatorList"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AddProductsMethod_toCompare:)
                                                 name:@"AddProducts"
                                               object:nil];
    
    tbl_EstimatorList.delegate = self;
    tbl_EstimatorList.dataSource = self;
    
    tbl_Survey.delegate = self;
    tbl_Survey.dataSource = self;

    tbl_Survey.backgroundColor = [UIColor clearColor];

    tbl_Analyze.delegate = self;
    tbl_Analyze.dataSource = self;
    
    tbl_Compare.delegate = self;
    tbl_Compare.dataSource = self;

    
    Btn_Survay = [UIButton buttonWithType:UIButtonTypeCustom];
    [Btn_Survay setBackgroundImage:[UIImage imageNamed:@"survey_tab_off.jpg"] forState:normal];
    [Btn_Survay setBackgroundImage:[UIImage imageNamed:@"survey_tab_on.jpg"] forState:UIControlStateSelected];
    Btn_Survay.frame = CGRectMake(805, 0, 64, 64);
    Btn_Survay.hidden = TRUE;
    [self.view addSubview:Btn_Survay];
    [Btn_Survay addTarget:self action:@selector(ToolBarButton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    Btn_Analyse = [UIButton buttonWithType:UIButtonTypeCustom];
    [Btn_Analyse setBackgroundImage:[UIImage imageNamed:@"cost_tab_off.jpg"] forState:normal];
    [Btn_Analyse setBackgroundImage:[UIImage imageNamed:@"cost_tab_on.jpg"] forState:UIControlStateSelected];
    Btn_Analyse.frame = CGRectMake(878, 0, 64, 64);
    Btn_Analyse.hidden = TRUE;
    [self.view addSubview:Btn_Analyse];
    [Btn_Analyse addTarget:self action:@selector(ToolBarButton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    /*
    Btn_Compare = [UIButton buttonWithType:UIButtonTypeCustom];
    [Btn_Compare setBackgroundImage:[UIImage imageNamed:@"compare_tab_off.jpg"] forState:normal];
    [Btn_Compare setBackgroundImage:[UIImage imageNamed:@"compare_tab_on.jpg"] forState:UIControlStateSelected];
    Btn_Compare.frame = CGRectMake(878, 0, 73, 64);
    Btn_Compare.hidden = TRUE;
    [self.view addSubview:Btn_Compare];
    [Btn_Compare addTarget:self action:@selector(ToolBarButton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    */
    Btn_info = [UIButton buttonWithType:UIButtonTypeCustom];
    [Btn_info setBackgroundImage:[UIImage imageNamed:@"info_tab_off.jpg"] forState:normal];
    [Btn_info setBackgroundImage:[UIImage imageNamed:@"info_tab_on.jpg"] forState:UIControlStateSelected];
    Btn_info.frame = CGRectMake(951, 0, 64, 64);
    Btn_info.hidden = TRUE;
    [self.view addSubview:Btn_info];
    [Btn_info addTarget:self action:@selector(ToolBarButton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    webview_analyze.delegate = self;

    [webview_analyze loadHTMLString:@"<script src='calc.js'></script>" baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
    
    txtFld_Survayothers.delegate = self;
    //[appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"insert into answer (estimator_instance_id, survey_asset_id, question_value_id, answer_value) values (%@, %@, '%@', '%@')", forTable:@"answer"];
    
    [self GetDefaultvaluesFrom_DB];
}
-(IBAction)ToolBarButton_Clicked:(UIButton *)sender
{
    for (UIButton *but1 in [self.view subviews]) {
        if ([but1 isKindOfClass:[UIButton class]] && ![but1 isEqual:sender]) {
            [but1 setSelected:NO];
        }
    }
    if (!sender.selected) {
        sender.selected = !sender.selected;
        
        [self removeAllViews];
        
        if (Btn_Survay.selected) {
            
            [self refreshServerpage];
            
        }else if (Btn_Analyse.selected){
            
            [self RefreshAnalyseList];
            
        }else if (Btn_info.selected){
            
            [self RefreshinfoList];
        }else if(Btn_Compare.selected){
            
            [self RefreshCompareData];
        }
        
    }
    
}
-(void)RefreshCompareData
{
    [self setUpComparePage];
    
    view_Compare.frame = CGRectMake(300, 66, 725, 685);
    
    [self.view addSubview:view_Compare];
    
    [self gettingAllDataFromSurveyPage];
}

-(void)setUpComparePage
{
    NSString *function = [[NSString alloc] initWithFormat: @"getComparisonMetaData(%d)", 0];
	NSString *jsonV = [webview_analyze stringByEvaluatingJavaScriptFromString:function];
    NSError *myError = nil;
    NSData *jsonData = [jsonV dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&myError];
    
}

-(void)RefreshAnalyseList{
    
    [self setUpAnalyzePage];
    
    view_Analyze.frame = CGRectMake(300, 66, 725, 685);

    [self.view addSubview:view_Analyze];
    
    [self gettingAllDataFromSurveyPage];

}
-(void)setUpAnalyzePage
{
    
    
    [self.circularSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventValueChanged];
	
    [self.circularSlider setMinimumValue:self.slider.minimumValue];
	[self.circularSlider_bg setMinimumValue:self.slider.minimumValue];
    
    [self.circularSlider setMaximumValue:self.slider.maximumValue];
    [self.circularSlider_bg setMaximumValue:self.slider.maximumValue];
    
    self.circularSlider.sliderStyle = UICircularSliderStyleCircle;
    self.circularSlider_bg.sliderStyle = UICircularSliderStyleCircle;
    self.circularSlider_bg.enabled = FALSE;
    self.slider.value = [str_FailRate floatValue];
    [self.circularSlider_bg setValue:self.slider.value];
    [self.circularSlider_bg setMinimumTrackTintColor:[UIColor greenColor]];
    [self.circularSlider_bg setMaximumTrackTintColor:[UIColor grayColor]];
    [self updateProgress:self.slider];
    
}
- (IBAction)updateProgress:(UISlider *)sender {
    
    if((int)sender.value <= 9.0)
        sender.value = 9.0;
//    else if((int)sender.value >= 91.0)
//        sender.value = 91.0;
    
    lbl_Percent.text = [NSString stringWithFormat:@"%d",(int)sender.value];
    
	[self.circularSlider setValue:sender.value];
	[self.slider setValue:sender.value];
    
    int sliderValue = floor(self.slider.value);
    [dict_surveyvalues setObject:[NSString stringWithFormat:@"%d",sliderValue] forKey:@"centurion_fail_rate"];
    
    NSString *jsonString = [dict_surveyvalues JSONStringWithOptions:JKSerializeOptionNone error:nil];
    
    NSString *function1 = [[NSString alloc] initWithFormat: @"doAnalysis('%@')", jsonString];
	NSString *jsonV1 = [webview_analyze stringByEvaluatingJavaScriptFromString:function1];
    NSError *myError1 = nil;
    NSData *jsonData1 = [jsonV1 dataUsingEncoding:NSUTF8StringEncoding];
    
    dict_DoAnalysis = [NSJSONSerialization JSONObjectWithData:jsonData1 options:NSJSONReadingMutableLeaves error:&myError1];
    [dict_DoAnalysis retain];
    lbl_Placeholder1.text = [[[dict_DoAnalysis objectForKey:[[[dict_placeholder1 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[dict_placeholder1 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:0];
    lbl_SubPlaceholder1.text = [[[dict_DoAnalysis objectForKey:[[[dict_placeholder1 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[dict_placeholder1 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:1];
    
    lbl_Placeholder2.text = [[[dict_DoAnalysis objectForKey:[[[dict_placeholder2 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[dict_placeholder2 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:0];
    lbl_SubPlaceholder2.text = [[[dict_DoAnalysis objectForKey:[[[dict_placeholder2 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[dict_placeholder2 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:1];
    
    lbl_Placeholder3.text = [[[dict_DoAnalysis objectForKey:[[[dict_placeholder3 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[dict_placeholder3 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:0];
    lbl_SubPlaceholder3.text = [[[dict_DoAnalysis objectForKey:[[[dict_placeholder3 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[dict_placeholder3 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:1];
    
    [tbl_Analyze reloadData];
    
}


-(void)RefreshinfoList{
    
    [webview_forinfo loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"info_page"ofType:@"jpg"]
                                                                 isDirectory:NO]]];
    view_Topics.frame = CGRectMake(300, 66, 725, 685);

    [self.view addSubview:view_Topics];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)GetDefaultvaluesFrom_DB{
    checkbox_arrTags = [[NSMutableArray alloc]init];
    checkbox_arrStr = [[NSMutableArray alloc]init];
    checkbox_arrStr_failRate = [[NSMutableArray alloc]init];
    dict_surveyvalues = [[NSMutableDictionary alloc]init];
    
    [dict_surveyvalues setObject:[NSNumber numberWithFloat:[str_FailRate floatValue]] forKey:@"fail_rate"];
    [dict_surveyvalues setObject:[NSNumber numberWithFloat:2.25] forKey:@"centurion_cost_per_unit"];
    [dict_surveyvalues setObject:[NSNumber numberWithFloat:9] forKey:@"centurion_fail_rate"];
    [dict_surveyvalues setObject:[NSNumber numberWithFloat:1.5] forKey:@"competitor_cost_per_unit"];

    for(int i=0 ;i < [arr_SurveyElements count] ; i ++)
    {
        
        if ([[[arr_SurveyElements objectAtIndex:i] objectForKey:@"type"] intValue] == 1 && [[[arr_SurveyElements objectAtIndex:i] objectForKey:@"estimator_id"]intValue] == [[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]intValue]) {
            
        }
        else if ([[[arr_SurveyElements objectAtIndex:i] objectForKey:@"estimator_id"]intValue] == [[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]intValue]){
            
            if ([[arr_SurveyElements objectAtIndex:i] objectForKey:@"reference_point_value"] == nil) {
                
                [dict_surveyvalues setObject:@"" forKey:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"variable_name"]];
                
                if ([[[arr_SurveyElements objectAtIndex:i]objectForKey:@"variable_name"]isEqualToString:@"competitor_product"]) {
                    
                    arr_variabletxt = [[NSMutableArray alloc]init];
                    arr_failRate = [[NSMutableArray alloc]init];
                    arr_selectedCheckBoxtxt = [[NSMutableArray alloc]init];
                    
                    for (int j=0; j<[arr_Survey_QustElements count]; j++) {
                        
                        if ([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"] intValue] == 2 && [[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"estimator_id"]intValue] == [[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]intValue]) {
                            
                            [arr_variabletxt addObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"value_text"]];
                            [arr_failRate addObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"fail_rate"]];
                        }
                        if ([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"] intValue] == 2 && [[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"default_flag"] intValue]==1 && [[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"estimator_id"]intValue] == [[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]intValue]) {
                            
                            [arr_selectedCheckBoxtxt addObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"value_text"] ];
                        }
                    }
                    [dict_surveyvalues setObject:arr_selectedCheckBoxtxt forKey:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"variable_name"]];
                    
                }else if ([[[arr_SurveyElements objectAtIndex:i]objectForKey:@"variable_name"]isEqualToString:@"current_secure_method"]){
                    
                    for (int j=0; j<[arr_Survey_QustElements count]; j++) {
                        
                        if ([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"] intValue] == 4 && [[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"default_flag"]intValue]==0 && [[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"estimator_id"]intValue] == [[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]intValue]){
                            
                            [dict_surveyvalues setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"value_text"] forKey:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"variable_name"]];
                            break;
                        }
                    }
                }else if ([[[arr_SurveyElements objectAtIndex:i]objectForKey:@"variable_name"]isEqualToString:@"current_wear_time"]){
                    
                    for (int j=0; j<[arr_Survey_QustElements count]; j++) {
                        
                        if ([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"] intValue] == 5 && [[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"default_flag"]intValue]==0 && [[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"estimator_id"]intValue] == [[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]intValue]){
                            
                            [dict_surveyvalues setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"value_text"] forKey:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"variable_name"]];
                            break;
                        }
                    }
                }
            }else{
                
                
                [dict_surveyvalues setObject:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"reference_point_value"] forKey:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"variable_name"]];
            }
        }
        
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
#pragma mark - 
#pragma mark Class Methods
-(void)EstimateEdited:(NSNotification *)notification
{
    NSDictionary *dict_temp = notification.userInfo;
    
    if(dict_Details)
    {
        [dict_Details autorelease];
        dict_Details = nil;
    }
    dict_Details = [[NSDictionary alloc] initWithDictionary:[[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate where create_dt_tm = '%@'",[dict_temp objectForKey:@"create_dt_tm"]]] objectAtIndex:0]];
    
    lbl_EstimateName.text = [dict_Details objectForKey:@"name"];
    lbl_LastUpdatedTime.text = [NSString stringWithFormat:@"Updated %@",[NSDate formattedString:[dict_Details objectForKey:@"update_dt_tm"]]];

   
}
-(void)removeAllViews
{
    if([self.view.subviews containsObject:view_Survey])
    {
        heightForElement = 0;
        [view_Survey removeFromSuperview];
    }
    if([self.view.subviews containsObject:view_Analyze])
    {
        [view_Analyze removeFromSuperview];
    }
    if([self.view.subviews containsObject:view_Topics])
    {
        [view_Topics removeFromSuperview];
    }
}
-(void)prepareSurveyView
{
//    [[scrl_Survey subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
//    arr_SurveyElements = 
    
}
 
#pragma mark - 
#pragma mark IBActions
-(IBAction)HomePressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)AddEstimatePressed:(id)sender
{
    AddEstimatorViewController *obj_AddEstimatorViewController = [[AddEstimatorViewController alloc] initWithNibName:@"AddEstimatorViewController" bundle:nil];
    //obj_AddEstimatorViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    obj_AddEstimatorViewController.str_EstimateID = str_EstimateID;
    //[self presentModalViewController:obj_AddEstimatorViewController animated:YES];
   // [obj_AddEstimatorViewController release];
    UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:obj_AddEstimatorViewController];
    [navi.view setFrame:CGRectMake(280,-100,450,700)];

    navi.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:navi animated:YES];
    [obj_AddEstimatorViewController release];//27 feb rel
    [navi release];
    obj_AddEstimatorViewController = nil;
    
    

}
-(void)updateEstimatorList:(NSNotification *)notification
{
    [self RefreshEstimatorList];
    [self refreshServerpage];
    [self GetDefaultvaluesFrom_DB];

}
-(void)RefreshEstimatorList
{
    tbl_EstimatorList.hidden = FALSE;
    
    if(arr_Estimator)
    {
        [arr_Estimator release];
        arr_Estimator = nil;
    }
    
    arr_Estimator = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select estimator.name as estimator_name, estimator.survey_js, estimator.chart_js, estimator.icon,estimator.id as estimator_id,estimator_instance.id from estimator, estimator_instance where estimator_instance.estimator_id = estimator.id and estimator_instance.estimate_id = %@ and estimator_instance.delete_flag = '0' ",str_EstimateID]]];
    [arr_Estimator retain];
    [tbl_EstimatorList reloadData];
    
}
-(void)refreshServerpage
{
    //select the row for newly added estimator
    if([arr_Estimator count] > 0)
    {
        selectedEstimator = [arr_Estimator count] - 1;
        //NSIndexPath* selectedCellIndexPath= [NSIndexPath indexPathForRow:selectedEstimator inSection:0];
        //[tbl_EstimatorList selectRowAtIndexPath:selectedCellIndexPath animated:false scrollPosition:UITableViewScrollPositionMiddle];
        
        [self removeAllViews];
        if(arr_SurveyElements)
        {
            [arr_SurveyElements release];
            arr_SurveyElements = nil;
        }
        arr_SurveyElements = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from survey_assets where estimator_id = %@ order by order_sequence",[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]]]];;
        [arr_SurveyElements retain];
        [tbl_Survey reloadData];
        tbl_Survey.backgroundColor = [UIColor clearColor];
        
        view_Survey.frame = CGRectMake(300, 66, 725, 685);
        
        if (Btn_Survay.selected) {
            
            [self.view addSubview:view_Survey];
        }
                
        if(arr_EstimatorInstance)
        {
            [arr_EstimatorInstance release];
            arr_EstimatorInstance = nil;
        }
        arr_EstimatorInstance = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimator_instance where estimate_id = %@ and estimator_id = %@",str_EstimateID,[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]]]];
        [arr_SurveyElements retain];

        if(arr_Survey_QustElements)
        {
            [arr_Survey_QustElements release];
            arr_Survey_QustElements = nil;
        }
        arr_Survey_QustElements = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from question_value where estimator_id = %@ order by order_number",[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]]]];
        
        [arr_Survey_QustElements retain];        
        
        NSArray *arr = [appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from answer where estimator_instance_id = %@",[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"id"]]];
        
        if([arr count] > 0)
        {
            [self UpDatedValuesFrom_answertblDB];
        }
        else
        {
            [self insertingValues_toAnswersDB];
            [self UpDatedValuesFrom_answertblDB];
        }
    }
    else if ([arr_Estimator count] == 0)
    {
        selectedEstimator = -1;
        [self removeAllViews];
    }

}

-(void)insertingValues_toAnswersDB{
    
    NSMutableArray *arr_answers = [[NSMutableArray alloc]init];
    for (int i = 1; i<[arr_SurveyElements count]; i++) {
        if ([[[arr_SurveyElements objectAtIndex:i] objectForKey:@"type"]intValue] == 2 && [[[arr_SurveyElements objectAtIndex:i] objectForKey:@"estimator_id"]intValue] == [[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]intValue] ) {
            
            for (int j=0; j<[arr_Survey_QustElements count]; j++) {
                
                if ([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"]intValue] == 2 && [[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"estimator_id"]intValue] == [[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]intValue]) {
                    
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"] forKey:@"survey_asset_id"];
                    [dict setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"id"] forKey:@"question_value_id"];
                    [dict setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"default_flag"] forKey:@"answer_value"];
                    [dict setObject:[[arr_EstimatorInstance objectAtIndex:0] objectForKey:@"id"] forKey:@"estimator_instance_id"];
                    [arr_answers addObject:dict];
                }
            }
        }else if ([[[arr_SurveyElements objectAtIndex:i] objectForKey:@"type"]intValue] == 4 && [[[arr_SurveyElements objectAtIndex:i] objectForKey:@"estimator_id"]intValue] == [[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]intValue]) {
            
            for (int j=0; j<[arr_Survey_QustElements count]; j++) {
                
                if ([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"]intValue] == 4 && [[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"estimator_id"]intValue] == [[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]intValue] ) {
                    
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"] forKey:@"survey_asset_id"];
                    [dict setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"id"] forKey:@"question_value_id"];
                    [dict setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"default_flag"] forKey:@"answer_value"];
                    [dict setObject:[[arr_EstimatorInstance objectAtIndex:0] objectForKey:@"id"] forKey:@"estimator_instance_id"];
                    [arr_answers addObject:dict];
                    
                }
            }
        }else if ([[[arr_SurveyElements objectAtIndex:i] objectForKey:@"type"]intValue] == 5 && [[[arr_SurveyElements objectAtIndex:i] objectForKey:@"estimator_id"]intValue] == [[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]intValue]) {
            
            for (int j=0; j<[arr_Survey_QustElements count]; j++) {
                
                if ([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"]intValue] == 5 && [[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"estimator_id"]intValue] == [[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]intValue] ) {
                    
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"] forKey:@"survey_asset_id"];
                    [dict setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"id"] forKey:@"question_value_id"];
                    [dict setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"default_flag"] forKey:@"answer_value"];
                    [dict setObject:[[arr_EstimatorInstance objectAtIndex:0] objectForKey:@"id"] forKey:@"estimator_instance_id"];
                    [arr_answers addObject:dict];
                    
                }
            }
        }else if ([[[arr_SurveyElements objectAtIndex:i] objectForKey:@"estimator_id"]intValue] == [[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]intValue]){
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setObject:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"id"] forKey:@"survey_asset_id"];
            [dict setObject:@"" forKey:@"question_value_id"];
            if ([[arr_SurveyElements objectAtIndex:i] objectForKey:@"reference_point_value"] == nil) {
                [dict setObject:@"" forKey:@"answer_value"];
            }else{
                [dict setObject:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"reference_point_value"] forKey:@"answer_value"];
            }
            [dict setObject:[[arr_EstimatorInstance objectAtIndex:0] objectForKey:@"id"] forKey:@"estimator_instance_id"];
            [arr_answers addObject:dict];
        }
    }
    [appDelegate.sk insertIntoAnswer:arr_answers];
}

-(void)UpDateValuesIn_AnswerDB:(NSString *)str_Answer_value :(NSString *)str_Estimator_id :(NSString *)str_Survey_id :(NSString *)str_Questionvalue_id
{
    
    
    [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"UPDATE answer SET answer_value = %@ where estimator_instance_id = %@ and survey_asset_id = %@ and question_value_id = %@",str_Answer_value,str_Estimator_id,str_Survey_id,str_Questionvalue_id] forTable:@"answer"];
    
    [self UpDatedValuesFrom_answertblDB];
}

-(void)UpDatedValuesFrom_answertblDB{
    
    if(arr_AnswerElements)
    {
        [arr_AnswerElements release];
        arr_AnswerElements = nil;
    }
    arr_AnswerElements = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from answer where estimator_instance_id = %@ order by id",[[arr_EstimatorInstance objectAtIndex:selectedEstimator] objectForKey:@"id"]]]];;
    [arr_AnswerElements retain];
    
}

-(void)EditEstimatePressed:(id)sender
{
}
-(IBAction)EditEstimateDetailsPressed:(id)sender
{
    CreateNewEstimateViewController *obj_CreateNewEstimateViewController = [[CreateNewEstimateViewController alloc] initWithNibName:@"CreateNewEstimateViewController" bundle:nil];
    obj_CreateNewEstimateViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    obj_CreateNewEstimateViewController.str_EstimateId = [dict_Details objectForKey:@"create_dt_tm"];
    obj_CreateNewEstimateViewController.str_FromSurvey = @"Survey";
    [self presentModalViewController:obj_CreateNewEstimateViewController animated:YES];
    [obj_CreateNewEstimateViewController release];
    obj_CreateNewEstimateViewController = nil;

}
-(IBAction)ForwardEstimatePressed:(id)sender;
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"View PDF",@"Email PDF",nil];
    action.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [action showFromRect:CGRectMake(btn_ForwardEstimate.center.x,btn_ForwardEstimate.center.y, 1, 1) inView:self.view animated:NO];
}
-(void)CheckBoxSelected:(id)sender
{
    SurveyCustomCell *cellsuperView = (SurveyCustomCell *)[sender superview];
    
    UIButton *btn = (UIButton *)sender;
    
            if (btn.selected)
            {
                btn.selected = FALSE;
                
                for (int i=0; i<[checkbox_arrTags count]; i++)
                {
                    if (btn.tag ==[[checkbox_arrTags objectAtIndex:i]intValue])
                    {
                        [checkbox_arrTags removeObjectAtIndex:i];
                        [checkbox_arrStr removeObjectAtIndex:i];
                        [checkbox_arrStr_failRate removeObjectAtIndex:i];
                    }
                }
            }
            else
            {
                btn.selected = TRUE;
                
                [checkbox_arrTags addObject:[NSString stringWithFormat:@"%d",btn.tag]];
                [checkbox_arrStr addObject:[arr_variabletxt objectAtIndex:btn.tag-1]];
                [checkbox_arrStr_failRate addObject:[arr_failRate objectAtIndex:btn.tag-1]];

            }

    if ([checkbox_arrStr_failRate count] > 0) {
        
        int k = [[checkbox_arrStr_failRate objectAtIndex:0]intValue];
        for (int i = 1; i < [checkbox_arrStr_failRate count]; i++){
            
            if([[checkbox_arrStr_failRate objectAtIndex:i]intValue] < k){
                
                k = [[checkbox_arrStr_failRate objectAtIndex:i]intValue];
            }
        }
        if (k < [str_FailRate intValue]) {
            [dict_surveyvalues setObject:[NSNumber numberWithFloat:[str_FailRate intValue]] forKey:@"fail_rate"];
        }else{
            [dict_surveyvalues setObject:[NSNumber numberWithFloat:k] forKey:@"fail_rate"];
        }
    }
    
    for (int i = 0; i < [arr_SurveyElements count]; i++) {
        
        if ([[[arr_SurveyElements objectAtIndex:i] objectForKey:@"variable_name"] isEqualToString:@"competitor_product"]) {
            
            if ([txtFld_Survayothers.text length] > 0) {
                
                for (int j = 0; j < [checkbox_arrStr count]; j++) {
                    
                    if ([[checkbox_arrStr objectAtIndex:j] isEqualToString:@"Other"]) {
                        
                        [checkbox_arrStr replaceObjectAtIndex:j withObject:txtFld_Survayothers.text];
                    }
                }
            }
            [dict_surveyvalues setObject:checkbox_arrStr forKey:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"variable_name"]];
            
        }
    }
    
    
    for (int j=0; j<[arr_AnswerElements count]; j++) {
        
        if([[[arr_AnswerElements objectAtIndex:j] objectForKey:@"survey_asset_id"]intValue] ==  [[[arr_SurveyElements objectAtIndex:cellsuperView.tag] objectForKey:@"id"]intValue] && [[[arr_AnswerElements objectAtIndex:j] objectForKey:@"question_value_id"]intValue] == btn.tag)
        {
            if (btn.selected) {
                
                [self UpDateValuesIn_AnswerDB:[NSString stringWithFormat:@"1"]:[[arr_AnswerElements objectAtIndex:j]objectForKey:@"estimator_instance_id"] :[[arr_SurveyElements objectAtIndex:cellsuperView.tag]objectForKey:@"id"] :[[arr_AnswerElements objectAtIndex:j] objectForKey:@"question_value_id"]];

            }else{
                                
                [self UpDateValuesIn_AnswerDB:[NSString stringWithFormat:@"0"]:[[arr_AnswerElements objectAtIndex:j]objectForKey:@"estimator_instance_id"]:[[arr_SurveyElements objectAtIndex:cellsuperView.tag]objectForKey:@"id"] :[[arr_AnswerElements objectAtIndex:j] objectForKey:@"question_value_id"]];
            }
            break;
        }
    }
}


-(void)AddProductsMethod_toCompare:(NSNotification *)notification{
    
    NSMutableDictionary *dict_Compare = [[[NSMutableDictionary alloc] initWithDictionary:notification.userInfo] autorelease];
    
    NSString *jsonString = [dict_Compare JSONStringWithOptions:JKSerializeOptionNone error:nil];
    
    NSString *function1 = [[NSString alloc] initWithFormat: @"doAnalysis('%@')", jsonString];
	NSString *jsonV1 = [webview_analyze stringByEvaluatingJavaScriptFromString:function1];
    NSError *myError1 = nil;
    NSData *jsonData1 = [jsonV1 dataUsingEncoding:NSUTF8StringEncoding];
    Dict_JSONCompare = [NSJSONSerialization JSONObjectWithData:jsonData1 options:NSJSONReadingMutableLeaves error:&myError1];
    
}


-(void)gettingAllDataFromSurveyPage{
    
    
    NSString *function = [[NSString alloc] initWithFormat: @"getAnalysisMetaData(%d)", 0];
	NSString *jsonV = [webview_analyze stringByEvaluatingJavaScriptFromString:function];
    NSError *myError = nil;
    NSData *jsonData = [jsonV dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&myError];
    
    dict_placeholder1 = [JSON objectForKey:@"cost_savings_placeholder_1"];
    [dict_placeholder1 retain];
    
    dict_placeholder2 = [JSON objectForKey:@"cost_savings_placeholder_2"];
    [dict_placeholder2 retain];
    
    dict_placeholder3 = [JSON objectForKey:@"cost_savings_placeholder_3"];
    [dict_placeholder3 retain];
    
    lbl_PlaceholderText1.text = [dict_placeholder1 objectForKey:@"label"];
    lbl_PlaceholderText2.text = [dict_placeholder2 objectForKey:@"label"];
    lbl_PlaceholderText3.text = [dict_placeholder3 objectForKey:@"label"];
    
    
    
    analysisTableDict = [JSON objectForKey:@"analysis_table"];
    [analysisTableDict retain];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithBool:0] forKey:@"current_secure_method"];
    [dict setObject:[NSNumber numberWithBool:0] forKey:@"current_wear_time"];
    [dict setObject:[NSNumber numberWithFloat:1.50] forKey:@"competitor_cost_per_unit"];
    [dict setObject:[NSNumber numberWithFloat:1000] forKey:@"current_piv_count_per_month"];
    [dict setObject:[NSNumber numberWithFloat:23] forKey:@"current_overall_cost"];
    [dict setObject:[NSNumber numberWithFloat:2.0] forKey:@"current_restart_count"];
    [dict setObject:[NSNumber numberWithFloat:20.0] forKey:@"current_restart_time"];
    [dict setObject:[NSNumber numberWithFloat:2.0] forKey:@"hai_per_month"];
    [dict setObject:[NSNumber numberWithFloat:2.25] forKey:@"centurion_cost_per_unit"];
    [dict setObject:[NSNumber numberWithFloat:0.48] forKey:@"fail_rate"];
    [dict setObject:[NSNumber numberWithFloat:0.09] forKey:@"centurion_fail_rate"];
    NSArray *arr = [[NSArray alloc] initWithObjects:@"Tape",@"BardStatLock", nil];
    [dict setObject:arr forKey:@"competitor_product"];
    
    NSString *jsonString = [dict_surveyvalues JSONStringWithOptions:JKSerializeOptionNone error:nil];
    
    NSString *function1 = [[NSString alloc] initWithFormat: @"doAnalysis('%@')", jsonString];
	NSString *jsonV1 = [webview_analyze stringByEvaluatingJavaScriptFromString:function1];
    NSError *myError1 = nil;
    NSData *jsonData1 = [jsonV1 dataUsingEncoding:NSUTF8StringEncoding];
    
    dict_DoAnalysis = [NSJSONSerialization JSONObjectWithData:jsonData1 options:NSJSONReadingMutableLeaves error:&myError1];
    [dict_DoAnalysis retain];
    
    NSString *str = [[[dict_placeholder1 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:0];
    NSString *str1 = [[dict_DoAnalysis objectForKey:[[[dict_placeholder1 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[dict_placeholder1 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:1]];
    
    lbl_Placeholder1.text = [[[dict_DoAnalysis objectForKey:[[[dict_placeholder1 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[dict_placeholder1 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:0];
    lbl_SubPlaceholder1.text = [[[dict_DoAnalysis objectForKey:[[[dict_placeholder1 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[dict_placeholder1 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:1];
    
    lbl_Placeholder2.text = [[[dict_DoAnalysis objectForKey:[[[dict_placeholder2 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[dict_placeholder2 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:0];
    lbl_SubPlaceholder2.text = [[[dict_DoAnalysis objectForKey:[[[dict_placeholder2 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[dict_placeholder2 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:1];
    
    lbl_Placeholder3.text = [[[dict_DoAnalysis objectForKey:[[[dict_placeholder3 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[dict_placeholder3 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:0];
    lbl_SubPlaceholder3.text = [[[dict_DoAnalysis objectForKey:[[[dict_placeholder3 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[dict_placeholder3 objectForKey:@"value"] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:1];
    [tbl_Analyze reloadData];
}
#pragma mark - 
#pragma mark UIActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    //0 = view pdf
    //1 = email pdf
    if(buttonIndex == 0)
    {
    }
    else if(buttonIndex == 1)
    {
        
    }
}

#pragma mark -
#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == tbl_EstimatorList){
        
        return [arr_Estimator count];
        
    }else if (tableView == tbl_Survey){
        
        return [arr_SurveyElements count];
    }else if (tableView == tbl_Analyze){
        
        return [[analysisTableDict objectForKey:@"values"] count];
    }else if (tableView == tbl_Compare){
        return 6;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbl_EstimatorList)
    {
        return 80;
    }else if(tableView == tbl_Survey){
        
        if (indexPath.row == 1) {
            return 220;
        }else if(indexPath.row == 7){
            return 140;
        }
        else{
            return 100;
        }
    }else if(tableView == tbl_Analyze)
    {
        return 70;
    }else if(tableView == tbl_Compare)
    {
        return 50;
    }
    else
        return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(tableView == tbl_Analyze){
        return 20.0;
    }else if (tableView == tbl_Compare){
        return 70.0;
    }
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView == tbl_Analyze)
    {
        UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 724, 20)] autorelease];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:view.bounds];
        imgView.image = [UIImage imageNamed:@"background_black.jpg"];
        [view addSubview:imgView];
        
        UILabel *lbl1 = [[[UILabel alloc] initWithFrame:CGRectMake(40, 0, 140, 20)] autorelease];
        UILabel *lbl2 = [[[UILabel alloc] initWithFrame:CGRectMake(260, 0, 140, 20)] autorelease];
        UILabel *lbl3 = [[[UILabel alloc] initWithFrame:CGRectMake(390, 0, 140, 20)] autorelease];
        UILabel *lbl4 = [[[UILabel alloc] initWithFrame:CGRectMake(520, 0, 140, 20)] autorelease];
        
        lbl1.text = [[analysisTableDict objectForKey:@"columns"] objectAtIndex:0];
        lbl1.textAlignment = UITextAlignmentRight;
        lbl1.font = [UIFont boldSystemFontOfSize:10];
        lbl1.textColor = [UIColor grayColor];
        lbl1.backgroundColor = [UIColor clearColor];
        
        lbl2.text = [[analysisTableDict objectForKey:@"columns"] objectAtIndex:1];
        lbl2.textAlignment = UITextAlignmentRight;
        lbl2.font = [UIFont boldSystemFontOfSize:10];
        lbl2.textColor = [UIColor grayColor];
        lbl2.backgroundColor = [UIColor clearColor];
        
        lbl3.text = [[analysisTableDict objectForKey:@"columns"] objectAtIndex:2];
        lbl3.textAlignment = UITextAlignmentRight;
        lbl3.font = [UIFont boldSystemFontOfSize:10];
        lbl3.textColor = [UIColor grayColor];
        lbl3.backgroundColor = [UIColor clearColor];
        
        lbl4.text = [[analysisTableDict objectForKey:@"columns"] objectAtIndex:3];
        lbl4.textAlignment = UITextAlignmentRight;
        lbl4.font = [UIFont boldSystemFontOfSize:10];
        lbl4.textColor = [UIColor grayColor];
        lbl4.backgroundColor = [UIColor clearColor];
        
        [view addSubview:lbl1];
        [view addSubview:lbl2];
        [view addSubview:lbl3];
        [view addSubview:lbl4];
        
        return view;
    }else if (tableView == tbl_Compare){
        
        UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 724, 82)] autorelease];
        view.backgroundColor = [UIColor clearColor];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:view.bounds];
        imgView.image = [UIImage imageNamed:@"background_black.jpg"];
        
        UIImageView *imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(295, 30, 120, 52)];
        imgView1.image = [UIImage imageNamed:@"blue_button.png"];
        
        UIImageView *imgView2= [[UIImageView alloc] initWithFrame:CGRectMake(430, 30, 120, 52)];
        imgView2.image = [UIImage imageNamed:@"gray_button.png"];
        
        UILabel *lbl_SOR = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 52)] autorelease];
        lbl_SOR.textAlignment = UITextAlignmentCenter;
        lbl_SOR.text = @"SORBAVIEW SHIELD";
        lbl_SOR.font = [UIFont boldSystemFontOfSize:10];
        lbl_SOR.backgroundColor = [UIColor clearColor];
        lbl_SOR.textColor = [UIColor whiteColor];
        lbl_SOR.numberOfLines = 2;
        
        UILabel *lbl_YOURPRO = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 52)] autorelease];
        lbl_YOURPRO.textAlignment = UITextAlignmentCenter;
        lbl_YOURPRO.text = @"YOUR PRODUCTS(S)";
        lbl_YOURPRO.font = [UIFont boldSystemFontOfSize:10];
        lbl_YOURPRO.backgroundColor = [UIColor clearColor];
        lbl_YOURPRO.textColor = [UIColor whiteColor];
        lbl_YOURPRO.numberOfLines = 2;
        
        UILabel *lbl_diff = [[[UILabel alloc] initWithFrame:CGRectMake(560, 30, 120, 52)] autorelease];
        lbl_diff.textAlignment = UITextAlignmentCenter;
        lbl_diff.text = @"DIFFERENCE";
        lbl_diff.font = [UIFont boldSystemFontOfSize:10];
        lbl_diff.backgroundColor = [UIColor clearColor];
        lbl_diff.textColor = [UIColor whiteColor];
        
        [view addSubview:imgView];
        
        [imgView1 addSubview:lbl_SOR];
        [imgView2 addSubview:lbl_YOURPRO];

        [view addSubview:imgView1];
        [view addSubview:imgView2];
        [view addSubview:lbl_diff];


        return view;
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"%d%d",indexPath.section,indexPath.row];
    
    SurveyCustomCell *cell = (SurveyCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[SurveyCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.tag = indexPath.row;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.imgV_Estimator.hidden = TRUE;
    cell.lbl_EstimatorName.hidden = TRUE;
    cell.lbl_EstimatorSavings.hidden = TRUE;

    cell.lbl_Section.hidden = TRUE;
    cell.lbl_Label.hidden = TRUE;
    cell.lbl_HintText.hidden = TRUE;
    cell.btn_Radio1.hidden = TRUE;
    cell.btn_Radio2.hidden = TRUE;
    cell.lbl_RadioBtn1.hidden = TRUE;
    cell.lbl_RadioBtn2.hidden = TRUE;
    
    cell.lbl_Checkbox.hidden = TRUE;
    cell.lbl_Question.hidden = TRUE;
    cell.slider_Question.hidden = TRUE;
    cell.lbl_Answer.hidden = TRUE;
    cell.lbl_SliderMin.hidden = TRUE;
    cell.lbl_SliderMax.hidden = TRUE;

    cell.btn_info_tbl.hidden = TRUE;
    
    cell.img_SliderAvg.hidden = TRUE;
    
    // for analtze
    cell.lbl_AddCost_sect.hidden = TRUE;
    cell.lbl_CurrCost_sect.hidden = TRUE;
    cell.lbl_sub_CurrCostt_sect.hidden = TRUE;
    cell.lbl_AdjCost_sect.hidden = TRUE;
    cell.lbl_sub_AdjCost_sect.hidden = TRUE;
    cell.lbl_PoteSavings_sect.hidden = TRUE;
    cell.lbl_sub_PoteSavings_sect.hidden = TRUE;
    cell.slider_analyze_Question.hidden = TRUE;

    // for compare
    cell.lbl_CompareProducts.hidden = TRUE;
    cell.lbl_SorbaviewShields.hidden = TRUE;
    cell.lbl_YourProducts.hidden = TRUE;
    cell.lbl_Differences.hidden = TRUE;
    
    if(tableView == tbl_EstimatorList)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imgV_Estimator.hidden = FALSE;
        cell.lbl_EstimatorName.hidden = FALSE;
        cell.lbl_EstimatorSavings.hidden = FALSE;
        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_strip"]];
        if (cell.imgV_Estimator.image == [UIImage imageNamed:@"perip-icon_off"]) {
            cell.imgV_Estimator.image = [UIImage imageNamed:[[arr_Estimator objectAtIndex:indexPath.row] objectForKey:@"icon"]];
        }
        else
        {
            cell.imgV_Estimator.image = [UIImage imageNamed:@"perip-icon_off"];
        }
        cell.lbl_EstimatorName.text = [[arr_Estimator objectAtIndex:indexPath.row] objectForKey:@"estimator_name"];
        cell.lbl_EstimatorName.textColor = [UIColor blackColor];
    }
    else if(tableView == tbl_Survey)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 277, 58)];
//        av.backgroundColor = [UIColor clearColor];
//        av.opaque = NO;
//        av.image = [UIImage imageNamed:@"bar_chart_bg.png"];
//        cell.backgroundView = av;
         int type = [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"type"] intValue];
        switch (type) {
            case 1:
                cell.lbl_Section.hidden= FALSE;
                cell.lbl_Section.text = [[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"text"];
                break;
            case 2:
                cell.lbl_Question.hidden = FALSE;
                cell.lbl_Question.text = [[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"text"];
                
                cell.btn_info_tbl.hidden = FALSE;
                [cell.btn_info_tbl addTarget:self action:@selector(btn_info_tblPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                for (int i = 0; i<[arr_variabletxt count]; i++) {
                    
                                            
                        if(!btn_Checkbox[i])
                        {
                            btn_Checkbox[i] = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn_Checkbox[i].hidden = FALSE;
                            btn_Checkbox[i].tag = i+1 ;
                            [btn_Checkbox[i] setImage:[UIImage imageNamed:@"check_box_off.png"] forState:UIControlStateNormal];
                            [btn_Checkbox[i] setImage:[UIImage imageNamed:@"check_box_on.png"] forState:UIControlStateSelected];
                            btn_Checkbox[i].frame = CGRectMake(275, 20+(i*30), 20, 20);
                            [btn_Checkbox[i] addTarget:self action:@selector(CheckBoxSelected:) forControlEvents:UIControlEventTouchDown];
                            
                            for (int j=0; j<[arr_AnswerElements count]; j++) {
                                

                                if ([[[arr_AnswerElements objectAtIndex:j] objectForKey:@"question_value_id"]intValue] == i+1 && [[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_value"]intValue] == 1) {
                                    btn_Checkbox[i].selected = TRUE;
                                    [checkbox_arrTags addObject:[NSString stringWithFormat:@"%d",i+1]];
                                    [checkbox_arrStr addObject:[arr_variabletxt objectAtIndex:i]];
                                    [checkbox_arrStr_failRate addObject:[arr_failRate objectAtIndex:i]];
                                    break;
                                }

                            }
                            [cell addSubview:btn_Checkbox[i]];
                        }
                        UILabel *lbl_Checkbox = [[UILabel alloc] initWithFrame:CGRectMake(305, 20+(i*30), 300, 20)];
                        lbl_Checkbox.hidden = FALSE;
                        lbl_Checkbox.backgroundColor = [UIColor clearColor];
                        lbl_Checkbox.textColor = [UIColor grayColor];
                        lbl_Checkbox.textAlignment = UITextAlignmentLeft;
                        lbl_Checkbox.font = [UIFont boldSystemFontOfSize:14];
                        lbl_Checkbox.numberOfLines = 0;
                        lbl_Checkbox.text = [arr_variabletxt objectAtIndex:i] ;
                        [cell addSubview:lbl_Checkbox];
                        
                        if ([[arr_variabletxt objectAtIndex:i] isEqualToString:@"Other"]) {
                            if (!txtFld_Survayothers) {
                                txtFld_Survayothers = [[UITextField alloc]initWithFrame:CGRectMake(305, lbl_Checkbox.frame.origin.y+37, 200, 30)];
                                txtFld_Survayothers.backgroundColor = [UIColor blackColor];
                                [txtFld_Survayothers setBorderStyle:UITextBorderStyleRoundedRect];
                                txtFld_Survayothers.placeholder = @" Enter Other Name";
                                txtFld_Survayothers.text = @"Other Product";
                                txtFld_Survayothers.textColor = [UIColor grayColor];
                                txtFld_Survayothers.font = [UIFont boldSystemFontOfSize:14];
                                txtFld_Survayothers.delegate = self;
                                [cell addSubview:txtFld_Survayothers];
                                
                                txt_OtherProducts = txtFld_Survayothers;
                            }
                        }
            }
                
                if ([checkbox_arrStr_failRate count] > 0)
                {
                    
                    int k = [[checkbox_arrStr_failRate objectAtIndex:0]intValue];
                    for (int i = 1; i < [checkbox_arrStr_failRate count]; i++){
                        
                        if([[checkbox_arrStr_failRate objectAtIndex:i]intValue] < k){
                            
                            k = [[checkbox_arrStr_failRate objectAtIndex:i]intValue];
                        }
                    }
                    if (k < [str_FailRate intValue]) {
                        [dict_surveyvalues setObject:[NSNumber numberWithFloat:[str_FailRate intValue]] forKey:@"fail_rate"];
                    }else{
                        [dict_surveyvalues setObject:[NSNumber numberWithFloat:k] forKey:@"fail_rate"];
                    }
                }
                
                for (int i=0; i<[arr_SurveyElements count]; i++) {
                    if ([[[arr_SurveyElements objectAtIndex:i]objectForKey:@"variable_name"]isEqualToString:@"competitor_product"]) {
                        
                        [dict_surveyvalues setObject:checkbox_arrStr forKey:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"variable_name"]];
                    }
                }

                break;
            case 3:
                cell.lbl_Question.hidden = FALSE;
                cell.lbl_HintText.hidden = FALSE;
                cell.lbl_SliderMin.hidden = FALSE;
                cell.lbl_SliderMax.hidden = FALSE;
                cell.slider_Question.hidden = FALSE;
                cell.btn_info_tbl.hidden = FALSE;
                cell.lbl_Label.hidden = FALSE;

                cell.lbl_Question.text = [[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"text"];
                cell.lbl_HintText.text = [[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"hint_text"];
                cell.slider_Question.minimumValue = [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"min_value"] intValue];
                cell.slider_Question.maximumValue = [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"max_value"] intValue];
                cell.slider_Question.tag = indexPath.row;
                [cell.slider_Question addTarget:self action:@selector(SliderMoves:) forControlEvents:UIControlEventValueChanged];
                [cell.slider_Question addTarget:self action:@selector(SliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                [cell.slider_Question addTarget:self action:@selector(SliderTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
                [cell.btn_info_tbl addTarget:self action:@selector(btn_info_tblPressed:) forControlEvents:UIControlEventTouchUpInside];

                if([[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"units"] length] > 0)
                {
                    cell.lbl_SliderMin.text = [NSString stringWithFormat:@"%@ %@",[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"min_value"],[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"units"]];
                    
                    cell.lbl_SliderMax.text = [NSString stringWithFormat:@"%@ %@",[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"max_value"],[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"units"]];
                }
                else
                {
                    cell.lbl_SliderMin.text = [[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"min_value"];
                    cell.lbl_SliderMax.text = [[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"max_value"];
                }
                
                
                for (int j=0; j<[arr_AnswerElements count]; j++) {

                    if([[[arr_AnswerElements objectAtIndex:j] objectForKey:@"survey_asset_id"]intValue] ==  [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"id"]intValue])
                    {
                        cell.slider_Question.value = [[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_value"] floatValue];
                    }
                }
                cell.lbl_Label.text = [NSString stringWithFormat:@"%d ",(int)cell.slider_Question.value];

                break;
            case 4:
                
                cell.lbl_Question.hidden = FALSE;
                cell.btn_Radio1.hidden = FALSE;
                cell.btn_Radio2.hidden = FALSE;
                cell.lbl_RadioBtn1.hidden = FALSE;
                cell.lbl_RadioBtn2.hidden = FALSE;
                cell.btn_Radio1.selected = FALSE;
                cell.btn_Radio2.selected = FALSE;

                cell.lbl_Question.text = [[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"text"];
                [cell.btn_Radio1 addTarget:self action:@selector(RadioButton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.btn_Radio2 addTarget:self action:@selector(RadioButton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
                
                for (int j=0; j<[arr_Survey_QustElements count]; j++) {
                    
                    if ([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"] intValue] == 4){
                        
                        if ([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"order_number"] intValue] == 1) {
                            cell.lbl_RadioBtn1.text = [[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"value_text"];
                        }else{
                            cell.lbl_RadioBtn2.text = [[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"value_text"];
                        }
                    }
                }
                
                for (int j=0; j<[arr_AnswerElements count]; j++) {
                    
                    if([[[arr_AnswerElements objectAtIndex:j] objectForKey:@"survey_asset_id"]intValue] ==  [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"id"]intValue])
                    {
                        if ([[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_value"]intValue] == 1) {
                            cell.btn_Radio1.selected = FALSE;
                            cell.btn_Radio2.selected = TRUE;
                            
                            for (int i=0; i<[arr_SurveyElements count]; i++) {
                                if ([[[arr_SurveyElements objectAtIndex:i]objectForKey:@"variable_name"]isEqualToString:@"current_secure_method"]) {
                                    
                                    [dict_surveyvalues setObject:@"Yes" forKey:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"variable_name"]];
                                }
                            }
                            break;
                        }else{
                            cell.btn_Radio2.selected = FALSE;
                            cell.btn_Radio1.selected = TRUE;
                            
                            for (int i=0; i<[arr_SurveyElements count]; i++) {
                                if ([[[arr_SurveyElements objectAtIndex:i]objectForKey:@"variable_name"]isEqualToString:@"current_secure_method"]) {
                                    
                                    [dict_surveyvalues setObject:@"No" forKey:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"variable_name"]];
                                }
                            }
                            break;
                        }
                    }
                }
                break;
            case 5:
                
                cell.lbl_Question.hidden = FALSE;
                cell.btn_Radio1.hidden = FALSE;
                cell.btn_Radio2.hidden = FALSE;
                cell.lbl_RadioBtn1.hidden = FALSE;
                cell.lbl_RadioBtn2.hidden = FALSE;
                cell.btn_info_tbl.hidden = FALSE;
                cell.btn_Radio1.selected = FALSE;
                cell.btn_Radio2.selected = FALSE;
                
                cell.lbl_Question.text = [[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"text"];
                [cell.btn_Radio1 addTarget:self action:@selector(RadioButton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.btn_Radio2 addTarget:self action:@selector(RadioButton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.btn_info_tbl addTarget:self action:@selector(btn_info_tblPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                for (int j=0; j<[arr_Survey_QustElements count]; j++) {
                    
                    if ([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"] intValue] == 4){
                        
                        if ([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"order_number"] intValue] == 1) {
                            cell.lbl_RadioBtn1.text = [[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"value_text"];
                        }else{
                            cell.lbl_RadioBtn2.text = [[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"value_text"];
                        }
                    }
                }
                
                for (int j=0; j<[arr_AnswerElements count]; j++) {
                    
                    if([[[arr_AnswerElements objectAtIndex:j] objectForKey:@"survey_asset_id"]intValue] ==  [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"id"]intValue])
                    {
                        if ([[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_value"]intValue] == 1) {
                            cell.btn_Radio1.selected = FALSE;
                            cell.btn_Radio2.selected = TRUE;
                            
                            for (int i=0; i<[arr_SurveyElements count]; i++) {
                                if ([[[arr_SurveyElements objectAtIndex:i]objectForKey:@"variable_name"]isEqualToString:@"current_wear_time"]) {
                                    
                                    [dict_surveyvalues setObject:@"Yes" forKey:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"variable_name"]];
                                }
                            }
                            break;
                        }else{
                            cell.btn_Radio2.selected = FALSE;
                            cell.btn_Radio1.selected = TRUE;
                            
                            for (int i=0; i<[arr_SurveyElements count]; i++) {
                                if ([[[arr_SurveyElements objectAtIndex:i]objectForKey:@"variable_name"]isEqualToString:@"current_wear_time"]) {
                                    
                                    [dict_surveyvalues setObject:@"No" forKey:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"variable_name"]];
                                }
                            }
                            break;
                        }
                    }
                }

                break;
            case 6:
                
                cell.lbl_Question.hidden = FALSE;
                cell.lbl_SliderMin.hidden = FALSE;
                cell.lbl_SliderMax.hidden = FALSE;
                cell.slider_Question.hidden = FALSE;
                cell.btn_info_tbl.hidden = FALSE;
                cell.lbl_Label.hidden = FALSE;
                cell.img_SliderAvg.hidden = FALSE;
                
                CGRect frame = cell.slider_Question.bounds;
                
                int int_avg = [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"reference_point_value"] intValue];
                int int_max = [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"max_value"] intValue];
                int int_min = [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"min_value"] intValue];
            
                int pxl = ((int_avg-int_min) * frame.size.width)/(int_max-int_min);
                cell.img_SliderAvg.frame = CGRectMake(frame.size.width + pxl-20, 55, 40, 25);
                if (int_avg == 0) {
                    cell.img_SliderAvg.hidden = TRUE;
                }
                
                cell.lbl_Question.text = [[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"text"];
                cell.slider_Question.minimumValue = [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"min_value"] intValue];
                cell.slider_Question.maximumValue = [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"max_value"] intValue];
                cell.slider_Question.tag = indexPath.row;
                [cell.slider_Question addTarget:self action:@selector(SliderMoves:) forControlEvents:UIControlEventValueChanged];
                [cell.slider_Question addTarget:self action:@selector(SliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                [cell.slider_Question addTarget:self action:@selector(SliderTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
                
                if([[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"units"] length] > 0)
                {
                    cell.lbl_SliderMin.text = [NSString stringWithFormat:@"%@%@",[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"units"],[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"min_value"]];
                    
                    cell.lbl_SliderMax.text = [NSString stringWithFormat:@"%@%@",[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"units"],[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"max_value"]];
                }
                else
                {
                    cell.lbl_SliderMin.text = [[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"min_value"];
                    cell.lbl_SliderMax.text = [[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"max_value"];
                }
                
                for (int j=0; j<[arr_AnswerElements count]; j++) {
                    
                    if([[[arr_AnswerElements objectAtIndex:j] objectForKey:@"survey_asset_id"]intValue] ==  [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"id"]intValue])
                    {

                        cell.slider_Question.value = [[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_value"] floatValue];
                    }
                }

                cell.lbl_Label.text = [NSString stringWithFormat:@"%d ",(int)cell.slider_Question.value];
                [cell.btn_info_tbl addTarget:self action:@selector(btn_info_tblPressed:) forControlEvents:UIControlEventTouchUpInside];

                break;
            case 7:
                cell.lbl_Question.hidden = FALSE;
                cell.lbl_HintText.hidden = FALSE;
                cell.lbl_SliderMin.hidden = FALSE;
                cell.lbl_SliderMax.hidden = FALSE;
                cell.slider_Question.hidden = FALSE;
                cell.lbl_Label.hidden = FALSE;
                cell.btn_info_tbl.hidden = FALSE;
                cell.img_SliderAvg.hidden = FALSE;
                
                CGRect frame7 = cell.slider_Question.bounds;
                
                int int_avg7 = [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"reference_point_value"] intValue];
                int int_max7 = [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"max_value"] intValue];
                int int_min7 = [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"min_value"] intValue];
                int pxl7 = ((int_avg7-int_min7) * frame7.size.width)/(int_max7-int_min7);
                cell.img_SliderAvg.frame = CGRectMake(frame7.size.width + pxl7-20, 55, 40, 25);
                if (int_avg7 == 0) {
                    cell.img_SliderAvg.hidden = TRUE;
                }
                cell.lbl_Question.text = [[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"text"];
                cell.lbl_HintText.frame = CGRectMake(20, 62, 250, 80);
                cell.lbl_HintText.text = [[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"hint_text"];
                cell.slider_Question.minimumValue = [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"min_value"] intValue];
                cell.slider_Question.maximumValue = [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"max_value"] intValue];
                cell.slider_Question.tag = indexPath.row;
                [cell.slider_Question addTarget:self action:@selector(SliderMoves:) forControlEvents:UIControlEventValueChanged];
                [cell.slider_Question addTarget:self action:@selector(SliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                [cell.slider_Question addTarget:self action:@selector(SliderTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];

                if([[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"units"] length] > 0)
                {
                    cell.lbl_SliderMin.text = [NSString stringWithFormat:@"%@ %@",[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"min_value"],[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"units"]];
                    
                    cell.lbl_SliderMax.text = [NSString stringWithFormat:@"%@ %@",[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"max_value"],[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"units"]];
                }
                else
                {
                    cell.lbl_SliderMin.text = [[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"min_value"];
                    cell.lbl_SliderMax.text = [[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"max_value"];
                }
                for (int j=0; j<[arr_AnswerElements count]; j++) {
                    
                    if([[[arr_AnswerElements objectAtIndex:j] objectForKey:@"survey_asset_id"]intValue] ==  [[[arr_SurveyElements objectAtIndex:indexPath.row] objectForKey:@"id"]intValue])
                    {
                        cell.slider_Question.value = [[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_value"] floatValue];
                    }
                }

                cell.lbl_Label.text = [NSString stringWithFormat:@"%d ",(int)cell.slider_Question.value];
                [cell.btn_info_tbl addTarget:self action:@selector(btn_info_tblPressed:) forControlEvents:UIControlEventTouchUpInside];

                break;
                
            default:
                break;
        }
    }
    else if(tableView == tbl_Analyze)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.lbl_AddCost_sect.hidden = FALSE;
        cell.lbl_CurrCost_sect.hidden = FALSE;
        cell.lbl_sub_CurrCostt_sect.hidden = FALSE;
        cell.lbl_AdjCost_sect.hidden = FALSE;
        cell.lbl_sub_AdjCost_sect.hidden = FALSE;
        cell.lbl_PoteSavings_sect.hidden = FALSE;
        cell.lbl_sub_PoteSavings_sect.hidden = FALSE;
        cell.imageView.hidden = FALSE;
        
        cell.lbl_AddCost_sect.text = [[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:1];
        
        //        [[[dict_DoAnalysis objectForKey:[ objectAtIndex:1]] objectForKey:[ objectAtIndex:0]] objectAtIndex:0];
        
        NSString *name = [[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:2];//current_cost.unscheduled_restart
        NSArray *arr = [name componentsSeparatedByString:@"."];// 0 = current_cost and 1 = unscheduled_restart
        NSDictionary *dict1 = [dict_DoAnalysis objectForKey:[arr objectAtIndex:0]];
        //NSArray *arr2 = [dict1 objectForKey:[arr objectAtIndex:1]];
        
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:0]]];
        
        if([[dict1 objectForKey:[arr objectAtIndex:1]] isKindOfClass:[NSArray class]])
        {
            cell.lbl_CurrCost_sect.text = [[[dict_DoAnalysis objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:2] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:2] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:0];
            cell.lbl_sub_CurrCostt_sect.text = [[[dict_DoAnalysis objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:2] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:2] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:1];
            
            cell.lbl_AdjCost_sect.text = [[[dict_DoAnalysis objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:3] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:3] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:0];
            cell.lbl_sub_AdjCost_sect.text = [[[dict_DoAnalysis objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:3] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:3] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:1];
            
            cell.lbl_PoteSavings_sect.text = [[[dict_DoAnalysis objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:4] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:4] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:0];
            cell.lbl_sub_PoteSavings_sect.text = [[[dict_DoAnalysis objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:4] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:4] componentsSeparatedByString:@"."] objectAtIndex:1]] objectAtIndex:1];
            
        }
        else
        {
            cell.lbl_CurrCost_sect.text = [NSString stringWithFormat:@"%@",[[dict_DoAnalysis objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:2] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:2] componentsSeparatedByString:@"."] objectAtIndex:1]]];
            
            cell.lbl_AdjCost_sect.text = [NSString stringWithFormat:@"%@",[[dict_DoAnalysis objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:3] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:3] componentsSeparatedByString:@"."] objectAtIndex:1]]];
            
            cell.lbl_PoteSavings_sect.text = [NSString stringWithFormat:@"%@",[[dict_DoAnalysis objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:4] componentsSeparatedByString:@"."] objectAtIndex:0]] objectForKey:[[[[[analysisTableDict objectForKey:@"values"] objectAtIndex:indexPath.row] objectAtIndex:4] componentsSeparatedByString:@"."] objectAtIndex:1]]];
        }
    }else if (tableView == tbl_Compare){
        
        cell.lbl_CompareProducts.hidden = FALSE;
        cell.lbl_SorbaviewShields.hidden = FALSE;
        cell.lbl_YourProducts.hidden = FALSE;
        cell.lbl_Differences.hidden = FALSE;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbl_EstimatorList)
    {
        selectedEstimator = indexPath.row;
        
        heightForElement = 0;
        
        lbl_CurrentEstTitle.text = [[arr_Estimator objectAtIndex:indexPath.row] objectForKey:@"estimator_name"];
        
        if(arr_Estimator)
        {
            [arr_Estimator release];
            arr_Estimator = nil;
        }
        
        ////////////////////////////////
        arr_Estimator = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select estimator.name as estimator_name, estimator.survey_js, estimator.chart_js, estimator.icon,estimator.id as estimator_id,estimator_instance.id from estimator, estimator_instance where estimator_instance.estimator_id = estimator.id and estimator_instance.estimate_id = %@ and estimator_instance.delete_flag = '0' ",str_EstimateID]]];
        [arr_Estimator retain];
        
        [tbl_EstimatorList reloadData];
        
        SurveyCustomCell *thecell = (SurveyCustomCell *)[tableView cellForRowAtIndexPath:indexPath];
        thecell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue_bg_button.jpg"]];
        thecell.lbl_EstimatorName.textColor = [UIColor whiteColor];
        thecell.lbl_EstimatorSavings.textColor = [UIColor whiteColor];
        
        //select the row for newly added estimator
        if([arr_Estimator count] > 0)
        {
            selectedEstimator = [arr_Estimator count] - 1;
            
            [self removeAllViews];
            if(arr_SurveyElements)
            {
                [arr_SurveyElements release];
                arr_SurveyElements = nil;
            }
            arr_SurveyElements = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from survey_assets where estimator_id = %@ order by order_sequence",[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]]]];;
            [arr_SurveyElements retain];
            [tbl_Survey reloadData];
            tbl_Survey.backgroundColor = [UIColor clearColor];

            view_Survey.frame = CGRectMake(300, 66, 725, 685);
             [self.view addSubview:view_Survey];
            
        }
        else if ([arr_Estimator count] == 0)
        {
            selectedEstimator = -1;
            [self removeAllViews];
        }

        
        segView.hidden = NO;
        Btn_Survay.hidden = FALSE;
        Btn_Survay.selected = TRUE;
        Btn_Analyse.hidden = FALSE;
        Btn_Analyse.selected = FALSE;
        Btn_Compare.hidden = FALSE;
        Btn_Compare.selected = FALSE;
        Btn_info.hidden = FALSE;
        Btn_info.selected = FALSE;

        lbl_CurrentEstTitle.hidden = NO;
        imgview_header.hidden = NO;
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tbl_Survey || tableView == tbl_Analyze)
        return UITableViewCellEditingStyleNone;
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbl_EstimatorList)
    {
        [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"update estimator_instance set delete_flag = '1' where id = %@",[[arr_Estimator objectAtIndex:indexPath.row] objectForKey:@"id"]] forTable:@"estimator_instance"];
        
        
        segView.hidden = TRUE;
        Btn_Survay.hidden = TRUE;
        Btn_Analyse.hidden = TRUE;
        Btn_info.hidden = TRUE;

        lbl_CurrentEstTitle.hidden = TRUE;
        imgview_header.hidden = TRUE;
        
        [self RefreshEstimatorList];
        [self refreshServerpage];
    }
}
/*
-(void)UpDateSurvey_Dictionary{
    for (int i=0; i<[arr_SurveyElements]; i++) {
        if ([[[arr_SurveyElements objectAtIndex:i]objectForKey:@"variable_name"]isEqualToString:@"competitor_product"]) {
            <#statements#>
        }
    }
}
*/

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField;{
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;{
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}
-(void)SliderMoves:(UISlider *)slide{
    
    SurveyCustomCell *superViewOfSlider = (SurveyCustomCell *)[slide superview];
    superViewOfSlider.lbl_Label.text = [NSString stringWithFormat:@"%d ",(int)slide.value];
    
    [dict_surveyvalues setObject:[NSNumber numberWithInt:(int)slide.value] forKey:[[arr_SurveyElements objectAtIndex:slide.tag] objectForKey:@"variable_name"]];
}

-(IBAction)SliderTouchUpInside:(UISlider *)sender{
    SurveyCustomCell *superViewOfSlider = (SurveyCustomCell *)[sender superview];
    
    
    [self UpDateValuesIn_AnswerDB:[NSString stringWithFormat:@"%d",(int)sender.value] :[[arr_AnswerElements objectAtIndex:superViewOfSlider.tag]objectForKey:@"estimator_instance_id"]:[[arr_SurveyElements objectAtIndex:superViewOfSlider.tag]objectForKey:@"id"] :@"0"];

}

-(IBAction)SliderTouchUpOutSide:(UISlider *)sender{
    SurveyCustomCell *superViewOfSlider = (SurveyCustomCell *)[sender superview];
    
    
    [self UpDateValuesIn_AnswerDB:[NSString stringWithFormat:@"%d",(int)sender.value] :[[arr_AnswerElements objectAtIndex:superViewOfSlider.tag]objectForKey:@"estimator_instance_id"]:[[arr_SurveyElements objectAtIndex:superViewOfSlider.tag]objectForKey:@"id"] :@"0"];
}
-(IBAction)RadioButton_Clicked:(UIButton *)sender
{
    SurveyCustomCell *cellsuperView = (SurveyCustomCell *)[sender superview];
    
    for (UIButton *but in [cellsuperView subviews]) {
        if ([but isKindOfClass:[UIButton class]] && ![but isEqual:sender]) {
            [but setSelected:NO];
        }
    }
    if (!sender.selected) {
        sender.selected = !sender.selected;
        
        for (int j=0; j<[arr_Survey_QustElements count]; j++) {
            
            
            if ([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"] intValue] == [[[arr_SurveyElements objectAtIndex:cellsuperView.tag] objectForKey:@"id"]intValue] && [[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"default_flag"] intValue] == sender.tag){
                
                [dict_surveyvalues setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"value_text"] forKey:[[arr_SurveyElements objectAtIndex:cellsuperView.tag] objectForKey:@"variable_name"]];
                break;
            }
        }
        
        for (int p=0; p<[arr_AnswerElements count]; p++) {
            
            if([[[arr_AnswerElements objectAtIndex:p] objectForKey:@"survey_asset_id"]intValue] ==  [[[arr_SurveyElements objectAtIndex:cellsuperView.tag] objectForKey:@"id"]intValue])
            {
                    if (sender.tag == 0) {

                    [self UpDateValuesIn_AnswerDB:[NSString stringWithFormat:@"1"] :[[arr_AnswerElements objectAtIndex:p]objectForKey:@"estimator_instance_id"] :[[arr_SurveyElements objectAtIndex:cellsuperView.tag]objectForKey:@"id"] :[[arr_AnswerElements objectAtIndex:p] objectForKey:@"question_value_id"]];
                    
                    [self UpDateValuesIn_AnswerDB:[NSString stringWithFormat:@"0"] :[[arr_AnswerElements objectAtIndex:p]objectForKey:@"estimator_instance_id"] :[[arr_SurveyElements objectAtIndex:cellsuperView.tag]objectForKey:@"id"] :[[arr_AnswerElements objectAtIndex:p+1] objectForKey:@"question_value_id"]];
                    break;
                }else{
                    [self UpDateValuesIn_AnswerDB:[NSString stringWithFormat:@"0"] :[[arr_AnswerElements objectAtIndex:p]objectForKey:@"estimator_instance_id"] :[[arr_SurveyElements objectAtIndex:cellsuperView.tag]objectForKey:@"id"] :[[arr_AnswerElements objectAtIndex:p] objectForKey:@"question_value_id"]];
                    
                    [self UpDateValuesIn_AnswerDB:[NSString stringWithFormat:@"1"] :[[arr_AnswerElements objectAtIndex:p]objectForKey:@"estimator_instance_id"] :[[arr_SurveyElements objectAtIndex:cellsuperView.tag]objectForKey:@"id"] :[[arr_AnswerElements objectAtIndex:p+1] objectForKey:@"question_value_id"]];
                    break;
                }
            }
        }

    }
}
-(void)btn_info_tblPressed:(id)sender
{
    UIButton *btn = (UIButton *)sender;

    if(!obj_SurvayInfoPopView)
    {
        obj_SurvayInfoPopView= [[SurvayInfoPopViewController alloc] initWithNibName:@"SurvayInfoPopViewController" bundle:nil];
        popoverController = [[[UIPopoverController alloc] initWithContentViewController:obj_SurvayInfoPopView] retain];
    }
    
    [popoverController setPopoverContentSize:CGSizeMake(400, 300)];
        
    [popoverController presentPopoverFromRect:btn.frame inView:[btn superview] permittedArrowDirections:UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown animated:YES];

}
-(IBAction)AddProductsPressed:(id)sender
{
    /*CurrentEstimatorTypeViewController *obj_CurrentEstimatorTypeViewController = [[CurrentEstimatorTypeViewController alloc] initWithNibName:@"CurrentEstimatorTypeViewController" bundle:nil];
    obj_CurrentEstimatorTypeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    //obj_CurrentEstimatorTypeViewController.str_EstimateID = str_EstimateID;
    [self presentModalViewController:obj_CurrentEstimatorTypeViewController animated:YES];
    [obj_CurrentEstimatorTypeViewController release];*/
    
       
    
    CurrentEstimatorTypeViewController *obj_CurrentEstimatorTypeViewController = [[CurrentEstimatorTypeViewController alloc] initWithNibName:@"CurrentEstimatorTypeViewController" bundle:nil];
    obj_CurrentEstimatorTypeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:obj_CurrentEstimatorTypeViewController animated:YES];
    [obj_CurrentEstimatorTypeViewController release];
    obj_CurrentEstimatorTypeViewController = nil;

}
@end
