//
//  SyncController.h
//  Centurion
//
//  Created by SMRITI on 4/2/13.
//
//

#import <Foundation/Foundation.h>

@class ASINetworkQueue, AppDelegate;
@interface SyncController : NSObject<UIAlertViewDelegate>
{
    AppDelegate *appDelegate;
    
    ASINetworkQueue *networkQueue;
    NSMutableData *responseData;
    NSMutableArray *arr_Settings;
    NSMutableDictionary *dict_Response;

    //NSString *strResponseMessage;
}

- (void)updateSettings:(BOOL)update;
- (void)startSync;
- (void)insertRecords;
@end
