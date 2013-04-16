//
//  SurveyViewController.m
//  Centurion
//
//  Created by c on 12/13/12.
//
//

#import "SurveyViewController.h"
#import "SKDatabase.h"
#import "AppDelegate.h"
#import "SurveyTableCustomCell.h"
#import "NSDate+Date_NSDate.h"
#import "JSONKit.h"
#import "JSON.h"
#import "UICircularSlider.h"
#import "ViewPDFViewController.h"
#import "CreateNewEstimateViewController.h"
#import "NDHTMLtoPDF.h"
#import "QuartzCore/QuartzCore.h"
#import "AddEstimatorViewController.h"
#import "NSString+HTML.h"

@interface SurveyViewController ()
@property (unsafe_unretained, nonatomic) IBOutlet UISlider *slider;
@property (unsafe_unretained, nonatomic) IBOutlet UICircularSlider *circularSlider;
@property (unsafe_unretained, nonatomic) IBOutlet UICircularSlider *circularSlider_bg;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *view_forCircularSlider ;

@end

@implementation SurveyViewController
@synthesize dict_Details;
@synthesize slider = _slider;
@synthesize circularSlider = _circularSlider;
@synthesize circularSlider_bg = _circularSlider_bg;
@synthesize sliderColor = _sliderColor;
@synthesize PDFCreator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc{
    
    [super dealloc];
    [arr_EstimatorInstanceRecords release];
    arr_EstimatorInstanceRecords = nil;
    [arr_Estimator release];
    arr_Estimator = nil;
    [arr_SurveyElements release];
    arr_SurveyElements = nil;
    [arr_EstimatorInstance release];
    arr_EstimatorInstance = nil;
    [arr_Survey_QustElements release];
    arr_Survey_QustElements = nil;
    [arr_AnswerElements release];
    arr_AnswerElements = nil;
    
    [dict_surveyvalues_forJS release];

    [arr_selectedCheckBoxtxt release];
    arr_selectedCheckBoxtxt = nil;
    [scrollViewForQus_Horizontal release];
    [txtFld_Survayothers release];
    [lbl_SlideTitle release];
    [img_lineSeperator_1 release];
    [lbl_DiscriptionTitle release];
    [img_lineSeperator_2 release];
    [lbl_Question release];
    [TxtView_Questionis release];
    [lbl_Checkbox release];
    [img_lineSeperator_3 release];
    [lbl_SliderMinValue release];
    [lbl_SliderMaxValue release];
    [lbl_Reference release];
    [TxtView_Referencesis release];
    [img_lineSeperator_4 release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isFirstTimeCosts = TRUE;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationController.navigationBarHidden = TRUE;
    
    self.sliderColor = [UIColor colorWithRed:(132/255.f) green:(180/255.f) blue:(0/255.f) alpha:1.0f];
    
    str_EstimateID = [[[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate where create_dt_tm = '%@'",[dict_Details objectForKey:@"create_dt_tm"]]] objectAtIndex:0] objectForKey:@"id"];
    [str_EstimateID retain];
    
    if([[dict_Details objectForKey:@"status"] isEqualToString:@"newEstimate"])
    {
        lbl_LocationName.text = [dict_Details objectForKey:@"name"];
        lbl_LastUpdatedTime.text = [NSString stringWithFormat:@"Updated %@",[NSDate formattedString:[dict_Details objectForKey:@"create_dt_tm"]]];
        
        [btn_AddEditEstimator addTarget:self action:@selector(AddEditEstimatorPressed:) forControlEvents:UIControlEventTouchDown];
        tbl_EstimatorList.hidden = TRUE;
    }
    else
    {
        lbl_LocationName.text = [dict_Details objectForKey:@"name"];
        lbl_LastUpdatedTime.text = [NSString stringWithFormat:@"Updated %@",[NSDate formattedString:[dict_Details objectForKey:@"update_dt_tm"]]];
        
        [btn_AddEditEstimator addTarget:self action:@selector(AddEditEstimatorPressed:) forControlEvents:UIControlEventTouchDown];
        
        [self updateEstimatorList:nil];
        tbl_EstimatorList.hidden = FALSE;
    }
    
    view_survey.frame = CGRectMake(290, 65, 735, 689);
    [self.view addSubview:view_survey];

    Btn_Survay = [UIButton buttonWithType:UIButtonTypeCustom];
    [Btn_Survay setBackgroundImage:[UIImage imageNamed:@"survey_tab_off.jpg"] forState:normal];
    [Btn_Survay setBackgroundImage:[UIImage imageNamed:@"survey_tab_on.jpg"] forState:UIControlStateSelected];
    Btn_Survay.frame = CGRectMake(805 + 24, 0, 65, 65);
    Btn_Survay.hidden = TRUE;
    [self.view addSubview:Btn_Survay];
    [Btn_Survay addTarget:self action:@selector(ToolBarButton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    Btn_Analyse = [UIButton buttonWithType:UIButtonTypeCustom];
    [Btn_Analyse setBackgroundImage:[UIImage imageNamed:@"cost_tab_off.jpg"] forState:normal];
    [Btn_Analyse setBackgroundImage:[UIImage imageNamed:@"cost_tab_on.jpg"] forState:UIControlStateSelected];
    Btn_Analyse.frame = CGRectMake(878 + 16, 0, 65, 65);
    Btn_Analyse.hidden = TRUE;
    [self.view addSubview:Btn_Analyse];
    [Btn_Analyse addTarget:self action:@selector(ToolBarButton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
   
    Btn_info = [UIButton buttonWithType:UIButtonTypeCustom];
    [Btn_info setBackgroundImage:[UIImage imageNamed:@"info_tab_off.jpg"] forState:normal];
    [Btn_info setBackgroundImage:[UIImage imageNamed:@"info_tab_on.jpg"] forState:UIControlStateSelected];
    Btn_info.frame = CGRectMake(951 + 8, 0, 65, 65);
    Btn_info.hidden = TRUE;
    [self.view addSubview:Btn_info];
    [Btn_info addTarget:self action:@selector(ToolBarButton_Clicked:) forControlEvents:UIControlEventTouchUpInside];

    imgview_header.hidden = TRUE;
    lbl_CurrentEstTitle.hidden = TRUE;
    view_survey.hidden = TRUE;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(EstimateEdited:)
                                                 name:@"refreshDataSurvayPage"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateEstimatorList:)
                                                 name:@"updateEstimatorList"
                                               object:nil];
    selectedEstimator = -1;
    
    Btn_Survay.hidden = FALSE;
    Btn_Survay.selected = TRUE;
    Btn_Analyse.hidden = FALSE;
    Btn_Analyse.selected = FALSE;
    Btn_info.hidden = FALSE;
    Btn_info.selected = FALSE;
    
    lbl_CurrentEstTitle.hidden = FALSE;
    imgview_header.hidden = FALSE;

    
    lbl_Placeholder1.font = [UIFont fontWithName:@"Graphik-Semibold" size:45];
    lbl_SubPlaceholder1.font = [UIFont fontWithName:@"Graphik-Semibold" size:14];
    lbl_RestartCost.font = [UIFont fontWithName:@"Graphik-Bold" size:42];
    
    lbl_Placeholder2.font = [UIFont fontWithName:@"Graphik-Semibold" size:24];
    lbl_SubPlaceholder2.font = [UIFont fontWithName:@"Graphik-Semibold" size:13];

    lbl_Placeholder3.font = [UIFont fontWithName:@"Graphik-Semibold" size:24];
    lbl_SubPlaceholder3.font = [UIFont fontWithName:@"Graphik-Semibold" size:13];

    lbl_Percent.font = [UIFont fontWithName:@"Graphik-Bold" size:40];
    lbl_Percent.backgroundColor = [UIColor clearColor];

}

-(void)updateEstimatorList:(NSNotification *)notification
{
    [self RefreshEstimatorList];
    
    if ([arr_Estimator count] > 0)
    {
        [tbl_EstimatorList reloadData];
        //[tbl_EstimatorList selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedEstimator inSection:0] animated:TRUE scrollPosition:UITableViewScrollPositionNone];
        tbl_EstimatorList.hidden = FALSE;
    }
    else
    {
        //[tbl_EstimatorList reloadData];
        tbl_EstimatorList.hidden = TRUE;
    }
    
}

-(IBAction)AddEditEstimatorPressed:(id)sender
{
    AddEstimatorViewController *obj_AddEstimatorViewController = [[AddEstimatorViewController alloc] initWithNibName:@"AddEstimatorViewController" bundle:nil];
    obj_AddEstimatorViewController.str_EstimateID = str_EstimateID;

    UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:obj_AddEstimatorViewController];
    [navi.view setFrame:CGRectMake(280,-100,450,700)];
    navi.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:navi animated:YES];
    [obj_AddEstimatorViewController release];
    [navi release];
    obj_AddEstimatorViewController = nil;
}

-(void)removeAllViews
{
    if([self.view.subviews containsObject:view_survey])
    {
        [view_survey removeFromSuperview];
    }
    if([self.view.subviews containsObject:view_Costs])
    {
        [view_Costs removeFromSuperview];
    }
    if([self.view.subviews containsObject:view_Topics])
    {
        [view_Topics removeFromSuperview];
    }
}

-(void)RefreshEstimatorList
{    
    if(arr_Estimator)
    {
        [arr_Estimator release];
        arr_Estimator = nil;
    }
    
    arr_Estimator = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select estimator.name as estimator_name,estimator.fail_rate, estimator.survey_js, estimator.chart_js,estimator.icon_off, estimator.icon_on,estimator.id as estimator_id,estimator_instance.id from estimator, estimator_instance where estimator_instance.estimator_id = estimator.id and estimator_instance.estimate_id = %@ and estimator_instance.delete_flag = '0'",str_EstimateID]]];
    [arr_Estimator retain];
    NSLog(@"%@",arr_Estimator);
}

-(void)refreshServerpage
{
    //select the row for newly added estimator
    if([arr_Estimator count] > 0)
    {
        //[self removeAllViews];
        if(arr_SurveyElements)
        {
            [arr_SurveyElements release];
            arr_SurveyElements = nil;
        }
        arr_SurveyElements = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select s.id as survey_id,s.page_title,s.evidence_based_insights,s.survey_references,s.estimator_id,q.units_prefix,q.units,q.min_val,q.max_val,q.increments,q.variable_name_to_js,q.id as question_id,q.answer_type_id as question_type,q.display_order,q.question_text from survey_assets s left join question q on s.id=q.survey_asset_id where s.estimator_id = %@ and s.delete_flag = 0 order by s.display_order,q.display_order",[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]]]];;
        [arr_SurveyElements retain];
        
        if(arr_Survey_QustElements)
        {
            [arr_Survey_QustElements release];
            arr_Survey_QustElements = nil;
        }
        arr_Survey_QustElements = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from question_value where estimator_id = %@ and delete_flag = 0 order by display_order",[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]]]];
        [arr_Survey_QustElements retain];
        
        if(arr_EstimatorInstance)
        {
            [arr_EstimatorInstance release];
            arr_EstimatorInstance = nil;
        }
        arr_EstimatorInstance = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimator_instance where estimate_id = %@ and estimator_id = %@",str_EstimateID,[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]]]];
        [arr_EstimatorInstance retain];
        
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
        [self CreateView_forEachQuestion];
        //[self EBI_Ref_heightBasedonWebview];
    }
    else if ([arr_Estimator count] == 0)
    {
        selectedEstimator = -1;
        [self removeAllViews];
    }
}

-(void)UpDateValuesIn_AnswerDB:(NSString *)str_Answer_text :(NSString *)str_Answer_value :(NSString *)str_Estimator_id :(NSString *)str_Survey_id :(NSString *)str_Questionvalue_id
{    
    [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"UPDATE answer SET answer_text = '%@',answer_value = %@ where estimator_instance_id = %@ and question_id = %@ and question_value_id = %@",str_Answer_text,str_Answer_value,str_Estimator_id,str_Survey_id,str_Questionvalue_id] forTable:@"answer"];
}

-(void)UpDatedValuesFrom_answertblDB{
    
    if(arr_AnswerElements)
    {
        [arr_AnswerElements release];
        arr_AnswerElements = nil;
    }
    arr_AnswerElements = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from answer where estimator_instance_id = %@ order by id",[[arr_EstimatorInstance objectAtIndex:0] objectForKey:@"id"]]]];;
    [arr_AnswerElements retain];
}

-(void)insertingValues_toAnswersDB{
    
    NSMutableArray *arr_answers = [[NSMutableArray alloc]init];
    for (int i = 0; i<[arr_SurveyElements count]; i++) {
        
        if ([[[arr_SurveyElements objectAtIndex:i] objectForKey:@"question_type"]intValue] == 2) {// for checkbox
            
            for (int j=0; j<[arr_Survey_QustElements count]; j++) {
                
                if ([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"]intValue] == [[[arr_SurveyElements objectAtIndex:i] objectForKey:@"question_id"]intValue]) {
                    
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setObject:[[arr_EstimatorInstance objectAtIndex:0] objectForKey:@"id"] forKey:@"estimator_instance_id"];
                    [dict setObject:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"question_id"] forKey:@"question_id"];
                    [dict setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"id"] forKey:@"question_value_id"];
                    [dict setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"default_flag"] forKey:@"answer_value"];
                    [dict setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"value_text"] forKey:@"answer_text"];
                    [arr_answers addObject:dict];
                    [dict release];
                }
            }
        }else if ([[[arr_SurveyElements objectAtIndex:i] objectForKey:@"question_type"]intValue] == 3) {// for radio button
            
            for (int j=0; j<[arr_Survey_QustElements count]; j++) {
                
                if ([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"]intValue] == [[[arr_SurveyElements objectAtIndex:i] objectForKey:@"question_id"]intValue]) {
                    
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setObject:[[arr_EstimatorInstance objectAtIndex:0] objectForKey:@"id"] forKey:@"estimator_instance_id"];
                    [dict setObject:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"question_id"] forKey:@"question_id"];
                    [dict setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"id"] forKey:@"question_value_id"];
                    [dict setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"default_flag"] forKey:@"answer_value"];
                    [dict setObject:[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"value_text"] forKey:@"answer_text"];
                    [arr_answers addObject:dict];
                    [dict release];
                }
            }
        }else if ([[[arr_SurveyElements objectAtIndex:i] objectForKey:@"question_type"]intValue] == 1){// for slider
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setObject:[[arr_EstimatorInstance objectAtIndex:0] objectForKey:@"id"] forKey:@"estimator_instance_id"];
            [dict setObject:[[arr_SurveyElements objectAtIndex:i] objectForKey:@"question_id"] forKey:@"question_id"];
            [arr_answers addObject:dict];
            [dict release];
        }
    }
    [appDelegate.sk insertIntoAnswer:arr_answers];
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
            
            view_survey.hidden = FALSE;
            view_Topics.hidden = TRUE;
            view_Costs.hidden = TRUE;
            
            [self DisplaySurveyPage];
            
        }else if (Btn_Analyse.selected){
            
            view_survey.hidden = TRUE;
            view_Topics.hidden = TRUE;
            view_Costs.hidden = FALSE;
            
            [self DisplayCostsPage];
            
        }else if (Btn_info.selected){
            
            view_survey.hidden = TRUE;
            view_Topics.hidden = FALSE;
            view_Costs.hidden = TRUE;
            
            [self DisplayinfoListPage];
        }
        
    }
    
}

