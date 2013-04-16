//
//  AppDelegate.h
//  Centurion
//
//  Created by costrategix technologies on 11/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//Ankur

#import <UIKit/UIKit.h>

@class LoginViewController;
@class SKDatabase;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSString *str_UserName;
    SKDatabase *sk;
    
    NSMutableDictionary *dict_GlobalInfo;
    NSString *str_LocationName;
    
    NSString *syncSource;
    
    NSString *strResponseMessage;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginViewController *obj_LoginViewController;
@property (nonatomic, retain) NSMutableDictionary *dict_GlobalInfo;
@property (nonatomic, retain) SKDatabase *sk;
@property (nonatomic, retain) NSString *str_LocationName;
@property (nonatomic, retain) NSString *syncSource;
@property (nonatomic, retain) NSString *strResponseMessage;

@end
