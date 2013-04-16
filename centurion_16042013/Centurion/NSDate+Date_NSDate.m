//
//  NSDate+Date_NSDate.m
//  Centurion
//
//  Created by costrategix technologies on 22/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDate+Date_NSDate.h"

@implementation NSDate (Date_NSDate)

+(NSString *)formattedDate:(NSDate *)dateRef
{
    NSString *str_FormattedDate;
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:@"YYYYMMddhhmmss"];
    str_FormattedDate = [df stringFromDate:dateRef];
    return str_FormattedDate; 
}

+(NSString *)formattedString:(NSString *)stringRef
{
    NSString *str_FormattedString;
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:@"yyyyMMddhhmmss"];
    NSDate *dateRef = [df dateFromString:stringRef];
    [df setDateFormat:@"MMMM dd, YYYY"];
    str_FormattedString = [df stringFromDate:dateRef];
    return str_FormattedString;
}
@end
