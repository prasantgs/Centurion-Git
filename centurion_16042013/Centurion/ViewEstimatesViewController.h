//
//  ViewEstimatesViewController.h
//  Centurion
//
//  Created by costrategix technologies on 16/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class AppDelegate;
@class CreateNewEstimateViewController;

@interface ViewEstimatesViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate, UISearchBarDelegate>
{
    IBOutlet UITableView *tbl_Locations;
    IBOutlet UILabel *lbl_LocationCount;
    IBOutlet UITableView *tbl_Reports;
    IBOutlet UILabel *lbl_ReportsCount;
    
    AppDelegate *appDelegate;
    NSMutableArray *arr_Locations;
    NSMutableArray *arr_Reports;
    int columnCount;
    int rowCount;
    int deleteObject;
    int tag_Rowbtn;
    CreateNewEstimateViewController *obj_CreateNewEstimateViewController;
    
    int selectedReport;
    int selectedLocation;
    UIButton *buttonMail[100];
    
    NSString *str_CommitTable;
    int deletedRow;
    NSMutableArray *arr_temp_estimatorinstance;
    NSMutableArray *arr_temp_estimate;
    NSMutableArray *arr_estimate;
    NSMutableArray *arr_temp_answer;
    NSMutableArray *arr_estimatorinstance;
    
    //SearchBar Variables
    
    IBOutlet UISearchBar *searchBar;
    NSMutableArray *arr_filteredData;               //will be storing data that will be displayed in table
    NSMutableArray *arr_allRecords;                 //will be storing data that will be displayed in table
    NSMutableArray *arr_LocationNames;
    int isSearch;                                   // 1 if searching
    int intDeleteLoc;                               //to store previous selected location
    
    
    IBOutlet UILabel *lbl_header_report;            //Showing total number of reports
    
    //Prasanth 2013/03/27 Start...
    //NSIndexPath *indextable;
    NSMutableArray *sectionFirstReport;
    int hide_Show;                                  //hide - 0 ; show - 1
    IBOutlet UIButton *Btn_Action;                  //To show selection; delete,mail,cancel
    //UIButton *hidenav;
    
    UIView *hidden_Action_View;                     //View showing button delete,email,cancel
    //NSString *Myreport;
    
    //Prashnath 02/04/2013 Start...
    BOOL boolReport;
    BOOL boolReportnext;
    UILabel *lblLocat;
    UIImageView *imgLocat;
    //Prashnath 02/04/2013 End...
    UILabel *lblName;
    UILabel *lblCustomer;
    UILabel *lblCustomer1;
    UIImageView *imgCustomer, *imgCustomer1;
    NSMutableArray *selectMutArray, *deleteMutArray;
    UIView *titleView;
    //int chk_selected;
}
-(void)setupLocationTable;
/*
-(void)LocationColumn1:(id)sender;
-(void)LocationColumn2:(id)sender;
-(void)LocationColumn3:(id)sender;
-(void)showDeletePopover:(NSIndexPath *)indexpath points:(CGPoint)point; */
//-(void)longPressGestureRecognizerStateChanged:(UILongPressGestureRecognizer *)gesture;
-(void)deleteLocation;
-(void)deleteLocation1;
-(void)deleteAllLocations;

-(IBAction)Btn_Back_Clicked:(id)sender;
-(IBAction)Btn_CreateEstimates_Clicked:(id)sender;
-(IBAction)Btn_Action_Clicked:(id)sender;
-(void)headerview;
-(void)EmailPDFfile;
@end
