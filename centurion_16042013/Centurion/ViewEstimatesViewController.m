//
//  ViewEstimatesViewController.m
//  Centurion
//
//  Created by costrategix technologies on 16/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewEstimatesViewController.h"
#import "AppDelegate.h"
#import "SKDatabase.h"
#import "SavedLocationCustomCell.h"
#import "CreateNewEstimateViewController.h"
#import "NSDate+Date_NSDate.h"
#import "SurvayPageViewController.h"
#import "ViewPDFViewController.h"
#import "SurveyViewController.h"


@implementation ViewEstimatesViewController

-(void)dealloc {

    [lbl_header_report release];

    if(arr_Locations)
    {
        [arr_Locations release];
        arr_Locations = nil;
    }
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (deleteMutArray)
    {
        [deleteMutArray release];
        deleteMutArray = nil;
    }
    deleteMutArray = [[NSMutableArray alloc] init];
    
    hidden_Action_View =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 1040,72)];
    [hidden_Action_View setBackgroundColor:[UIColor grayColor]];
    hidden_Action_View.hidden = TRUE;
    [self.view addSubview:hidden_Action_View];
    [hidden_Action_View release];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:hidden_Action_View.bounds];
    imgView.image = [UIImage imageNamed:@"rhsover_black_strip_full.jpg"];
    [hidden_Action_View addSubview:imgView];
    [imgView release];
    
    UIButton *delete_Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [delete_Button addTarget:self action:@selector(deleteMethod:)forControlEvents:UIControlEventTouchUpInside];
    [delete_Button setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
    delete_Button.frame = CGRectMake(770, 8, 80, 40);;
    [hidden_Action_View addSubview:delete_Button];
    
    
    UIButton *mail_Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [mail_Button addTarget:self action:@selector(mailMethod:)forControlEvents:UIControlEventTouchUpInside];
    [mail_Button setImage:[UIImage imageNamed:@"Mail.png"] forState:UIControlStateNormal];
    mail_Button.frame = CGRectMake(860, 8, 60, 40);
    [hidden_Action_View addSubview:mail_Button];
    
    
    UIButton *cancel_Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel_Button addTarget:self action:@selector(cancelMethod:)forControlEvents:UIControlEventTouchUpInside];
    [cancel_Button setImage:[UIImage imageNamed:@"Cancel.png"] forState:UIControlStateNormal];
    cancel_Button.frame = CGRectMake(930, 8, 80, 40);
    [hidden_Action_View addSubview:cancel_Button];

    self.navigationController.navigationBarHidden = TRUE;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:51.0/256.0 green:64.0/256.0 blue:75.0/256.0 alpha:1.0];
    self.navigationItem.title = @"My Locations";
    
    searchBar.delegate = self;
    searchBar.text = @"";
    isSearch = 0;
    intDeleteLoc = -1;
    
    arr_filteredData = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Home" style: UIBarButtonItemStyleBordered target: nil action: nil];    
    [self.navigationItem setBackBarButtonItem: newBackButton];
    [newBackButton release];

    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    tbl_Locations.delegate = self;
    tbl_Locations.dataSource = self;
    
    tbl_Reports.delegate = self;
    tbl_Reports.dataSource = self;
    
    //Add long press gesture to popup delete functionality
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(longPressGestureRecognizerStateChanged:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    lpgr.delegate = self;
    [tbl_Reports addGestureRecognizer:lpgr];
    [lpgr release];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(estimateEdited:)
                                                 name:@"refreshDataOnLocationList"
                                               object:nil];
}

/*- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}*/

-(void)estimateEdited:(NSNotification *) notification
{
    // it moves to survey page for editing the selected Report under perticular location
    
    SurveyViewController *obj_SurvayPageViewController = [[SurveyViewController alloc] initWithNibName:@"SurveyViewController" bundle:nil];
    obj_SurvayPageViewController.dict_Details = notification.userInfo;
    [self.navigationController pushViewController:obj_SurvayPageViewController animated:YES];
    [obj_SurvayPageViewController release];
    obj_SurvayPageViewController = nil;
}

