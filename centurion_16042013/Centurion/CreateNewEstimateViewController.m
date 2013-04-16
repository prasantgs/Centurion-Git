//
//  CreateNewEstimateViewController.m
//  Centurion
//
//  Created by costrategix technologies on 20/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateNewEstimateViewController.h"
#import "AppDelegate.h"
#import "SKDatabase.h"
#import "NSDate+Date_NSDate.h"
#import "AddEstimatorViewController.h"

@implementation CreateNewEstimateViewController
@synthesize str_EstimateId,str_FromSurvey;

-(void)dealloc
{
    if(dict_SelectedLocation)
    {
        [dict_SelectedLocation release];
        dict_SelectedLocation = nil;
    }
    if(arr_SelectedDepartments)
    {
        [arr_SelectedDepartments release];
        arr_SelectedDepartments = nil;
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
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    arr_LocationList = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:@"select * from location where delete_flag = 0 order by name"]];
    [arr_LocationList retain];
    
    arr_DepartmentList = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:@"select * from department"]];
    
    txt_ContactNumber.delegate = self;
    txt_EmailAddress.delegate = self;
    txtV_Notes.delegate = self;

    pkr_Location.delegate = self;
    pkr_Location.dataSource = self;

    selectedItems = [[NSMutableArray alloc]init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([str_EstimateId length] > 0)
    {
        lbl_CreateEditEstimateTitle.text = @"Edit Estimate";
        arr_UpdateDetails = [[NSArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select estimate.name, estimate.note,estimate.contact_email,estimate.department_ids,estimate.contact_name,estimate.contact_lastname, estimate.create_dt_tm, estimate.update_dt_tm,estimate.contact_phone, location.name as location_name, location.address_1, location.city, location.state, location.id as location_id from estimate left join location on estimate.location_id = location.id where estimate.create_dt_tm = %@",str_EstimateId]]];

        [arr_UpdateDetails retain];
                //select * from department where id in (select department_ids from estimate where id = 1)
        str_DepartmentID = [[arr_UpdateDetails objectAtIndex:0] objectForKey:@"department_ids"];
        [str_DepartmentID retain];
        
        if(arr_SelectedDepartments)
        {
            [arr_SelectedDepartments release];
            arr_SelectedDepartments = nil;
        }
        arr_SelectedDepartments = [[NSArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from department where id in (%@)",[[arr_UpdateDetails objectAtIndex:0] objectForKey:@"department_ids"]]]];
        [arr_SelectedDepartments retain];
                
        NSString *str = @"";
        for(int i = 0 ; i < [arr_SelectedDepartments count] ; i++)
        {
            if(i == 0)
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%@",[[arr_SelectedDepartments objectAtIndex:i] objectForKey:@"department"]]];
            else
                str = [str stringByAppendingString:[NSString stringWithFormat:@",%@",[[arr_SelectedDepartments objectAtIndex:i] objectForKey:@"department"]]];
        }
        
        lbl_Department.text = str;
        txt_EstimateName.text = [[arr_UpdateDetails objectAtIndex:0] objectForKey:@"name"];
        lbl_LocationName.text = [NSString stringWithFormat:@"%@, %@, %@",[[arr_UpdateDetails objectAtIndex:0] objectForKey:@"location_name"],[[arr_UpdateDetails objectAtIndex:0] objectForKey:@"city"],[[arr_UpdateDetails objectAtIndex:0] objectForKey:@"state"]];
        txt_ContactName.text = [[arr_UpdateDetails objectAtIndex:0] objectForKey:@"contact_name"];
        txt_CustomerLastName.text = [[arr_UpdateDetails objectAtIndex:0] objectForKey:@"contact_lastname"];
        txt_ContactNumber.text = [[arr_UpdateDetails objectAtIndex:0] objectForKey:@"contact_phone"];
        txt_EmailAddress.text = [[arr_UpdateDetails objectAtIndex:0] objectForKey:@"contact_email"];
        txtV_Notes.text = [[arr_UpdateDetails objectAtIndex:0] objectForKey:@"note"];
        
        str_LocationId = [[arr_UpdateDetails objectAtIndex:0] objectForKey:@"location_id"];
        [str_LocationId retain];
        
        appDelegate.str_LocationName = [NSString stringWithFormat:@"%@",[[arr_LocationList objectAtIndex:0] objectForKey:@"name"]];
    }
    else
    {
        lbl_CreateEditEstimateTitle.text = @"Create Estimate";
    }
    int_RowSelect = 0;
    
    appDelegate.str_LocationName = [NSString stringWithFormat:@"%@",[[arr_LocationList objectAtIndex:0] objectForKey:@"name"]];
    
    if(dict_SelectedLocation)
    {
        [dict_SelectedLocation release];
        dict_SelectedLocation = nil;
    }
    dict_SelectedLocation = [[NSMutableDictionary alloc] initWithDictionary:[arr_LocationList objectAtIndex:0]];
    [dict_SelectedLocation retain];
        
    [self tool_DonePressed:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark -
#pragma mark Location Picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
    {
        return [arr_LocationList count];
    }
    else if (pickerView.tag == 2)
    {
        return [arr_DepartmentList count];
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
    {
        
    }
    else if (pickerView.tag == 2)
    {
        return [NSString stringWithFormat:@"%@, %@, %@",[[arr_LocationList objectAtIndex:row] objectForKey:@"name"],[[arr_LocationList objectAtIndex:row] objectForKey:@"city"],[[arr_LocationList objectAtIndex:row] objectForKey:@"state"]];

    }
    return nil;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (pickerView.tag == 1)
    {
        UILabel* tView = (UILabel*)view;
        if([view isKindOfClass:[UITableViewCell class]])
        {
            [view release];
            view = nil;
            
            tView = [[UILabel alloc] init];
            tView.backgroundColor = [UIColor clearColor];
            tView.minimumFontSize = 8.;
            tView.adjustsFontSizeToFitWidth = YES;
        }
        else if (tView == nil)
        {
            tView = [[UILabel alloc] init];
            tView.backgroundColor = [UIColor clearColor];
            tView.minimumFontSize = 8.;
            tView.adjustsFontSizeToFitWidth = YES;
        }
        // Fill the label text here
        NSString *str_LocationName = [NSString stringWithFormat:@"%@, %@, %@",[[arr_LocationList objectAtIndex:row] objectForKey:@"name"],[[arr_LocationList objectAtIndex:row] objectForKey:@"city"],[[arr_LocationList objectAtIndex:row] objectForKey:@"state"]];
        if([lbl_LocationName.text isEqualToString:str_LocationName])
        {
            int_RowSelect = row;
            str_LocationId = [[arr_LocationList objectAtIndex:row] objectForKey:@"id"];
            [str_LocationId retain];
            
        }
        tView.text = [NSString stringWithFormat:@"  %@",str_LocationName];
        
        return tView;
    }
    else if (pickerView.tag == 2)
    {
        UITableViewCell *cell = (UITableViewCell *)view;
        if([view isKindOfClass:[UILabel class]])
        {
            [view release];
            view = nil;
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setBounds: CGRectMake(0, 0, 255 , 44)];
            UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSelection:)];
            singleTapGestureRecognizer.numberOfTapsRequired = 1;
            [cell addGestureRecognizer:singleTapGestureRecognizer];
        }
        else if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]; 
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setBounds: CGRectMake(0, 0, 255 , 44)];
            UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSelection:)];
            singleTapGestureRecognizer.numberOfTapsRequired = 1;
            [cell addGestureRecognizer:singleTapGestureRecognizer];
        }
        
        if ([selectedItems indexOfObject:[NSNumber numberWithInt:row]] != NSNotFound)
        {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        NSString *str_DepartmentName = [NSString stringWithFormat:@"%@",[[arr_DepartmentList objectAtIndex:row] objectForKey:@"department"]];

        cell.textLabel.text = [NSString stringWithFormat:@"%@",str_DepartmentName];
        cell.tag = row;
    
        return cell;
    }
    return nil;
}

