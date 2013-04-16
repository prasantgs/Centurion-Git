//
//  RevSyncController.m
//  Centurion
//
//  Created by SMRITI on 4/9/13.
//
//

#import "RevSyncController.h"
#import "SKDatabase.h"
#import "JSONKit.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "AppDelegate.h"
#import "SKDatabase.h"
#import "NSDate+Date_NSDate.h"
#import "UIDevice+IdentifierAddition.h"

@implementation RevSyncController
- (void)dealloc
{
    if (arr_Settings)
    {
        [arr_Settings release];
        arr_Settings = nil;
    }
    
    [super dealloc];
}

- (void)updateSettings:(BOOL)update
{
    //NSLog(@"%@",dict_Response);
    if (update)
    {
        NSString *strUserID = [dict_Response objectForKey:@"user_id"];
        if ([strUserID isEqual:[NSNull null]] || strUserID == nil)
        {
            //
        }
        else
        {
            if ([dict_Response objectForKey:@"estimates"])
            {
                if ([[dict_Response objectForKey:@"estimates"] count] > 0)
                {
                    NSArray *arrEstimates = [[NSArray alloc]initWithArray:[dict_Response objectForKey:@"estimates"]];
                    NSDictionary *dictEstimate = [[NSDictionary alloc] init];
                    for (int i = 0; i < [arrEstimates count]; i++)
                    {
                        if (dictEstimate)
                        {
                            [dictEstimate release];
                            dictEstimate = nil;
                            dictEstimate = [arrEstimates objectAtIndex:i];
                        }
                        
                        //insert estimate_ id in estimate
                        if ([dictEstimate objectForKey:@"estimators"])
                        {
                            if ([[dictEstimate objectForKey:@"estimators"] count] > 0)
                            {
                                NSArray *arrEstimators = [[NSArray alloc]initWithArray:[dictEstimate objectForKey:@"estimators"]];
                                NSDictionary *dictEstimator = [[NSDictionary alloc] init];
                                for (int j = 0; j < [arrEstimators count]; j++)
                                {
                                    if (dictEstimator)
                                    {
                                        [dictEstimator release];
                                        dictEstimator = nil;
                                        dictEstimator = [arrEstimators objectAtIndex:j];
                                    }
                                    //insert estimator_id in estimator_instance
                                    [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"update estimator_instance set centurion_server_id = '%@' where id = '%@'",[dictEstimator objectForKey:@"estimator_instance_id"],[dictEstimator objectForKey:@"local_estimator_instance_id"]] forTable:@"estimator_instance"];
                                    
                                    if ([dictEstimator objectForKey:@"estimate_answers"])
                                    {
                                        if ([[dictEstimator objectForKey:@"estimate_answers"] count] > 0)
                                        {
                                            NSArray *arrAnswers = [[NSArray alloc]initWithArray:[dictEstimator objectForKey:@"estimate_answers"]];
                                            NSDictionary *dictAnswer = [[NSDictionary alloc] init];
                                            for (int k = 0; k < [arrAnswers count]; k++)
                                            {
                                                if (dictAnswer)
                                                {
                                                    [dictAnswer release];
                                                    dictAnswer = nil;
                                                    dictAnswer = [arrAnswers objectAtIndex:k];
                                                    //replace answer_id in answer table
                                                    [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"update answer set centurion_server_id = '%@' where id = '%@'",[dictAnswer objectForKey:@"answer_id"],[dictAnswer objectForKey:@"local_answer_id"]] forTable:@"answer"];
                                                }
                                            }

                                        }
                                    }
                                }
                            }
                        }
                        [appDelegate.sk runDynamicSQL:[NSString stringWithFormat:@"update estimate set centurion_server_id = '%@', is_sent_to_server = 1  where id = '%@'",[dictEstimate objectForKey:@"estimate_id"],[dictEstimate objectForKey:@"local_estimate_id"]] forTable:@"estimate"];
                    }
                }
            }
        }
    }
    
//    strResponseMessage = @"Internet Connection Lost.";
//    strResponseMessage = @"Synchronization Successfull.";
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"StartRevSync" object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"message", strResponseMessage, nil]  ];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StartRevSync" object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:nil]];
}