-(void)setupLocationTable
{
    // its for fetching the saved locations from DB
    if(arr_Locations)
    {
        [arr_Locations release];
        arr_Locations = nil;
    }
    [arr_Locations removeAllObjects];
    arr_Locations = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select l.name, l.id, l.address_1, l.city, l.state, l.zip, count(e.location_id) from location l join estimate e on e.location_id = l.id where l.delete_flag = 0 and user_id = %@ group by e.location_id order by l.name",[appDelegate.dict_GlobalInfo objectForKey:@"id"]]]];
    [arr_Locations retain];
    tbl_Reports.hidden = TRUE;
    lbl_LocationCount.text = [NSString stringWithFormat:@"Locations"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupLocationTable];
    
    if (arr_Locations)
    {
        if ([arr_Locations count] > 0)
        {
            [self headerview];
            
            [tbl_Locations reloadData];
            [self tableView: tbl_Locations didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction)Btn_CreateEstimates_Clicked:(id)sender
{
    // its for creating the new estimate popup
    
    if(obj_CreateNewEstimateViewController)
    {
        [obj_CreateNewEstimateViewController release];
        obj_CreateNewEstimateViewController = nil;
    }
    obj_CreateNewEstimateViewController = [[CreateNewEstimateViewController alloc] initWithNibName:@"CreateNewEstimateViewController" bundle:nil];
    obj_CreateNewEstimateViewController.str_FromSurvey = @"";
    obj_CreateNewEstimateViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:obj_CreateNewEstimateViewController animated:YES];
}

-(IBAction)Btn_Back_Clicked:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark -
#pragma mark UITableView Datasource and Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == tbl_Locations)
    {
        lbl_LocationCount.text = [NSString stringWithFormat:@"Locations"];
        
        if ([arr_Locations count] == 0)
            return 0;
        else
            return [arr_Locations count]+2;
    }
    else
    {
        if (isSearch == 0)
        {
            return [arr_Reports count];
        }
        else
        {
            return [arr_filteredData count];
        }
    }
}

#pragma mark HeaderView
-(void) headerview
{
    titleView=[[UIView alloc]initWithFrame:CGRectMake(274, 110, 750,50)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    titleView.hidden = FALSE;
    [self.view addSubview:titleView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:titleView.bounds];
    imgView.image = [UIImage imageNamed:@"black_strip_w_line.jpg"];
    [titleView addSubview:imgView];
    [imgView release];
    
    UIImageView *imgName, *imgDate;
    UILabel  *lblDate;
    
    lblName = [[UILabel alloc] init];
    lblName.frame = CGRectMake(60, 30, 250, 20);
    lblName.text = @"NAME";
    //lblName.hidden = TRUE;
    lblName.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
    lblName.backgroundColor =[UIColor clearColor];
    lblName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    [titleView addSubview:lblName];
    [lblName release];
    
    lblDate = [[UILabel alloc] init];
    lblDate.frame = CGRectMake(595, 30, 250, 20);
    lblDate.text = @"LAST UPDATED";
    
    //Prasanth 20130327 Start...
    lblCustomer = [[UILabel alloc] init];
    lblCustomer.frame = CGRectMake(435, 30, 250, 20);
    lblCustomer.text = @"CUSTOMER";
    lblCustomer.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
    lblCustomer.backgroundColor =[UIColor clearColor];
    lblCustomer.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    [titleView addSubview:lblCustomer];
    [lblCustomer release];
    
    lblLocat = [[UILabel alloc] init];
    lblLocat.frame = CGRectMake(260, 30, 250, 20);
    lblLocat.text = @"LOCATION";
    lblLocat.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
    lblLocat.backgroundColor =[UIColor clearColor];
    lblLocat.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    [titleView addSubview:lblLocat];
    [lblLocat release];
    //Prasanth 20130327 End...
    
    //Prashanth 02/04/2013 Start... 2ND CUSTOMER...
    lblCustomer1 = [[UILabel alloc] init];
    lblCustomer1.frame = CGRectMake(350, 30, 250, 20);
    lblCustomer1.text = @"CUSTOMER";
    lblCustomer1.hidden = TRUE;
    lblCustomer1.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
    lblCustomer1.backgroundColor =[UIColor clearColor];
    lblCustomer1.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    [titleView addSubview:lblCustomer1];
    [lblCustomer1 release];
    //Prashanth 02/04/2013 End...
    
    lblDate.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
    lblDate.backgroundColor =[UIColor clearColor];
    lblDate.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    [titleView addSubview:lblDate];
    [lblDate release];
    
    imgName = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grey_down_arrow"]];
    imgName.frame = CGRectMake(105, 37, 5, 6);
    [titleView addSubview:imgName];
    [imgName release];
    
    imgDate = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grey_down_arrow"]];
    imgDate.frame = CGRectMake(695, 37, 5, 6);
    [titleView addSubview:imgDate];
    [imgDate release];
    
    //Prasanth 20130327 Start...
    imgLocat = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grey_down_arrow"]];
    imgLocat.frame = CGRectMake(332, 37, 5, 6);
    [titleView addSubview:imgLocat];
    [imgLocat release];
    
    imgCustomer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grey_down_arrow"]];
    imgCustomer.frame = CGRectMake(513, 37, 5, 6);
    [titleView addSubview:imgCustomer];
    [imgCustomer release];
    //Prasanth 20130327 End...
    
    //Prasanth 03/04/2013 Start...
    imgCustomer1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grey_down_arrow"]];
    imgCustomer1.frame = CGRectMake(429, 37, 5, 6);
    [titleView addSubview:imgCustomer1];
    [imgCustomer1 release];
    //Prasanth 03/04/2013 End...
}

/*- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView == tbl_Reports)
    {
        UIView *view_Header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 750, 60)] autorelease];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:view_Header.bounds];
        imgView.image = [UIImage imageNamed:@"black_strip_w_line.jpg"];
        [view_Header addSubview:imgView];
        [imgView release];
        
        UIImageView *imgName, *imgDate;
        UILabel *lblName, *lblDate;
        
        lblName = [[UILabel alloc] init];
        lblName.frame = CGRectMake(30, 30, 250, 20);
        lblName.text = @"NAME";
        lblName.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
        lblName.backgroundColor =[UIColor clearColor];
        lblName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        [view_Header addSubview:lblName];
        [lblName release];
        
        lblDate = [[UILabel alloc] init];
        lblDate.frame = CGRectMake(370, 30, 250, 20);
        lblDate.text = @"LAST UPDATED";
        
        if (isSearch == 1)
        {
            UILabel *lblLocation;
            UIImageView *imgLocation;
            
            lblLocation = [[UILabel alloc] init];
            lblLocation.frame = CGRectMake(550, 30, 250, 20);
            lblLocation.text = @"LOCATION NAME";
            lblLocation.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
            lblLocation.backgroundColor =[UIColor clearColor];
            lblLocation.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
            [view_Header addSubview:lblLocation];
            [lblLocation release];
            
            imgLocation = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grey_down_arrow"]];
            imgLocation.frame = CGRectMake(665, 37, 5, 6);
            [view_Header addSubview:imgLocation];
            [imgLocation release];
        }
        
        lblDate.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
        lblDate.backgroundColor =[UIColor clearColor];
        lblDate.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        [view_Header addSubview:lblDate];
        [lblDate release];
        
        imgName = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grey_down_arrow"]];
        imgName.frame = CGRectMake(75, 37, 5, 6);
        [view_Header addSubview:imgName];
        [imgName release];
        
        imgDate = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grey_down_arrow"]];
        imgDate.frame = CGRectMake(475, 37, 5, 6);
        [view_Header addSubview:imgDate];
        [imgDate release];

        return view_Header;
    }
    else
    {
        UIView *view_header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        view_header.backgroundColor = [UIColor clearColor];
        return view_header;
    }
    return nil;
}*/

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 100;
//}
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"%d%d",indexPath.section,indexPath.row];
    
    SavedLocationCustomCell *cell = (SavedLocationCustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[SavedLocationCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.lbl_LocationName1.hidden = TRUE;
    cell.lbl_LocationName1.textColor = [UIColor blackColor];
    cell.lbl_LocationAddress1.hidden = TRUE;
    cell.lbl_LocationAddress1.textColor = [UIColor grayColor];

    cell.lbl_LocationReports1.hidden = TRUE;
    cell.lbl_LocationReports1.textColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.6f ];

    cell.lbl_ReportName.hidden = TRUE;
    cell.lbl_UpdatedDate.hidden = TRUE;
    //cell.btn_Row.hidden = TRUE;
    
    cell.lbl_LocationName4.hidden = TRUE;
    cell.lbl_LocationName5.hidden = TRUE;
    
    cell.checkbox_Button.hidden = TRUE;
 
    if(selectedLocation > 0)
    {
        cell.lbl_Place.hidden = TRUE;
        lblLocat.hidden = TRUE;
        imgLocat.hidden = TRUE;
        
        lblCustomer.hidden = TRUE;
        imgCustomer.hidden = TRUE;
        cell.lbl_CustomerName.hidden = TRUE;
        //lblCustomer1.hidden = TRUE;
        //imgCustomer1.hidden = TRUE;
    }
    else
    {
        cell.lbl_Place.hidden = FALSE;
        lblLocat.hidden = FALSE;
        imgLocat.hidden = FALSE;
        
        lblCustomer.hidden = FALSE;
        imgCustomer.hidden = FALSE;
        cell.lbl_CustomerName.hidden = FALSE;
        lblCustomer1.hidden = TRUE;
        imgCustomer1.hidden = TRUE;
    }

    if(tableView == tbl_Locations)
    {
        cell.lbl_LocationName1.hidden = FALSE;
        cell.lbl_LocationReports1.hidden = FALSE;

        if(selectedLocation == indexPath.row)
        {
            cell.lbl_LocationName1.textColor = [UIColor whiteColor];
            cell.lbl_LocationAddress1.textColor = [UIColor whiteColor];
            cell.lbl_LocationReports1.textColor = [UIColor whiteColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue_bg_button.jpg"]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            UIImageView *imgWhiteArrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 15)] ;
            imgWhiteArrow.image = [UIImage imageNamed:@"white-arrow.png"];
            cell.accessoryView = imgWhiteArrow;
        }
        else
        {
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lhs-grey-strip.jpg"]] autorelease];
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        if (indexPath.row == 0)
        {
            cell.lbl_LocationAddress1.hidden = TRUE;

            cell.lbl_LocationName1.frame = CGRectMake(20, 20, 280,20);
            cell.lbl_LocationName1.text = @"All Locations";
            cell.lbl_LocationReports1.frame = CGRectMake(20, 39, 280,20);
            cell.lbl_LocationReports1.text = [NSString stringWithFormat:@"%d Reports",[appDelegate.sk lookupCountWhere:[NSString stringWithFormat:@"user_id = '%@'",[appDelegate.dict_GlobalInfo objectForKey:@"id"]] forTable:@"Estimate"]];
        }
        else if (indexPath.row == [arr_Locations count]+1)
        {
            cell.lbl_LocationAddress1.hidden = TRUE;
            cell.lbl_LocationName1.frame = CGRectMake(20, 20, 280,20);
            cell.lbl_LocationName1.text = @"Support Documents";
            cell.lbl_LocationReports1.frame = CGRectMake(20, 39, 280,20);
            cell.lbl_LocationReports1.text = @"0 Documents";
        }
        else
        {
            cell.lbl_LocationAddress1.hidden = FALSE;
            //cell.lbl_LocationName1.frame = CGRectMake(20, 20, 280,20);
            cell.lbl_LocationReports1.frame = CGRectMake(20, 51, 280,20);
            int int_minusofindexpath = indexPath.row - 1;
            
            cell.lbl_LocationName1.text = [[arr_Locations objectAtIndex:int_minusofindexpath] objectForKey:@"name"];
            
            cell.lbl_LocationAddress1.text = [NSString stringWithFormat:@"%@, %@",[[arr_Locations objectAtIndex:int_minusofindexpath] objectForKey:@"city"],[[arr_Locations objectAtIndex:int_minusofindexpath] objectForKey:@"state"]];
            
            cell.lbl_LocationReports1.text = [NSString stringWithFormat:@"%@ Reports",[[arr_Locations objectAtIndex:int_minusofindexpath] objectForKey:@"count(e.location_id)"]];
        }
    }
    else
    {
        //Add long press gesture to popup delete functionality
        /*UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                                  initWithTarget:self action:@selector(longPressGestureRecognizerStateChanged:)];
            lpgr.minimumPressDuration = 2.0; //seconds
            lpgr.delegate = self;
            [cell addGestureRecognizer:lpgr];
            [lpgr release];*/
        
        cell.lbl_ReportName.hidden = FALSE;
        cell.lbl_UpdatedDate.hidden = FALSE;
        cell.lbl_Notes.hidden = FALSE;
        
        //Prasanth 2013/03/27 Start...
        if(Btn_Action.selected)
        {
            if (deleteMutArray)
                
            {    if ([deleteMutArray containsObject:[arr_Reports objectAtIndex:indexPath.row]])
                {
                    cell.checkbox_Button.selected = TRUE;
                }
                else
                {
                    cell.checkbox_Button.selected = FALSE;
                }
            }
            else
            {
                cell.checkbox_Button.selected = FALSE;
            }
            cell.checkbox_Button.hidden = FALSE;
        }
        else
        {
            cell.checkbox_Button.hidden = TRUE;
        }
        
        if (isSearch == 1)
        {
            cell.lbl_LocationName4.hidden = FALSE;
            cell.lbl_LocationName5.hidden = FALSE;
            
            cell.lbl_ReportName.text = [[arr_filteredData objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.lbl_UpdatedDate.text = [NSString stringWithFormat:@"%@",[NSDate formattedString:[[arr_filteredData objectAtIndex:indexPath.row] objectForKey:@"update_dt_tm"]]];
            cell.lbl_Notes.text = [[arr_filteredData objectAtIndex:indexPath.row] objectForKey:@"note"];
            
            NSArray *arrLocationName = [appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select name,city,state from location where id = %@",[[arr_filteredData objectAtIndex:indexPath.row] objectForKey:@"location_id"]]];
            
            NSDictionary *dictTemp = [[NSDictionary alloc]initWithDictionary:[arrLocationName objectAtIndex:0]];
            
            cell.lbl_LocationName4.text = [dictTemp objectForKey:@"name"];
            
            NSString *strLocationName = [dictTemp objectForKey:@"city"];
            strLocationName = [strLocationName stringByAppendingString:[NSString stringWithFormat:@", %@",[dictTemp objectForKey:@"state"]]];
            
            cell.lbl_LocationName5.text = strLocationName;
        }
        else
        {
            [cell.checkbox_Button addTarget:self action:@selector(checkButton:) forControlEvents:UIControlEventTouchUpInside];
            cell.checkbox_Button.tag = indexPath.row;
            cell.lbl_Notes.text = [[arr_Reports objectAtIndex:indexPath.row] objectForKey:@"note"];
            cell.lbl_CustomerName.text = [[arr_Reports objectAtIndex:indexPath.row] objectForKey:@"contact_name"];
            
            selectMutArray  = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select l.name from location as l join estimate as e on e.location_id = l.id where e.location_id = %@",[[arr_Reports objectAtIndex:indexPath.row] objectForKey:@"location_id"]]]];
            
            cell.lbl_Place.text = [[selectMutArray objectAtIndex:0] objectForKey:@"name"];
            cell.lbl_ReportName.text = [[arr_Reports objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.lbl_UpdatedDate.text = [NSString stringWithFormat:@"%@",[NSDate formattedString:[[arr_Reports objectAtIndex:indexPath.row] objectForKey:@"update_dt_tm"]]];
            cell.lbl_Notes.text = [[arr_Reports objectAtIndex:indexPath.row] objectForKey:@"note"];
        }
        if(selectedReport == indexPath.row)
        {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectedImageForReport.jpg"]];
        }
        else
            cell.backgroundView = nil;
        
        
        if(boolReport) //Set Boolean to hide & show(Customer, Location, cell.text and title)...
        {
            lblLocat.hidden = FALSE;
            imgLocat.hidden = FALSE;
            cell.lbl_Place.hidden = FALSE;
            
            lblCustomer.hidden = FALSE;
            imgCustomer.hidden = FALSE;
            cell.lbl_CustomerName.hidden = FALSE;
            [cell.lbl_CustomerName setFrame:CGRectMake(435, 10, 340, 25)];
        }
        else
        {
            cell.lbl_CustomerName.hidden = FALSE;
            [cell.lbl_CustomerName setFrame:CGRectMake(355, 0, 160, 40)];
        }
        
        if (boolReportnext)
        {
            lblCustomer1.hidden = FALSE;
            imgCustomer1.hidden = FALSE;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [searchBar resignFirstResponder];
    
    if(tableView == tbl_Locations)
    {
        selectedLocation = indexPath.row;
        selectedReport = -1;
        
        if(arr_Reports)
        {
            [arr_Reports release];
            arr_Reports = nil;
        }
        
        [tbl_Locations reloadData];
        
        if (indexPath.row == 0)
        {
            boolReport = TRUE;  //Set boolean...
            boolReportnext = FALSE;
            
            arr_Reports = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate where user_id = '%@'",[appDelegate.dict_GlobalInfo objectForKey:@"id"]]]];
            
            int int_totalReports = [appDelegate.sk lookupCountWhere:[NSString stringWithFormat:@"user_id = '%@'",[appDelegate.dict_GlobalInfo objectForKey:@"id"]] forTable:@"estimate"];
            lbl_header_report.text = [NSString stringWithFormat:@"%d Results", int_totalReports];
            lbl_header_report.hidden = FALSE;
        }
        else if (indexPath.row == [arr_Locations count]+1)
        {
            lbl_header_report.text = @"0 Results";

            boolReport = FALSE;
            boolReportnext = TRUE;
        }
        else
        {
            boolReport = FALSE;
            boolReportnext = TRUE;
            
            arr_Reports = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate where location_id = %@ and user_id = '%@' order by id",[[arr_Locations objectAtIndex:indexPath.row - 1] objectForKey:@"id"],[appDelegate.dict_GlobalInfo objectForKey:@"id"]]]];
            lbl_header_report.text = [NSString stringWithFormat:@"%d Reports", arr_Reports.count];
            lbl_header_report.hidden = FALSE;
        }
        [arr_Reports retain];
        
        isSearch = 0;
        searchBar.text = @"";
        tbl_Reports.hidden = FALSE;
        titleView.hidden = FALSE;
        [tbl_Reports reloadData];
        [tbl_Locations reloadData];
    }

    else if (tbl_Reports)
    {
        SurveyViewController *obj_SurvayPageViewController = [[SurveyViewController alloc] initWithNibName:@"SurveyViewController" bundle:nil];
        
        if (isSearch == 0)
        {
            obj_SurvayPageViewController.dict_Details = [arr_Reports objectAtIndex:indexPath.row];
        }
        else
        {
            obj_SurvayPageViewController.dict_Details = [arr_filteredData objectAtIndex:indexPath.row];
        }
        
        [self.navigationController pushViewController:obj_SurvayPageViewController animated:YES];
        [obj_SurvayPageViewController release];
        obj_SurvayPageViewController = nil;
    }
}

//smr 12/04/2013 code...

/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{ 
    if(tableView == tbl_Locations)
    {
        str_CommitTable = @"Location";
        [str_CommitTable retain];
        // showing alert for deleting the saved location
        if (indexPath.row == 0)
        {
            deletedRow = -2;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete all estimates?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
            [alert show];
            [alert release];
        }
        else if (indexPath.row == [arr_Locations count]+1)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You cannot delete Support Documents." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else
        {
            deletedRow = (indexPath.row) - 1;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete all estimates for this location?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
            [alert show];
            [alert release];
        }
    }
}*/

-(void)deleteAllLocations
{

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)//Cancel Button Pressed
    {
    }
    else// ok button pressed
    {
        if([str_CommitTable isEqualToString:@"Reports"])
        {
            for(NSDictionary *dict in deleteMutArray)
            {
                if([arr_Reports containsObject:dict])
                {
                    [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from estimate where user_id = %@ and id = %@",[appDelegate.dict_GlobalInfo objectForKey:@"id"],[dict objectForKey:@"id"]] forTable:@"estimate"];
                    [arr_Reports removeObject:dict];
                    [arr_Reports retain];
                }
            }
            
            [deleteMutArray removeAllObjects];
            
            if(deleteMutArray)
            {
                [deleteMutArray release];
                deleteMutArray = nil;
                
                deleteMutArray = [[NSMutableArray alloc] init];
            }
            else
                deleteMutArray = [[NSMutableArray alloc] init];
            
            
            int int_totalReports = [appDelegate.sk lookupCountWhere:[NSString stringWithFormat:@"user_id = '%@'",[appDelegate.dict_GlobalInfo objectForKey:@"id"]] forTable:@"estimate"];
            lbl_header_report.text = [NSString stringWithFormat:@"%d Results", int_totalReports];
            
            lbl_header_report.hidden = FALSE;
            Btn_Action.selected = TRUE;
            
            if ([arr_Reports count] == 0)
            {
                if(selectedLocation == 0)
                {
                    [arr_Locations removeAllObjects];
                    [arr_Locations retain];
                }
                else
                {
                    int z = selectedLocation - 1;
                    [arr_Locations removeObjectAtIndex:z];
                    [arr_Locations retain];
                }
                selectedLocation = -1;
                tbl_Reports.hidden = TRUE;
                titleView.hidden = TRUE;
                tbl_Reports.hidden = TRUE;
            }
            else
            {
                if(arr_Locations)
                {
                    [arr_Locations release];
                    arr_Locations = nil;
                }
                [arr_Locations removeAllObjects];
                arr_Locations = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select l.name, l.id, l.address_1, l.city, l.state, l.zip, count(e.location_id) from location l join estimate e on e.location_id = l.id where l.delete_flag = 0 and user_id = %@ group by e.location_id order by l.name",[appDelegate.dict_GlobalInfo objectForKey:@"id"]]]];
                
                [arr_Locations retain];
                
                if ([arr_Locations count] < 1)
                {
                    selectedLocation = -1;
                    lbl_header_report.hidden = TRUE;
                    titleView.hidden = TRUE;
                    tbl_Reports.hidden = TRUE;
                    [self cancelMethod:nil];
                }
            }

            [tbl_Reports reloadData];
            [tbl_Locations reloadData];
        }
        //DElete action in location table
        else if ([str_CommitTable isEqualToString: @"Location"])
        {
            if (deletedRow == -2)
            {
                [self deleteAllLocations];
                //NSLog(@"Delete All location");
            }
            else
            {
                [self deleteLocation1];
                //NSLog(@"Delete Particular location");
            }
        }
    }
}

-(IBAction)Btn_Action_Clicked:(id)sender
{
    str_CommitTable = @"Reports";
    hidden_Action_View.hidden = FALSE;
    Btn_Action.selected = TRUE;
    if (deleteMutArray)
    {
        [deleteMutArray release];
        deleteMutArray = nil;
    }
    deleteMutArray = [[NSMutableArray alloc] init];
    [tbl_Reports reloadData];
}

-(void)checkButton:(id)sender
{
    UIButton *ckButton = (UIButton *)sender;
    
    if (ckButton.selected == NO)
    {
        [ckButton setSelected:YES];
        
        [deleteMutArray addObject:[arr_Reports objectAtIndex:ckButton.tag]];
        [deleteMutArray retain];
    }
    else if(ckButton.selected == YES)
    {
        [ckButton setSelected:NO];
        
        NSDictionary *dict = [arr_Reports objectAtIndex:ckButton.tag];
        [deleteMutArray removeObject:dict];
        [deleteMutArray retain];
    }
}

-(void)deleteMethod:(id)sender
{
    if ([deleteMutArray count] > 0)
    {
        UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete selected estimates?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
        myalert.tag = 1;
        [myalert show];
        [myalert center];
        [myalert release];
    }
    else
    {
        UIAlertView *myalertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please select at least one estimate!!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [myalertView show];
        [myalertView center];
        [myalertView release];
    }
}

-(void)mailMethod:(id)sender
{
    UIAlertView *mailAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This function is not yet implemented!!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [mailAlert show];
    [mailAlert center];
    [mailAlert release];
}

-(void)cancelMethod:(id)sender
{
    Btn_Action.selected = FALSE;
    hidden_Action_View.hidden = TRUE;
    
    if (deleteMutArray)
    {
        [deleteMutArray release];
        deleteMutArray = nil;
    }
    [tbl_Reports reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView ==tbl_Reports)
    {
        return UITableViewCellEditingStyleNone;
    }
    else if (tableView == tbl_Locations)
    {
        if (indexPath.row == [arr_Locations count] + 1)
        {
            return UITableViewCellEditingStyleNone;
        }
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView ==tbl_Reports)
    {
        //null
    }
    else if (tableView == tbl_Locations)
    {
        str_CommitTable = @"Location";
        [str_CommitTable retain];
        // showing alert for deleting the saved location
        if (indexPath.row == 0)
        {
            deletedRow = -2;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete all location estimates?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
            [alert show];
            [alert release];
        }
        else if (indexPath.row == [arr_Locations count]+1)
        {
            deletedRow = indexPath.row;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You cannot delete Support Documents." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else
        {
            deletedRow = (indexPath.row) - 1;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete all estimates for this location?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
            [alert show];
            [alert release];
        }
    }
}

#pragma mark deleteLocation1
//method for deleting selected Location using swipe to delete
-(void)deleteLocation1 
{
    if (arr_temp_estimate)
    {
        [arr_temp_estimate release];
        arr_temp_estimate = nil;
    }
    
    //NSLog(@"%@",arr_Locations);
    NSString *sql;
    if (deletedRow == -2)
    {
        sql = [NSString stringWithFormat:@"select * from estimate where user_id = %@",[appDelegate.dict_GlobalInfo objectForKey:@"id"]];
    }
    else
    {
        sql = [NSString stringWithFormat:@"select * from estimate where user_id = %@ and location_id = %@",[appDelegate.dict_GlobalInfo objectForKey:@"id"],[[arr_Locations objectAtIndex:deletedRow] objectForKey:@"id"]];
    }
    arr_temp_estimate = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:sql]];
    
    for (int i=0; i < [arr_temp_estimate count]; i++)
    {
        [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from answer where estimator_instance_id = %@",[[arr_temp_estimate objectAtIndex:i]objectForKey:@"id"]] forTable:@"answer"];
        
        NSMutableArray *arr_temp_costs = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from costs where estimator_instance_id = %@",[[arr_temp_estimate objectAtIndex:i]objectForKey:@"id"]]]];
        
        if ([arr_temp_costs count] > 0)
        {
            [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from costs where estimator_instance_id = %@",[[arr_temp_estimate objectAtIndex:i]objectForKey:@"id"]] forTable:@"costs"];
        }
        [arr_temp_costs release];
        
        [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from estimator_instance where estimate_id = %@",[[arr_temp_estimate objectAtIndex:i]objectForKey:@"id"]] forTable:@"estimator_instance"];
    }

    selectedLocation = -1;
    [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from estimate where user_id = %@ and location_id = %@",[appDelegate.dict_GlobalInfo objectForKey:@"id"],[[arr_Locations objectAtIndex:deletedRow] objectForKey:@"id"]] forTable:@"estimate"];
    [arr_Locations removeObjectAtIndex:deletedRow];
    [tbl_Locations reloadData];
    
    [arr_Reports removeAllObjects];
    arr_Reports = nil;
    [tbl_Reports reloadData];
    
    if ([arr_Locations count] < 1)
    {
        titleView.hidden = TRUE;
        lbl_header_report.hidden = TRUE;
        tbl_Reports.hidden =TRUE;
    }
}


/*-(void)deleteReports // method for deleting selected Report
{
    if (arr_temp_estimate)
    {
        [arr_temp_estimate release];
        arr_temp_estimate = nil;
    }
    
    if (isSearch == 1)
    {
        arr_temp_estimate = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate where user_id = %@ and id = %@",[appDelegate.dict_GlobalInfo objectForKey:@"id"],[[arr_filteredData objectAtIndex:deletedRow]objectForKey:@"id"]]]];
    }
    else
    {
        arr_temp_estimate = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate where user_id = %@ and id = %@",[appDelegate.dict_GlobalInfo objectForKey:@"id"],[[arr_Reports objectAtIndex:deletedRow]objectForKey:@"id"]]]];
    }

    
   // arr_temp_estimate = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate where user_id = %@ and id = %@",[appDelegate.dict_GlobalInfo objectForKey:@"id"],[[arr_Reports objectAtIndex:deletedRow]objectForKey:@"id"]]]];
    
    
    
    if (arr_temp_estimatorinstance)
    {
        [arr_temp_estimatorinstance release];
        arr_temp_estimatorinstance = nil;
    }
    arr_temp_estimatorinstance = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimator_instance where estimate_id = %@",[[arr_temp_estimate objectAtIndex:0] objectForKey:@"id"]]]];
    
    [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from answer where estimator_instance_id = %@",[[arr_temp_estimatorinstance objectAtIndex:0]objectForKey:@"id"]] forTable:@"answer"];
    
    NSMutableArray *arr_temp_costs = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from costs where estimator_instance_id = %@",[[arr_temp_estimatorinstance objectAtIndex:0]objectForKey:@"id"]]]];
    
    if ([arr_temp_costs count] > 0) {
        
        [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from costs where estimator_instance_id = %@",[[arr_temp_estimatorinstance objectAtIndex:0]objectForKey:@"id"]] forTable:@"costs"];
    }
    [arr_temp_costs release];
    
    [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from estimator_instance where estimate_id = %@",[[arr_temp_estimate objectAtIndex:0]objectForKey:@"id"]] forTable:@"estimator_instance"];
    
    
    if (isSearch == 1)
    {
        NSString *strLocationId = [[arr_filteredData objectAtIndex:deletedRow]objectForKey:@"location_id"];
        NSString *strTempName = [[arr_filteredData objectAtIndex:deletedRow]objectForKey:@"name"];
        [strTempName retain];
        [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from estimate where user_id = %@ and id = %@",[appDelegate.dict_GlobalInfo objectForKey:@"id"],[[arr_filteredData objectAtIndex:deletedRow]objectForKey:@"id"]] forTable:@"estimate"];
        [arr_filteredData removeObjectAtIndex:deletedRow];
        [arr_filteredData retain];
        
        NSMutableDictionary *dictTemp;
        
        for (int i = 0; i < [arr_allRecords count]; i++)
        {
            dictTemp = [[NSMutableDictionary alloc]initWithDictionary:[arr_allRecords objectAtIndex:i]];
            
            NSString *strCompareName = [dictTemp objectForKey:@"name"];
            
            if ([strTempName isEqualToString:strCompareName])
            {
                [arr_allRecords removeObjectAtIndex:i];
                [arr_allRecords retain];
                [arr_LocationNames removeObjectAtIndex:i];
                [arr_LocationNames retain];
                break;
            }
        }
        
        arr_Reports = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate where location_id = %@ order by name",strLocationId]]];
        [arr_Reports retain];
    }
    else
    {
        [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from estimate where user_id = %@ and id = %@",[appDelegate.dict_GlobalInfo objectForKey:@"id"],[[arr_Reports objectAtIndex:deletedRow]objectForKey:@"id"]] forTable:@"estimate"];
        [arr_Reports removeObjectAtIndex:deletedRow];
    }

    //[appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from estimate where user_id = %@ and id = %@",[appDelegate.dict_GlobalInfo objectForKey:@"id"],[[arr_Reports objectAtIndex:deletedRow]objectForKey:@"id"]] forTable:@"estimate"];
    //[arr_Reports removeObjectAtIndex:deletedRow];
    
    [tbl_Reports reloadData];
    
    //Reloading location data
    if(arr_Locations)
    {
        [arr_Locations release];
        arr_Locations = nil;
    }
    [arr_Locations removeAllObjects];
    arr_Locations = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select l.name, l.id, l.address_1, l.city, l.state, l.zipcode, count(e.location_id) from location l join estimate e on e.location_id = l.id where l.delete_flag = 0 and user_id = %@ group by e.location_id order by l.name",[appDelegate.dict_GlobalInfo objectForKey:@"id"]]]];

    [arr_Locations retain];
    
    if (isSearch == 1)
    {
        selectedLocation = -1;
    }
    
    [tbl_Locations reloadData];
    
    if (arr_filteredData == 0)
    {
        tbl_Reports.hidden = TRUE;
    }

    if ([arr_Reports count] == 0)
    {
        [arr_Locations removeObjectAtIndex:selectedLocation];
        selectedLocation = -1;
        tbl_Reports.hidden = TRUE;
        [tbl_Locations reloadData];
    }
    else
    {
        if(arr_Locations)
        {
            [arr_Locations release];
            arr_Locations = nil;
        }
        [arr_Locations removeAllObjects];
        arr_Locations = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select l.name, l.id, l.address_1, l.city, l.state, l.zipcode, count(e.location_id) from location l join estimate e on e.location_id = l.id where l.delete_flag = 0 and user_id = %@ group by e.location_id order by l.name",[appDelegate.dict_GlobalInfo objectForKey:@"id"]]]];
        [tbl_Locations reloadData];
    }
}*/

/*-(void)deleteLocation1 // method for deleting selected location
{
    if (arr_temp_estimate)
    {
        [arr_temp_estimate release];
        arr_temp_estimate = nil;
    }
    
    
    NSLog(@"%@",arr_Locations);
    NSString *sql;
    if (deletedRow == -2)
    {
        sql = [NSString stringWithFormat:@"select * from estimate where user_id = %@",[appDelegate.dict_GlobalInfo objectForKey:@"id"]];
    }
    else
    {
        sql = [NSString stringWithFormat:@"select * from estimate where user_id = %@ and location_id = %@",[appDelegate.dict_GlobalInfo objectForKey:@"id"],[[arr_Locations objectAtIndex:deletedRow] objectForKey:@"id"]];
    }
    arr_temp_estimate = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:sql]];
    
    for (int i=0; i < [arr_temp_estimate count]; i++) {
        
        [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from answer where estimator_instance_id = %@",[[arr_temp_estimate objectAtIndex:i]objectForKey:@"id"]] forTable:@"answer"];
        
        NSMutableArray *arr_temp_costs = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from costs where estimator_instance_id = %@",[[arr_temp_estimate objectAtIndex:i]objectForKey:@"id"]]]];
        
        if ([arr_temp_costs count] > 0) {
            
            [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from costs where estimator_instance_id = %@",[[arr_temp_estimate objectAtIndex:i]objectForKey:@"id"]] forTable:@"costs"];
        }
        [arr_temp_costs release];
        
        [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from estimator_instance where estimate_id = %@",[[arr_temp_estimate objectAtIndex:i]objectForKey:@"id"]] forTable:@"estimator_instance"];
    }
    
    selectedLocation = -1;
    [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from estimate where user_id = %@ and location_id = %@",[appDelegate.dict_GlobalInfo objectForKey:@"id"],[[arr_Locations objectAtIndex:deletedRow] objectForKey:@"id"]] forTable:@"estimate"];
    [arr_Locations removeObjectAtIndex:deletedRow];
    [tbl_Locations reloadData];
    
    [arr_Reports removeAllObjects];
    arr_Reports = nil;
    [tbl_Reports reloadData];

}*/

#pragma mark -
#pragma mark IBActions

-(IBAction)ForwardAndEditEstimatePressed:(id)sender;
{
    
    UIButton *Rowbtn = (UIButton *)sender;
    tag_Rowbtn = Rowbtn.tag;

    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"View PDF",@"Email PDF",@"Edit this Estimate",@"Edit a Copy", nil];
    action.actionSheetStyle = UIActionSheetStyleBlackOpaque;

    [action showFromRect:CGRectMake(0, 0, 2, 20) inView:Rowbtn animated:NO];
    
    selectedReport = Rowbtn.tag;
    [tbl_Reports reloadData];

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self ViewPDFfile];
    }
    /*else if (buttonIndex == 1)
    {
        [self EmailPDFfile];
    }
    else if (buttonIndex == 2)
    {
        SurveyViewController *obj_SurvayPageViewController = [[SurveyViewController alloc] initWithNibName:@"SurveyViewController" bundle:nil];
        
        if (isSearch == 0)
        {
            obj_SurvayPageViewController.dict_Details = [arr_Reports objectAtIndex:tag_Rowbtn];
        }
        else
        {
            obj_SurvayPageViewController.dict_Details = [arr_filteredData objectAtIndex:tag_Rowbtn];
        }
        
        [self.navigationController pushViewController:obj_SurvayPageViewController animated:YES];
        [obj_SurvayPageViewController release];
        obj_SurvayPageViewController = nil;
        
    }
    else if (buttonIndex == 3)
    {
        // edit a copy of Estimate
        
        NSString *str_formattedDate = [NSDate formattedDate:[NSDate date]];
        if (arr_temp_estimate)
        {
            [arr_temp_estimate release];
            arr_temp_estimate = nil;
        }
        
        if (isSearch == 0)
        {
            arr_temp_estimate = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate where user_id = %@ and id = %@",[appDelegate.dict_GlobalInfo objectForKey:@"id"],[[arr_Reports objectAtIndex:tag_Rowbtn]objectForKey:@"id"]]]];
        }
        else
        {
            arr_temp_estimate = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate where user_id = %@ and id = %@",[appDelegate.dict_GlobalInfo objectForKey:@"id"],[[arr_filteredData objectAtIndex:tag_Rowbtn]objectForKey:@"id"]]]];
        }
        
        NSString *str_Query = [NSString stringWithFormat:@"insert into estimate (name, location_id, user_id, create_dt_tm, update_dt_tm, delete_flag, department, contact_name,contact_lastname, contact_email, contact_phone, note, is_sent_to_server) values ('%@', %@, %@, '%@', '%@', %@,'%@', '%@','%@', '%@', '%@', '%@', 0)",[NSString stringWithFormat:@"Copy of (%@)",[[arr_temp_estimate objectAtIndex:0] objectForKey:@"name"]], [[arr_temp_estimate objectAtIndex:0] objectForKey:@"location_id"], [[arr_temp_estimate objectAtIndex:0] objectForKey:@"user_id"], str_formattedDate, str_formattedDate, [[arr_temp_estimate objectAtIndex:0] objectForKey:@"delete_flag"], [[arr_temp_estimate objectAtIndex:0] objectForKey:@"department"], [[arr_temp_estimate objectAtIndex:0] objectForKey:@"contact_name"], [[arr_temp_estimate objectAtIndex:0] objectForKey:@"contact_lastname"], [[arr_temp_estimate objectAtIndex:0] objectForKey:@"contact_email"], [[arr_temp_estimate objectAtIndex:0] objectForKey:@"contact_phone"], [[arr_temp_estimate objectAtIndex:0] objectForKey:@"note"]];
        
        [appDelegate.sk runDynamicSQL:str_Query forTable:@"estimate"]; // inserting copy of Selected estimate into "estimate" table based on current date
        
        if (arr_estimate)
        {
            [arr_estimate release];
            arr_estimate = nil;
        }
        arr_estimate = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select max(id) as lastId from estimate"]]];

        if (arr_temp_estimatorinstance)
        {
            [arr_temp_estimatorinstance release];
            arr_temp_estimatorinstance = nil;
        }
        arr_temp_estimatorinstance = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimator_instance where estimate_id = %@",[[arr_temp_estimate objectAtIndex:0] objectForKey:@"id"]]]];
        
        
         for (int j=0; j < [arr_temp_estimatorinstance count]; j++)
         {
             
             [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"insert into estimator_instance (delete_flag,estimate_id,estimator_id) values (%@,%@,%@)",@"0",[[arr_estimate objectAtIndex:0] objectForKey:@"lastId"],[[arr_temp_estimatorinstance objectAtIndex:j] objectForKey:@"estimator_id"]] forTable:@"estimator_instance"];
             
             if (arr_temp_answer)
             {
                 [arr_temp_answer release];
                 arr_temp_answer = nil;
             }
             arr_temp_answer = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from answer where estimator_instance_id = %@",[[arr_temp_estimatorinstance objectAtIndex:j]objectForKey:@"id"]]]];
             
             if (arr_estimatorinstance)
             {
                 [arr_estimatorinstance release];
                 arr_estimatorinstance = nil;
             }
             arr_estimatorinstance = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select max(id) as lastId from estimator_instance"]]];
             
             for (int i=0; i < [arr_temp_answer count]; i++)
             {
                 // inserting copy of Selected estimate answers into "answer" table
                 
                 [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"insert into answer (estimator_instance_id,survey_asset_id,question_value_id,answer_value) values (%@,%@,%@,%@)",[[arr_estimatorinstance objectAtIndex:0] objectForKey:@"lastId"],[[arr_temp_answer objectAtIndex:i] objectForKey:@"survey_asset_id"],[[arr_temp_answer objectAtIndex:i] objectForKey:@"question_value_id"],[[arr_temp_answer objectAtIndex:i] objectForKey:@"answer_value"]] forTable:@"answer"];
             }
             [arr_temp_answer release];
             arr_temp_answer = nil;
             
             NSMutableArray *arr_temp_costs = [[NSMutableArray alloc]initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from costs where estimator_instance_id = %@",[[arr_temp_estimatorinstance objectAtIndex:j]objectForKey:@"id"]]]];
             
             if ([arr_temp_costs count] > 0)
             {
                 
                 [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"insert into Costs (current_fail_rate,estimator_instance_id,slidervalue) values (%@,%@,%@)",[[arr_temp_costs objectAtIndex:0] objectForKey:@"current_fail_rate"],[[arr_estimatorinstance objectAtIndex:0] objectForKey:@"lastId"],[[arr_temp_costs objectAtIndex:0] objectForKey:@"sliderValue"]] forTable:@"Costs"];
             }
             [arr_temp_costs release];
             arr_temp_costs = nil;
         }
        
         
        if(arr_Reports)
        {
            [arr_Reports release];
            arr_Reports = nil;
        }

        if (isSearch > 0)
        {
            arr_Reports = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate where order by id"]]];
            [arr_Reports retain];
            
            arr_allRecords = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate order by name"]]];
            [arr_allRecords retain];
            
            [self searchBarSearchButtonClicked:nil];
            
            selectedLocation = -1;

        }
        else
        {
            arr_Reports = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate where location_id = %@ order by id",[[arr_Locations objectAtIndex:selectedLocation] objectForKey:@"id"]]]];
            [arr_Reports retain];
        
        }
        
        [tbl_Reports reloadData];
        
        if(arr_Locations)
        {
            [arr_Locations release];
            arr_Locations = nil;
        }
        [arr_Locations removeAllObjects];
        arr_Locations = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select l.name, l.id, l.address_1, l.city, l.state, l.zipcode, count(e.location_id) from location l join estimate e on e.location_id = l.id where l.delete_flag = 0 and user_id = %@ group by e.location_id order by l.name",[appDelegate.dict_GlobalInfo objectForKey:@"id"]]]];
        [tbl_Locations reloadData];
        
    }*/
}

/*
-(void)LocationColumn1:(id)sender
{
    UIButton *button = (UIButton *)sender;
    int objAtIndex = button.tag * 3;
    
    SubEstimatesViewController *obj_SubEstimatesViewController = [[SubEstimatesViewController alloc] initWithNibName:@"SubEstimatesViewController" bundle:nil];
    obj_SubEstimatesViewController.dict_LocationDetails = [arr_Locations objectAtIndex:objAtIndex];
    [self.navigationController pushViewController:obj_SubEstimatesViewController animated:YES];
    [obj_SubEstimatesViewController release];
    obj_SubEstimatesViewController = nil;


}
-(void)LocationColumn2:(id)sender
{
    UIButton *button = (UIButton *)sender;
    int objAtIndex = button.tag * 3 + 1;

    SubEstimatesViewController *obj_SubEstimatesViewController = [[SubEstimatesViewController alloc] initWithNibName:@"SubEstimatesViewController" bundle:nil];
    obj_SubEstimatesViewController.dict_LocationDetails = [arr_Locations objectAtIndex:objAtIndex];
    [self.navigationController pushViewController:obj_SubEstimatesViewController animated:YES];
    [obj_SubEstimatesViewController release];
    obj_SubEstimatesViewController = nil;

}
-(void)LocationColumn3:(id)sender
{
    UIButton *button = (UIButton *)sender;
    int objAtIndex = button.tag * 3 + 2;

    SubEstimatesViewController *obj_SubEstimatesViewController = [[SubEstimatesViewController alloc] initWithNibName:@"SubEstimatesViewController" bundle:nil];
    obj_SubEstimatesViewController.dict_LocationDetails = [arr_Locations objectAtIndex:objAtIndex];
    [self.navigationController pushViewController:obj_SubEstimatesViewController animated:YES];
    [obj_SubEstimatesViewController release];
    obj_SubEstimatesViewController = nil;

}
*/
#pragma mark -
#pragma Gesture Recognizer
/*- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    //Checking for location action butto
    if (gestureRecognizer.view == tbl_Reports)
    {
        return YES;
    }
    return NO;
}

-(void)longPressGestureRecognizerStateChanged:(UILongPressGestureRecognizer *)gesture
{
    if(UIGestureRecognizerStateBegan == gesture.state)
    {
        CGPoint p = [gesture locationInView:tbl_Reports];
        
        NSIndexPath *indexPath = [tbl_Reports indexPathForRowAtPoint:p];
        
        CGRect rect1 = CGRectMake(50, 15+(15 *indexPath.row), 290, 70);
        CGRect rect2 = CGRectMake(rect1.origin.x + rect1.size.width + 25, rect1.origin.y + (rect1.origin.y *indexPath.row), rect1.size.width, rect1.size.height);
        CGRect rect3 = CGRectMake(rect2.origin.x + rect2.size.width + 25, rect2.origin.y + (rect2.origin.y *indexPath.row), rect2.size.width, rect2.size.height);
        
        if(rect1.origin.x < p.x && p.x < rect1.origin.x + rect1.size.width)
        {
            deleteObject = indexPath.row * 3;
        }
        else if(rect2.origin.x < p.x && p.x < rect2.origin.x + rect2.size.width)
        {
            deleteObject = indexPath.row * 3 +1;
        }
        else if(rect3.origin.x < p.x && p.x < rect3.origin.x + rect3.size.width)
        {
            deleteObject = indexPath.row * 3 + 2;
        }
        
        if (indexPath == nil)
        {
        
        }
        else
        {
                       [self showDeletePopover:indexPath points:p];
        }
    }
    if(UIGestureRecognizerStateEnded == gesture.state)
    {
        // Do end work here when finger is lifted
    }
}
*/

-(void)showDeletePopover:(NSIndexPath *)indexpath points:(CGPoint)point
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"View PDF",nil];
    action.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [action showFromRect:CGRectMake(point.x, point.y + 50, 10, 10) inView:self.view animated:NO];
}

#pragma mark - 
#pragma mark UIActionSheet

/*-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        //[self deleteLocation];
    }
}*/

-(void)ViewPDFfile
{
    ViewPDFViewController *obj_ViewPDFViewController = [[ViewPDFViewController alloc] initWithNibName:@"ViewPDFViewController" bundle:nil];
    [self presentModalViewController:obj_ViewPDFViewController animated:YES];
    [obj_ViewPDFViewController release];
    obj_ViewPDFViewController = nil;
}

-(void)EmailPDFfile
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }

}
-(void)displayComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Peripheral IV Analysis Report"];
    
    
    // Set up recipients
//    NSArray *toRecipients = [NSArray arrayWithObject:@""];
//    NSArray *ccRecipients = [NSArray arrayWithObjects:@"", @"", nil];
//    NSArray *bccRecipients = [NSArray arrayWithObject:@""];
//    
//    [picker setToRecipients:toRecipients];
//    [picker setCcRecipients:ccRecipients];
//    [picker setBccRecipients:bccRecipients];
    
    // Attach an image to the email
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Peripheral_IV_Estimate_01" ofType:@"pdf"];
    NSData *myData = [NSData dataWithContentsOfFile:path];
    [picker addAttachmentData:myData mimeType:@"application/pdf" fileName:@"Peripheral_IV_Estimate_01.pdf"];
    
    // Fill out the email body text
    NSString *emailBody = @"Please find attached Peripheral IV Analysis Report in PDF format.";
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentModalViewController:picker animated:YES];
    [picker release];
}
// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:

            break;
        case MFMailComposeResultSent:

            break;
        case MFMailComposeResultFailed:

            break;
        default:

            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
    NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
    NSString *body = @"&body=It is raining in sunny California!";
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

-(void)deleteLocation
{
    if(deleteObject >= 0)
    {
        //perform delete query here and reload table after then
    }
    deleteObject = -1;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar1
{
    searchBar.showsCancelButton = YES;
    if ([searchBar.text length] < 1)
    {
        //selectedLocation = intDeleteLoc;
        [tbl_Locations reloadData];
        isSearch = 0;
    }
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar1
{
    isSearch = 1;
    if (selectedLocation != -1)
    {
        intDeleteLoc = selectedLocation;
    }
    selectedLocation = -1;
    [tbl_Locations reloadData];
    
    arr_allRecords = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimate order by name"]]];
    [arr_allRecords retain];
    
    //Creating search array list
    arr_LocationNames = [[NSMutableArray alloc]init];
    NSMutableDictionary *dictTemp;
    for (int i = 0; i < [arr_allRecords count]; i++)
    {
        dictTemp = [[NSMutableDictionary alloc] initWithDictionary:[arr_allRecords  objectAtIndex:i]];
        NSString *strTemp = [dictTemp objectForKey:@"name"];
        [arr_LocationNames addObject:strTemp];
    }
    [arr_LocationNames retain];
    selectedReport = -1;
    if ([searchBar.text length] > 0)
    {
        tbl_Reports.hidden = FALSE;
    }
    else
    {
        tbl_Reports.hidden = TRUE;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [arr_filteredData removeAllObjects];// remove all data that belongs to previous search
    if([searchText isEqualToString: @""] || searchText == nil)
    {
        [tbl_Reports reloadData];
        return;
    }
    
    NSMutableDictionary *dictTemp;
    for( int i = 0; i < [arr_allRecords count]; i++ )
    {
        dictTemp = [[NSMutableDictionary alloc]init];
        dictTemp = [arr_allRecords objectAtIndex:i];
        NSString *strTemp = [dictTemp objectForKey:@"name"];
        
        NSRange r = [strTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if(r.location != NSNotFound)
        {
            [arr_filteredData addObject:dictTemp];
        }
    }
    [arr_filteredData retain];
    
    if ([arr_filteredData count] > 0)
    {
        tbl_Reports.hidden = FALSE;
        [tbl_Reports reloadData];
    }
    else
    {
        [arr_Reports removeAllObjects];
        tbl_Reports.hidden = TRUE;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar1
{
    // if a valid search was entered but the user wanted to cancel, bring back the main list content
    if ([searchBar.text length] < 1)
    {
        //selectedLocation = intDeleteLoc;
        [tbl_Locations reloadData];
        isSearch = 0;
    }
    
    [arr_filteredData removeAllObjects];
    tbl_Reports.hidden = TRUE;
    [searchBar resignFirstResponder];
    searchBar.text = @"";
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar1
{
    searchBar.showsCancelButton = YES;
    if ([searchBar.text length] < 1)
    {
        selectedLocation = intDeleteLoc;
        [tbl_Locations reloadData];
        isSearch = 0;
    }
    else
    {
        [arr_filteredData removeAllObjects];// remove all data that belongs to previous search
        
        NSMutableDictionary *dictTemp;
        for( int i = 0; i < [arr_allRecords count]; i++ )
        {
            dictTemp = [[NSMutableDictionary alloc]init];
            dictTemp = [arr_allRecords objectAtIndex:i];
            NSString *strTemp = [dictTemp objectForKey:@"name"];
            
            NSRange r = [strTemp rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
            if(r.location != NSNotFound)
            {
                [arr_filteredData addObject:dictTemp];
            }
        }
        [arr_filteredData retain];
        
        if ([arr_filteredData count] > 0)
        {
            tbl_Reports.hidden = FALSE;
            [tbl_Reports reloadData];
        }
        else
        {
            [arr_Reports removeAllObjects];
            tbl_Reports.hidden = TRUE;
        }
    }
    [searchBar resignFirstResponder];
}

@end