-(void)DisplayinfoListPage{
    
    [webview_forinfo loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"info_page_new@2x"ofType:@"jpg"]
                                                                         isDirectory:NO]]];
    view_Topics.frame = CGRectMake(290, 65, 735, 689);

    [self.view addSubview:view_Topics];
}

-(void)DisplayCostsPage{
    
    float sliderV;
    if([arr_Estimator count] > 0)
    {
        NSArray *arr = [appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from costs where estimator_instance_id = %@",[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"id"]]];
        
        if([arr count] == 1)
        {
            sliderV = [[[arr objectAtIndex:0] objectForKey:@"sliderValue"] floatValue];
            if(sliderV > [[dict_surveyvalues_forJS objectForKey:@"fail_rate"] floatValue])
                sliderV = [[dict_surveyvalues_forJS objectForKey:@"fail_rate"] floatValue];
            
            isFirstTimeCosts = FALSE;
            [self setUpAnalyzePage:sliderV];
            [self updateProgress:self.slider];
        }
        else
        {

            if(![dict_surveyvalues_forJS objectForKey:@"fail_rate"])
            {
                sliderV = [[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"fail_rate"] floatValue];
                [dict_surveyvalues_forJS setObject:[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"fail_rate"] forKey:@"fail_rate" ];
                
                isFirstTimeCosts = TRUE;
                [self setUpAnalyzePage:sliderV];
            }
            else
            {
                sliderV = [[dict_surveyvalues_forJS objectForKey:@"fail_rate"] floatValue];
                
                isFirstTimeCosts = TRUE;
                [self setUpAnalyzePage:sliderV];

            }
        }
    }
    else if(![dict_surveyvalues_forJS objectForKey:@"fail_rate"])
    {
        sliderV = [[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"fail_rate"] floatValue];
        [dict_surveyvalues_forJS setObject:[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"fail_rate"] forKey:@"fail_rate" ];
        
        isFirstTimeCosts = TRUE;
        [self setUpAnalyzePage:sliderV];
    }
    else
    {
        sliderV = [[dict_surveyvalues_forJS objectForKey:@"fail_rate"] floatValue];

        isFirstTimeCosts = TRUE;
        [self setUpAnalyzePage:sliderV];
    }
    
    
    
    view_Costs.frame = CGRectMake(290, 65, 735, 689);

    [self.view addSubview:view_Costs];
}

-(void)SaveSliderValueToCosts
{
    NSArray *arr = [appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from costs where estimator_instance_id = %@",[[arr_Estimator objectAtIndex:0] objectForKey:@"id"]]];
    
    if([arr count] == 0)
    {
        int sliderVal = floor(self.slider.value);
        
        NSString *str_Query = [NSString stringWithFormat:@"insert into costs (estimator_instance_id, sliderValue, current_fail_rate) values (%d,%d,%d)",[[[arr_Estimator objectAtIndex:0] objectForKey:@"id"] intValue],sliderVal,[[dict_surveyvalues_forJS objectForKey:@"fail_rate"] integerValue]];
        BOOL bal = [appDelegate.sk runDynamicSQL:str_Query forTable:@"costs"];
    }
    else
    {
        
        int sliderVal = floor(self.slider.value);
        
        
        NSString *str_Query = [NSString stringWithFormat:@"update costs set sliderValue = %d, current_fail_rate = %d where estimator_instance_id = %d",sliderVal,[[dict_surveyvalues_forJS objectForKey:@"fail_rate"] integerValue],[[[arr_Estimator objectAtIndex:0] objectForKey:@"id"] intValue]];
        BOOL bal = [appDelegate.sk runDynamicSQL:str_Query forTable:@"costs"];
    }
    
}

-(void)DisplaySurveyPage
{
    
    view_survey.frame = CGRectMake(290, 65, 735, 689);
    
    [self.view addSubview:view_survey];
}

-(void)setUpAnalyzePage:(float)sliderValue
{
    [self.circularSlider setMinimumValue:self.slider.minimumValue];
	[self.circularSlider_bg setMinimumValue:self.slider.minimumValue];
    
    [self.circularSlider setMaximumValue:self.slider.maximumValue];
    [self.circularSlider_bg setMaximumValue:self.slider.maximumValue];
    
    self.circularSlider.sliderStyle = UICircularSliderStyleCircle;
    self.circularSlider_bg.sliderStyle = UICircularSliderStyleCircle;
    self.circularSlider_bg.enabled = FALSE;
    self.slider.value = sliderValue;
    [self.circularSlider_bg setValue:[[dict_surveyvalues_forJS objectForKey:@"fail_rate"] floatValue]];
    [self.circularSlider_bg setMinimumTrackTintColor:self.sliderColor];
    [self.circularSlider_bg setMaximumTrackTintColor:[UIColor grayColor]];
    [self disableCostFlag:self.slider];
        
}

-(void)disableCostFlag:(UISlider *)sender
{
    if((int)sender.value <= 9.0)
        sender.value = 9.0;
    else if((int)sender.value >= [[dict_surveyvalues_forJS objectForKey:@"fail_rate"] floatValue])
        sender.value = [[dict_surveyvalues_forJS objectForKey:@"fail_rate"] floatValue];
    
    if((int)sender.value < 10)
        lbl_Percent.text = [NSString stringWithFormat:@"0%d",(int)sender.value];
    else
        lbl_Percent.text = [NSString stringWithFormat:@"%d",(int)sender.value];
    
	[self.circularSlider setValue:sender.value];
	[self.slider setValue:sender.value];
    
    int sliderValue = floor(self.slider.value);
    [dict_surveyvalues_forJS setObject:[NSNumber numberWithInt:sliderValue] forKey:@"centurion_fail_rate"];
    [dict_surveyvalues_forJS setObject:[NSNumber numberWithFloat:[[dict_surveyvalues_forJS objectForKey:@"fail_rate"] floatValue]] forKey:@"current_fail_rate"];
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[dict_surveyvalues_forJS objectForKey:@"competitor_product"]];
    if([arr count] > 0)
    {
        for(int i = 0 ; i < [arr count] ; i++)
        {
            [arr replaceObjectAtIndex:i withObject:[[[arr objectAtIndex:i] stringByReplacingOccurrencesOfString:@"'" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
        }
        [dict_surveyvalues_forJS setObject:arr forKey:@"competitor_product"];
    }
    [arr release];
    arr = nil;

    NSString *jsonString = [dict_surveyvalues_forJS JSONStringWithOptions:JKSerializeOptionNone error:nil];
    NSString *jsonString_arr = [arr_forSurveyResults JSONStringWithOptions:JKSerializeOptionNone error:nil];

    NSLog(@"jsonString :%@",jsonString);
    NSLog(@"arr_forSurveyResults : %@",jsonString_arr);
    NSString *function1 = [[NSString alloc] initWithFormat: @"doAnalysis('%@','%@')", jsonString, jsonString_arr];//JSON.stringify(jsonData)
//    NSString *function1 = [[NSString alloc] initWithFormat:@"doAnalysis(JSON.stringify('%@'),%@)", jsonString,jsonString_arr];//JSON.stringify(jsonData)

	NSString *jsonV1 = [webview_Costs stringByEvaluatingJavaScriptFromString:function1];
    NSError *myError1 = nil;
    NSData *jsonData1 = [jsonV1 dataUsingEncoding:NSUTF8StringEncoding];
    
    dict_DoAnalysis = [NSJSONSerialization JSONObjectWithData:jsonData1 options:NSJSONReadingMutableLeaves error:&myError1];
    [dict_DoAnalysis retain];
    NSLog(@"%@",dict_DoAnalysis);
    lbl_Placeholder1.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_1"] objectForKey:@"value"];
    lbl_PlaceholderText1.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_1"] objectForKey:@"label"];
    lbl_SubPlaceholder1.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_1"] objectForKey:@"sub_value"];
    
    lbl_PlaceholderText2.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_2"] objectForKey:@"label"];
    lbl_PlaceholderText3.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_3"] objectForKey:@"label"];
    lbl_Placeholder3.textColor = [UIColor colorWithRed:(132/255.f) green:(183/255.f) blue:(0/255.f) alpha:1.0f];
    
    if(isFirstTimeCosts)
    {
        lbl_Placeholder2.text = @"-";
        lbl_SubPlaceholder2.text = @"-";
        
        lbl_Placeholder3.text = @"-";
        lbl_SubPlaceholder3.text = @"-";
        
    }
    else
    {
        lbl_Placeholder2.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_2"] objectForKey:@"value"];
        lbl_SubPlaceholder2.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_2"] objectForKey:@"sub_value"];
        
        lbl_Placeholder3.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_3"] objectForKey:@"value"];
        lbl_SubPlaceholder3.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_3"] objectForKey:@"sub_value"];
    }
    lbl_CostSectionTitle1.text = [[dict_DoAnalysis objectForKey:@"analysis_table_columns"] objectAtIndex:0];
    lbl_CostSectionTitle2.text = [[dict_DoAnalysis objectForKey:@"analysis_table_columns"] objectAtIndex:1];
    lbl_CostSectionTitle3.text = [[dict_DoAnalysis objectForKey:@"analysis_table_columns"] objectAtIndex:2];
    
    
    [tbl_Costs reloadData];

    [self.circularSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventValueChanged];

}

- (IBAction)updateProgress:(UISlider *)sender {
    
    isFirstTimeCosts = FALSE;

    if((int)sender.value <= 9.0)
        sender.value = 9.0;
    else if((int)sender.value >= [[dict_surveyvalues_forJS objectForKey:@"fail_rate"] floatValue])
        sender.value = [[dict_surveyvalues_forJS objectForKey:@"fail_rate"] floatValue];
    if((int)sender.value < 10)
        lbl_Percent.text = [NSString stringWithFormat:@"0%d",(int)sender.value];
    else
        lbl_Percent.text = [NSString stringWithFormat:@"%d",(int)sender.value];
    
	[self.circularSlider setValue:sender.value];
	[self.slider setValue:sender.value];
    
    int sliderValue = floor(self.slider.value);
    [dict_surveyvalues_forJS setObject:[NSNumber numberWithInt:sliderValue] forKey:@"centurion_fail_rate"];
    [dict_surveyvalues_forJS setObject:[NSNumber numberWithFloat:[[dict_surveyvalues_forJS objectForKey:@"fail_rate"] floatValue]] forKey:@"current_fail_rate"];
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[dict_surveyvalues_forJS objectForKey:@"competitor_product"]];
    if([arr count] > 0)
    {
        for(int i = 0 ; i < [arr count] ; i++)
        {
            [arr replaceObjectAtIndex:i withObject:[[[arr objectAtIndex:i] stringByReplacingOccurrencesOfString:@"'" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
        }
        [dict_surveyvalues_forJS setObject:arr forKey:@"competitor_product"];
    }
    [arr release];
    arr = nil;
    
    NSString *jsonString = [dict_surveyvalues_forJS JSONStringWithOptions:JKSerializeOptionNone error:nil];
    NSString *jsonString_arr = [dict_surveyvalues_forJS JSONStringWithOptions:JKSerializeOptionNone error:nil];
    NSString *function1 = [[NSString alloc] initWithFormat: @"doAnalysis('%@','%@')", jsonString, jsonString_arr];//JSON.stringify(jsonData)
//    NSString *function1 = [[NSString alloc] initWithFormat:@"doAnalysis(JSON.stringify('%@'),%@)", jsonString,jsonString_arr];
	NSString *jsonV1 = [webview_Costs stringByEvaluatingJavaScriptFromString:function1];
    NSError *myError1 = nil;
    NSData *jsonData1 = [jsonV1 dataUsingEncoding:NSUTF8StringEncoding];
    
    dict_DoAnalysis = [NSJSONSerialization JSONObjectWithData:jsonData1 options:NSJSONReadingMutableLeaves error:&myError1];
    [dict_DoAnalysis retain];
    
    lbl_Placeholder1.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_1"] objectForKey:@"value"];
    lbl_PlaceholderText1.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_1"] objectForKey:@"label"];
    lbl_SubPlaceholder1.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_1"] objectForKey:@"sub_value"];
    
    lbl_PlaceholderText2.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_2"] objectForKey:@"label"];
    lbl_PlaceholderText3.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_3"] objectForKey:@"label"];
    
    if(isFirstTimeCosts)
    {
        lbl_Placeholder2.text = @"-";
        lbl_SubPlaceholder2.text = @"-";
        
        lbl_Placeholder3.text = @"-";
        lbl_SubPlaceholder3.text = @"-";
        
    }
    else
    {
        lbl_Placeholder2.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_2"] objectForKey:@"value"];
        lbl_SubPlaceholder2.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_2"] objectForKey:@"sub_value"];
        
        lbl_Placeholder3.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_3"] objectForKey:@"value"];
        lbl_SubPlaceholder3.text = [[dict_DoAnalysis objectForKey:@"cost_savings_placeholder_3"] objectForKey:@"sub_value"];
    }
    lbl_CostSectionTitle1.text = [[dict_DoAnalysis objectForKey:@"analysis_table_columns"] objectAtIndex:0];
    lbl_CostSectionTitle2.text = [[dict_DoAnalysis objectForKey:@"analysis_table_columns"] objectAtIndex:1];
    lbl_CostSectionTitle3.text = [[dict_DoAnalysis objectForKey:@"analysis_table_columns"] objectAtIndex:2];
    
    [tbl_Costs reloadData];
    
    [self SaveSliderValueToCosts];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateCustomSlider" object:self userInfo:dict_forCustomSlider];
}

-(void)gettingAllDataFromSurveyPage
{
    
    [dict_surveyvalues_forJS setObject:[NSNumber numberWithFloat:[[dict_surveyvalues_forJS objectForKey:@"fail_rate"] floatValue]] forKey:@"current_fail_rate"];
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[dict_surveyvalues_forJS objectForKey:@"competitor_product"]];
    if([arr count] > 0)
    {
        for(int i = 0 ; i < [arr count] ; i++)
        {
            [arr replaceObjectAtIndex:i withObject:[[[arr objectAtIndex:i] stringByReplacingOccurrencesOfString:@"'" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
        }
        [dict_surveyvalues_forJS setObject:arr forKey:@"competitor_product"];
    }
    [arr release];
    arr = nil;
    
    NSString *jsonString = [dict_surveyvalues_forJS JSONStringWithOptions:JKSerializeOptionNone error:nil];
    NSString *jsonString_arr = [arr_forSurveyResults JSONStringWithOptions:JKSerializeOptionNone error:nil];
   NSString *function1 = [[NSString alloc] initWithFormat: @"doAnalysis('%@','%@')", jsonString, jsonString_arr];//JSON.stringify(jsonData)
//    NSString *function1 = [[NSString alloc] initWithFormat:@"doAnalysis(JSON.stringify('%@'),%@)", jsonString,jsonString_arr];
	NSString *jsonV1 = [webview_Costs stringByEvaluatingJavaScriptFromString:function1];
    NSError *myError1 = nil;
    NSData *jsonData1 = [jsonV1 dataUsingEncoding:NSUTF8StringEncoding];
    
    dict_DoAnalysis = [NSJSONSerialization JSONObjectWithData:jsonData1 options:NSJSONReadingMutableLeaves error:&myError1];
    [dict_DoAnalysis retain];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
/*    svos = scrollViewForQus_Vertical[textField.tag].contentOffset;
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:scrollViewForQus_Vertical[textField.tag]];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 60;
    [scrollViewForQus_Vertical[textField.tag] setContentOffset:pt animated:YES];*/
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
/*    [scrollViewForQus_Vertical[textField.tag] setContentOffset:svos animated:YES];
    [textField resignFirstResponder];*/
    return YES;
}
//-(void)CalculateHeight_forEBI:(NSString *)str
//{
//    if (webview_forEBI_Ref) {
//        [webview_forEBI_Ref release];
//        [webview_forEBI_Ref removeFromSuperview];
//        webview_forEBI_Ref.delegate = nil;
//        webview_forEBI_Ref = nil;
//    }
//    webview_forEBI_Ref= [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 735, 100)];
//    webview_forEBI_Ref.scalesPageToFit = YES;
//    webview_forEBI_Ref.delegate = self;
//    webview_forEBI_Ref.autoresizingMask = webview_forEBI_Ref.autoresizingMask;
//    [webview_forEBI_Ref loadHTMLString:str baseURL:nil];
//    [view_survey addSubview:webview_forEBI_Ref];
//}
//-(void)CalculateHeight_forReference:(NSString *)str
//{
//    if (webview_forReference) {
//        [webview_forReference release];
//        [webview_forReference removeFromSuperview];
//        webview_forReference.delegate = nil;
//        webview_forReference = nil;
//    }
//    webview_forReference= [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 735, 100)];
//    webview_forReference.scalesPageToFit = YES;
//    webview_forReference.delegate = self;
//    webview_forReference.autoresizingMask = webview_forReference.autoresizingMask;
//    [webview_forReference loadHTMLString:str baseURL:nil];
//    [view_survey addSubview:webview_forReference];
//}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    webView.scalesPageToFit = YES;
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    web_height = webView.frame.size.height;//[[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    //NSLog(@"webview height :%f",web_height);
    
    if (webView == webview_forReference) {
        [[arr_QuestionTableDetails[int_currentPage] objectAtIndex:webView.tag] setObject:[NSString stringWithFormat:@"%f",webView.frame.size.height+30.0] forKey:@"EBI_Height"];
        NSIndexPath *tmpIndexpath=[NSIndexPath indexPathForRow:0 inSection:webView.tag];
        [tbl_Qus_Vertical[int_currentPage] insertRowsAtIndexPaths:[NSArray arrayWithObjects:tmpIndexpath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
    /*
    if (webView == webview_forEBI_Ref || webView == webview_forReference) {
        
        if (webView == webview_forEBI_Ref) {
            //NSLog(@"EBI height : %d",[[webview_forEBI_Ref stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue]);
            
            webView.scalesPageToFit = YES;
            //webView.autoresizingMask = webView.autoresizingMask;
            CGRect frame = webView.frame;
            frame.size.height = 1;
            webView.frame = frame;
            CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
            frame.size = fittingSize;
            webView.frame = frame;


            dict_EBIRef_height = [[NSMutableDictionary alloc]init];
            //[dict_EBIRef_height setObject:[NSString stringWithFormat:@"%f",[[webview_forEBI_Ref stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue]+10.0] forKey:@"EBI_Height"];
            [dict_EBIRef_height setObject:[NSString stringWithFormat:@"%f",webView.scrollView.frame.size.height] forKey:@"EBI_Height"];
            [dict_EBIRef_height retain];
            
             if (int_forEBI < kNumberOfPages-1) {
                 
                if (webview_forEBI_Ref) {
                    //[webview_forEBI_Ref release];
                    [webview_forEBI_Ref removeFromSuperview];
                    webview_forEBI_Ref.delegate = nil;
                    webview_forEBI_Ref = nil;
                }
                webview_forEBI_Ref= [[UIWebView alloc]initWithFrame:CGRectMake(5, 0, view_survey.frame.size.width - 10, 0.1)];
                webview_forEBI_Ref.scalesPageToFit = YES;
                webview_forEBI_Ref.delegate = self;
                webview_forEBI_Ref.autoresizingMask = webview_forEBI_Ref.autoresizingMask;
                [webview_forEBI_Ref loadHTMLString:[SurveyViewController formattedStringfor_EBI_Ref:[[arr_survey objectAtIndex:int_forEBI] objectForKey:@"evidence_based_insights"]] baseURL:nil];
                [view_survey addSubview:webview_forEBI_Ref];
                webview_forEBI_Ref.hidden = TRUE;
                 
                 int_forEBI++;
            }
        }
        if (webView == webview_forReference) {
            //NSLog(@"References height : %d",[[webview_forReference stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue]);
            [webview_forReference sizeToFit];
            [dict_EBIRef_height setObject:[NSString stringWithFormat:@"%f",[[webview_forReference stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue]+10.0] forKey:@"References_Height"];
            [arr_EBI_Ref_Height addObject:dict_EBIRef_height];
            [dict_EBIRef_height release];
            //NSLog(@"EBItemp_int : %d, Reftemp_int : %d ,kNumberOfPages :%d",int_forEBI,int_forRef,kNumberOfPages-1);
            if (int_forEBI == kNumberOfPages-1 && int_forRef == kNumberOfPages-1) {
                [self CreateView_forEachQuestion];
                [self performSelector:@selector(Reload_firstSlideTable) withObject:nil afterDelay:0.1];
            }
            if (int_forRef < kNumberOfPages-1)
            {
                if (webview_forReference) {
                    //[webview_forReference release];
                    [webview_forReference removeFromSuperview];
                    webview_forReference.delegate = nil;
                    webview_forReference = nil;
                }
                webview_forReference= [[UIWebView alloc]initWithFrame:CGRectMake(5, 0, view_survey.frame.size.width - 10, 0.1)];
                webview_forReference.scalesPageToFit = YES;
                webview_forReference.delegate = self;
                webview_forReference.autoresizingMask = webview_forReference.autoresizingMask;
                [webview_forReference loadHTMLString:[SurveyViewController formattedStringfor_EBI_Ref:[[arr_survey objectAtIndex:int_forRef] objectForKey:@"survey_references"]] baseURL:nil];
                [view_survey addSubview:webview_forReference];
                webview_forReference.hidden = TRUE;
                
                int_forRef++;
            }
        }
        
    }*/
}
-(void)Reload_firstSlideTable
{
    [tbl_Qus_Vertical[0] reloadData];
}

+(NSString *)formattedStringfor_EBI_Ref:(NSString *)stringRef
{
    NSString *strTemp2 = stringRef;
    strTemp2 = [NSString stringWithFormat:@"<style>font span,p,div{color:#ffffff !important;font-size:large !important; } </style><font color = \"ffffff\"  size=\"4\">%@</font>",[strTemp2 stringByDecodingHTMLEntities]];
    if ([strTemp2 isEqual:[NSNull null]] || [strTemp2 isEqualToString:@"<nil>"])
    {
        strTemp2 = @"";
    }
    return strTemp2;
}

-(void)EBI_Ref_heightBasedonWebview
{
    view_survey.hidden = FALSE;
    
    [scrollViewForQus_Horizontal removeFromSuperview];
    
    arr_EBI_Ref_Height = [[[NSMutableArray alloc]init] autorelease];
    [arr_EBI_Ref_Height retain];
    
    kNumberOfPages = [appDelegate.sk lookupCountWhere:[NSString stringWithFormat:@"estimator_id = %@ and delete_flag = 0",[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]] forTable:@"survey_assets"];
    kNumberOfPages = kNumberOfPages+1;
    
    // loading dummy webview for, to calculate height of EBI and References
    arr_survey = [appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from survey_assets where estimator_id = %@ and delete_flag = 0",[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]]];
    [arr_survey retain];
    
    int_forEBI = 1;
    int_forRef = 1;
    if (webview_forEBI_Ref) {
        //[webview_forEBI_Ref release];
        [webview_forEBI_Ref removeFromSuperview];
        webview_forEBI_Ref.delegate = nil;
        webview_forEBI_Ref = nil;
    }
    webview_forEBI_Ref= [[UIWebView alloc]initWithFrame:CGRectMake(5, 0, view_survey.frame.size.width - 10, 0.1)];
    webview_forEBI_Ref.scalesPageToFit = YES;
    webview_forEBI_Ref.delegate = self;
    webview_forEBI_Ref.autoresizingMask = webview_forEBI_Ref.autoresizingMask;//[[arr_survey objectAtIndex:0] objectForKey:@"evidence_based_insights"]
    [webview_forEBI_Ref loadHTMLString:[SurveyViewController formattedStringfor_EBI_Ref:[[arr_survey objectAtIndex:0] objectForKey:@"evidence_based_insights"]] baseURL:nil];
    [view_survey addSubview:webview_forEBI_Ref];
    webview_forEBI_Ref.hidden = TRUE;

    if (webview_forReference) {
        //[webview_forReference release];
        [webview_forReference removeFromSuperview];
        webview_forReference.delegate = nil;
        webview_forReference = nil;
    }
    webview_forReference= [[UIWebView alloc]initWithFrame:CGRectMake(5, 0, view_survey.frame.size.width - 10, 0.1)];
    webview_forReference.scalesPageToFit = YES;
    webview_forReference.delegate = self;
    webview_forReference.autoresizingMask = webview_forReference.autoresizingMask;
    [webview_forReference loadHTMLString:[SurveyViewController formattedStringfor_EBI_Ref:[[arr_survey objectAtIndex:0] objectForKey:@"survey_references"]] baseURL:nil];
    [view_survey addSubview:webview_forReference];
    webview_forReference.hidden = TRUE;
}

-(void)CreateView_forEachQuestion
{
    NSString *str_JSFilePath = [NSString stringWithFormat:@"<script src='%@'></script>",[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"survey_js"]];
    NSLog(@"%@",str_JSFilePath);
    webview_Costs.delegate = self;
    [webview_Costs loadHTMLString:str_JSFilePath baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
    
    if (dict_surveyvalues_forJS) {
        [dict_surveyvalues_forJS release];
        dict_surveyvalues_forJS = nil;
    }
    dict_surveyvalues_forJS = [[NSMutableDictionary alloc]init];// creating dictionary for JS file Calculations purpose
    [dict_surveyvalues_forJS setObject:[appDelegate.dict_GlobalInfo objectForKey:@"username"] forKey:@"name"];
    [dict_surveyvalues_forJS setObject:[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"fail_rate"] forKey:@"fail_rate"];
    [dict_surveyvalues_forJS setObject:@"48.0" forKey:@"centurion_fail_rate"];//hardcoded line
    [dict_surveyvalues_forJS setObject:[NSNumber numberWithFloat:[[dict_surveyvalues_forJS objectForKey:@"fail_rate"] floatValue]] forKey:@"current_fail_rate"];//hardcoded line
    str_FailRate = [[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"fail_rate"];
    [str_FailRate retain];
    
    ///Passing default values to pdf slider start....
    if (dict_forCustomSlider) {
        
        dict_forCustomSlider = nil;
        [dict_forCustomSlider release];
    }
    dict_forCustomSlider = [[NSMutableDictionary alloc] init];
    [dict_forCustomSlider setObject:[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"] forKey:@"EstimatorID"];
    [dict_forCustomSlider setObject:[dict_surveyvalues_forJS objectForKey:@"centurion_fail_rate"] forKey:@"centurion_fail_rate"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateCustomSlider" object:self userInfo:dict_forCustomSlider];
    ///Passing default values to pdf slider end....

//    NSString *path = [[NSBundle mainBundle] pathForResource:@"Demo1" ofType:@"html"];
//    NSURL *pathURL = [NSURL fileURLWithPath:path];
//    NSArray* path_forDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    NSString* documentsDirectory = [path_forDirectory objectAtIndex:0];
//    
//    // saving HTML file to DocumentDirectory
//    NSData* data = [NSData dataWithContentsOfURL:pathURL];
//    [data writeToFile:[NSString stringWithFormat:@"%@/Centurion.html",documentsDirectory] atomically:YES];
    
    if (arr_forSurveyResults) {
        [arr_forSurveyResults release];
        arr_forSurveyResults = nil;
    }
    arr_forSurveyResults = [[NSMutableArray alloc]init];
    //[arr_forSurveyResults retain];

    view_survey.hidden = FALSE;
    
    [scrollViewForQus_Horizontal removeFromSuperview];
    
    kNumberOfPages = [appDelegate.sk lookupCountWhere:[NSString stringWithFormat:@"estimator_id = %@ and delete_flag = 0",[[arr_Estimator objectAtIndex:selectedEstimator] objectForKey:@"estimator_id"]] forTable:@"survey_assets"];
    kNumberOfPages = kNumberOfPages+1;
    
    scrollViewForQus_Horizontal = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 735, 633)];
    scrollViewForQus_Horizontal.pagingEnabled = YES;
    scrollViewForQus_Horizontal.contentSize = CGSizeMake(scrollViewForQus_Horizontal.frame.size.width * kNumberOfPages, scrollViewForQus_Horizontal.frame.size.height);
    scrollViewForQus_Horizontal.delegate = self;
    scrollViewForQus_Horizontal.showsHorizontalScrollIndicator = NO;
    scrollViewForQus_Horizontal.showsVerticalScrollIndicator = NO;
    scrollViewForQus_Horizontal.scrollsToTop = NO;
    scrollViewForQus_Horizontal.delaysContentTouches = NO;
    
    [view_survey addSubview:scrollViewForQus_Horizontal];
    
    pagecontroller.numberOfPages = kNumberOfPages;
    pagecontroller.currentPage = 0;
    pagecontroller.userInteractionEnabled = FALSE;
    
    int int_maintain_i = 0;
    int int_dummy;
    for (int i = 0; i < kNumberOfPages; i++)
    {
        
        views_forQus = [[UIView alloc]init];
        CGRect frame = scrollViewForQus_Horizontal.frame; frame.origin.x = frame.size.width * i; frame.origin.y = 0;
        views_forQus.frame = frame;
        views_forQus.backgroundColor = [UIColor clearColor];
        
        lbl_SlideTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, 713, 90)];
        lbl_SlideTitle.numberOfLines = 1;
        lbl_SlideTitle.textColor = [UIColor whiteColor];
        lbl_SlideTitle.backgroundColor = [UIColor clearColor];
        lbl_SlideTitle.font = [UIFont fontWithName:@"Graphik-Bold" size:42];
        
        //SMRITI 18-03-2013
        // Change ScrollViews o TableViews.
        if (i < kNumberOfPages - 1)
        {
            lbl_SlideTitle.text = [[arr_SurveyElements objectAtIndex:int_maintain_i] objectForKey:@"page_title"];
            [views_forQus addSubview:lbl_SlideTitle];
            
            arr_QuestionTableDetails[i] = [[[NSMutableArray alloc]init] autorelease];
            ///////////////////////////////Evidance based insights//////////////////////////////////////////////
            NSMutableDictionary *dictHeaderDetails = [[NSMutableDictionary alloc]init];
            [dictHeaderDetails setObject:@"Evidence Based Insights" forKey:@"header_title"];
            [dictHeaderDetails setObject:@"0" forKey:@"selected_state"];
            [dictHeaderDetails setObject:[SurveyViewController formattedStringfor_EBI_Ref:[[arr_SurveyElements objectAtIndex:int_maintain_i] objectForKey:@"evidence_based_insights"]] forKey:@"webview_data"];
            //[dictHeaderDetails setObject:[[arr_EBI_Ref_Height objectAtIndex:i] objectForKey:@"EBI_Height"] forKey:@"EBI_Height"];
            [dictHeaderDetails setObject:@"0" forKey:@"EBI_Height"];
            
            [arr_QuestionTableDetails[i] addObject:dictHeaderDetails];
            [dictHeaderDetails release];
            //////////////////////////////////////////Questions////////////////////////////////////////////////
            int total_ques_forCurrentSlide = [appDelegate.sk lookupCountWhere:[NSString stringWithFormat:@"survey_asset_id = %@",[[arr_SurveyElements objectAtIndex:int_maintain_i] objectForKey:@"survey_id"]] forTable:@"question"];
            int temp_count = int_maintain_i;
            for (int k = 0; k<total_ques_forCurrentSlide; k++) {
                
                int_dummy = temp_count;
                
                if ([[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"question_text"] != nil || [[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"question_text"] length]>1)
                {
                    NSMutableDictionary *dictQuesDetails = [[NSMutableDictionary alloc]init];
                    NSMutableDictionary *dict_forSurveyResult = [[NSMutableDictionary alloc]init];
                    if (total_ques_forCurrentSlide > 1)
                    {
                        NSString *stringToTest = @"abcdefghijklmnopqrstuvwxyz";
                        aChar = [stringToTest characterAtIndex: k];
                        [dictQuesDetails setObject:[NSString stringWithFormat:@"Question %d%c",i+1,aChar] forKey:@"header_title"];
                        [dict_forSurveyResult setObject:[NSString stringWithFormat:@"%d%c",i+1,aChar]  forKey:@"Question_num"];
                    }
                    else
                    {
                        [dictQuesDetails setObject:[NSString stringWithFormat:@"Question %d",i+1] forKey:@"header_title"];
                        [dict_forSurveyResult setObject:[NSString stringWithFormat:@"%d",i+1]  forKey:@"Question_num"];
                    }
                    [dictQuesDetails setObject:@"1" forKey:@"selected_state"];
                    [dictQuesDetails setObject:[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"question_text"]  forKey:@"question_text"];
                    [dict_forSurveyResult setObject:[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"question_text"]  forKey:@"question"];

                    [dictQuesDetails setObject:[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"question_type"]  forKey:@"question_type"];
                    
                    if ([[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"variable_name_to_js"] != nil) {
                        [dictQuesDetails setObject:[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"variable_name_to_js"]  forKey:@"variable_name_to_js"];
                        [dict_forSurveyResult setObject:[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"variable_name_to_js"]  forKey:@"variable_name_to_js"];
                    }
                    [dictQuesDetails setObject:[[arr_EstimatorInstance objectAtIndex:0] objectForKey:@"id"] forKey:@"estimator_instance_id"];
                    [dictQuesDetails setObject:[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"question_id"]  forKey:@"question_id"];
                    
                    int lines = [[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"question_text"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:16]constrainedToSize:CGSizeMake(690, 80)lineBreakMode:UILineBreakModeWordWrap].height;
                    
                    [dict_forSurveyResult setObject:[NSString stringWithFormat:@"%d",lines+30]  forKey:@"cell_height"];

                    int type = [[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"question_type"] intValue];
                    switch (type)
                    {
                        case 1: // for slider
                            if ([[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"increments"] != nil) {
                                [dictQuesDetails setObject:[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"increments"] forKey:@"increments"];
                            }
                            if ([[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"min_val"] != nil) {
                                [dictQuesDetails setObject:[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"min_val"]  forKey:@"min_value"];
                            }
                            if ([[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"max_val"] != nil) {
                                [dictQuesDetails setObject:[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"max_val"]  forKey:@"max_value"];
                            }
                            NSString *str_SliderValueAndUnits = @"";
                            NSString *strTempUnits_prefix = [[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"units_prefix"];
                            if ([strTempUnits_prefix isEqual:[NSNull null]] || [strTempUnits_prefix isEqualToString:@"<nil>"] || [strTempUnits_prefix length] < 1)
                            {
                                strTempUnits_prefix = @"";
                                [strTempUnits_prefix retain];
                            }
                            str_SliderValueAndUnits = [str_SliderValueAndUnits stringByAppendingString:[NSString stringWithFormat:@"%@",strTempUnits_prefix]];
                            [dictQuesDetails setObject:strTempUnits_prefix  forKey:@"units_prefix"];
                            for (int j=0; j<[arr_AnswerElements count]; j++)
                            {
                                if([[[arr_AnswerElements objectAtIndex:j] objectForKey:@"question_id"]intValue] ==  [[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"question_id"]intValue])
                                {
                                    [dictQuesDetails setObject:[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_value"]  forKey:@"slider_value"];
                                    str_SliderValueAndUnits = [str_SliderValueAndUnits stringByAppendingString:[NSString stringWithFormat:@"%@",[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_value"]]];

                                    if ([[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"variable_name_to_js"] != nil) {
                                        [dict_surveyvalues_forJS setObject:[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_value"] forKey:[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"variable_name_to_js"]];
                                    }
                                    break;
                                }
                            }
                            NSString *strTempUnits = [[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"units"];
                            if ([strTempUnits isEqual:[NSNull null]] || [strTempUnits isEqualToString:@"<nil>"] || [strTempUnits length] < 1)
                            {
                                strTempUnits = @"";
                                [strTempUnits retain];
                            }
                            str_SliderValueAndUnits = [str_SliderValueAndUnits stringByAppendingString:[NSString stringWithFormat:@"%@",strTempUnits]];
                            [dictQuesDetails setObject:strTempUnits  forKey:@"units_postfix"];
                            [dict_forSurveyResult setObject:str_SliderValueAndUnits forKey:@"answer"];

                            lines = lines + 150;
                            [dictQuesDetails setObject:[NSString stringWithFormat:@"%d",lines]  forKey:@"cell_height"];
                            break;
                        case 2: // for CheckBox
                            arr_forCheckBox = [[NSMutableArray alloc]init];
                            if ([arr_Survey_QustElements count]>0)
                            {
                                for (int j=0; j<[arr_Survey_QustElements count]; j++)
                                {
                                    if([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"]intValue] ==  [[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"question_id"]intValue])
                                    {
                                        [arr_forCheckBox addObject:[arr_Survey_QustElements objectAtIndex:j]];
                                    }
                                }
                            }
                            NSMutableArray *arr_SelectedCheckBox_text = [[NSMutableArray alloc]init];
                            NSString *str_selectedCheckBox_txt = @"";
                            for (int j=0; j<[arr_AnswerElements count]; j++)
                            {
                                for (int k=0; k<[arr_forCheckBox count]; k++)
                                {
                                    if([[[arr_AnswerElements objectAtIndex:j] objectForKey:@"question_value_id"]intValue] ==  [[[arr_forCheckBox objectAtIndex:k] objectForKey:@"id"]intValue])
                                    {
                                        NSMutableDictionary *dt = [[NSMutableDictionary alloc]init];
                                        [dt setDictionary:[arr_forCheckBox objectAtIndex:k]];
                                        [dt setObject:[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_value"] forKey:@"default_flag"];
                                        
                                        if ([[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_text"] isEqual:[NSNull null]] || [[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_text"] isEqualToString:@"<nil>"] || [[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_text"] length] < 1)
                                        {
                                            [dt setObject:@"" forKey:@"answer_text"];
                                        }
                                        else
                                        {
                                            [dt setObject:[[arr_forCheckBox objectAtIndex:k] objectForKey:@"value_text"] forKey:@"answer_text"];
                                            
                                            if ([[[arr_forCheckBox objectAtIndex:k] objectForKey:@"value_text"] isEqualToString:@"Other"] || [[[arr_forCheckBox objectAtIndex:k] objectForKey:@"value_text"] isEqualToString:@"other"])
                                            {
                                                [dt setObject:[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_text"] forKey:@"answer_text_forOtherTxtField"];
                                            }
                                        }
                                        [arr_forCheckBox replaceObjectAtIndex:k withObject:dt];
                                        [dt release];
                                        dt = nil;
                                        
                                        if ([[[arr_forCheckBox objectAtIndex:k] objectForKey:@"default_flag"] integerValue] == 1)
                                        {
                                            [arr_SelectedCheckBox_text addObject:[[arr_forCheckBox objectAtIndex:k] objectForKey:@"answer_text"]];
                                            
                                            if([str_selectedCheckBox_txt isEqualToString:@""])
                                            {
                                                str_selectedCheckBox_txt = [str_selectedCheckBox_txt stringByAppendingString:[NSString stringWithFormat:@"%@",[[arr_forCheckBox objectAtIndex:k] objectForKey:@"answer_text"]]];
                                            }
                                            else
                                            {    str_selectedCheckBox_txt = [str_selectedCheckBox_txt stringByAppendingString:[NSString stringWithFormat:@",%@",[[arr_forCheckBox objectAtIndex:k] objectForKey:@"answer_text"]]];
                                            }
                                        }
                                        break;
                                    }
                                }
                            }
                            if ([arr_forCheckBox count]>0) {
                                [dictQuesDetails setObject:arr_forCheckBox  forKey:@"CheckBox_Details"];
                                if ([[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"variable_name_to_js"] != nil) {
                                    [dict_surveyvalues_forJS setObject:arr_SelectedCheckBox_text forKey:[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"variable_name_to_js"]];
                                    [dict_forSurveyResult setObject:str_selectedCheckBox_txt forKey:@"answer"];
                                }
                            }
                            [arr_SelectedCheckBox_text release];
                            arr_SelectedCheckBox_text = nil;
                            
                            lines = lines + ([arr_forCheckBox count]*60);
                            [dictQuesDetails setObject:[NSString stringWithFormat:@"%d",lines]  forKey:@"cell_height"];
                            [arr_forCheckBox release];
                            arr_forCheckBox = nil;
                            break;
                        case 3: // for RadioButton
                            arr_forRadioButton = [[NSMutableArray alloc]init];
                            if ([arr_Survey_QustElements count]>0)
                            {
                                for (int j=0; j<[arr_Survey_QustElements count]; j++)
                                {
                                    if([[[arr_Survey_QustElements objectAtIndex:j] objectForKey:@"question_id"]intValue] ==  [[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"question_id"]intValue])
                                    {
                                        [arr_forRadioButton addObject:[arr_Survey_QustElements objectAtIndex:j]];
                                    }
                                }
                            }
                            
                            for (int j=0; j<[arr_AnswerElements count]; j++)
                            {
                                for (int k=0; k<[arr_forRadioButton count]; k++)
                                {
                                    if([[[arr_AnswerElements objectAtIndex:j] objectForKey:@"question_value_id"]intValue] ==  [[[arr_forRadioButton objectAtIndex:k] objectForKey:@"id"]intValue])
                                    {
                                        NSMutableDictionary *dt = [[NSMutableDictionary alloc]init];
                                        [dt setDictionary:[arr_forRadioButton objectAtIndex:k]];
                                        [dt setObject:[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_value"] forKey:@"default_flag"];
                                        if ([[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_text"] isEqual:[NSNull null]] || [[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_text"] isEqualToString:@"<nil>"] || [[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_text"] length] < 1)
                                        {
                                            [dt setObject:@"" forKey:@"answer_text"];
                                        }
                                        else
                                        {
                                            [dt setObject:[[arr_AnswerElements objectAtIndex:j] objectForKey:@"answer_text"] forKey:@"answer_text"];
                                        }
                                        [arr_forRadioButton replaceObjectAtIndex:k withObject:dt];
                                        [dt release];
                                        dt = nil;
                                        
                                        if ([[[arr_forRadioButton objectAtIndex:k] objectForKey:@"default_flag"] integerValue] == 1)
                                        {
                                            if ([[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"variable_name_to_js"] != nil)
                                            {
                                                [dict_surveyvalues_forJS setObject:[[arr_forRadioButton objectAtIndex:k] objectForKey:@"answer_text"] forKey:[[arr_SurveyElements objectAtIndex:temp_count] objectForKey:@"variable_name_to_js"]];
                                                [dict_forSurveyResult setObject:[[arr_forRadioButton objectAtIndex:k] objectForKey:@"answer_text"] forKey:@"answer"];
                                            }
                                        }
                                    }
                                }
                            }
                            if ([arr_forRadioButton count]>0) {
                                [dictQuesDetails setObject:arr_forRadioButton  forKey:@"RadioButton_Details"];
                            }
                            lines = lines + ([arr_forRadioButton count]*64);
                            [dictQuesDetails setObject:[NSString stringWithFormat:@"%d",lines]  forKey:@"cell_height"];
                            [arr_forRadioButton release];
                            arr_forRadioButton = nil;
                            break;
                        default:
                            break;
                    }
                    
                    [arr_QuestionTableDetails[i] addObject:dictQuesDetails];
                    [arr_forSurveyResults addObject:dict_forSurveyResult];
                    [dictQuesDetails release];
                    dictQuesDetails = nil;
                    [dict_forSurveyResult release];
                    dict_forSurveyResult = nil;
                    
                    temp_count++;
                }
            }
            ///////////////////////////////References/////////////////////////////////////////////
            NSMutableDictionary *dictFooterDetails = [[NSMutableDictionary alloc]init];
            [dictFooterDetails setObject:@"References" forKey:@"header_title"];
            [dictFooterDetails setObject:@"0" forKey:@"selected_state"];
//            NSString *strTemp2 = [[arr_SurveyElements objectAtIndex:int_maintain_i] objectForKey:@"survey_references"];
//            if ([strTemp2 isEqual:[NSNull null]] || [strTemp2 isEqualToString:@"<nil>"])
//            {
//                strTemp2 = @"";
//                [strTemp2 retain];
//            }
            [dictFooterDetails setObject:[SurveyViewController formattedStringfor_EBI_Ref:[[arr_SurveyElements objectAtIndex:int_maintain_i] objectForKey:@"survey_references"]] forKey:@"webview_data"];
            //[dictHeaderDetails setObject:[[arr_EBI_Ref_Height objectAtIndex:i] objectForKey:@"References_Height"] forKey:@"References_Height"];
            [dictHeaderDetails setObject:@"0" forKey:@"References_Height"];
            [arr_QuestionTableDetails[i] addObject:dictFooterDetails];
            [dictFooterDetails release];
            [arr_QuestionTableDetails[i] retain];
            /////////////////////////////////////////////////////////////////////////////

            tbl_Qus_Vertical[i] = [[[UITableView alloc]initWithFrame:CGRectMake(0, lbl_SlideTitle.frame.origin.y + lbl_SlideTitle.frame.size.height, views_forQus.frame.size.width, scrollViewForQus_Horizontal.frame.size.height-95) style:UITableViewStylePlain] autorelease];
            tbl_Qus_Vertical[i].tag = i;
            tbl_Qus_Vertical[i].delegate = self;
            tbl_Qus_Vertical[i].dataSource = self;
            tbl_Qus_Vertical[i].separatorStyle = UITableViewCellSeparatorStyleNone;
            tbl_Qus_Vertical[i].separatorColor = [UIColor clearColor];
            tbl_Qus_Vertical[i].backgroundColor = [UIColor clearColor];
            tbl_Qus_Vertical[i].showsVerticalScrollIndicator = FALSE;
            tbl_Qus_Vertical[i].showsHorizontalScrollIndicator = FALSE;
            tbl_Qus_Vertical[i].delaysContentTouches = NO;
            [views_forQus addSubview:tbl_Qus_Vertical[i]];
            //[tbl_Qus_Vertical[i] reloadData];
            
            int_maintain_i = int_dummy +1;
        }
        else
        {
            lbl_SlideTitle.text = @"SURVEY RESULTS";
            [views_forQus addSubview:lbl_SlideTitle];
            
            img_lineSeperator_4 = [[UIImageView alloc]initWithFrame:CGRectMake(0,lbl_SlideTitle.frame.origin.y + lbl_SlideTitle.frame.size.height, views_forQus.frame.size.width, 2.5)];
            img_lineSeperator_4.image = [UIImage imageNamed:@"line-strip.jpg"];
            [views_forQus addSubview:img_lineSeperator_4];

            tbl_SurveyResults = [[UITableView alloc]initWithFrame:CGRectMake(0, img_lineSeperator_4.frame.origin.y + img_lineSeperator_4.frame.size.height, views_forQus.frame.size.width, scrollViewForQus_Horizontal.frame.size.height-95)];
            tbl_SurveyResults.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tbl_SurveyResults.delegate = self;
            tbl_SurveyResults.dataSource = self;
            tbl_SurveyResults.backgroundColor = [UIColor clearColor];
            [views_forQus addSubview:tbl_SurveyResults];
        }
        
        //scrollViewForQus_Vertical[i].contentSize = CGSizeMake(scrollViewForQus_Vertical[i].frame.size.width, TxtView_Referencesis.frame.origin.y + TxtView_Referencesis.frame.size.height + 50);
                
        [scrollViewForQus_Horizontal addSubview:views_forQus];
    }
    //NSLog(@"dict_surveyvalues_forJS : %@",dict_surveyvalues_forJS);
    //lokesh20130405 start..
    [self CreateSegmentControl];
    
    //[self performSelector:@selector(SegmentControl_pressed:) withObject:segmentedControl afterDelay:0.1];
    [self performSelector:@selector(setSegmentColor) withObject:nil afterDelay:0.1];
    // set first segment as selected by default for first slide
    //lokesh20130405 end..

}

#pragma mark SegmentController methods
-(void)CreateSegmentControl
{
    if(kNumberOfPages > 0)
    {
        [segmentedControl removeAllSegments];
    }
    
    for(int i = 0 ; i < kNumberOfPages ; i++)
    {
        if(i == kNumberOfPages-1)
        {
            [segmentedControl insertSegmentWithTitle:[NSString stringWithFormat:@"Results"] atIndex:i animated:YES];
            [segmentedControl setWidth:80.0 forSegmentAtIndex:i];
        }
        else
        {
            [segmentedControl insertSegmentWithTitle:[NSString stringWithFormat:@"%d",i+1] atIndex:i animated:YES];
            [segmentedControl setWidth:30.0 forSegmentAtIndex:i];
        }
    }
    [segmentedControl sizeToFit];
    [segmentedControl setSelectedSegmentIndex:0];
    
}
-(IBAction)SegmentControl_pressed:(UISegmentedControl *)sender
{
    [self setSegmentColor];
    //NSLog(@"%d",sender.selectedSegmentIndex);
    if (sender.selectedSegmentIndex == kNumberOfPages-1) {
        [tbl_SurveyResults reloadData];
    }
    [scrollViewForQus_Horizontal setContentOffset:CGPointMake(sender.selectedSegmentIndex * views_forQus.frame.size.width,0) animated:NO];
}

-(void)setSegmentColor
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIColor blackColor]
                                                           forKey:UITextAttributeTextColor];
    [segmentedControl setTitleTextAttributes:attributes
                                    forState:UIControlStateSelected];
    
    attributes = [NSDictionary dictionaryWithObject:[UIColor grayColor]
                                             forKey:UITextAttributeTextColor];
    [segmentedControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    
    for (int i=0; i<[segmentedControl.subviews count]; i++)
    {
        if ([[segmentedControl.subviews objectAtIndex:i]isSelected] )
        {
            UIColor *tintcolor=[UIColor whiteColor];
            [[segmentedControl.subviews objectAtIndex:i] setTintColor:tintcolor];
        }
        else
        {
            UIColor *tintcolor=[UIColor colorWithRed:(40.0/255.f) green:(40.0/255.f) blue:(40.0/255.f) alpha:1.0f]; // default color
            [[segmentedControl.subviews objectAtIndex:i] setTintColor:tintcolor];
        }
        [[segmentedControl.subviews objectAtIndex:i] setTag:i];
    }
    [segmentedControl setNeedsDisplay];
}
-(void)CheckBoxSelected:(id)sender
{
    SurveyTableCustomCell *cellsuperView = (SurveyTableCustomCell *)[sender superview];
     NSIndexPath *indexPath = [(SurveyTableCustomCell *)cellsuperView.superview indexPathForCell:cellsuperView];

    UIButton *btn = (UIButton *)sender;
    if (btn.selected)
    {
        btn.selected = FALSE;
        NSMutableDictionary *dt = [[NSMutableDictionary alloc]init];
        [dt setDictionary:[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag]];
        [dt setObject:@"0" forKey:@"default_flag"];
        [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] replaceObjectAtIndex:btn.tag withObject:dt];
        [dt release];
        dt = nil;
        
        if ([[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"value_text"]isEqualToString:@"Other"]||[[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"value_text"]isEqualToString:@"other"])
        {
            txtFld_Survayothers.text = [[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"answer_text"];
            [self UpDateValuesIn_AnswerDB:txtFld_Survayothers.text:[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"default_flag"]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"estimator_instance_id"]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"question_id"] :[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"id"]];
        }
        else
        {
            [self UpDateValuesIn_AnswerDB:[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"answer_text"]:[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"default_flag"]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"estimator_instance_id"]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"question_id"] :[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"id"]];
        }
    }
    else
    {
        btn.selected = TRUE;
        NSMutableDictionary *dt = [[NSMutableDictionary alloc]init];
        [dt setDictionary:[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag]];
        [dt setObject:@"1" forKey:@"default_flag"];
        [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] replaceObjectAtIndex:btn.tag withObject:dt];
        [dt release];
        dt = nil;
        if ([[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"value_text"]isEqualToString:@"Other"]||[[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"value_text"]isEqualToString:@"other"])
        {
            if ([txtFld_Survayothers.text isEqualToString:@""]) {
                txtFld_Survayothers.text = [[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"value_text"];
            }
            [self UpDateValuesIn_AnswerDB:txtFld_Survayothers.text:[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"default_flag"]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"estimator_instance_id"]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"question_id"] :[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"id"]];
        }
        else
        {
            [self UpDateValuesIn_AnswerDB:[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"answer_text"]:[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"default_flag"]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"estimator_instance_id"]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"question_id"] :[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:btn.tag] objectForKey:@"id"]];
        }
    }
    NSMutableArray *arr_tmpcheckbox = [[NSMutableArray alloc]init];
    NSString *str_Selectedchcekboxs = @"";
    checkbox_arrStr_failRate = [[NSMutableArray alloc] init];
    for (int j = 0; j<[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] count]; j++)
    {
        if ([[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:j] objectForKey:@"default_flag"] integerValue]==1)
        {
            [checkbox_arrStr_failRate addObject:[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:j]];
            
            if ([[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:j] objectForKey:@"value_text"]isEqualToString:@"Other"]||[[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:j] objectForKey:@"value_text"]isEqualToString:@"other"])
            {
                
                [arr_tmpcheckbox addObject:txtFld_Survayothers.text];
                if ([str_Selectedchcekboxs isEqualToString:@""])
                {
                    str_Selectedchcekboxs = [str_Selectedchcekboxs stringByAppendingString:[NSString stringWithFormat:@"%@",txtFld_Survayothers.text]];
                }
                else
                {
                    str_Selectedchcekboxs = [str_Selectedchcekboxs stringByAppendingString:[NSString stringWithFormat:@",%@",txtFld_Survayothers.text]];
                }
            }
            else
            {
                [arr_tmpcheckbox addObject:[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:j] objectForKey:@"value_text"]];
                if ([str_Selectedchcekboxs isEqualToString:@""])
                {
                    str_Selectedchcekboxs = [str_Selectedchcekboxs stringByAppendingString:[NSString stringWithFormat:@"%@",[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:j] objectForKey:@"value_text"]]];
                }
                else
                {
                    str_Selectedchcekboxs = [str_Selectedchcekboxs stringByAppendingString:[NSString stringWithFormat:@",%@",[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:j] objectForKey:@"value_text"]]];\
                }
            }
        }
    }
    [dict_surveyvalues_forJS setObject:arr_tmpcheckbox forKey:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"variable_name_to_js"]];
    [arr_tmpcheckbox release];
    arr_tmpcheckbox = nil;
    
    for (int q=0; q<[arr_forSurveyResults count]; q++)
    {
        if ([[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"variable_name_to_js"] isEqualToString:[[arr_forSurveyResults objectAtIndex:q] objectForKey:@"variable_name_to_js"]])
        {
            [[arr_forSurveyResults objectAtIndex:q] setObject:str_Selectedchcekboxs forKey:@"answer"];
            break;
        }
    }
    //checking selected product which is having least fail rate
    if ([checkbox_arrStr_failRate count] > 0) {
        float k = [[[checkbox_arrStr_failRate objectAtIndex:0] objectForKey:@"fail_rate"]floatValue];
        for (int i = 1; i < [checkbox_arrStr_failRate count]; i++){
            
            if([[[checkbox_arrStr_failRate objectAtIndex:i] objectForKey:@"fail_rate"]floatValue] < k){
                
                k = [[[checkbox_arrStr_failRate objectAtIndex:i] objectForKey:@"fail_rate"]floatValue];
            }
        }
        if (k < [str_FailRate floatValue]) {
            [dict_surveyvalues_forJS setObject:[NSNumber numberWithFloat:[str_FailRate floatValue]] forKey:@"fail_rate"];
        }else{
            [dict_surveyvalues_forJS setObject:[NSNumber numberWithFloat:k] forKey:@"fail_rate"];
        }
    }
    [checkbox_arrStr_failRate release];
    checkbox_arrStr_failRate = nil;
    NSLog(@"dict_surveyvalues_forJS :%@",dict_surveyvalues_forJS);
}


-(IBAction)RadioButton_Clicked:(UIButton *)sender
{
    SurveyTableCustomCell *cellsuperView = (SurveyTableCustomCell *)[sender superview];
    NSIndexPath *indexPath = [(SurveyTableCustomCell *)cellsuperView.superview indexPathForCell:cellsuperView];

    for (UIButton *btn in [cellsuperView subviews]) {
        if ([btn isKindOfClass:[UIButton class]] && ![btn isEqual:sender]) {
            [btn setSelected:NO];
            
            NSMutableDictionary *dt = [[NSMutableDictionary alloc]init];
            [dt setDictionary:[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"RadioButton_Details"] objectAtIndex:btn.tag]];
            [dt setObject:@"0" forKey:@"default_flag"];
            [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"RadioButton_Details"] replaceObjectAtIndex:btn.tag withObject:dt];
            [dt release];
            dt = nil;
            
            [self UpDateValuesIn_AnswerDB:[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"RadioButton_Details"] objectAtIndex:btn.tag] objectForKey:@"value_text"]:[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"RadioButton_Details"] objectAtIndex:btn.tag] objectForKey:@"default_flag"]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"estimator_instance_id"]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"question_id"] :[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"RadioButton_Details"] objectAtIndex:btn.tag] objectForKey:@"id"]];
        }
    }
    if (!sender.selected) {
        sender.selected = !sender.selected;
        
        NSMutableDictionary *dt = [[NSMutableDictionary alloc]init];
        [dt setDictionary:[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"RadioButton_Details"] objectAtIndex:sender.tag]];
        [dt setObject:@"1" forKey:@"default_flag"];
        [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"RadioButton_Details"] replaceObjectAtIndex:sender.tag withObject:dt];
        [dt release];
        dt = nil;
        
        [self UpDateValuesIn_AnswerDB:[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"RadioButton_Details"] objectAtIndex:sender.tag] objectForKey:@"value_text"]:[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"RadioButton_Details"] objectAtIndex:sender.tag] objectForKey:@"default_flag"]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"estimator_instance_id"]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"question_id"] :[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"RadioButton_Details"] objectAtIndex:sender.tag] objectForKey:@"id"]];
        
        [dict_surveyvalues_forJS setObject:[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"RadioButton_Details"] objectAtIndex:sender.tag] objectForKey:@"value_text"] forKey:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"variable_name_to_js"]];
    }
    for (int q=0; q<[arr_forSurveyResults count]; q++)
    {
        if ([[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"variable_name_to_js"] isEqualToString:[[arr_forSurveyResults objectAtIndex:q] objectForKey:@"variable_name_to_js"]])
        {
            [[arr_forSurveyResults objectAtIndex:q] setObject:[dict_surveyvalues_forJS objectForKey:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"variable_name_to_js"]] forKey:@"answer"];
            break;
        }
    }
    //NSLog(@"dict_surveyvalues_forJS :%@",dict_surveyvalues_forJS);
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    SurveyTableCustomCell *superViewOfSlider = (SurveyTableCustomCell *)[textField superview];
    NSIndexPath *indexPath = [(SurveyTableCustomCell *)superViewOfSlider.superview indexPathForCell:superViewOfSlider];
    
    if (textField == txtFld_Survayothers)
    {
        if([textField.text isEqualToString:[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:textField.tag] objectForKey:@"answer_text"]])
        {
            txtFld_Survayothers.text = @"";
        }
        //[superViewOfSlider setContentOffset:CGPointMake(0,(superViewOfSlider.contentSize.height - txtFld_Survayothers.frame.origin.y)+100) animated:YES];
    }else if(textField == superViewOfSlider.txtfld_SliderValue){
       
        superViewOfSlider.txtfld_SliderValue.keyboardType = UIKeyboardTypeNumberPad;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    SurveyTableCustomCell *superViewOfSlider = (SurveyTableCustomCell *)[textField superview];
    NSIndexPath *indexPath = [(SurveyTableCustomCell *)superViewOfSlider.superview indexPathForCell:superViewOfSlider];
    
    if (textField == txtFld_Survayothers)
    {
        if ([txtFld_Survayothers.text isEqualToString:@""]) {
            btn_Checkbox[textField.tag].selected = TRUE;
            [self CheckBoxSelected:btn_Checkbox[textField.tag]];
        }else{
            if (!btn_Checkbox[textField.tag].selected){
                [self CheckBoxSelected:btn_Checkbox[textField.tag]];
            }
            else{
                btn_Checkbox[textField.tag].selected = FALSE;
                [self CheckBoxSelected:btn_Checkbox[textField.tag]];
            }
        }
        [txtFld_Survayothers resignFirstResponder];

    }
    else if (textField == superViewOfSlider.txtfld_SliderValue)
    {
        [superViewOfSlider.txtfld_SliderValue resignFirstResponder];
        
        if ([superViewOfSlider.txtfld_SliderValue.text integerValue] < [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"min_value"] integerValue] || [superViewOfSlider.txtfld_SliderValue.text floatValue] > [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"max_value"] floatValue])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Invalid Range" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            superViewOfSlider.txtfld_SliderValue.text = [NSString stringWithFormat:@"%@",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"slider_value"]];
        }
        else
        {
            superViewOfSlider.sli_Answer.value = [superViewOfSlider.txtfld_SliderValue.text floatValue];
            [self SliderMoves:superViewOfSlider.sli_Answer];
        }
    }
    return YES;
}

