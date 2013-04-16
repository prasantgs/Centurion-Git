//
//  AddEstimatorCustomCell.m
//  Centurion
//
//  Created by c on 11/14/12.
//
//

#import "AddEstimatorCustomCell.h"

@implementation AddEstimatorCustomCell
@synthesize Btn_checkBox;
@synthesize lbl_EstimatorName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        Btn_checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
        Btn_checkBox.hidden = TRUE;
        [Btn_checkBox setBackgroundImage:[UIImage imageNamed:@"radio_button-gry.png"] forState:normal];
        [Btn_checkBox setBackgroundImage:[UIImage imageNamed:@"radio_button-green.png"] forState:UIControlStateSelected];
        Btn_checkBox.frame = CGRectMake(3, 18, 45, 45);
        [self addSubview:Btn_checkBox];
        
        lbl_EstimatorName = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 240, 80)];
        lbl_EstimatorName.hidden = TRUE;
        lbl_EstimatorName.textAlignment = UITextAlignmentLeft;
        lbl_EstimatorName.textColor = [UIColor blackColor];
        lbl_EstimatorName.backgroundColor = [UIColor clearColor];
        [self addSubview:lbl_EstimatorName];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
