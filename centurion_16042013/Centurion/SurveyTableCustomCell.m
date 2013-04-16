//
//  SurveyTableCustomCell.m
//  Centurion
//
//  Created by c on 12/17/12.
//
//

#import "SurveyTableCustomCell.h"

@implementation SurveyTableCustomCell
//@synthesize TxtView_ForSurveyResultQus;
//@synthesize Btn_EditForSurveyResults;
@synthesize imgV_Estimator,imageView;
@synthesize lbl_SurveyResultQusValue,lbl_EstimatorName,lbl_AddCost_sect,lbl_AdjCost_sect,lbl_CurrCost_sect,lbl_PoteSavings_sect,lbl_sub_AdjCost_sect,lbl_sub_CurrCostt_sect,lbl_sub_PoteSavings_sect,img_lineSeperator,lbl_QuestionNumber,lbl_DetailedTextForCosts,lbl_ForSurveyResultQus;
@synthesize web_Data,lbl_QuestionText,sli_Answer,txtfld_SliderValue,lbl_bckground,lbl_SliderMaxValue,lbl_SliderMinValue;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        lbl_QuestionNumber = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, 25, 18)];
        lbl_QuestionNumber.hidden = TRUE;
        lbl_QuestionNumber.backgroundColor = [UIColor clearColor];
        lbl_QuestionNumber.textAlignment = UITextAlignmentRight;
        lbl_QuestionNumber.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        lbl_QuestionNumber.textColor = [UIColor whiteColor];
        lbl_QuestionNumber.numberOfLines = 1;
        [self addSubview:lbl_QuestionNumber];
        
        img_lineSeperator = [[UIImageView alloc]init];
        img_lineSeperator.image = [UIImage imageNamed:@"line-strip.jpg"];
        img_lineSeperator.hidden = TRUE;
        [self addSubview:img_lineSeperator];
        
//        TxtView_ForSurveyResultQus = [[UITextView alloc]init];
//        TxtView_ForSurveyResultQus.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
//        TxtView_ForSurveyResultQus.userInteractionEnabled = FALSE;
//        TxtView_ForSurveyResultQus.hidden = TRUE;
//        TxtView_ForSurveyResultQus.textColor = [UIColor whiteColor];
//        TxtView_ForSurveyResultQus.backgroundColor = [UIColor clearColor];
//        [self.contentView addSubview:TxtView_ForSurveyResultQus];
        
        lbl_ForSurveyResultQus = [[UILabel alloc]init];
        lbl_ForSurveyResultQus.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        lbl_ForSurveyResultQus.hidden = TRUE;
        lbl_ForSurveyResultQus.textColor = [UIColor whiteColor];
        lbl_ForSurveyResultQus.backgroundColor = [UIColor clearColor];
        lbl_ForSurveyResultQus.lineBreakMode = UILineBreakModeWordWrap;
        lbl_ForSurveyResultQus.numberOfLines = 0;
        [self addSubview:lbl_ForSurveyResultQus];
        
        lbl_SurveyResultQusValue = [[UILabel alloc] initWithFrame:CGRectMake(480, 13, 230, 80)];
        lbl_SurveyResultQusValue.hidden = TRUE;
        lbl_SurveyResultQusValue.lineBreakMode = UILineBreakModeTailTruncation;
        lbl_SurveyResultQusValue.backgroundColor = [UIColor clearColor];
        lbl_SurveyResultQusValue.textAlignment = UITextAlignmentRight;
        lbl_SurveyResultQusValue.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        lbl_SurveyResultQusValue.textColor = [UIColor colorWithRed:(153/255.f) green:(153/255.f) blue:(153/255.f) alpha:1.0f];
        lbl_SurveyResultQusValue.numberOfLines = 0;
        [self addSubview:lbl_SurveyResultQusValue];
        