-(void)SliderMoves:(UISlider *)slide
{
    SurveyTableCustomCell *superViewOfSlider = (SurveyTableCustomCell *)[slide superview];
    NSIndexPath *indexPath = [(SurveyTableCustomCell *)superViewOfSlider.superview indexPathForCell:superViewOfSlider];
    if ([[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:slide.tag] objectForKey:@"increments"] floatValue] < 1) {
               
        int value = [[[[NSString stringWithFormat:@"%@",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:slide.tag] objectForKey:@"increments"]]componentsSeparatedByString:@"."]lastObject] length];
        NSString *floatPoint_dynamicvalue = [@"%." stringByAppendingFormat:@"%if", value];
        superViewOfSlider.txtfld_SliderValue.text = [NSString stringWithFormat:floatPoint_dynamicvalue,(float)slide.value];
        
        [dict_surveyvalues_forJS setObject:[NSNumber numberWithFloat:[[NSString stringWithFormat:floatPoint_dynamicvalue,(float)slide.value] floatValue]] forKey:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"variable_name_to_js"]];
        [[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] setObject:[NSNumber numberWithFloat:[[NSString stringWithFormat:floatPoint_dynamicvalue,(float)slide.value] floatValue]] forKey:@"slider_value"];

        [self UpDateValuesIn_AnswerDB:@"":[NSString stringWithFormat:floatPoint_dynamicvalue,(float)slide.value]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"estimator_instance_id"]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"question_id"] :@"0"];
    }
    else
    { 
        float theFloat = (float) slide.value;
        theFloat = theFloat / [[NSString stringWithFormat:@"%@",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:slide.tag] objectForKey:@"increments"]] integerValue];
        int roundedDown = floor(theFloat);
        int finalDigit = roundedDown * [[NSString stringWithFormat:@"%@",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:slide.tag] objectForKey:@"increments"]] integerValue];
        
