//
//  SurvayPageViewController.h
//  Centurion
//
//  Created by costrategix technologies on 25/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@class SurvayInfoPopViewController;

@interface SurvayPageViewController : UIViewController <UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate,UITextFieldDelegate>
{
    AppDelegate *appDelegate;
    SurvayInfoPopViewController *obj_SurvayInfoPopView;
    
    IBOutlet UISegmentedControl *segView;
    IBOutlet UILabel *lbl_EstimateName;
    IBOutlet UILabel *lbl_LastUpdatedTime;
    IBOutlet UILabel *lbl_EstimatedAmount;
    IBOutlet UILabel *lbl_LocationName;
    IBOutlet UIButton *btn_AddEditEstimator;
    IBOutlet UIButton *btn_ForwardEstimate;
    IBOutlet UITableView *tbl_EstimatorList;
    
    UIButton *Btn_Survay;
    UIButton *Btn_Analyse;
    UIButton *Btn_Compare;
    UIButton *Btn_info;
        
    //survey page
    IBOutlet UITableView *tbl_Survey;
    IBOutlet UIView *view_Survey;
    
    NSMutableArray *arr_Estimator;
    NSString *str_EstimateID;

    //daynamic allocation
    UIView *view_Section[10];
    
//    UIButton *btn_CheckBox[10];
//    UILabel *lbl_CheckBox[10];
//    UILabel *lbl_ProductSliderQuestion[10];
//    UISlider *slider_Product[10];
//    
//    UISlider *slider[10];
//    UITextField *txtField[10];
    
    NSMutableArray *arr_SurveyElements;
    NSMutableArray *arr_Survey_QustElements;
    NSMutableArray *arr_variabletxt;
    NSMutableArray *arr_AnswerElements;
    NSMutableArray *arr_EstimatorInstance;
    
    int selectedEstimator;
    int heightForElement;
    IBOutlet UILabel *lbl_CurrentEstTitle;
    IBOutlet UIImageView *imgview_header;
    UIPopoverController *popoverController;
    
    //Analysis page
    IBOutlet UIView *view_Analyze;
    IBOutlet UITableView *tbl_Analyze;
    IBOutlet UIWebView *webview_analyze;
    NSMutableDictionary *dict_surveyvalues;
    NSMutableArray *checkbox_arrTags;
    NSMutableArray *checkbox_arrStr;
    NSMutableArray *checkbox_arrStr_failRate;
    NSMutableArray *arr_selectedCheckBoxtxt;
    NSMutableArray *arr_AddCost_sectText;
    UITextField *txtFld_Survayothers;
    UIButton *btn_Checkbox[100];

    IBOutlet  UILabel *lbl_Percent;
    NSDictionary *analysisTableDict;
    
    //info page
    IBOutlet UIView *view_Topics;
    IBOutlet UIWebView *webview_forinfo;
    
    NSDictionary *dict_placeholder1;
    NSDictionary *dict_placeholder2;
    NSDictionary *dict_placeholder3;
    
    IBOutlet UILabel *lbl_PlaceholderText1;
    IBOutlet UILabel *lbl_Placeholder1;
    IBOutlet UILabel *lbl_SubPlaceholder1;
    
    IBOutlet UILabel *lbl_PlaceholderText2;
    IBOutlet UILabel *lbl_Placeholder2;
    IBOutlet UILabel *lbl_SubPlaceholder2;
    
    IBOutlet UILabel *lbl_PlaceholderText3;
    IBOutlet UILabel *lbl_Placeholder3;
    IBOutlet UILabel *lbl_SubPlaceholder3;

    NSDictionary *dict_DoAnalysis;
    
    UITextField *txt_OtherProducts;
    
    NSString *str_FailRate;
    NSMutableArray *arr_failRate;
    
    //compare page
    IBOutlet UIView *view_Compare;
    IBOutlet UITableView *tbl_Compare;
    NSDictionary *Dict_JSONCompare;
    
    //NSMutableArray *arr_CurrentTableValues;
}
@property (nonatomic, retain) NSDictionary *dict_Details;

-(IBAction)HomePressed:(id)sender;
//-(IBAction)createSegmentControl:(id)sender;
-(IBAction)AddEstimatePressed:(id)sender;
-(void)EditEstimatePressed:(id)sender;
-(IBAction)EditEstimateDetailsPressed:(id)sender;
-(void)EstimateEdited:(NSNotification *)notification;
-(IBAction)ForwardEstimatePressed:(id)sender;
-(void)updateEstimatorList:(NSNotification *)notification;
-(void)RefreshEstimatorList;

-(void)removeAllViews;
-(void)prepareSurveyView;
-(void)CheckBoxSelected:(id)sender;

-(void)setUpAnalyzePage;
-(IBAction)updateProgress:(UISlider *)sender;
-(void)refreshServerpage;;
-(void)RefreshCompareData;
-(void)setUpComparePage;
-(IBAction)AddProductsPressed:(id)sender;
@end
