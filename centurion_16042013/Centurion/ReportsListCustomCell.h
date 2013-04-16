//
//  ReportsListCustomCell.h
//  Centurion
//
//  Created by costrategix technologies on 22/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportsListCustomCell : UITableViewCell
{
    UILabel *lbl_ReportName;
    UILabel *lbl_UpdatedDate;
    UIButton *btn_Download;
    UIButton *btn_email;
}
@property (nonatomic, retain) UILabel *lbl_ReportName;
@property (nonatomic, retain) UILabel *lbl_UpdatedDate;
@property (nonatomic, retain) UIButton *btn_Download;
@property (nonatomic, retain) UIButton *btn_email; 
@end