//        lbl_Slidervalue[slide.tag].text = [NSString stringWithFormat:@"%d",finalDigit];
        superViewOfSlider.txtfld_SliderValue.text = [NSString stringWithFormat:@"%d",finalDigit];
        [dict_surveyvalues_forJS setObject:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%d",finalDigit] integerValue]] forKey:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"variable_name_to_js"]];
        [[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] setObject:[NSString stringWithFormat:@"%d",finalDigit] forKey:@"slider_value"];

        [self UpDateValuesIn_AnswerDB:@"":[NSString stringWithFormat:@"%d",finalDigit]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"estimator_instance_id"]:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section]objectForKey:@"question_id"] :@"0"];
    }
    
    for (int q=0; q<[arr_forSurveyResults count]; q++) {
        
        if ([[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"variable_name_to_js"] isEqualToString:[[arr_forSurveyResults objectAtIndex:q] objectForKey:@"variable_name_to_js"]])
        {
            NSString *str_SliderValueAndUnits = @"";
            if ([[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"units_prefix"] != nil)
            {
                str_SliderValueAndUnits = [str_SliderValueAndUnits stringByAppendingString:[NSString stringWithFormat:@"%@",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"units_prefix"]]];
            }
            str_SliderValueAndUnits = [str_SliderValueAndUnits stringByAppendingString:[NSString stringWithFormat:@"%@",[dict_surveyvalues_forJS objectForKey:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"variable_name_to_js"]]]];
            if ([[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"units_postfix"] != nil)
            {
                str_SliderValueAndUnits = [str_SliderValueAndUnits stringByAppendingString:[NSString stringWithFormat:@"%@",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"units_postfix"]]];
            }
            [[arr_forSurveyResults objectAtIndex:q] setObject:str_SliderValueAndUnits forKey:@"answer"];
            break;
        }
    }
    //NSLog(@"dict_surveyvalues_forJS : %@",dict_surveyvalues_forJS);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == tbl_Costs)
    {
        return [[dict_DoAnalysis objectForKey:@"analysis_table"] count];
    }
    else if (tableView == tbl_EstimatorList || tableView == tbl_SurveyResults)
    {
        return 1;
    }
    else if (tableView == tbl_Qus_Vertical[int_currentPage])
    {
        return [arr_QuestionTableDetails[int_currentPage] count];
    }
    return 0;
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == tbl_EstimatorList)
    {
        if ([arr_Estimator count] == 0)
        {
            imgview_header.hidden = TRUE;
            lbl_CurrentEstTitle.hidden = TRUE;
            Btn_Survay.hidden = TRUE;
            Btn_Analyse.hidden = TRUE;
            Btn_info.hidden = TRUE;
            view_survey.hidden = TRUE;
            view_Costs.hidden = TRUE;
            view_Topics.hidden = TRUE;
        }
        return [arr_Estimator count];
    }
    else if (tableView == tbl_SurveyResults)
    {
        return [arr_forSurveyResults count];
    }
    else if (tableView == tbl_Costs)
    {
        return [[[[dict_DoAnalysis objectForKey:@"analysis_table"] objectAtIndex:section] objectForKey:@"section_elements"] count];
    }
    else if (tableView == tbl_Qus_Vertical[int_currentPage])
    {
        return [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:section] objectForKey:@"selected_state"] integerValue];
    }
    return 0;
}
    
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView == tbl_Costs)
    {
        UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 750, 50)] autorelease];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:view.bounds];
        imgView.image = [UIImage imageNamed:@"rhsover_black_strip_full.jpg"];
        [view addSubview:imgView];

        UILabel *lbl_Title = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 250, 50)];
        lbl_Title.text = [[[dict_DoAnalysis objectForKey:@"analysis_table"] objectAtIndex:section] objectForKey:@"section_title"];
        lbl_Title.textAlignment = UITextAlignmentLeft;
        lbl_Title.font = [UIFont fontWithName:@"Graphik-Semibold" size:20];
        lbl_Title.textColor = [UIColor whiteColor];
        lbl_Title.backgroundColor = [UIColor clearColor];
        
        [view addSubview:lbl_Title];
        [lbl_Title release];
        if(section == 0 || section == 1)
        {
            UILabel *lbl_Title1 = [[UILabel alloc] initWithFrame:CGRectMake(235, 0, 135, 50)];
            lbl_Title1.text = [[dict_DoAnalysis objectForKey:@"analysis_table_columns"] objectAtIndex:0];
            lbl_Title1.textAlignment = UITextAlignmentRight;
            lbl_Title1.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
            lbl_Title1.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
            lbl_Title1.backgroundColor = [UIColor clearColor];
            [view addSubview:lbl_Title1];
            [lbl_Title1 release];
            
            UILabel *lbl_Title2 = [[UILabel alloc] initWithFrame:CGRectMake(390, 0, 135, 50)];
            lbl_Title2.text = [[dict_DoAnalysis objectForKey:@"analysis_table_columns"] objectAtIndex:1];
            lbl_Title2.textAlignment = UITextAlignmentRight;
            lbl_Title2.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
            lbl_Title2.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
            lbl_Title2.backgroundColor = [UIColor clearColor];
            [view addSubview:lbl_Title2];
            [lbl_Title2 release];
            
            UILabel *lbl_Title3 = [[UILabel alloc] initWithFrame:CGRectMake(545, 0, 138, 50)];
            lbl_Title3.text = [[dict_DoAnalysis objectForKey:@"analysis_table_columns"] objectAtIndex:2];
            lbl_Title3.textAlignment = UITextAlignmentRight;
            lbl_Title3.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
            lbl_Title3.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
            lbl_Title3.backgroundColor = [UIColor clearColor];
            [view addSubview:lbl_Title3];
            [lbl_Title3 release];
        }
        
        return view;
    }
    else if(tableView == tbl_EstimatorList || tableView == tbl_SurveyResults)
    {
        return nil;
    }
    else if (tableView == tbl_Qus_Vertical[int_currentPage])
    {
        UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 750, 70)] autorelease];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:view.bounds];
        //imgView.image = [UIImage imageNamed:@"rhsover_black_strip_full.jpg"];
        imgView.image = [UIImage imageNamed:@"tab_bg.jpg"];
        [view addSubview:imgView];
        [imgView release];
        
        UIImageView *imgView_arrow = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width - 60, 27, 18, 14)];
        imgView_arrow.image = [UIImage imageNamed:@"cen-v-arrow.png"];
        [view addSubview:imgView_arrow];
        [imgView_arrow release];
        
        UIButton *btnArrow = [UIButton buttonWithType:UIButtonTypeCustom];
        btnArrow.frame = CGRectMake(0, 0, 750, 70);
        [btnArrow setBackgroundColor:[UIColor clearColor]];
        btnArrow.tag = section;
        [btnArrow addTarget:self action:@selector(AnimateSelectedSectionRows:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btnArrow];
        
        UILabel *lbl_Title = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 250, 70)];
        lbl_Title.text = [[arr_QuestionTableDetails[int_currentPage] objectAtIndex:section] objectForKey:@"header_title"];
        lbl_Title.textAlignment = UITextAlignmentLeft;
        lbl_Title.font = [UIFont fontWithName:@"Graphik-Semibold" size:20];
        lbl_Title.textColor = [UIColor whiteColor];
        lbl_Title.backgroundColor = [UIColor clearColor];
        [view addSubview:lbl_Title];
        [lbl_Title release];
        
        return view;
    }
    else{
        return nil;
    }
}

