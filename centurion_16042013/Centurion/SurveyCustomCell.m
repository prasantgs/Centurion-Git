//
//  SurveyCustomCell.m
//  Centurion
//
//  Created by costrategix technologies on 31/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SurveyCustomCell.h"

@implementation SurveyCustomCell
@synthesize lbl_Section,lbl_Label,lbl_HintText,lbl_Checkbox,lbl_Question,slider_Question,lbl_Answer,lbl_SliderMin,lbl_SliderMax,imgV_Estimator,lbl_EstimatorName,lbl_EstimatorSavings;
@synthesize  btn_Radio1,btn_Radio2,lbl_RadioBtn1,lbl_RadioBtn2,btn_info_tbl;
@synthesize  img_SliderAvg;
@synthesize slider_analyze_Question,lbl_AddCost_sect,lbl_AdjCost_sect,lbl_CurrCost_sect,lbl_PoteSavings_sect,lbl_sub_AdjCost_sect,lbl_sub_CurrCostt_sect,lbl_sub_PoteSavings_sect,imageView;
@synthesize lbl_CompareProducts,lbl_Differences,lbl_SorbaviewShields,lbl_YourProducts;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    lbl_Section = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 704, 80)];
    lbl_Section.hidden = TRUE;
    lbl_Section.backgroundColor = [UIColor clearColor];
    lbl_Section.textAlignment = UITextAlignmentLeft;
    lbl_Section.font = [UIFont boldSystemFontOfSize:40];
    lbl_Section.textColor = [UIColor whiteColor];
    lbl_Section.numberOfLines = 1;
    [self addSubview:lbl_Section];
    
    
    
    img_SliderAvg = [[UIImageView alloc] init];
    img_SliderAvg.image = [UIImage imageNamed:@"average-arrow.png"];
    img_SliderAvg.hidden = TRUE;
    [self addSubview:img_SliderAvg];
    
    

    
    //it is for analyze
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 15, 40, 40)];
    imageView.hidden = TRUE;
    [self addSubview:imageView];
    
    lbl_AddCost_sect = [[UILabel alloc] initWithFrame:CGRectMake(120, 10, 150, 60)];
    lbl_AddCost_sect.hidden = TRUE;
    lbl_AddCost_sect.backgroundColor = [UIColor clearColor];
    lbl_AddCost_sect.textAlignment = UITextAlignmentLeft;
    lbl_AddCost_sect.font = [UIFont boldSystemFontOfSize:17];
    lbl_AddCost_sect.textColor = [UIColor whiteColor];
    lbl_AddCost_sect.numberOfLines = 0;
    [self addSubview:lbl_AddCost_sect];
    
    lbl_CurrCost_sect = [[UILabel alloc] initWithFrame:CGRectMake(280, 15, 120, 20)];
    lbl_CurrCost_sect.hidden = TRUE;
    lbl_CurrCost_sect.backgroundColor = [UIColor clearColor];
    lbl_CurrCost_sect.textAlignment = UITextAlignmentRight;
    lbl_CurrCost_sect.font = [UIFont boldSystemFontOfSize:15];
    lbl_CurrCost_sect.textColor = [UIColor redColor];
    lbl_CurrCost_sect.numberOfLines = 1;
    [self addSubview:lbl_CurrCost_sect];
    
    lbl_sub_CurrCostt_sect = [[UILabel alloc] initWithFrame:CGRectMake(280, 40, 120, 20)];
    lbl_sub_CurrCostt_sect.hidden = TRUE;
    lbl_sub_CurrCostt_sect.backgroundColor = [UIColor clearColor];
    lbl_sub_CurrCostt_sect.textAlignment = UITextAlignmentRight;
    lbl_sub_CurrCostt_sect.font = [UIFont boldSystemFontOfSize:13];
    lbl_sub_CurrCostt_sect.textColor = [UIColor grayColor];
    lbl_sub_CurrCostt_sect.numberOfLines = 1;
    [self addSubview:lbl_sub_CurrCostt_sect];
    
    lbl_AdjCost_sect = [[UILabel alloc] initWithFrame:CGRectMake(410, 15, 120, 20)];
    lbl_AdjCost_sect.hidden = TRUE;
    lbl_AdjCost_sect.backgroundColor = [UIColor clearColor];
    lbl_AdjCost_sect.textAlignment = UITextAlignmentRight;
    lbl_AdjCost_sect.font = [UIFont boldSystemFontOfSize:15];
    lbl_AdjCost_sect.textColor = [UIColor whiteColor];
    lbl_AdjCost_sect.numberOfLines = 1;
    [self addSubview:lbl_AdjCost_sect];
    
    lbl_sub_AdjCost_sect = [[UILabel alloc] initWithFrame:CGRectMake(410, 40, 120, 20)];
    lbl_sub_AdjCost_sect.hidden = TRUE;
    lbl_sub_AdjCost_sect.backgroundColor = [UIColor clearColor];
    lbl_sub_AdjCost_sect.textAlignment = UITextAlignmentRight;
    lbl_sub_AdjCost_sect.font = [UIFont boldSystemFontOfSize:13];
    lbl_sub_AdjCost_sect.textColor = [UIColor grayColor];
    lbl_sub_AdjCost_sect.numberOfLines = 1;
    [self addSubview:lbl_sub_AdjCost_sect];
    
    lbl_PoteSavings_sect = [[UILabel alloc] initWithFrame:CGRectMake(540, 15, 120, 20)];
    lbl_PoteSavings_sect.hidden = TRUE;
    lbl_PoteSavings_sect.backgroundColor = [UIColor clearColor];
    lbl_PoteSavings_sect.textAlignment = UITextAlignmentRight;
    lbl_PoteSavings_sect.font = [UIFont boldSystemFontOfSize:15];
    lbl_PoteSavings_sect.textColor = [UIColor greenColor];
    lbl_PoteSavings_sect.numberOfLines = 1;
    [self addSubview:lbl_PoteSavings_sect];
    
    lbl_sub_PoteSavings_sect = [[UILabel alloc] initWithFrame:CGRectMake(540, 40, 120, 20)];
    lbl_sub_PoteSavings_sect.hidden = TRUE;
    lbl_sub_PoteSavings_sect.backgroundColor = [UIColor clearColor];
    lbl_sub_PoteSavings_sect.textAlignment = UITextAlignmentRight;
    lbl_sub_PoteSavings_sect.font = [UIFont boldSystemFontOfSize:13];
    lbl_sub_PoteSavings_sect.textColor = [UIColor grayColor];
    lbl_sub_PoteSavings_sect.numberOfLines = 1;
    [self addSubview:lbl_sub_PoteSavings_sect];

       return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
