//
//  CustomCell.m
//  PicBook
//
//  Created by costrategix technologies on 29/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SavedLocationCustomCell.h"

@implementation SavedLocationCustomCell
@synthesize img_Location1,img_Location2,img_Location3;
@synthesize btn_Row1,btn_Row2,btn_Row3;
@synthesize lbl_LocationName1,lbl_LocationName2,lbl_LocationName3;
@synthesize lbl_LocationAddress1,lbl_LocationAddress2,lbl_LocationAddress3;
@synthesize lbl_LocationReports1,lbl_LocationReports2,lbl_LocationReports3;
@synthesize lbl_ReportName, lbl_UpdatedDate, lbl_Notes;
@synthesize lbl_LocationName4,lbl_LocationName5;
@synthesize lbl_CustomerName,checkbox_Button,lbl_Place;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        //Location Image
        img_Location1 = [[UIImageView alloc] init];
        img_Location1.image = [UIImage imageNamed:@"add.png"];
        img_Location1.hidden = TRUE;
        [self addSubview:img_Location1];
        [img_Location1 release];
        
        img_Location2 = [[UIImageView alloc] init];
        img_Location2.image = [UIImage imageNamed:@"add.png"];
        img_Location2.hidden = TRUE;
        [self addSubview:img_Location2];
        [img_Location2 release];

        img_Location3 = [[UIImageView alloc] init];
        img_Location3.image = [UIImage imageNamed:@"add.png"];
        img_Location3.hidden = TRUE;
        [self addSubview:img_Location3];
        [img_Location3 release];
        
        //Location Name
        lbl_LocationName1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 16, 280,20)];
        lbl_LocationName1.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];//[UIFont boldSystemFontOfSize:16];
        lbl_LocationName1.textColor = [UIColor blackColor];
        lbl_LocationName1.backgroundColor = [UIColor clearColor];
        lbl_LocationName1.hidden = TRUE;
        [self addSubview:lbl_LocationName1];
        [lbl_LocationName1 release];
        
        lbl_LocationName2 = [[UILabel alloc] init];
        lbl_LocationName2.font = [UIFont boldSystemFontOfSize:15];
        lbl_LocationName2.textColor = [UIColor blackColor];
        lbl_LocationName2.hidden = TRUE;
        [self addSubview:lbl_LocationName2];
        [lbl_LocationName2 release];
        
        lbl_LocationName3 = [[UILabel alloc] init];
        lbl_LocationName3.font = [UIFont boldSystemFontOfSize:15];
        lbl_LocationName3.textColor = [UIColor blackColor];
        lbl_LocationName3.hidden = TRUE;
        [self addSubview:lbl_LocationName3];
        [lbl_LocationName3 release];
         
        //Location Address
        lbl_LocationAddress1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 34, 280,20)];
        lbl_LocationAddress1.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];//[UIFont boldSystemFontOfSize:13];
        lbl_LocationAddress1.textColor = [UIColor lightGrayColor];
        lbl_LocationAddress1.backgroundColor = [UIColor clearColor];
        lbl_LocationAddress1.hidden = TRUE;
        [self addSubview:lbl_LocationAddress1];
        [lbl_LocationAddress1 release];
        
        lbl_LocationAddress2 = [[UILabel alloc] init];
        lbl_LocationAddress2.font = [UIFont systemFontOfSize:13];
        lbl_LocationAddress2.textColor = [UIColor grayColor];
        [self addSubview:lbl_LocationAddress2];
        lbl_LocationAddress2.hidden = TRUE;
        [lbl_LocationAddress2 release];
        
        lbl_LocationAddress3 = [[UILabel alloc] init];
        lbl_LocationAddress3.font = [UIFont systemFontOfSize:13];
        lbl_LocationAddress3.textColor = [UIColor grayColor];
        lbl_LocationAddress3.hidden = TRUE;
        [self addSubview:lbl_LocationAddress3];
        [lbl_LocationAddress3 release];
        
        //Location Total Reports
        lbl_LocationReports1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 51, 280,20)];
        lbl_LocationReports1.font = [UIFont fontWithName:@"HelveticaNeue" size:13];//[UIFont boldSystemFontOfSize:12];
        lbl_LocationReports1.textColor = [UIColor colorWithRed:210/255 green:35/255 blue:35/255 alpha:1.0];
        lbl_LocationReports1.backgroundColor = [UIColor clearColor];
        lbl_LocationReports1.hidden = TRUE;
        [self addSubview:lbl_LocationReports1];
        [lbl_LocationReports1 release];
        
        lbl_LocationReports2 = [[UILabel alloc] init];
        lbl_LocationReports2.font = [UIFont systemFontOfSize:13];
        lbl_LocationReports2.textColor = [UIColor blueColor];
        lbl_LocationReports2.hidden = TRUE;
        [self addSubview:lbl_LocationReports2];
        [lbl_LocationReports2 release];
        
        lbl_LocationReports3 = [[UILabel alloc] init];
        lbl_LocationReports3.font = [UIFont systemFontOfSize:13];
        lbl_LocationReports3.textColor = [UIColor blueColor];
        lbl_LocationReports3.hidden = TRUE;
        [self addSubview:lbl_LocationReports3];
        [lbl_LocationReports3 release];
        
        //Action buttons
        btn_Row1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_Row1.hidden = TRUE;
        btn_Row1.alpha = 1.0;
        [self addSubview:btn_Row1];

        btn_Row2 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_Row2.hidden = TRUE;
        btn_Row2.alpha = 1.0;
        [self addSubview:btn_Row2];

        btn_Row3 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_Row3.hidden = TRUE;
        btn_Row3.alpha = 1.0;
        [self addSubview:btn_Row3];
     
        lbl_ReportName = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 330, 25)];
        lbl_ReportName.backgroundColor = [UIColor clearColor];
        lbl_ReportName.textColor = [UIColor whiteColor];
        lbl_ReportName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        [self addSubview:lbl_ReportName];
        
        lbl_UpdatedDate = [[UILabel alloc] initWithFrame:CGRectMake(595, 0, 250, 50)];
        lbl_UpdatedDate.backgroundColor = [UIColor clearColor];
        lbl_UpdatedDate.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
        lbl_UpdatedDate.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        [self addSubview:lbl_UpdatedDate];
        
        /*btn_Row = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_Row.frame = CGRectMake(670, 10, 26, 20);
        [btn_Row setBackgroundImage:[UIImage imageNamed:@"action_icon_smal.png"] forState:UIControlStateNormal];
        btn_Row.hidden = TRUE;
        [self addSubview:btn_Row];*/
        
        lbl_Notes = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, 185, 60)];
        lbl_Notes.hidden = TRUE;
        lbl_Notes.backgroundColor = [UIColor clearColor];
        lbl_Notes.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
        lbl_Notes.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        lbl_Notes.numberOfLines = 2;
        [self addSubview:lbl_Notes];
        
        lbl_LocationName4 = [[UILabel alloc] initWithFrame:CGRectMake(550, 23, 250, 50)];
        lbl_LocationName4.backgroundColor = [UIColor clearColor];
        lbl_LocationName4.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
        lbl_LocationName4.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        [self addSubview:lbl_LocationName4];
        
        lbl_LocationName5 = [[UILabel alloc] initWithFrame:CGRectMake(550, 43, 250, 50)];
        lbl_LocationName5.backgroundColor = [UIColor clearColor];
        lbl_LocationName5.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
        lbl_LocationName5.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        [self addSubview:lbl_LocationName5];

        lbl_CustomerName = [[UILabel alloc] initWithFrame:CGRectMake(435, 10, 340, 25)];
        lbl_CustomerName.backgroundColor = [UIColor clearColor];
        lbl_CustomerName.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
        lbl_CustomerName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        [self addSubview:lbl_CustomerName];
        
        
        lbl_Place = [[UILabel alloc] initWithFrame:CGRectMake(260, 10, 160, 25)];
        lbl_Place.backgroundColor = [UIColor clearColor];
        lbl_Place.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
        lbl_Place.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        [self addSubview:lbl_Place];
        
        checkbox_Button = [UIButton buttonWithType:UIButtonTypeCustom];
        checkbox_Button.frame = CGRectMake(14, 25, 25, 25);
        [checkbox_Button setBackgroundImage:[UIImage imageNamed:@"radio_button-gry.png"] forState:UIControlStateNormal];
        [checkbox_Button setBackgroundImage:[UIImage imageNamed:@"radio_button-green.png"] forState:UIControlStateSelected];
        checkbox_Button.adjustsImageWhenHighlighted=YES;
        checkbox_Button.hidden = TRUE;
        [self addSubview:checkbox_Button];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}
-(void)dealloc{
    [super dealloc];
    
    //[btn_Row release];
    [btn_Row1 release];
    [btn_Row2 release];
    [btn_Row3 release];
}
@end