-(void)AnimateSelectedSectionRows:(UIButton *)Sender
{
    int int_selectedText = [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:Sender.tag] objectForKey:@"selected_state"] integerValue];
    if (int_selectedText == 0)
    {
        [[arr_QuestionTableDetails[int_currentPage] objectAtIndex:Sender.tag] setObject:@"1" forKey:@"selected_state"];
        
        if ([[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:Sender.tag] objectForKey:@"EBI_Height"] integerValue]>0 || [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:Sender.tag] objectForKey:@"References_Height"] integerValue]>0)
        {
            NSIndexPath *tmpIndexpath=[NSIndexPath indexPathForRow:0 inSection:Sender.tag];
            [tbl_Qus_Vertical[int_currentPage] insertRowsAtIndexPaths:[NSArray arrayWithObjects:tmpIndexpath, nil] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            if (webview_forReference) {
                //[webview_forReference release];
                [webview_forReference removeFromSuperview];
                webview_forReference.delegate = nil;
                webview_forReference = nil;
            }
            webview_forReference= [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 735, 250)];
            webview_forReference.scalesPageToFit = YES;
            webview_forReference.delegate = self;
            webview_forReference.tag = Sender.tag;
            webview_forReference.autoresizingMask = webview_forReference.autoresizingMask;
            [webview_forReference loadHTMLString:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:Sender.tag] objectForKey:@"webview_data"] baseURL:nil];
            [view_survey addSubview:webview_forReference];
            webview_forReference.hidden = TRUE;
        }
    }
    else
    {
        [[arr_QuestionTableDetails[int_currentPage] objectAtIndex:Sender.tag] setObject:@"0" forKey:@"selected_state"];
        NSIndexPath *tmpIndexpath=[NSIndexPath indexPathForRow:0 inSection:Sender.tag];
        [tbl_Qus_Vertical[int_currentPage] deleteRowsAtIndexPaths:[NSArray arrayWithObjects:tmpIndexpath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#define FONT_SIZE 16.0f
#define CELL_CONTENT_WIDTH 370.0f
#define CELL_CONTENT_MARGIN 10.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbl_EstimatorList)
    {
        return 80;
    }
    else if (tableView == tbl_SurveyResults)
    {
        return [[[arr_forSurveyResults objectAtIndex:indexPath.row] objectForKey:@"cell_height"] integerValue];
    }
    else if(tableView == tbl_Costs)
    {
        if(indexPath.section == 0 && indexPath.row == 1)
            return 70.0;
        return 70;
    }
    else if (tableView == tbl_Qus_Vertical[int_currentPage])
    {
        if(indexPath.section == 0)
        {
            //return 250.0;
            return [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"EBI_Height"] floatValue]+10.0;
        }
        else if (indexPath.section == [arr_QuestionTableDetails[int_currentPage] count]-1)
        {
            return [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"References_Height"] floatValue]+10.0;
        }
        else
        {
            return [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"cell_height"] integerValue];
        }
    }
    return 0.0;
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == tbl_Costs)
    {
        return 50.0;
    }
    if(tableView == tbl_EstimatorList || tableView == tbl_SurveyResults)
    {
        return 0.0;
    }
    else if (tableView == tbl_Qus_Vertical[int_currentPage])
    {
        return 70;
    }
    return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"%d%d",indexPath.section,indexPath.row];
    SurveyTableCustomCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[SurveyTableCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.lbl_ForSurveyResultQus.hidden = TRUE;

    cell.lbl_SurveyResultQusValue.hidden = TRUE;
    cell.imgV_Estimator.hidden = TRUE;
    cell.lbl_EstimatorName.hidden = TRUE;
    
    // for analyze
    cell.lbl_AddCost_sect.hidden = TRUE;
    cell.lbl_CurrCost_sect.hidden = TRUE;
    cell.lbl_sub_CurrCostt_sect.hidden = TRUE;
    cell.lbl_AdjCost_sect.hidden = TRUE;
    cell.lbl_sub_AdjCost_sect.hidden = TRUE;
    cell.lbl_PoteSavings_sect.hidden = TRUE;
    cell.lbl_sub_PoteSavings_sect.hidden = TRUE;
    cell.imageView.hidden = TRUE;
    cell.img_lineSeperator.hidden = TRUE;
    cell.lbl_QuestionText.hidden = TRUE;

    //Survey assets
    cell.web_Data.hidden = TRUE;
    cell.lbl_QuestionText.hidden = TRUE;
    cell.sli_Answer.hidden = TRUE;
    cell.lbl_bckground.hidden = TRUE;
    cell.txtfld_SliderValue.hidden = TRUE;
    cell.lbl_SliderMinValue.hidden = TRUE;
    cell.lbl_SliderMaxValue.hidden = TRUE;
    
    // Configure the cell...
    if(tableView == tbl_EstimatorList)
    {
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lhs-grey-strip.jpg"]] autorelease];

        cell.imgV_Estimator.hidden = FALSE;
        cell.lbl_EstimatorName.hidden = FALSE;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        cell.lbl_EstimatorName.text = [[arr_Estimator objectAtIndex:indexPath.row] objectForKey:@"estimator_name"];
        //cell.lbl_EstimatorName.textColor = [UIColor blackColor];
        
        if (indexPath.row == selectedEstimator)
        {
            cell.lbl_EstimatorName.textColor = [UIColor whiteColor];

            NSString *filePath1 = [[arr_Estimator objectAtIndex:indexPath.row] objectForKey:@"icon_on"];
            UIImage *img_on = [[[UIImage alloc] initWithContentsOfFile:filePath1] autorelease];
            cell.imgV_Estimator.image = img_on;
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue_bg_button.jpg"]];
        }
        else
        {
            cell.lbl_EstimatorName.textColor = [UIColor blackColor];

            NSString *filePath1 = [[arr_Estimator objectAtIndex:indexPath.row] objectForKey:@"icon_off"];
            UIImage *img_off = [[[UIImage alloc] initWithContentsOfFile:filePath1] autorelease];
            cell.imgV_Estimator.image = img_off;
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lhs-grey-strip.jpg"]] autorelease];
        }
    }
    else if (tableView == tbl_SurveyResults)
    {
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [tbl_SurveyResults setSeparatorColor:[UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:1.0]];

        cell.lbl_ForSurveyResultQus.hidden = FALSE;
        cell.lbl_QuestionNumber.hidden = FALSE;
        cell.lbl_SurveyResultQusValue.hidden = FALSE;
        cell.lbl_QuestionNumber.backgroundColor = [UIColor redColor];
        cell.lbl_ForSurveyResultQus.backgroundColor = [UIColor blueColor];
        cell.lbl_SurveyResultQusValue.backgroundColor = [UIColor greenColor];
        int width = [[[arr_forSurveyResults objectAtIndex:indexPath.row] objectForKey:@"cell_height"] integerValue]-30;
        cell.lbl_ForSurveyResultQus.frame = CGRectMake(cell.lbl_QuestionNumber.frame.origin.x+cell.lbl_QuestionNumber.frame.size.width+30, 13, 420, width);
        int height = [[[arr_forSurveyResults objectAtIndex:indexPath.row] objectForKey:@"answer"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]constrainedToSize:CGSizeMake(250, 15)lineBreakMode:UILineBreakModeWordWrap].height;
        cell.lbl_SurveyResultQusValue.frame = CGRectMake(cell.lbl_ForSurveyResultQus.frame.origin.x+cell.lbl_ForSurveyResultQus.frame.size.width+10, 13, 220,height);

        cell.lbl_QuestionNumber.text = [[arr_forSurveyResults objectAtIndex:indexPath.row] objectForKey:@"Question_num"];
        [cell.lbl_ForSurveyResultQus setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
        cell.lbl_ForSurveyResultQus.text = [[[arr_forSurveyResults objectAtIndex:indexPath.row] objectForKey:@"question"] stringByDecodingHTMLEntities];
        cell.lbl_SurveyResultQusValue.text = [[arr_forSurveyResults objectAtIndex:indexPath.row] objectForKey:@"answer"];
    }
    else if (tableView == tbl_Costs)
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
        cell.lbl_DetailedTextForCosts.hidden = TRUE;

        cell.imageView.image = [UIImage imageNamed:[[[[[dict_DoAnalysis objectForKey:@"analysis_table"] objectAtIndex:indexPath.section] objectForKey:@"section_elements"] objectAtIndex:indexPath.row] objectForKey:@"image_name"]];

        cell.lbl_AddCost_sect.text = [[[[[dict_DoAnalysis objectForKey:@"analysis_table"] objectAtIndex:indexPath.section] objectForKey:@"section_elements"] objectAtIndex:indexPath.row] objectForKey:@"title"];
        [cell.lbl_AddCost_sect sizeToFit];
        cell.lbl_AddCost_sect.lineBreakMode = UILineBreakModeWordWrap;
        
        CGRect myFrame = cell.lbl_AddCost_sect.frame;
        // Resize the frame's width to 280 (320 - margins)
        // width could also be myOriginalLabelFrame.size.width
        myFrame = CGRectMake(myFrame.origin.x, myFrame.origin.y, 120, myFrame.size.height);
        cell.lbl_AddCost_sect.frame = myFrame;
        
        if((indexPath.section == 0 && indexPath.row == 0) || (indexPath.section == 0 && indexPath.row == 1))
        {
            cell.lbl_AddCost_sect.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
            cell.lbl_CurrCost_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:18];
            cell.lbl_sub_CurrCostt_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:14];
            cell.lbl_AdjCost_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:18];
            cell.lbl_sub_AdjCost_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:14];
            cell.lbl_PoteSavings_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:18];
            cell.lbl_sub_PoteSavings_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:14];
        }
        else
        {
            cell.lbl_AddCost_sect.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
            cell.lbl_CurrCost_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:16];
            cell.lbl_sub_CurrCostt_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:14];
            cell.lbl_AdjCost_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:16];
            cell.lbl_sub_AdjCost_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:14];
            cell.lbl_PoteSavings_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:16];
            cell.lbl_sub_PoteSavings_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:14];
        }
        
        cell.lbl_CurrCost_sect.text = [[[[[dict_DoAnalysis objectForKey:@"analysis_table"] objectAtIndex:indexPath.section] objectForKey:@"section_elements"] objectAtIndex:indexPath.row] objectForKey:@"first_value"];
        cell.lbl_sub_CurrCostt_sect.text = [[[[[dict_DoAnalysis objectForKey:@"analysis_table"] objectAtIndex:indexPath.section] objectForKey:@"section_elements"] objectAtIndex:indexPath.row] objectForKey:@"first_sub_value"];

        if(indexPath.section == 0 && indexPath.row == 1)
        {
            cell.lbl_DetailedTextForCosts.hidden = FALSE;
            cell.lbl_DetailedTextForCosts.text = @"(per PIV start)";
        }
        
        if(isFirstTimeCosts)
        {
            cell.lbl_AdjCost_sect.text = @"-";
            cell.lbl_sub_AdjCost_sect.text = @"-";
            
            cell.lbl_PoteSavings_sect.text = @"-";
            cell.lbl_sub_PoteSavings_sect.text = @"-";
            
            if(indexPath.section == 2 || (indexPath.section == 1 && indexPath.row == 1))
            {
                cell.lbl_CurrCost_sect.text = @"-";
            }

        }
        else
        {
            
            cell.lbl_AdjCost_sect.text = [[[[[dict_DoAnalysis objectForKey:@"analysis_table"] objectAtIndex:indexPath.section] objectForKey:@"section_elements"] objectAtIndex:indexPath.row] objectForKey:@"second_value"];
            cell.lbl_sub_AdjCost_sect.text = [[[[[dict_DoAnalysis objectForKey:@"analysis_table"] objectAtIndex:indexPath.section] objectForKey:@"section_elements"] objectAtIndex:indexPath.row] objectForKey:@"second_sub_value"];
            
            cell.lbl_PoteSavings_sect.text = [[[[[dict_DoAnalysis objectForKey:@"analysis_table"] objectAtIndex:indexPath.section] objectForKey:@"section_elements"] objectAtIndex:indexPath.row] objectForKey:@"third_value"];
            cell.lbl_sub_PoteSavings_sect.text = [[[[[dict_DoAnalysis objectForKey:@"analysis_table"] objectAtIndex:indexPath.section] objectForKey:@"section_elements"] objectAtIndex:indexPath.row] objectForKey:@"third_sub_value"];
            
            cell.lbl_sub_PoteSavings_sect.frame = CGRectMake(545, 40, 138, 20);
            cell.lbl_sub_PoteSavings_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:14];
            if([cell.lbl_sub_PoteSavings_sect.text length] == 0 && [cell.lbl_PoteSavings_sect.text length] > 10)
            {
                cell.lbl_sub_PoteSavings_sect.frame = CGRectMake(545, 5, 138, 55);
                cell.lbl_sub_PoteSavings_sect.numberOfLines = 0;
                cell.lbl_sub_PoteSavings_sect.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:11];
                cell.lbl_sub_PoteSavings_sect.text = cell.lbl_PoteSavings_sect.text;
                cell.lbl_sub_PoteSavings_sect.backgroundColor = [UIColor clearColor];
                cell.lbl_PoteSavings_sect.text = @"";
            }
        }
    }
    else if (tableView == tbl_Qus_Vertical[int_currentPage])
    {
        cell.web_Data.hidden = TRUE;
        cell.lbl_QuestionText.hidden = TRUE;
        cell.sli_Answer.hidden = TRUE;
        cell.txtfld_SliderValue.hidden = TRUE;
        cell.lbl_SliderMinValue.hidden = TRUE;
        cell.lbl_SliderMaxValue.hidden = TRUE;
        
        UIImageView *imgview_temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg.jpg"]];
//        UIView *view_bg = [[UIView alloc]initWithFrame:[cell bounds]];
//        view_bg.backgroundColor = [UIColor colorWithRed:(71.0/255.f) green:(71.0/255.f) blue:(71.0/255.f) alpha:1.0f];
        cell.backgroundView = imgview_temp;
        [imgview_temp release];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.section == 0)
        {
            cell.web_Data.hidden = FALSE;
            cell.web_Data.delegate = self;
            //NSString *strTemp = [[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"webview_data"];
            [cell.web_Data loadHTMLString:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"webview_data"] baseURL:nil];
            //cell.web_Data.frame = CGRectMake(10, 0, tbl_Qus_Vertical[int_currentPage].frame.size.width-5, [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"EBI_Height"] floatValue]);
            //            [cell.web_Data loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]
