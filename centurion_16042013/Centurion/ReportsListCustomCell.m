//
//  ReportsListCustomCell.m
//  Centurion
//
//  Created by costrategix technologies on 22/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReportsListCustomCell.h"

@implementation ReportsListCustomCell
@synthesize lbl_ReportName, lbl_UpdatedDate, btn_Download, btn_email;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        lbl_ReportName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 460, 50)];
        lbl_ReportName.backgroundColor = [UIColor clearColor];
        lbl_ReportName.textColor = [UIColor colorWithRed:114.0/256.0 green:177.0/256.0 blue:211.0/256.0 alpha:1.0];
        lbl_ReportName.font = [UIFont boldSystemFontOfSize:15.0];
        [self addSubview:lbl_ReportName];
        
        lbl_UpdatedDate = [[UILabel alloc] initWithFrame:CGRectMake(480, 0, 250, 50)];
        lbl_UpdatedDate.backgroundColor = [UIColor clearColor];
        lbl_UpdatedDate.textColor = [UIColor darkGrayColor];
        lbl_UpdatedDate.font = [UIFont boldSystemFontOfSize:14.0];
        [self addSubview:lbl_UpdatedDate];
        
        btn_Download = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_Download.frame = CGRectMake(759, 10, 120, 30);
        btn_Download.alpha = 1.0;
        [btn_Download setBackgroundImage:[UIImage imageNamed:@"download_btn.png"] forState:UIControlStateNormal];
        [self addSubview:btn_Download];

        btn_email = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_email.frame = CGRectMake(889, 10, 85, 30);
        btn_email.alpha = 1.0;
        [btn_email setBackgroundImage:[UIImage imageNamed:@"email_btn.png"] forState:UIControlStateNormal];
        [self addSubview:btn_email];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