- (void)fetchRecords
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableDictionary *dictSend = [[NSMutableDictionary alloc]init];
    
    NSString *strUDID = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    [dictSend setObject:strUDID forKey:@"device_UDID"];

    //NSLog(@"appDelegate.dict_GlobalInfo = %@",appDelegate.dict_GlobalInfo);
    NSString *strUser_id = [appDelegate.dict_GlobalInfo objectForKey:@"id"];
    [dictSend setObject:strUser_id forKey:@"user_id"];

    //NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    //NSString *strLastSyncDate = [NSString stringWithFormat:@"%@",[userDef objectForKey:@"last_rev_sync_dt_tm"]];

    //is_sent_to_server == 0 means created; 1 means added; 2 means updated
    //NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM estimate WHERE (is_sent_to_server = 0 OR is_sent_to_server = 2)"];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM estimate WHERE (is_sent_to_server = 0)"];
    NSMutableArray *arr_Answers, *arr_Estimators, *arr_Estimates;   //Array to add in dictSend
    
    NSArray *arrEstimates = [appDelegate.sk lookupAllForSQL:[[NSString alloc] initWithFormat:@"%@",sql]];
    if (arrEstimates)
    {
        if ([arrEstimates count] > 0)
        {
            arr_Estimates = [[NSMutableArray alloc]init];
            if (arr_Estimates)
            {
                [arr_Estimates release];
                arr_Estimates = nil;
                arr_Estimates = [[NSMutableArray alloc]init];
            }
            NSMutableDictionary *dictEs = [[NSMutableDictionary alloc]init];
            for (int i = 0; i < [arrEstimates count]; i++)
            {
                arr_Estimators = [[NSMutableArray alloc]init];
                NSString *sql1 = [[NSString alloc] initWithFormat:@"SELECT * FROM estimator_instance WHERE (estimate_id == %@)", [[arrEstimates objectAtIndex:i] objectForKey:@"id"]];
                NSArray *arrEstimators = [appDelegate.sk lookupAllForSQL:[[NSString alloc] initWithFormat:@"%@",sql1]];
                if (arrEstimators)
                {
                    if ([arrEstimators count] > 0)
                    {
                        arr_Answers = [[NSMutableArray alloc]init];
                        if (arr_Answers)
                        {
                            [arr_Answers release];
                            arr_Answers = nil;
                            arr_Answers = [[NSMutableArray alloc]init];
                        }
                        NSMutableDictionary *dictE = [[NSMutableDictionary alloc]init];
                        for (int j = 0; j < [arrEstimators count]; j++)
                        {
                            NSString *sql2 = [[NSString alloc] initWithFormat:@"SELECT * FROM answer WHERE (estimator_instance_id == %@)", [[arrEstimators objectAtIndex:j] objectForKey:@"id"]];
                            NSArray *arrAnswers = [appDelegate.sk lookupAllForSQL:[[NSString alloc] initWithFormat:@"%@",sql2]];
                            
                            if (arrAnswers)
                            {
                                if ([arrAnswers count] > 0)
                                {
                                    NSMutableDictionary *dictA = [[NSMutableDictionary alloc]init];
                                    for (int k = 0; k < [arrAnswers count]; k++)
                                    {
                                        if (dictA)
                                        {
                                            [dictA release];
                                            dictA = nil;
                                            dictA = [[NSMutableDictionary alloc]init];
                                        }
                                        NSString *str_ServerID = [[arrAnswers objectAtIndex:k] objectForKey:@"centurion_server_id"];
                                        if ([str_ServerID isEqual:[NSNull null]] || str_ServerID == nil)
                                        {
                                            str_ServerID = @"";
                                        }
                                        [dictA setObject:str_ServerID forKey:@"answer_id"];
                                        [dictA setObject:[[arrAnswers objectAtIndex:k] objectForKey:@"id"] forKey:@"local_answer_id"];
                                        [dictA setObject:[[arrAnswers objectAtIndex:k] objectForKey:@"question_id"] forKey:@"question_id"];
                                        [dictA setObject:[[arrAnswers objectAtIndex:k] objectForKey:@"question_value_id"] forKey:@"question_value_id"];
                                        [dictA setObject:[[arrAnswers objectAtIndex:k] objectForKey:@"answer_value"] forKey:@"answer_value"];
                                        NSString *str_AnsText = [[arrAnswers objectAtIndex:k] objectForKey:@"answer_text"];
                                        if ([str_AnsText isEqual:[NSNull null]] || str_AnsText == nil)
                                        {
                                            str_AnsText = @"";
                                        }
                                        [dictA setObject:str_AnsText forKey:@"answer_text"];
                                        [arr_Answers addObject:dictA];
                                    }
                                }
                            }
                            if (dictE)
                            {
                                [dictE release];
                                dictE = nil;
                                dictE = [[NSMutableDictionary alloc]init];
                            }
                            NSString *str_ServerID1 = [[arrEstimators objectAtIndex:j] objectForKey:@"centurion_server_id"];
                            if ([str_ServerID1 isEqual:[NSNull null]] || str_ServerID1 == nil)
                            {
                                str_ServerID1 = @"";
                            }
                            [dictE setObject:str_ServerID1 forKey:@"estimator_instance_id"];
                            [dictE setObject:[[arrEstimators objectAtIndex:j] objectForKey:@"id"] forKey:@"local_estimator_instance_id"];
                            [dictE setObject:[[arrEstimators objectAtIndex:j] objectForKey:@"estimator_id"] forKey:@"estimator_id"];
                            [dictE setObject:arr_Answers forKey:@"estimate_answers"];
                            [arr_Estimators addObject:dictE];
                        }
                    }
                }
                if (dictEs)
                {
                    [dictEs release];
                    dictEs = nil;
                    dictEs = [[NSMutableDictionary alloc]init];
                }
                NSString *str_ServerID2 = [[arrEstimates objectAtIndex:i] objectForKey:@"centurion_server_id"];
                if ([str_ServerID2 isEqual:[NSNull null]] || str_ServerID2 == nil)
                {
                    str_ServerID2 = @"";
                }
                [dictEs setObject:str_ServerID2 forKey:@"estimate_id"];
                [dictEs setObject:[[arrEstimates objectAtIndex:i] objectForKey:@"id"] forKey:@"local_estimate_id"];
                [dictEs setObject:[[arrEstimates objectAtIndex:i] objectForKey:@"name"] forKey:@"name"];
                [dictEs setObject:[[arrEstimates objectAtIndex:i] objectForKey:@"contact_name"] forKey:@"contact_name"];
                [dictEs setObject:[[arrEstimates objectAtIndex:i] objectForKey:@"contact_email"] forKey:@"contact_email"];
                [dictEs setObject:[[arrEstimates objectAtIndex:i] objectForKey:@"contact_phone"] forKey:@"contact_number"];
                [dictEs setObject:[[arrEstimates objectAtIndex:i] objectForKey:@"note"] forKey:@"notes"];
                [dictEs setObject:[[arrEstimates objectAtIndex:i] objectForKey:@"location_id"] forKey:@"location_id"];
                [dictEs setObject:[[arrEstimates objectAtIndex:i] objectForKey:@"department_ids"] forKey:@"department_ids"];
                [dictEs setObject:arr_Estimators forKey:@"estimators"];
                [arr_Estimates addObject:dictEs];
            }
            [dictSend setObject:arr_Estimates forKey:@"estimates"];
        }
    }
    [self startRevSync:dictSend];
}