- (void)toggleSelection:(UITapGestureRecognizer *)recognizer
{
    NSNumber *row = [NSNumber numberWithInt:recognizer.view.tag];
    NSUInteger index = [selectedItems indexOfObject:row];
    if (index != NSNotFound)
    {
        [selectedItems removeObjectAtIndex:index];
        [(UITableViewCell *)(recognizer.view) setAccessoryType:UITableViewCellAccessoryNone];
        
        NSString *strTemp = [[arr_DepartmentList objectAtIndex:[row intValue]] objectForKey:@"department"];
        NSArray *arr_listofDept = [str_Department componentsSeparatedByString:@", "];
        NSArray *arr_listofDeptID = [str_DepartmentID componentsSeparatedByString:@", "];
        
        if ([arr_listofDept containsObject:strTemp])
        {
            int entityRow = [arr_listofDept indexOfObject:strTemp];

            if (entityRow == 0)
            {
                
                if ([arr_listofDept count] < 2)
                {
                    str_Department = [str_Department stringByReplacingOccurrencesOfString:[arr_listofDept objectAtIndex:entityRow] withString:@""];
                    [str_Department retain];
                    
                    str_DepartmentID = [str_DepartmentID stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",[arr_listofDeptID objectAtIndex:entityRow]] withString:@""];
                    [str_DepartmentID retain];

                }
                else
                {
                    str_Department = [str_Department stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@, ",[arr_listofDept objectAtIndex:entityRow]]
                                                                               withString:@""];
                    [str_Department retain];
                    
                    str_DepartmentID = [str_DepartmentID stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@, ",[arr_listofDeptID objectAtIndex:entityRow]] withString:@""];
                    [str_DepartmentID retain];
                }
            }
            else
            {
                str_Department = [str_Department stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@", %@",[arr_listofDept objectAtIndex:entityRow]]
                                                                           withString:@""];
                [str_Department retain];
                
                str_DepartmentID = [str_DepartmentID stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@", %@",[arr_listofDeptID objectAtIndex:entityRow]] withString:@""];
                [str_DepartmentID retain];
            }
        }
    }
    else
    {
        [selectedItems addObject:row];
        [(UITableViewCell *)(recognizer.view) setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        if ([str_Department isEqual:[NSNull null]] || [str_Department length] < 1 )
        {
            str_Department = [[arr_DepartmentList objectAtIndex:[row intValue]] objectForKey:@"department"];
            [str_Department retain];
            
            str_DepartmentID = [NSString stringWithFormat:@"%@",[[arr_DepartmentList objectAtIndex:[row intValue]] objectForKey:@"id"]];
            [str_DepartmentID retain];
        }
        else
        {
            str_Department = [str_Department stringByAppendingString:@", "];
            str_Department = [str_Department stringByAppendingString:[[arr_DepartmentList objectAtIndex:[row intValue]] objectForKey:@"department"]];
            [str_Department retain];
            
            str_DepartmentID = [str_DepartmentID stringByAppendingString:@", "];
            str_DepartmentID = [str_DepartmentID stringByAppendingString:[NSString stringWithFormat:@"%@",[[arr_DepartmentList objectAtIndex:[row intValue]] objectForKey:@"id"]]];
            [str_DepartmentID retain];
        }
    }

    lbl_Department.text = str_Department;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
    {
        int_RowSelect = row;
        
        appDelegate.str_LocationName = [NSString stringWithFormat:@"%@",[[arr_LocationList objectAtIndex:row] objectForKey:@"name"]];
        
        if(dict_SelectedLocation)
        {
            [dict_SelectedLocation release];
            dict_SelectedLocation = nil;
        }
        dict_SelectedLocation = [[NSMutableDictionary alloc] initWithDictionary:[arr_LocationList objectAtIndex:row]];
        [dict_SelectedLocation retain];
        
        str_LocationId = [[arr_LocationList objectAtIndex:row] objectForKey:@"id"];
        [str_LocationId retain];
     
         lbl_LocationName.text = [NSString stringWithFormat:@"%@, %@, %@",[[arr_LocationList objectAtIndex:row] objectForKey:@"name"],[[arr_LocationList objectAtIndex:row] objectForKey:@"city"],[[arr_LocationList objectAtIndex:row] objectForKey:@"state"]];
    }
}

#pragma mark -
#pragma mark IBAction
-(IBAction)LocationSelectionPressed:(id)sender
{
    [txt_EstimateName resignFirstResponder];
    [txt_ContactName resignFirstResponder];
    [txt_ContactNumber resignFirstResponder];
    [txt_EmailAddress resignFirstResponder];
    [txtV_Notes resignFirstResponder];
    [txt_CustomerLastName resignFirstResponder];

    pkr_Location.tag = 1;
    
    pkr_Location.showsSelectionIndicator = TRUE;
    pkr_Location.frame = CGRectMake(242, 185, 275, 216);
    tool_Location.frame = CGRectMake(242, 141, 275, 44);
    
    [pkr_Location reloadAllComponents];
    
    [self.view bringSubviewToFront:pkr_Location];
    [self.view bringSubviewToFront:tool_Location];
    
    pkr_Location.hidden = FALSE;
    tool_Location.hidden = FALSE;
    
    appDelegate.str_LocationName = [NSString stringWithFormat:@"%@",[[arr_LocationList objectAtIndex:0] objectForKey:@"name"]];
    
    if(dict_SelectedLocation)
    {
        [dict_SelectedLocation release];
        dict_SelectedLocation = nil;
    }
    dict_SelectedLocation = [[NSMutableDictionary alloc] initWithDictionary:[arr_LocationList objectAtIndex:0]];
    [dict_SelectedLocation retain];
    
    str_LocationId = [[arr_LocationList objectAtIndex:0] objectForKey:@"id"];
    [str_LocationId retain];
    
    if ([lbl_LocationName.text length] < 1)
    {
        lbl_LocationName.text = [NSString stringWithFormat:@"%@, %@, %@",[[arr_LocationList objectAtIndex:0] objectForKey:@"name"],[[arr_LocationList objectAtIndex:0] objectForKey:@"city"],[[arr_LocationList objectAtIndex:0] objectForKey:@"state"]];
    }
}

-(IBAction)DepartmentSelectionPressed:(id)sender
{
    [txt_EstimateName resignFirstResponder];
    [txt_ContactName resignFirstResponder];
    [txt_ContactNumber resignFirstResponder];
    [txt_EmailAddress resignFirstResponder];
    [txtV_Notes resignFirstResponder];
    [txt_CustomerLastName resignFirstResponder];
    
    pkr_Location.tag = 2;
    pkr_Location.showsSelectionIndicator = FALSE;
    pkr_Location.frame = CGRectMake(242, 235, 275, 216);
    tool_Location.frame = CGRectMake(242, 191, 275, 44);
    
    [pkr_Location reloadAllComponents];
    
    [pkr_Location selectRow:0 inComponent:0 animated:NO];
    
    [self.view bringSubviewToFront:pkr_Location];
    [self.view bringSubviewToFront:tool_Location];

    pkr_Location.hidden = FALSE;
    tool_Location.hidden = FALSE;
}

-(IBAction)tool_DonePressed:(id)sender
{
    pkr_Location.hidden = TRUE;
    tool_Location.hidden = TRUE;
}


-(IBAction)SavePressed:(id)sender
{
    if([txt_EstimateName.text length] > 0 &&[txt_ContactName.text length] > 0 && [txt_CustomerLastName.text length] > 0 && [txt_ContactNumber.text length] > 0 && [txt_EmailAddress.text length] > 0 && [lbl_LocationName.text length] > 0 && [lbl_Department.text length] > 0)
    {
        //save query
        NSString *str_formattedDate = [NSDate formattedDate:[NSDate date]];
        NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
        if([str_EstimateId length]>0)
        {
            /*NSString *str_Query = @"";
            NSDictionary *dict_chk_isServerSent = [appDelegate.sk lookupRowForSQL:[NSString stringWithFormat:@"select is_sent_to_server from estimate where create_dt_tm = '%@'",str_EstimateId]];
            NSString *str_chk_isServerSent = [[dict_chk_isServerSent objectForKey:@"is_sent_to_server"] stringValue];
            
            if ([str_chk_isServerSent isEqual:[NSNull null]] || (str_chk_isServerSent == nil) || [str_chk_isServerSent isEqualToString:@"0"])
            {*/
               NSString *str_Query= [NSString stringWithFormat:@"update estimate set name = '%@', location_id = %@, update_dt_tm = '%@', department_ids = '%@', contact_name = '%@', contact_lastname = '%@', contact_email = '%@', contact_phone = '%@', note = '%@', is_sent_to_server = 0 where create_dt_tm = '%@'",[txt_EstimateName.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], str_LocationId, str_formattedDate,str_DepartmentID, [txt_ContactName.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"],[txt_CustomerLastName.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], txt_EmailAddress.text, [txt_ContactNumber.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], [txtV_Notes.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], str_EstimateId];
            /*}
            else
            {
                 str_Query= [NSString stringWithFormat:@"update estimate set name = '%@', location_id = %@, update_dt_tm = '%@', department_ids = '%@', contact_name = '%@', contact_lastname = '%@', contact_email = '%@', contact_phone = '%@', note = '%@', is_sent_to_server = 2 where create_dt_tm = '%@'",[txt_EstimateName.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], str_LocationId, str_formattedDate,str_DepartmentID, [txt_ContactName.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"],[txt_CustomerLastName.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], txt_EmailAddress.text, [txt_ContactNumber.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], [txtV_Notes.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], str_EstimateId];
            }*/
            
            [appDelegate.sk runDynamicSQL:str_Query forTable:@"estimate"];
                        
            [dict setObject:txt_EstimateName.text forKey:@"name"];
            [dict setObject:str_LocationId forKey:@"location_id"];
            [dict setObject:[appDelegate.dict_GlobalInfo objectForKey:@"id"] forKey:@"user_id"];
            [dict setObject:str_formattedDate forKey:@"update_dt_tm"];
            [dict setObject:str_EstimateId forKey:@"create_dt_tm"];
            
            [self dismissModalViewControllerAnimated:YES];
            
            if([str_FromSurvey isEqualToString:@"Survey"])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDataSurvayPage" object:self userInfo:dict];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDataOnLocationList" object:self userInfo:dict];
            }
        }
        else
        {
            NSString *str_Query = [NSString stringWithFormat:@"insert into estimate (name, location_id, user_id, create_dt_tm, update_dt_tm, delete_flag, department_ids, contact_name,contact_lastname, contact_email, contact_phone, note,is_sent_to_server) values ('%@', %@, %@, '%@', '%@', %@,'%@', '%@','%@', '%@', '%@', '%@', 0)",[txt_EstimateName.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], [dict_SelectedLocation objectForKey:@"id"], [appDelegate.dict_GlobalInfo objectForKey:@"id"], str_formattedDate, str_formattedDate, @"0",str_DepartmentID, [txt_ContactName.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"],[txt_CustomerLastName.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], [txt_EmailAddress.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], txt_ContactNumber.text,[txtV_Notes.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
            
            [appDelegate.sk runDynamicSQL:str_Query forTable:@"estimate"];
         
            [dict setObject:@"newEstimate" forKey:@"status"];
            [dict setObject:txt_EstimateName.text forKey:@"name"];
            [dict setObject:[dict_SelectedLocation objectForKey:@"id"] forKey:@"location_id"];
            [dict setObject:[appDelegate.dict_GlobalInfo objectForKey:@"id"] forKey:@"user_id"];
            [dict setObject:str_formattedDate forKey:@"update_dt_tm"];
            [dict setObject:str_formattedDate forKey:@"create_dt_tm"];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshData" object:self userInfo:dict];
            [self dismissModalViewControllerAnimated:YES];
        }
    }
    else
    {
        
        if([txt_EstimateName.text length] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Enter Estimate Name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];

        }
        else if([lbl_Department.text length] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Select at least one Department" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
        }

        else if([txt_ContactName.text length] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Enter Customer First Name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];

        }
        else if ([txt_CustomerLastName.text length] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Enter Customer Last Name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];

        }
        else if ([txt_ContactNumber.text length] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Enter Customer Phone" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];

        }
        else if([txt_EmailAddress.text length] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Enter Customer Email" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}

-(IBAction)CancelPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITextField Delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == txt_ContactNumber)
    {
        kOFFSET_FOR_KEYBOARD = 80;
        [self setViewMovedUp:YES];
    }
    else if(textField == txt_EmailAddress)
    {
        kOFFSET_FOR_KEYBOARD = 80;
        [self setViewMovedUp:YES];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self setViewMovedUp:FALSE];
    
    if(textField == txt_ContactNumber)
    {
        if([txt_ContactNumber.text length] == 10)
        {
            NSRange range;
            range.length = 3;
            range.location = 3;

            NSString *areaCode = [txt_ContactNumber.text substringToIndex:3];
            NSString *phone1 = [textField.text substringWithRange:range];
            NSString *phone2 = [textField.text substringFromIndex:6];
            
            txt_ContactNumber.text = [NSString stringWithFormat:@"(%@) %@-%@", areaCode, phone1, phone2];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if(textView == txtV_Notes)
    {
        kOFFSET_FOR_KEYBOARD = 150;
        [self setViewMovedUp:YES];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
   
    [self setViewMovedUp:FALSE];
}

-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.view.frame;
    if (movedUp)
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
    else
        rect.origin.y = 0.0;
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


@end
