//
//  CustomCell.h
//  PicBook
//
//  Created by costrategix technologies on 29/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavedLocationCustomCell : UITableViewCell
{
    UIImageView *img_Location1;
    UIImageView *img_Location2;
    UIImageView *img_Location3;
    
    UIButton *btn_Row1;
    UIButton *btn_Row2;
    UIButton *btn_Row3;
    
    UILabel *lbl_LocationName1;
    UILabel *lbl_LocationName2;
    UILabel *lbl_LocationName3;
    
    UILabel *lbl_LocationAddress1;
    UILabel *lbl_LocationAddress2;
    UILabel *lbl_LocationAddress3;
    
    UILabel *lbl_LocationReports1;
    UILabel *lbl_LocationReports2;
    UILabel *lbl_LocationReports3;
    
    UILabel *lbl_ReportName;
    UILabel *lbl_UpdatedDate;
    //UIButton *btn_Row;
    
    UILabel *lbl_Notes;
    
    //Displaying location information in report table when searching
    UILabel *lbl_LocationName4;
    UILabel *lbl_LocationName5;
    
    UIButton *checkbox_Button;
    UILabel *lbl_Place;
    UILabel *lbl_CustomerName;
}

@property (nonatomic, retain) UIImageView *img_Location1;
@property (nonatomic, retain) UIImageView *img_Location2;
@property (nonatomic, retain) UIImageView *img_Location3;

@property (nonatomic, retain) UIButton *btn_Row1;
@property (nonatomic, retain) UIButton *btn_Row2;
@property (nonatomic, retain) UIButton *btn_Row3;

@property (nonatomic, retain) UILabel *lbl_LocationName1;
@property (nonatomic, retain) UILabel *lbl_LocationName2;
@property (nonatomic, retain) UILabel *lbl_LocationName3;

@property (nonatomic, retain) UILabel *lbl_LocationAddress1;
@property (nonatomic, retain) UILabel *lbl_LocationAddress2;
@property (nonatomic, retain) UILabel *lbl_LocationAddress3;

@property (nonatomic, retain) UILabel *lbl_LocationReports1;
@property (nonatomic, retain) UILabel *lbl_LocationReports2;
@property (nonatomic, retain) UILabel *lbl_LocationReports3;

@property (nonatomic, retain) UILabel *lbl_ReportName;
@property (nonatomic, retain) UILabel *lbl_UpdatedDate;
//@property (nonatomic, retain) UIButton *btn_Row;

@property (nonatomic, retain) UILabel *lbl_Notes;

@property (nonatomic, retain) UILabel *lbl_LocationName4;
@property (nonatomic, retain) UILabel *lbl_LocationName5;
@property(nonatomic, retain) UIButton *checkbox_Button;
@property (nonatomic, retain)  UILabel *lbl_CustomerName;
@property (nonatomic, retain) UILabel *lbl_Place;

@end