- (void)startRevSync:(NSDictionary *)dict
{
    NSURL *url = [NSURL URLWithString:@"http://centurion.new.cosdevx.com/api/v1/sendEstimates"];
    NSError *jsonSerializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&jsonSerializationError];
    NSString *serJSON = @"";
    if(!jsonSerializationError)
    {
        serJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //NSLog(@"Serialized JSON: %@", serJSON);
    }
    else
    {
        //NSLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
    }
    NSString *postString =[NSString stringWithFormat:@"estimateData=%@",serJSON];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        // Peform the request
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
    
    NSString *responeString = [[NSString alloc] initWithData:receivedData
                                                    encoding:NSUTF8StringEncoding];
    NSLog(@"%@",responeString);
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
            
            //strResponseMessage = @"Internet Connection Lost.";
            appDelegate.strResponseMessage = @"Synchronization Successfull.";
            [appDelegate.strResponseMessage retain];
            
            [self updateSettings:YES];
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
            
            //strResponseMessage = @"Internet Connection Lost.";
            appDelegate.strResponseMessage = @"Synchronization Successfull.";
            [appDelegate.strResponseMessage retain];
            
            [self updateSettings:YES];
        }
    }
   // });
}

/*#pragma mark - ConnectionDelegates
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self updateSettings:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responeString = [[NSString alloc] initWithData:responseData
                                                    encoding:NSUTF8StringEncoding];
    NSLog(@"%@",responeString);
    //NSDictionary *res;
    NSError *myError = nil;
    
    Class jsonSerializationClass = NSClassFromString(@"NSJSONSerialization");
    if (!jsonSerializationClass)
    {
        //iOS < 5 didn't have the JSON serialization class
        
        JSONDecoder *decoder = [JSONDecoder decoderWithParseOptions:JKParseOptionStrict];
        dict_Response = [decoder objectWithData:responseData];
        //dict_Response = [[NSMutableDictionary alloc] initWithDictionary:res];
        [dict_Response retain];
        //NSLog(@"%@",dict_Response);
        [self updateSettings:YES];
    }
    else
    {
        dict_Response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
        //dict_Response = [[NSMutableDictionary alloc] initWithDictionary:res];
        [dict_Response retain];
        //NSLog(@"%@",dict_Response);
        [self updateSettings:YES];
    }

}*/


@end