//                                                                                                           pathForResource:@"centu-table" ofType:@"html"]isDirectory:NO]]];
        }
        else if (indexPath.section == ([arr_QuestionTableDetails[int_currentPage] count] - 1))
        {
            cell.web_Data.hidden = FALSE;
            cell.web_Data.delegate = self;
            //NSString *strTemp = [[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"webview_data"];
            [cell.web_Data loadHTMLString:[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"webview_data"] baseURL:nil];
           // cell.web_Data.frame = CGRectMake(10, 0, tbl_Qus_Vertical[int_currentPage].frame.size.width-5, [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"References_Height"] floatValue]);
//            [cell.web_Data loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]
//                                                                                            pathForResource:@"Reference" ofType:@"html"]isDirectory:NO]]];
        }
        else
        {            
            cell.lbl_QuestionText.text = [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"question_text"] stringByDecodingHTMLEntities];
            
            if ([[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"question_text"] length] < 2)
            {
                
            }
            else
            {    //Configur cell based on Question type (either Slider or Checkbox or Radiobutton)
                
                cell.lbl_QuestionText.hidden = FALSE;

                int type = [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"question_type"] intValue];
                switch (type) {
                    case 2: //for Checkbox
                        for (int i = 0; i<[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] count]; i++)
                        {
                            if(!btn_Checkbox[i])
                            {
                                btn_Checkbox[i] = [UIButton buttonWithType:UIButtonTypeCustom];
                                btn_Checkbox[i].hidden = FALSE;
                                btn_Checkbox[i].tag = i;
                                [btn_Checkbox[i] setImage:[UIImage imageNamed:@"check_box_off_New.png"] forState:UIControlStateNormal];
                                [btn_Checkbox[i] setImage:[UIImage imageNamed:@"check_box_on_New.png"] forState:UIControlStateSelected];
                                btn_Checkbox[i].frame = CGRectMake(cell.lbl_QuestionText.frame.origin.x, cell.lbl_QuestionText.frame.size.height+(i*40), 120, 25);
                                [btn_Checkbox[i] addTarget:self action:@selector(CheckBoxSelected:) forControlEvents:UIControlEventTouchDown];
                                btn_Checkbox[i].selected = FALSE;
                                [cell addSubview:btn_Checkbox[i]];

                                if ([[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:i] objectForKey:@"default_flag"] integerValue]==1) {
                                    btn_Checkbox[i].selected = TRUE;
                                }
                                
                                lbl_Checkbox = [[UILabel alloc] initWithFrame:CGRectMake(cell.lbl_QuestionText.frame.origin.x+50, btn_Checkbox[i].frame.origin.y+3, 300, 20)];
                                lbl_Checkbox.hidden = FALSE;
                                lbl_Checkbox.backgroundColor = [UIColor clearColor];
                                lbl_Checkbox.textColor = [UIColor grayColor];
                                lbl_Checkbox.textAlignment = UITextAlignmentLeft;
                                lbl_Checkbox.font = [UIFont boldSystemFontOfSize:16];
                                lbl_Checkbox.numberOfLines = 0;
                                lbl_Checkbox.text = [[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:i] objectForKey:@"value_text"] ;
                                [cell addSubview:lbl_Checkbox];
                                
                                if ([[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:i] objectForKey:@"value_text"] isEqualToString:@"Other"] || [[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:i] objectForKey:@"value_text"] isEqualToString:@"other"]){
                                    
                                    if (!txtFld_Survayothers) {
                                        txtFld_Survayothers = [[UITextField alloc]init];
                                        txtFld_Survayothers.backgroundColor = [UIColor blackColor];
                                        [txtFld_Survayothers setBorderStyle:UITextBorderStyleRoundedRect];
                                        txtFld_Survayothers.placeholder = @" Enter Other Name";
                                        txtFld_Survayothers.textColor = [UIColor grayColor];
                                        txtFld_Survayothers.font = [UIFont boldSystemFontOfSize:14];
                                        txtFld_Survayothers.delegate = self;
                                        txtFld_Survayothers.tag = i;
                                        [cell addSubview:txtFld_Survayothers];
                                        if (btn_Checkbox[i].selected)
                                        {
                                            txtFld_Survayothers.text = [[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"CheckBox_Details"] objectAtIndex:i] objectForKey:@"answer_text_forOtherTxtField"];
                                        }
                                    }
                                }
                            }
                        }
                        txtFld_Survayothers.frame = CGRectMake(lbl_Checkbox.frame.origin.x, lbl_Checkbox.frame.origin.y+37, 200, 30);
                        break;
                    case 1: //for slider
                        
                        cell.sli_Answer.hidden = FALSE;
                        cell.txtfld_SliderValue.hidden = FALSE;
                        cell.lbl_bckground.hidden = FALSE;
                        cell.lbl_SliderMinValue.hidden = FALSE;
                        cell.lbl_SliderMaxValue.hidden = FALSE;
                        cell.txtfld_SliderValue.delegate = self;

                        int lbl_Qheight = [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"cell_height"] intValue];
                        lbl_Qheight = lbl_Qheight - 80;
                        
                        //frames settings start...
                        cell.lbl_bckground.frame = CGRectMake(610, lbl_Qheight-12, 90, 35);
                        cell.txtfld_SliderValue.frame = CGRectMake(cell.lbl_bckground.frame.origin.x+4, cell.lbl_bckground.frame.origin.y+cell.lbl_bckground.frame.size.height-28, cell.lbl_bckground.frame.size.width-9, 20);
                        cell.sli_Answer.frame = CGRectMake(30, lbl_Qheight, 550, 12);
                        cell.lbl_SliderMinValue.frame = CGRectMake(cell.sli_Answer.frame.origin.x+5, (cell.sli_Answer.frame.origin.y + cell.sli_Answer.frame.size.height + 20), 100, 15);
                        cell.lbl_SliderMaxValue.frame = CGRectMake((cell.sli_Answer.frame.origin.x + cell.sli_Answer.frame.size.width) - 100, (cell.sli_Answer.frame.origin.y + cell.sli_Answer.frame.size.height + 20), 100, 15);
                        //frames settings end...
                        
                        //configur slider
                        cell.sli_Answer.minimumValue = [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"min_value"] integerValue];
                        NSString *str = [NSString stringWithFormat:@"%@",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"max_value"]];
                        cell.sli_Answer.maximumValue = [[str stringByReplacingOccurrencesOfString:@"," withString:@""] floatValue];
                        cell.sli_Answer.value = [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"slider_value"] floatValue];
                        cell.sli_Answer.tag = indexPath.section;
                        [cell.sli_Answer addTarget:self action:@selector(SliderMoves:) forControlEvents:UIControlEventValueChanged];
                        [cell.sli_Answer addTarget:self action:@selector(SliderMoves:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.sli_Answer addTarget:self action:@selector(SliderMoves:) forControlEvents:UIControlEventTouchUpOutside];
                        if ([[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"increments"] floatValue] < 1) {
                            
                            int value = [[[[NSString stringWithFormat:@"%@",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"increments"]]componentsSeparatedByString:@"."]lastObject] length];
                            
                            NSString *floatPoint_dynamicvalue = [@"%." stringByAppendingFormat:@"%if", value];
                            cell.txtfld_SliderValue.text = [NSString stringWithFormat:floatPoint_dynamicvalue,(float)cell.sli_Answer.value];
                        }
                        else
                        {
                            float theFloat = (float)cell.sli_Answer.value;
                            theFloat = theFloat / [[NSString stringWithFormat:@"%@",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"increments"]] integerValue];
                            int roundedDown = floor(theFloat);
                            int finalDigit = roundedDown * [[NSString stringWithFormat:@"%@",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"increments"]] integerValue];
                            cell.txtfld_SliderValue.text = [NSString stringWithFormat:@"%d",finalDigit];
                            
                        }
                        //configur slider min & max labels
                        NSMutableString *str_forlbl_SliderMinValue = [[NSMutableString alloc]init];
                        NSMutableString *str_forlbl_SliderMaxValue = [[NSMutableString alloc]init];

                        if ([[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"units_prefix"] isEqual:[NSNull null]] || [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"units_prefix"] isEqualToString:@"<nil>"] || [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"units_prefix"] length] < 1)
                        {
                            //units_prefix dont have any value
                        }
                        else
                        {
                            [str_forlbl_SliderMinValue appendFormat:@"%@ ",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"units_prefix"]];
                            [str_forlbl_SliderMaxValue appendFormat:@"%@ ",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"units_prefix"]];
                        }
                        if ([[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"min_value"] != nil)
                        {
                            [str_forlbl_SliderMinValue appendFormat:@"%@",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"min_value"]];
                        }
                        if ([[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"max_value"] != nil)
                        {
                            [str_forlbl_SliderMaxValue appendFormat:@"%@",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"max_value"]];
                        }
                        if ([[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"units_postfix"] isEqual:[NSNull null]] || [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"units_postfix"] isEqualToString:@"<nil>"] || [[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"units_postfix"] length] < 1)
                        {
                            //units_postfix dont have any value
                        }
                        else
                        {
                            [str_forlbl_SliderMinValue appendFormat:@" %@",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"units_postfix"]];
                            [str_forlbl_SliderMaxValue appendFormat:@" %@",[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"units_postfix"]];
                        }
                        cell.lbl_SliderMinValue.text = str_forlbl_SliderMinValue;
                        cell.lbl_SliderMaxValue.text = str_forlbl_SliderMaxValue;
                        [str_forlbl_SliderMinValue release];
                        str_forlbl_SliderMinValue = nil;
                        [str_forlbl_SliderMaxValue release];
                        str_forlbl_SliderMaxValue = nil;
                        break;
                    case 3: //for radiobutton
                        for (int i = 0; i<[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"RadioButton_Details"] count]; i++)
                        {
                            if(!btn_Radio[i])
                            {
                                btn_Radio[i] = [UIButton buttonWithType:UIButtonTypeCustom];
                                btn_Radio[i].hidden = FALSE;
                                btn_Radio[i].tag = i;
                                [btn_Radio[i] setImage:[UIImage imageNamed:@"radio_button-grey-off.png"] forState:UIControlStateNormal];
                                [btn_Radio[i] setImage:[UIImage imageNamed:@"radio_button-white.png"] forState:UIControlStateSelected];
                                btn_Radio[i].frame = CGRectMake(cell.lbl_QuestionText.frame.origin.x, cell.lbl_QuestionText.frame.size.height+(i*40), 28, 28);
                                [btn_Radio[i] addTarget:self action:@selector(RadioButton_Clicked:) forControlEvents:UIControlEventTouchDown];
                                btn_Radio[i].selected = FALSE;
                                [cell addSubview:btn_Radio[i]];
                                
                                if ([[[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"RadioButton_Details"] objectAtIndex:i] objectForKey:@"default_flag"] integerValue]==1) {
                                    btn_Radio[i].selected = TRUE;
                                }
                                
                                lbl_RadioBtn = [[UILabel alloc] initWithFrame:CGRectMake(cell.lbl_QuestionText.frame.origin.x+50, btn_Radio[i].frame.origin.y+3, 300, 20)];
                                lbl_RadioBtn.hidden = FALSE;
                                lbl_RadioBtn.backgroundColor = [UIColor clearColor];
                                lbl_RadioBtn.textColor = [UIColor grayColor];
                                lbl_RadioBtn.textAlignment = UITextAlignmentLeft;
                                lbl_RadioBtn.font = [UIFont boldSystemFontOfSize:16];
                                lbl_RadioBtn.numberOfLines = 0;
                                lbl_RadioBtn.text = [[[[arr_QuestionTableDetails[int_currentPage] objectAtIndex:indexPath.section] objectForKey:@"RadioButton_Details"] objectAtIndex:i] objectForKey:@"value_text"] ;
                                [cell addSubview:lbl_RadioBtn];
                            }
                        }
                        break;
                    default:
                        break;
                }
            }
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbl_EstimatorList)
    {
        selectedEstimator = indexPath.row;
        [tbl_EstimatorList reloadData];

        /*SurveyTableCustomCell *thecell = (SurveyTableCustomCell *)[tableView cellForRowAtIndexPath:indexPath];
        thecell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue_bg_button.jpg"]];
        thecell.lbl_EstimatorName.textColor = [UIColor whiteColor];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 15)];
        imageView.image = [UIImage imageNamed:@"white-arrow.png"];
        thecell.accessoryView = imageView;
        [imageView release];
        NSString *filePath2 = [[arr_Estimator objectAtIndex:indexPath.row] objectForKey:@"icon_on"];
        UIImage *img_on = [[[UIImage alloc] initWithContentsOfFile:filePath2] autorelease];
        //cell.imgV_Estimator.highlightedImage = img_on;
        thecell.imgV_Estimator.image = img_on;*/
        lbl_CurrentEstTitle.text = [[arr_Estimator objectAtIndex:indexPath.row] objectForKey:@"estimator_name"];

        imgview_header.hidden = FALSE;
        lbl_CurrentEstTitle.hidden = FALSE;
        Btn_Survay.hidden = FALSE;
        Btn_Analyse.hidden = FALSE;
        Btn_info.hidden = FALSE;
                
        if (Btn_Survay.selected){
            view_survey.hidden = FALSE;
            view_Costs.hidden = TRUE;
            view_Topics.hidden = TRUE;
            [self refreshServerpage];
        }else if (Btn_Analyse.selected){
            view_Costs.hidden = FALSE;
            view_survey.hidden = TRUE;
            view_Topics.hidden = TRUE;
        }else if (Btn_info.selected){
            view_Topics.hidden = FALSE;
            view_survey.hidden = TRUE;
            view_Costs.hidden = TRUE;
        }
    }
}
    
