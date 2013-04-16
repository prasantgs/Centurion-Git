//
//  AddEstimatorViewController.h
//  Centurion
//
//  Created by costrategix technologies on 25/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@interface AddEstimatorViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *tbl_Estimator;
    
    AppDelegate *appDelegate;
    NSMutableArray *arr_Estimator;
    NSString *str_EstimateID;
    NSMutableArray *arr_SelectedEstimators;
    NSMutableArray *arr_EstimatorInstanceRecords;
}

@property (nonatomic, retain) NSString *str_EstimateID;
@end
