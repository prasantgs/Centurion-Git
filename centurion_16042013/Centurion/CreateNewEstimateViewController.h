//
//  CreateNewEstimateViewController.h
//  Centurion
//
//  Created by costrategix technologies on 20/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@interface CreateNewEstimateViewController : UIViewController <UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,UITextViewDelegate>
{
    AppDelegate *appDelegate;
    
    IBOutlet UITextField *txt_EstimateName;
    IBOutlet UITextField *txt_ContactName;
    IBOutlet UITextField *txt_CustomerLastName;
    IBOutlet UITextField *txt_ContactNumber;
    IBOutlet UITextField *txt_EmailAddress;
    IBOutlet UITextView *txtV_Notes;
    IBOutlet UIPickerView *pkr_Location;
    IBOutlet UIToolbar *tool_Location;
    IBOutlet UILabel *lbl_LocationName;
    IBOutlet UILabel *lbl_CreateEditEstimateTitle;
    IBOutlet UILabel *lbl_Department;
    
    NSMutableArray *arr_LocationList;
    NSMutableArray *arr_DepartmentList;
    NSMutableDictionary *dict_SelectedLocation;
    NSString *str_LocationId;
    NSString *str_DepartmentID;
    NSString *str_Department;
    int selectedLocation;
    
    NSArray *arr_UpdateDetails;
    int kOFFSET_FOR_KEYBOARD;
    int int_RowSelect;
    int int_RowSelectD;

    NSMutableArray *selectedItems;
    NSArray *arr_SelectedDepartments;
}

@property (nonatomic, retain) NSString *str_EstimateId;
@property (nonatomic, retain) NSString *str_FromSurvey;

-(IBAction)LocationSelectionPressed:(id)sender;
-(IBAction)tool_DonePressed:(id)sender;
-(IBAction)SavePressed:(id)sender;
-(IBAction)CancelPressed:(id)sender;

-(IBAction)DepartmentSelectionPressed:(id)sender;

@end
