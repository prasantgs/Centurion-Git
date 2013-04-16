//
//  AddEstimatorViewController.m
//  Centurion
//
//  Created by costrategix technologies on 25/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddEstimatorViewController.h"
#import "AppDelegate.h"
#import "SKDatabase.h"
#import "AddEstimatorCustomCell.h"
#import "CurrentEstimatorTypeViewController.h"

@implementation AddEstimatorViewController
@synthesize str_EstimateID;

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
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    arr_Estimator = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:@"select * from estimator where delete_flag = 0"]];
    [arr_Estimator retain];
    
    arr_EstimatorInstanceRecords = [[NSMutableArray alloc] initWithArray:[appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimator_instance where estimate_id = %@",str_EstimateID]]];
    [arr_EstimatorInstanceRecords retain];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
   
    self.navigationItem.title = @"Current Estimators";
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(CancelPressed:)];
    self.navigationItem.leftBarButtonItem = btnCancel;
    [btnCancel release];
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(SaveButtonPressed:)];
    [btnSave setTintColor:[UIColor colorWithRed:55.0/255.0 green:152.0/255.0 blue:197.0/255.0 alpha:0.6f]];
    self.navigationItem.rightBarButtonItem = btnSave;///55  152  197
    [btnSave release];
    
    tbl_Estimator.delegate = self;
    tbl_Estimator.dataSource = self;
    
    arr_SelectedEstimators = [[NSMutableArray alloc] init];

    if ([arr_EstimatorInstanceRecords count] > 0)
    {
        for (int j=0; j<[arr_Estimator count]; j++) {
            
            for (int i=0; i < [arr_EstimatorInstanceRecords count]; i++) {
                
                if ([[[arr_Estimator objectAtIndex:j] objectForKey:@"id"] integerValue] == [[[arr_EstimatorInstanceRecords objectAtIndex:i] objectForKey:@"estimator_id"] integerValue]) {
                    
                    [arr_SelectedEstimators addObject:[arr_Estimator objectAtIndex:j]];
                }
            }
        }
        [arr_SelectedEstimators retain];
    }
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
	return YES;
}
#pragma mark -
#pragma mark IBActions
-(IBAction)CancelPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arr_Estimator count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    AddEstimatorCustomCell *cell = (AddEstimatorCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[AddEstimatorCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectionStyle = UITableViewCellSeparatorStyleSingleLine;
    
    cell.lbl_EstimatorName.hidden = FALSE;
    cell.lbl_EstimatorName.text = [[arr_Estimator objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.lbl_EstimatorName.font = [UIFont boldSystemFontOfSize:14];
    cell.Btn_checkBox.tag = indexPath.row;
    cell.Btn_checkBox.selected = FALSE;
    cell.Btn_checkBox.hidden = FALSE;
    [cell.Btn_checkBox addTarget:self action:@selector(CheckBox_Clicked:) forControlEvents:UIControlEventTouchDown];
    
    if ([arr_SelectedEstimators count]>0) {
        
        for (int i=0; i<[arr_SelectedEstimators count]; i++) {
            
            if ([[[arr_Estimator objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue] == [[[arr_SelectedEstimators objectAtIndex:i] objectForKey:@"id"] integerValue]) {
                cell.Btn_checkBox.selected = TRUE;
            }
        }
    }
    return cell;
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CurrentEstimatorTypeViewController *obj_curentEst = [[CurrentEstimatorTypeViewController alloc]initWithNibName:@"CurrentEstimatorTypeViewController" bundle:nil];
    obj_curentEst.str_CurEstNavTitle = [[arr_Estimator objectAtIndex:indexPath.row] objectForKey:@"name"];
    [self.navigationController pushViewController:obj_curentEst animated:YES];
    
    
}*/

-(void)CheckBox_Clicked:(id)Sender{

    UIButton *btn = (UIButton *)Sender;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    if (btn.selected) {
        
        [arr_SelectedEstimators removeObject:[arr_Estimator objectAtIndex:btn.tag]];
        btn.selected = FALSE;
        
        if ([[[arr_Estimator objectAtIndex:btn.tag] objectForKey:@"delete_flag"] integerValue]!= 1) {
            //dict = [arr_Estimator objectAtIndex:btn.tag];
            [dict setDictionary:[arr_Estimator objectAtIndex:btn.tag]];
            [dict setObject:@"1" forKey:@"delete_flag"];
            [arr_Estimator replaceObjectAtIndex:btn.tag withObject:dict];
        }
    }else{
        btn.selected = TRUE;
        [arr_SelectedEstimators addObject:[arr_Estimator objectAtIndex:btn.tag]];
        [arr_SelectedEstimators retain];
        
        if ([[[arr_Estimator objectAtIndex:btn.tag] objectForKey:@"delete_flag"] integerValue]!= 0) {
            [dict setDictionary:[arr_Estimator objectAtIndex:btn.tag]];
            [dict setObject:@"0" forKey:@"delete_flag"];
            [arr_Estimator replaceObjectAtIndex:btn.tag withObject:dict];
        }
    }
    [dict release];
}

-(IBAction)SaveButtonPressed:(id)sender
{
    for (int i=0; i<[arr_Estimator count]; i++)
    {
        //to delete unselected items from estimator_instance table
        if ([[[arr_Estimator objectAtIndex:i] objectForKey:@"delete_flag"] integerValue]== 1) {
            [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"delete from estimator_instance where estimator_id = %@ and estimate_id = %@",[[arr_Estimator objectAtIndex:i]objectForKey:@"id"],str_EstimateID] forTable:@"estimator_instance"];
        }
    }
    
    for(int i = 0; i < [arr_SelectedEstimators count] ; i++)
    {
        // to insert selected items in estimator_instance table
        NSArray *arr = [appDelegate.sk lookupAllForSQL:[NSString stringWithFormat:@"select * from estimator_instance where estimator_id = %@ and estimate_id = %@",[[arr_SelectedEstimators objectAtIndex:i] objectForKey:@"id"],str_EstimateID]];
        
        if([arr count] > 0)
        {
            
        }
        else
        {
            [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"insert into estimator_instance (delete_flag,estimator_id,estimate_id) values (%@,%@,%@)",@"0",[[arr_SelectedEstimators objectAtIndex:i] objectForKey:@"id"],str_EstimateID] forTable:@"estimator_instance"];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateEstimatorList" object:self];
    [self dismissModalViewControllerAnimated:YES];
}

@end
