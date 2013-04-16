//
//  RevSyncController.h
//  Centurion
//
//  Created by SMRITI on 4/9/13.
//
//

#import <Foundation/Foundation.h>

@class ASINetworkQueue, AppDelegate;
@interface RevSyncController : NSObject<UIAlertViewDelegate>
{
    AppDelegate *appDelegate;
    
    ASINetworkQueue *networkQueue;
    //NSData *responseData;
    NSMutableArray *arr_Settings;
    NSMutableDictionary *dict_Response;
    
    //NSString *strResponseMessage;
}

-(void)updateSettings:(BOOL)update;
-(void)startRevSync:(NSDictionary *)dict;
-(void)fetchRecords;
@end
