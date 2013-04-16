//
//  SurveyTableCustomCell.h
//  Centurion
//
//  Created by c on 12/17/12.
//
//

#import <UIKit/UIKit.h>

@interface SurveyTableCustomCell : UITableViewCell<UITextFieldDelegate>
{
    UILabel *lbl_QuestionNumber;
    UILabel *lbl_SurveyResultQusValue;
    //UIButton *Btn_EditForSurveyResults;
    UIImageView *imgV_Estimator;
    UILabel *lbl_EstimatorName;
    
    //analyze
    UILabel *lbl_AddCost_sect;
    UILabel *lbl_CurrCost_sect;
    UILabel *lbl_sub_CurrCostt_sect;
    UILabel *lbl_AdjCost_sect;
    UILabel *lbl_sub_AdjCost_sect;
    UILabel *lbl_PoteSavings_sect;
    UILabel *lbl_sub_PoteSavings_sect;
    UIImageView *imageView;
    UIImageView *img_lineSeperator;
    
    UILabel *lbl_DetailedTextForCosts;
    UILabel *lbl_ForSurveyResultQus;
    
    //Survey Assets
    UIWebView *web_Data;
    UILabel *lbl_QuestionText;
    UISlider *sli_Answer;
    UITextField *txtfld_SliderValue;
    UILabel *lbl_bckground;
    UILabel *lbl_SliderMinValue;
    UILabel *lbl_SliderMaxValue;
}
@property (nonatomic, retain) UILabel *lbl_QuestionNumber;
//@property (nonatomic, retain) UITextView *TxtView_ForSurveyResultQus;
@property (nonatomic, retain) UILabel *lbl_SurveyResultQusValue;
//@property (nonatomic, retain) UIButton *Btn_EditForSurveyResults;
@property (nonatomic, retain) UIImageView *imgV_Estimator;
@property (nonatomic, retain) UILabel *lbl_EstimatorName;
@property (nonatomic, retain) UILabel *lbl_ForSurveyResultQus;

//analyze
@property (nonatomic, retain) UILabel *lbl_AddCost_sect;
@property (nonatomic, retain) UILabel *lbl_CurrCost_sect;
@property (nonatomic, retain) UILabel *lbl_sub_CurrCostt_sect;
@property (nonatomic, retain) UILabel *lbl_AdjCost_sect;
@property (nonatomic, retain) UILabel *lbl_sub_AdjCost_sect;
@property (nonatomic, retain) UILabel *lbl_PoteSavings_sect;
@property (nonatomic, retain) UILabel *lbl_sub_PoteSavings_sect;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImageView *img_lineSeperator;
@property (nonatomic, retain) UILabel *lbl_DetailedTextForCosts;

//Survey Assets
@property (nonatomic, retain) UIWebView *web_Data;
@property (nonatomic, retain) UILabel *lbl_QuestionText;
@property (nonatomic, retain) UISlider *sli_Answer;
@property (nonatomic, retain) UITextField *txtfld_SliderValue;
@property (nonatomic, retain) UILabel *lbl_bckground;
@property (nonatomic, retain) UILabel *lbl_SliderMinValue;
@property (nonatomic, retain) UILabel *lbl_SliderMaxValue;

@end
