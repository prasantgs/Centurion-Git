//
//  SurveyViewController.h
//  Centurion
//
//  Created by c on 12/13/12.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "NDHTMLtoPDF.h"

@class AppDelegate;

@interface SurveyViewController : UIViewController <UIActionSheetDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate,MFMailComposeViewControllerDelegate,UITextFieldDelegate,NDHTMLtoPDFDelegate>
{
    
    AppDelegate *appDelegate;
    IBOutlet UILabel *lbl_EstimateName;
    IBOutlet UILabel *lbl_LastUpdatedTime;
    IBOutlet UILabel *lbl_LocationName;
    IBOutlet UILabel *lbl_CurrentEstTitle;
    
    IBOutlet UIImageView *imgview_header;

    IBOutlet UIPageControl *pagecontroller;

    IBOutlet UIView *view_survey;
    IBOutlet UIView *view_Topics;
    IBOutlet UIView *view_Costs;
    
    IBOutlet UIWebView *webview_forinfo;
    
    IBOutlet UITableView *tbl_EstimatorList;
    IBOutlet UITableView *tbl_Costs;
    
    IBOutlet UIWebView *webview_Costs;

    UITableView *tbl_SurveyResults;

    NSString *str_EstimateID;
    NSString *str_FailRate;
    
    NSMutableArray *arr_SurveyElements;
    //NSMutableArray *arr_EstimatorToDisplayInTable;
    NSMutableArray *arr_EstimatorInstanceRecords;
    NSMutableArray *arr_EstimatorInstance;
    NSMutableArray *arr_Survey_QustElements;
    NSMutableArray *arr_Estimator;
    NSMutableArray *arr_AnswerElements;
    NSMutableArray *checkbox_arrStr_failRate;

    NSMutableArray *arr_selectedCheckBoxtxt;
    NSMutableArray *arr_forSurveyResults;
    
    NSMutableDictionary *dict_surveyvalues_forJS;
    NSDictionary *dict_placeholder1;
    NSDictionary *dict_placeholder2;
    NSDictionary *dict_placeholder3;
    NSDictionary *analysisTableDict;
    NSDictionary *dict_DoAnalysis;

    int selectedEstimator;
    int kNumberOfPages;
    int int_currentPage;

    UIScrollView *scrollViewForQus_Horizontal;  //
    //UIScrollView *scrollViewForQus_Vertical[100];
    UITableView *tbl_Qus_Vertical[100]; //Array of table for each page in view of horizontal scrollview.
    NSMutableArray *arr_QuestionTableDetails[100];
    
    UIView *views_forQus; 
    
    UIButton *Btn_Survay;
    UIButton *Btn_Analyse;
    UIButton *Btn_info;
    UIButton *btn_Checkbox[20];
    UIButton *btn_Radio[20];
    UIButton *btn_Radio2[20];
    
    UILabel *lbl_SlideTitle;
    UILabel *lbl_Question;
    UILabel *lbl_DiscriptionTitle;
    UILabel *lbl_RadioBtn;
    UILabel *lbl_RadioBtn2;
    UITextField *lbl_Slidervalue[100];
    UILabel *lbl_SliderMinValue;
    UILabel *lbl_SliderMaxValue;
    UILabel *lbl_Checkbox;
    UILabel *lbl_Reference;
    
    IBOutlet UILabel *lbl_PlaceholderText1;
    IBOutlet UILabel *lbl_Placeholder1;
    IBOutlet UILabel *lbl_SubPlaceholder1;
    
    IBOutlet UILabel *lbl_PlaceholderText2;
    IBOutlet UILabel *lbl_Placeholder2;
    IBOutlet UILabel *lbl_SubPlaceholder2;
    
    IBOutlet UILabel *lbl_PlaceholderText3;
    IBOutlet UILabel *lbl_Placeholder3;
    IBOutlet UILabel *lbl_SubPlaceholder3;

    UITextView *TxtView_Discription;
    UITextView *TxtView_Questionis;
    UITextView *TxtView_Referencesis;
    
    UISlider *slider[100];
    UIImageView *img_lineSeperator_1;
    UIImageView *img_lineSeperator_2;
    UIImageView *img_lineSeperator_3;
    
    IBOutlet  UILabel *lbl_Percent;
    
    IBOutlet UILabel *lbl_CostSectionTitle1;
    IBOutlet UILabel *lbl_CostSectionTitle2;
    IBOutlet UILabel *lbl_CostSectionTitle3;
    
    IBOutlet UIButton *btn_ForwardEstimate;
    
    BOOL isFirstTimeCosts;
    UITextField *txtFld_Survayothers;

    IBOutlet UIButton *btn_ViewResults;
    CGPoint svos;
    UIImageView *img_lineSeperator_4;
    
    IBOutlet UILabel *lbl_RestartCost;
    UILabel *lbl_bckground;
    
    int actionSheet_buttonIndex;
    
    NSMutableDictionary *dict_forCustomSlider;
    //lokesh20130401 start..
    IBOutlet UIButton *btn_AddEditEstimator;
    //lokesh20130401 end..
    
    NSDictionary *dict_SelectedLoc;
    
    //lokesh20130405 start..
    IBOutlet UISegmentedControl *segmentedControl;
    //lokesh20130405 end..
    UIWebView  *webview_forEBI_Ref;
    UIWebView  *webview_forReference;
    int int_forEBI;
    int int_forRef;
    NSArray *arr_survey;
    NSMutableArray *arr_EBI_Ref_Height;
    NSMutableDictionary *dict_EBIRef_height;
    //lokesh 201130410...
    NSMutableArray *arr_forCheckBox;
    NSMutableArray *arr_forRadioButton;
    float web_height;
    unichar aChar;
    NSMutableArray *arr_ForJS_QusAns;
}
@property (nonatomic, retain) UIColor *sliderColor;
@property (nonatomic, retain) NSDictionary *dict_Details;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;

-(IBAction)Button_ViewResultsPressed:(id)sender;
-(IBAction)BackButton_Pressed:(id)sender;
-(IBAction)ForwardEstimatePressed:(id)sender;
-(IBAction)pageControllerTouched:(id)sender;
-(IBAction)EditEstimateDetailsPressed:(id)sender;
-(void)EstimateEdited:(NSNotification *)notification;
-(void)CheckBoxSelected:(id)sender;
//lokesh20130405 start..
-(IBAction)SegmentControl_pressed:(UISegmentedControl *)sender;
//lokesh20130405 end..
@end
