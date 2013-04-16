//
//  SurveyCustomCell.h
//  Centurion
//
//  Created by costrategix technologies on 31/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SurveyCustomCell : UITableViewCell
{
    UILabel *lbl_Section;
    UILabel *lbl_Label;
    UILabel *lbl_HintText;
    
    UIButton  *btn_Radio1;
    UIButton  *btn_Radio2;
    UILabel *lbl_RadioBtn1;
    UILabel *lbl_RadioBtn2;

    UILabel *lbl_Checkbox;
    UILabel *lbl_Question;
    UISlider *slider_Question;
    UILabel *lbl_Answer;
    UILabel *lbl_SliderMin;
    UILabel *lbl_SliderMax;
    UIImageView *imgV_Estimator;
    UILabel *lbl_EstimatorName;
    UILabel *lbl_EstimatorSavings;
    
    UIButton *btn_info_tbl;
    UIImageView *img_SliderAvg;
    
    //analyze
    UILabel *lbl_AddCost_sect;
    UILabel *lbl_CurrCost_sect;
    UILabel *lbl_sub_CurrCostt_sect;
    UILabel *lbl_AdjCost_sect;
    UILabel *lbl_sub_AdjCost_sect;
    UILabel *lbl_PoteSavings_sect;
    UILabel *lbl_sub_PoteSavings_sect;
    
    UISlider *slider_analyze_Question;
    
    UIImageView *imageView;
    
    //compare
    UILabel *lbl_CompareProducts;
    UILabel *lbl_SorbaviewShields;
    UILabel *lbl_YourProducts;
    UILabel *lbl_Differences;
}
@property (nonatomic, retain) UILabel *lbl_Section;
@property (nonatomic, retain) UILabel *lbl_Label;
@property (nonatomic, retain) UILabel *lbl_HintText;

@property (nonatomic, retain) UIButton *btn_Radio1;
@property (nonatomic, retain) UIButton *btn_Radio2;
@property (nonatomic, retain) UILabel *lbl_RadioBtn1;
@property (nonatomic, retain) UILabel *lbl_RadioBtn2;

@property (nonatomic, retain) UILabel *lbl_Checkbox;
@property (nonatomic, retain) UILabel *lbl_Question;
@property (nonatomic, retain) UISlider *slider_Question;
@property (nonatomic, retain) UILabel *lbl_Answer;
@property (nonatomic, retain) UILabel *lbl_SliderMin;
@property (nonatomic, retain) UILabel *lbl_SliderMax;
@property (nonatomic, retain) UIImageView *imgV_Estimator;
@property (nonatomic, retain) UILabel *lbl_EstimatorName;
@property (nonatomic, retain) UILabel *lbl_EstimatorSavings;

@property (nonatomic, retain) UIButton *btn_info_tbl;
@property (nonatomic, retain) UIImageView *img_SliderAvg;

//analyze
@property (nonatomic, retain) UILabel *lbl_AddCost_sect;
@property (nonatomic, retain) UILabel *lbl_CurrCost_sect;
@property (nonatomic, retain) UILabel *lbl_sub_CurrCostt_sect;
@property (nonatomic, retain) UILabel *lbl_AdjCost_sect;
@property (nonatomic, retain) UILabel *lbl_sub_AdjCost_sect;
@property (nonatomic, retain) UILabel *lbl_PoteSavings_sect;
@property (nonatomic, retain) UILabel *lbl_sub_PoteSavings_sect;
@property (nonatomic, retain) UISlider *slider_analyze_Question;

@property (nonatomic, retain) UIImageView *imageView;

//compare
@property (nonatomic, retain) UILabel *lbl_CompareProducts;
@property (nonatomic, retain) UILabel *lbl_SorbaviewShields;
@property (nonatomic, retain) UILabel *lbl_YourProducts;
@property (nonatomic, retain) UILabel *lbl_Differences;
@end