//        Btn_EditForSurveyResults = [UIButton buttonWithType:UIButtonTypeCustom];
//        Btn_EditForSurveyResults.hidden = TRUE;
//        [Btn_EditForSurveyResults setTitle:@"Edit" forState:UIControlStateNormal];
//        Btn_EditForSurveyResults.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
//        [Btn_EditForSurveyResults setBackgroundImage:[UIImage imageNamed:@"edit_blue_button.png"] forState:normal];
//        Btn_EditForSurveyResults.frame = CGRectMake(680, 13, 45, 30);
//        [self addSubview:Btn_EditForSurveyResults];
        
        //Estimator Table///////
        imgV_Estimator = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 60, 60)];
        imgV_Estimator.hidden = TRUE;
        [self addSubview:imgV_Estimator];

        lbl_EstimatorName = [[UILabel alloc] initWithFrame:CGRectMake(95, 0, 230, 80)];
        lbl_EstimatorName.hidden = TRUE;
        lbl_EstimatorName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        lbl_EstimatorName.textAlignment = UITextAlignmentLeft;
        lbl_EstimatorName.textColor = [UIColor whiteColor];
        lbl_EstimatorName.backgroundColor = [UIColor clearColor];
        [self addSubview:lbl_EstimatorName];
        
        
        //it is for analyze
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 15, 40, 40)];
        imageView.hidden = TRUE;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        
        lbl_AddCost_sect = [[UILabel alloc] initWithFrame:CGRectMake(100, 12, 120, 50)];
        lbl_AddCost_sect.hidden = TRUE;
        lbl_AddCost_sect.backgroundColor = [UIColor clearColor];
        lbl_AddCost_sect.textAlignment = UITextAlignmentLeft;
        lbl_AddCost_sect.textColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];//[UIColor whiteColor];
        lbl_AddCost_sect.numberOfLines = 0;
        [self addSubview:lbl_AddCost_sect];
        
        lbl_DetailedTextForCosts = [[UILabel alloc] initWithFrame:CGRectMake(100, 35, 120, 20)];
        lbl_DetailedTextForCosts.hidden = TRUE;
        lbl_DetailedTextForCosts.backgroundColor = [UIColor clearColor];
        lbl_DetailedTextForCosts.textAlignment = UITextAlignmentLeft;
        lbl_DetailedTextForCosts.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:12];
        lbl_DetailedTextForCosts.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
        lbl_DetailedTextForCosts.numberOfLines = 0;
        [self addSubview:lbl_DetailedTextForCosts];
        
        lbl_CurrCost_sect = [[UILabel alloc] initWithFrame:CGRectMake(235, 15, 135, 20)];
        lbl_CurrCost_sect.hidden = TRUE;
        lbl_CurrCost_sect.backgroundColor = [UIColor clearColor];
        lbl_CurrCost_sect.textAlignment = UITextAlignmentRight;
        lbl_CurrCost_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:18];
        lbl_CurrCost_sect.textColor = [UIColor colorWithRed:(255/255.f) green:(0/255.f) blue:(0/255.f) alpha:1.0f];
        lbl_CurrCost_sect.numberOfLines = 1;
        [self addSubview:lbl_CurrCost_sect];
        
        lbl_sub_CurrCostt_sect = [[UILabel alloc] initWithFrame:CGRectMake(235, 40, 135, 20)];
        lbl_sub_CurrCostt_sect.hidden = TRUE;
        lbl_sub_CurrCostt_sect.backgroundColor = [UIColor clearColor];
        lbl_sub_CurrCostt_sect.textAlignment = UITextAlignmentRight;
        lbl_sub_CurrCostt_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:13];
        lbl_sub_CurrCostt_sect.textColor = [UIColor colorWithRed:(104.0/255.f) green:(104.0/255.f) blue:(104.0/255.f) alpha:1.0f];
        lbl_sub_CurrCostt_sect.numberOfLines = 1;
        [self addSubview:lbl_sub_CurrCostt_sect];
        
        lbl_AdjCost_sect = [[UILabel alloc] initWithFrame:CGRectMake(390, 15, 135, 20)];
        lbl_AdjCost_sect.hidden = TRUE;
        lbl_AdjCost_sect.backgroundColor = [UIColor clearColor];
        lbl_AdjCost_sect.textAlignment = UITextAlignmentRight;
        lbl_AdjCost_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:18];
        lbl_AdjCost_sect.textColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        lbl_AdjCost_sect.numberOfLines = 1;
        [self addSubview:lbl_AdjCost_sect];
        
        lbl_sub_AdjCost_sect = [[UILabel alloc] initWithFrame:CGRectMake(390, 40, 135, 20)];
        lbl_sub_AdjCost_sect.hidden = TRUE;
        lbl_sub_AdjCost_sect.backgroundColor = [UIColor clearColor];
        lbl_sub_AdjCost_sect.textAlignment = UITextAlignmentRight;
        lbl_sub_AdjCost_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:13];
        lbl_sub_AdjCost_sect.textColor = [UIColor colorWithRed:(104.0/255.f) green:(104.0/255.f) blue:(104.0/255.f) alpha:1.0f];
        lbl_sub_AdjCost_sect.numberOfLines = 1;
        [self addSubview:lbl_sub_AdjCost_sect];
        
        lbl_PoteSavings_sect = [[UILabel alloc] initWithFrame:CGRectMake(545, 15, 138, 20)];
        lbl_PoteSavings_sect.hidden = TRUE;
        lbl_PoteSavings_sect.backgroundColor = [UIColor clearColor];
        lbl_PoteSavings_sect.textAlignment = UITextAlignmentRight;
        lbl_PoteSavings_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:18];
        lbl_PoteSavings_sect.textColor = [UIColor colorWithRed:(132/255.f) green:(180/255.f) blue:(0/255.f) alpha:1.0f];
        lbl_PoteSavings_sect.numberOfLines = 1;
        [self addSubview:lbl_PoteSavings_sect];
        
        lbl_sub_PoteSavings_sect = [[UILabel alloc] initWithFrame:CGRectMake(545, 40, 138, 20)];
        lbl_sub_PoteSavings_sect.hidden = TRUE;
        lbl_sub_PoteSavings_sect.backgroundColor = [UIColor clearColor];
        lbl_sub_PoteSavings_sect.textAlignment = UITextAlignmentRight;
        lbl_sub_PoteSavings_sect.font = [UIFont fontWithName:@"Graphik-Semibold" size:13];
        lbl_sub_PoteSavings_sect.textColor = [UIColor colorWithRed:(104.0/255.f) green:(104.0/255.f) blue:(104.0/255.f) alpha:1.0f];
        lbl_sub_PoteSavings_sect.numberOfLines = 1;
        [self addSubview:lbl_sub_PoteSavings_sect];
        
        //Survey assets
        web_Data = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 735, 250)];
        web_Data.scrollView.scrollEnabled = NO;
        web_Data.scrollView.bounces = NO;
        web_Data.userInteractionEnabled = NO;
        web_Data.opaque = NO;
        web_Data.backgroundColor = [UIColor clearColor];
        //web_Data.backgroundColor = [UIColor colorWithRed:(71.0/255.f) green:(71.0/255.f) blue:(71.0/255.f) alpha:1.0f];
        [self addSubview:web_Data];
        
        lbl_QuestionText = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 670, 80)];
        lbl_QuestionText.hidden = TRUE;
        lbl_QuestionText.backgroundColor = [UIColor clearColor];
        lbl_QuestionText.textAlignment = UITextAlignmentLeft;
        lbl_QuestionText.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
        lbl_QuestionText.textColor = [UIColor whiteColor];
        lbl_QuestionText.numberOfLines = 0;
        [self addSubview:lbl_QuestionText];
        
        sli_Answer = [[UISlider alloc] init];
        [sli_Answer setBackgroundColor:[UIColor clearColor]];
        sli_Answer.continuous = YES;
        [sli_Answer setMinimumTrackImage:[[UIImage imageNamed: @"progress-bar_blue.jpg"] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0] forState: UIControlStateNormal];
        [sli_Answer setMaximumTrackImage:[[UIImage imageNamed: @"progress-bar_black.jpg"] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0] forState: UIControlStateNormal];
        [sli_Answer setThumbImage:[UIImage imageNamed:@"progress_bar_slider.png"] forState:UIControlStateNormal];
        [self addSubview:sli_Answer];
        
        lbl_bckground =[[UILabel alloc]init];
        lbl_bckground.backgroundColor = [UIColor blackColor];
        [self addSubview:lbl_bckground];
    
        txtfld_SliderValue = [[UITextField alloc] init];
        txtfld_SliderValue.hidden = TRUE;
        txtfld_SliderValue.backgroundColor = [UIColor clearColor];
        txtfld_SliderValue.textAlignment = UITextAlignmentRight;
        txtfld_SliderValue.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //lbl_Slidervalue.font = [UIFont boldSystemFontOfSize:14];
        txtfld_SliderValue.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        txtfld_SliderValue.textColor = [UIColor whiteColor];
        //lbl_Slidervalue.numberOfLines = 1;
        txtfld_SliderValue.delegate = self;
        [self addSubview:txtfld_SliderValue];
        
        lbl_SliderMinValue = [[UILabel alloc] init];
        lbl_SliderMinValue.hidden = FALSE;
        lbl_SliderMinValue.backgroundColor = [UIColor clearColor];
        lbl_SliderMinValue.textAlignment = UITextAlignmentLeft;
        //lbl_SliderMinValue.font = [UIFont boldSystemFontOfSize:12];
        lbl_SliderMinValue.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        lbl_SliderMinValue.textColor = [UIColor colorWithRed:(153/255.f) green:(153/255.f) blue:(153/255.f) alpha:1.0f];
        lbl_SliderMinValue.numberOfLines = 1;
        [self addSubview:lbl_SliderMinValue];
        
        lbl_SliderMaxValue = [[UILabel alloc] init];
        lbl_SliderMaxValue.hidden = FALSE;
        lbl_SliderMaxValue.backgroundColor = [UIColor clearColor];
        lbl_SliderMaxValue.textAlignment = UITextAlignmentRight;
        //lbl_SliderMaxValue.font = [UIFont boldSystemFontOfSize:12];
        lbl_SliderMaxValue.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        lbl_SliderMaxValue.textColor = [UIColor colorWithRed:(153/255.f) green:(153/255.f) blue:(153/255.f) alpha:1.0f];
        lbl_SliderMaxValue.numberOfLines = 1;
        [self addSubview:lbl_SliderMaxValue];
    }
    return self;
}
-(void)dealloc{
    [web_Data release];
    web_Data = nil;

    [lbl_QuestionText release];
    lbl_QuestionText = nil;
    [txtfld_SliderValue release];
    txtfld_SliderValue = nil;
    [sli_Answer release];
    sli_Answer = nil;
    [lbl_bckground release];
    lbl_bckground = nil;

    [lbl_QuestionNumber release];
    lbl_QuestionNumber = nil;
    [lbl_SliderMaxValue release];
    lbl_SliderMaxValue = nil;
    [lbl_SliderMinValue release];
    lbl_SliderMinValue = nil;
    [lbl_sub_PoteSavings_sect release];
    lbl_sub_PoteSavings_sect = nil;
    [lbl_PoteSavings_sect release];
    lbl_PoteSavings_sect = nil;
    [lbl_sub_AdjCost_sect release];
    lbl_sub_AdjCost_sect = nil;
    [lbl_AdjCost_sect release];
    lbl_AdjCost_sect =nil;
    [lbl_sub_CurrCostt_sect release];
    lbl_sub_CurrCostt_sect = nil;
    [lbl_CurrCost_sect release];
    lbl_CurrCost_sect = nil;
    [lbl_DetailedTextForCosts release];
    lbl_DetailedTextForCosts = nil;
    [lbl_AddCost_sect release];
    lbl_AddCost_sect = nil;
    [imageView release];
    imageView = nil;
    [lbl_EstimatorName release];
    lbl_EstimatorName = nil;
    [imgV_Estimator release];
    imgV_Estimator = nil;
    [lbl_SurveyResultQusValue release];
    lbl_SurveyResultQusValue = nil;
    [lbl_ForSurveyResultQus release];
    lbl_ForSurveyResultQus = nil;
    [img_lineSeperator release];
    img_lineSeperator = nil;
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