-(void)ButtonEdit_SurveyResults:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    btn_ViewResults.hidden = FALSE;
    [scrollViewForQus_Horizontal setContentOffset:CGPointMake(btn.tag * views_forQus.frame.size.width,0) animated:NO];
}
    
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = scrollViewForQus_Horizontal.frame.size.width;
    int page = floor((scrollViewForQus_Horizontal.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pagecontroller.currentPage = page;
    int_currentPage = page;
    [segmentedControl setSelectedSegmentIndex:page];
    [self setSegmentColor];
    [tbl_Qus_Vertical[int_currentPage] reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}
    
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"int_currentPage ::::: %d",int_currentPage);
    if (int_currentPage == kNumberOfPages - 1)
    {
        btn_ViewResults.hidden = TRUE;
        [tbl_SurveyResults reloadData];
    }
    else if (int_currentPage == 0)
    {
        [tbl_Qus_Vertical[int_currentPage] reloadData];
    }
    else
    {
        btn_ViewResults.hidden = FALSE;
    }
}
    
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Button_ViewResultsPressed:(id)sender
{
    btn_ViewResults.hidden = TRUE;
    [tbl_SurveyResults reloadData];
    [scrollViewForQus_Horizontal setContentOffset:CGPointMake((kNumberOfPages - 1) * views_forQus.frame.size.width,0) animated:NO];
}
    
