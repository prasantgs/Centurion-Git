//
//  SyncController.m
//  Centurion
//
//  Created by SMRITI on 4/2/13.
//
//

#import "SyncController.h"
#import "SKDatabase.h"
#import "JSONKit.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "AppDelegate.h"
#import "SKDatabase.h"

@implementation SyncController
- (void)dealloc
{
    if (arr_Settings)
    {
        [arr_Settings release];
        arr_Settings = nil;
    }
    
    if(responseData)
    {
        [responseData release];
        responseData = nil;
    }
    [super dealloc];
}

- (void)updateSettings:(BOOL)update
{
    if (update)
    {
        NSString *strLastSyncDate = [NSString stringWithFormat:@"%@",[dict_Response objectForKey:@"last_sync_dt_tm"]];
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        [userDef setObject:strLastSyncDate forKey:@"last_sync_dt_tm"];
        [userDef synchronize];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!!" message:@"No internet connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"startSync" object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"message", strResponseMessage, nil]  ];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"startSync" object:self userInfo:nil];
}

- (void)startSync
{
    responseData = [[NSMutableData alloc] init];
    NSURLRequest *request;
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *strLastSyncDate = [NSString stringWithFormat:@"%@",[userDef objectForKey:@"last_sync_dt_tm"]];
    
    if ([strLastSyncDate isEqual:[NSNull null]] || [strLastSyncDate length] < 1 || [strLastSyncDate isEqualToString:@"(null)"])
    {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://centurion.new.cosdevx.com/api/v1/synchronize"]]];
    }
    else
    {
        //request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://centurion.new.cosdevx.com/api/v1/synchronize"]]];

        request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://centurion.new.cosdevx.com/api/v1/synchronize?date=%@",strLastSyncDate]]];
    }
    //[[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSURLResponse *response;
    NSError *error = nil;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
    
    if (error)
    {
        appDelegate.strResponseMessage = @"Internet Connection Lost.";
        //strResponseMessage = @"Synchronization Successfull.";
        [appDelegate.strResponseMessage retain];
        
        [self updateSettings:NO];
    }
    
    //NSString *responeString = [[NSString alloc] initWithData:receivedData
    //                                                encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",responeString);
    NSError *myError = nil;
    
    Class jsonSerializationClass = NSClassFromString(@"NSJSONSerialization");
    if (!jsonSerializationClass)
    {
        //iOS < 5 didn't have the JSON serialization class
        if (receivedData == nil)
        {
            appDelegate.strResponseMessage = @"Internet Connection Lost.";
            //strResponseMessage = @"Synchronization Successfull.";
            [appDelegate.strResponseMessage retain];
            
            [self updateSettings:NO];
        }
        else
        {
            JSONDecoder *decoder = [JSONDecoder decoderWithParseOptions:JKParseOptionStrict];
            dict_Response = [decoder objectWithData:receivedData];
            [dict_Response retain];
            
            [self insertRecords];

        }
    }
    else
    {
        if (receivedData == nil)
        {
            appDelegate.strResponseMessage = @"Internet Connection Lost.";
            //strResponseMessage = @"Synchronization Successfull.";
            [appDelegate.strResponseMessage retain];
            
            [self updateSettings:NO];
        }
        else
        {
            dict_Response = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableLeaves error:&myError];
            [dict_Response retain];
            
            [self insertRecords];

        }
    }
}

#pragma mark - ConnectionDelegates
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    appDelegate.strResponseMessage = @"Internet Connection Lost.";
    //strResponseMessage = @"Synchronization Successfull.";
    [appDelegate.strResponseMessage retain];
    
    [self updateSettings:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    /*NSDictionary *res;
    NSError *myError = nil;
    
    Class jsonSerializationClass = NSClassFromString(@"NSJSONSerialization");
    if (!jsonSerializationClass)
    {
        //iOS < 5 didn't have the JSON serialization class
        
        JSONDecoder *decoder = [JSONDecoder decoderWithParseOptions:JKParseOptionStrict];
        res = [decoder objectWithData:responseData];
        dict_Response = [[NSMutableDictionary alloc] initWithDictionary:[res objectForKey:@"response"]];
        [dict_Response retain];
    }
    else
    {
        res = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
        dict_Response = [[NSMutableDictionary alloc] initWithDictionary:res];
        [dict_Response retain];
    }
    [self insertRecords];*/
}

#pragma mark - Database Insertion
- (void)insertRecords
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray *arrDept, *arrEstimator, *arrLoc, *arrQues, *arrQues_Val, *arrSurvey_Asset;
    
    arrDept = [dict_Response objectForKey:@"department"];
    arrEstimator = [dict_Response objectForKey:@"estimator"];
    arrLoc = [dict_Response objectForKey:@"location"];
    arrQues = [dict_Response objectForKey:@"question"];
    arrQues_Val = [dict_Response objectForKey:@"question_value"];
    arrSurvey_Asset = [dict_Response objectForKey:@"survey_asset"];
    
    if (!([arrDept isEqual:[NSNull null]] || [arrDept count] < 1))
    {
        [appDelegate.sk  InsertReplaceDepartment:arrDept];
    }
    
    if (!([arrEstimator isEqual:[NSNull null]] || [arrEstimator count] < 1))
    {
        [appDelegate.sk  InsertReplaceEstimator:arrEstimator];
    }
    
    if (!([arrLoc isEqual:[NSNull null]] || [arrLoc count] < 1))
    {
        [appDelegate.sk  InsertReplaceLocation:arrLoc];
    }
    
    if (!([arrQues isEqual:[NSNull null]] || [arrQues count] < 1))
    {
        [appDelegate.sk  InsertReplaceQuestion:arrQues];
    }
    
    if (!([arrQues_Val isEqual:[NSNull null]] || [arrQues_Val count] < 1))
    {
        [appDelegate.sk  InsertReplaceQuestionValue:arrQues_Val];
    }
    
    if (!([arrSurvey_Asset isEqual:[NSNull null]] || [arrSurvey_Asset count] < 1))
    {
        [appDelegate.sk  InsertReplaceSurveyAsset:arrSurvey_Asset];
    }
    
    //strResponseMessage = @"Internet Connection Lost.";
    appDelegate.strResponseMessage = @"Synchronization Successfull.";
    [appDelegate.strResponseMessage retain];
    
    [self updateSettings:YES];
}
@end