-(IBAction)BackButton_Pressed:(id)sender
{
    //[self SaveSliderValueToCosts];
    [self.navigationController popViewControllerAnimated:YES];
}
    
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Notifications
-(void)EstimateEdited:(NSNotification *)notification
{
    NSDictionary *dict_temp = notification.userInfo;
    
    if(dict_Details)
    {
        [dict_Details autorelease];
        dict_Details = nil;
    }
    dict_Details = [[NSDictionary alloc] initWithDictionary:[[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate where create_dt_tm = '%@'",[dict_temp objectForKey:@"create_dt_tm"]]] objectAtIndex:0]];
    
    lbl_LocationName.text = [dict_Details objectForKey:@"name"];
    lbl_LastUpdatedTime.text = [NSString stringWithFormat:@"Updated %@",[NSDate formattedString:[dict_Details objectForKey:@"update_dt_tm"]]];
}

#pragma mark - IBActions
-(IBAction)ForwardEstimatePressed:(id)sender
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"View PDF",@"Email PDF",nil];
    action.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [action showFromRect:CGRectMake(btn_ForwardEstimate.center.x,btn_ForwardEstimate.center.y, 1, 1) inView:self.view animated:NO];
}
    
-(IBAction)pageControllerTouched:(id)sender
{
    int page1 = pagecontroller.currentPage;
    if(page1 == 9)
    {
        btn_ViewResults.hidden = TRUE;
    }
    else
    {
        btn_ViewResults.hidden = FALSE;
    }
    [scrollViewForQus_Horizontal setContentOffset:CGPointMake(page1 * views_forQus.frame.size.width,0) animated:NO];
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

#pragma mark -
#pragma mark UIActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //0 = view pdf
    //1 = email pdf
    NSArray* deletepath_forDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString* deletedocumentsDirectoryfiles = [deletepath_forDirectory objectAtIndex:0];
    
    // Delete HTML file in DocumentDirectory
    NSString *deleteHTMLPath = [deletedocumentsDirectoryfiles stringByAppendingPathComponent:@"Centurion.html"];
    NSString *deletePDFPath = [deletedocumentsDirectoryfiles stringByAppendingPathComponent:@"Centurion.pdf"];
    if([[NSFileManager defaultManager] fileExistsAtPath:deleteHTMLPath]) {
        
        [[NSFileManager defaultManager] removeItemAtPath:deleteHTMLPath error:NULL];
        [[NSFileManager defaultManager] removeItemAtPath:deletePDFPath error:NULL];
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Demo1" ofType:@"html"];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    NSArray* path_forDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString* documentsDirectory = [path_forDirectory objectAtIndex:0];
    
    // saving HTML file to DocumentDirectory
    NSData* data = [NSData dataWithContentsOfURL:pathURL];
    [data writeToFile:[NSString stringWithFormat:@"%@/Centurion.html",documentsDirectory] atomically:YES];
    
    // Fetching HTML file from DocumentDirectory
    NSString *HTMLPath = [documentsDirectory stringByAppendingPathComponent:@"Centurion.html"];
    if([[NSFileManager defaultManager] fileExistsAtPath:HTMLPath]) {
        
        NSURL *targetURL = [NSURL fileURLWithPath:HTMLPath];
    
        // Converting HTML to PDF
        self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:targetURL
                                         pathForPDF:[@"~/Documents/Centurion.pdf" stringByExpandingTildeInPath]
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(20, 5, 90, 5)];
    }
    actionSheet_buttonIndex = buttonIndex;
}

#pragma mark - PDF delegate Methods

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    if(actionSheet_buttonIndex == 0)
    {
        [self ViewPDFfile];
    }
    else if(actionSheet_buttonIndex == 1)
    {
        [self EmailPDFfile];
    }
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
}

#pragma mark - Email Methods

-(void)ViewPDFfile
{
    ViewPDFViewController *obj_ViewPDFViewController = [[ViewPDFViewController alloc] initWithNibName:@"ViewPDFViewController" bundle:nil];
    [self presentModalViewController:obj_ViewPDFViewController animated:YES];
    [obj_ViewPDFViewController release];
    obj_ViewPDFViewController = nil;
    
}

-(void)EmailPDFfile
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
    
}
    
-(void)displayComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Peripheral IV Analysis Report"];
    
    // Attach an image to the email
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"Peripheral_IV_Estimate_01" ofType:@"pdf"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:@"Centurion.pdf"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pdfPath]) {
        
        NSData *myData = [NSData dataWithContentsOfFile:pdfPath];
        //[picker addAttachmentData:myData mimeType:@"application/pdf" fileName:@"Peripheral_IV_Estimate_01.pdf"];
        [picker addAttachmentData:myData mimeType:@"application/pdf" fileName:@"Centurion.pdf"];

        // Fill out the email body text
        NSString *emailBody = @"Please find attached Peripheral IV Analysis Report in PDF format.";
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self presentModalViewController:picker animated:YES];
    }
    
    [picker release];
}
    
// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            
            break;
        case MFMailComposeResultSent:
            
            break;
        case MFMailComposeResultFailed:
            
            break;
        default:
            
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
    NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
    NSString *body = @"&body=It is raining in sunny California!";
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

@end

