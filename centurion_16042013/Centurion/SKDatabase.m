// Copyright 2011-2012 Jason Whitehorn
// Released under the terms of the license found
// in the license.txt in the root of the project

// Based on works originally found @
// http://iphoneinaction.manning.com/iphone_in_action/2009/07/skdatabase-11-a-sqlite-library-for-the-iphone.html
// Unfortunantly that website is no longer around.
// If memory serves me correctly the original author
// released it into the public domain.

#import "SKDatabase.h"
#import "NSString+HTML.h"

@implementation SKDatabase

@synthesize delegate;
@synthesize dbh;
@synthesize dynamic;

// Two ways to init: one if you're just SELECTing from a database, one if you're UPDATing
// and or INSERTing

- (id)initWithReadOnlyFile:(NSString *)dbFile {
	if (self = [super init]) {
		
		NSString *paths = [[NSBundle mainBundle] resourcePath];
		NSString *path = [paths stringByAppendingPathComponent:dbFile];
		NSLog(@"Opening database %@", path);
		
		int result = sqlite3_open([path UTF8String], &dbh);
		NSAssert1(SQLITE_OK == result, NSLocalizedStringFromTable(@"Unable to open the sqlite database (%@).", @"Database", @""), [NSString stringWithUTF8String:sqlite3_errmsg(dbh)]);	
		self.dynamic = NO;
	}
	
	return self;	
}

- (id)initWithFile:(NSString *)dbFile
{
	if (self = [super init]) {
		
		NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *docDir = [docPaths objectAtIndex:0];
		NSString *docPath = [docDir stringByAppendingPathComponent:dbFile];
        
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		if (![fileManager fileExistsAtPath:docPath]) {
			
			NSString *origPaths = [[NSBundle mainBundle] resourcePath];
			NSString *origPath = [origPaths stringByAppendingPathComponent:dbFile];
            
			NSError *error;
			int success = [fileManager copyItemAtPath:origPath toPath:docPath error:&error];			
			NSAssert1(success,@"Failed to copy database into dynamic location",error);
                        
		}
		int result = sqlite3_open([docPath UTF8String], &dbh);
		NSAssert1(SQLITE_OK == result, NSLocalizedStringFromTable(@"Unable to open the sqlite database (%@).", @"Database", @""), [NSString stringWithUTF8String:sqlite3_errmsg(dbh)]);	
		self.dynamic = YES;
	}
	
	return self;	
}

- (id)initWithData:(NSData *)data andFile:(NSString *)dbFile {
	if (self = [super init]) {
		
		NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *docDir = [docPaths objectAtIndex:0];
		NSString *docPath = [docDir stringByAppendingPathComponent:dbFile]; 
		bool success = [data writeToFile:docPath atomically:YES];
		
		NSAssert1(success,@"Failed to save database into documents path", nil);
		
		int result = sqlite3_open([docPath UTF8String], &dbh);
		NSAssert1(SQLITE_OK == result, NSLocalizedStringFromTable(@"Unable to open the sqlite database (%@).", @"Database", @""), [NSString stringWithUTF8String:sqlite3_errmsg(dbh)]);	
		self.dynamic = YES;
	}
	
	return self;	
}

// Users should never need to call prepare

- (sqlite3_stmt *)prepare:(NSString *)sql
{
	const char *utfsql = [sql UTF8String];
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare([self dbh],utfsql,-1,&statement,NULL) == SQLITE_OK) {
		return statement;
	} else {
		return 0;
	}
}

// Three ways to lookup results: for a variable number of responses, for a full row
// of responses, or for a singular bit of data

- (NSArray *)lookupAllForSQL:(NSString *)sql
{
	sqlite3_stmt *statement;
	id result;
	NSMutableArray *thisArray = [NSMutableArray arrayWithCapacity:4];
    statement = [self prepare:sql];
	if (statement) {
		while (sqlite3_step(statement) == SQLITE_ROW) {	
			NSMutableDictionary *thisDict = [NSMutableDictionary dictionaryWithCapacity:4];
			for (int i = 0 ; i < sqlite3_column_count(statement) ; i++) {
				if(sqlite3_column_type(statement,i) == SQLITE_NULL){
					continue;
				}
				if (sqlite3_column_decltype(statement,i) != NULL &&
					strcasecmp(sqlite3_column_decltype(statement,i),"Boolean") == 0) {
					result = [NSNumber numberWithBool:(BOOL)sqlite3_column_int(statement,i)];
				} else if (sqlite3_column_type(statement,i) == SQLITE_INTEGER) {
					result = [NSNumber numberWithInt:(int)sqlite3_column_int(statement,i)];
				} else if (sqlite3_column_type(statement,i) == SQLITE_FLOAT) {
					result = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement,i)];					
				} else {
					if((char *)sqlite3_column_text(statement,i) != NULL){
                        result = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement,i)];
                        [thisDict setObject:result
                                     forKey:[NSString stringWithUTF8String:sqlite3_column_name(statement,i)]];
                        result = nil;
					}
				}
				if (result) {
					[thisDict setObject:result
								 forKey:[NSString stringWithUTF8String:sqlite3_column_name(statement,i)]];
				}
			}
			[thisArray addObject:[NSDictionary dictionaryWithDictionary:thisDict]];
		}
	}
	sqlite3_finalize(statement);
	return thisArray;
}

- (NSDictionary *)lookupRowForSQL:(NSString *)sql
{
	sqlite3_stmt *statement;
	id result;
	NSMutableDictionary *thisDict = [NSMutableDictionary dictionaryWithCapacity:4];
    statement = [self prepare:sql];
	if (statement) {
		if (sqlite3_step(statement) == SQLITE_ROW) {	
			for (int i = 0 ; i < sqlite3_column_count(statement) ; i++) {
				if(sqlite3_column_type(statement,i) == SQLITE_NULL){
					continue;
				}
				if (sqlite3_column_decltype(statement,i) != NULL &&
					strcasecmp(sqlite3_column_decltype(statement,i),"Boolean") == 0) {
					result = [NSNumber numberWithBool:(BOOL)sqlite3_column_int(statement,i)];
				} else if (sqlite3_column_type(statement,i) == SQLITE_INTEGER) {
					result = [NSNumber numberWithInt:(int)sqlite3_column_int(statement,i)];
				} else if (sqlite3_column_type(statement,i) == SQLITE_FLOAT) {
					result = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement,i)];					
				} else {
					if((char *)sqlite3_column_text(statement,i) != NULL){
                        result = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement,i)];
                        [thisDict setObject:result
                                     forKey:[NSString stringWithUTF8String:sqlite3_column_name(statement,i)]];
                        result = nil;
					}
				}
				if (result) {
					[thisDict setObject:result
								 forKey:[NSString stringWithUTF8String:sqlite3_column_name(statement,i)]];
				}
			}
		}
	}
	sqlite3_finalize(statement);
	return thisDict;
}

- (id)lookupColForSQL:(NSString *)sql
{
	sqlite3_stmt *statement;
	id result = nil;
	if ((statement = [self prepare:sql]))
    {
		if (sqlite3_step(statement) == SQLITE_ROW) {		
			if (strcasecmp(sqlite3_column_decltype(statement,0),"Boolean") == 0) {
				result = [NSNumber numberWithBool:(BOOL)sqlite3_column_int(statement,0)];
			} else if (sqlite3_column_type(statement, 0) == SQLITE_TEXT) {
				result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,0)];
			} else if (sqlite3_column_type(statement,0) == SQLITE_INTEGER) {
				result = [NSNumber numberWithInt:(int)sqlite3_column_int(statement,0)];
			} else if (sqlite3_column_type(statement,0) == SQLITE_FLOAT) {
				result = [NSNumber numberWithDouble:(double)sqlite3_column_double(statement,0)];					
			} else {
				result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,0)];
			}
		}
	}
	sqlite3_finalize(statement);
	return result;
	
}

// Simple use of COUNTS, MAX, etc.

- (int)lookupCountWhere:(NSString *)where forTable:(NSString *)table {
	
	int tableCount = 0;
	NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@",
					 table,where];    	
	sqlite3_stmt *statement;
	
	if ((statement = [self prepare:sql])) {
		if (sqlite3_step(statement) == SQLITE_ROW) {		
			tableCount = sqlite3_column_int(statement,0);
		}
	}
	sqlite3_finalize(statement);
	return tableCount;
	
}

- (int)lookupMax:(NSString *)key Where:(NSString *)where forTable:(NSString *)table {
	
	int tableMax = 0;
	NSString *sql = [NSString stringWithFormat:@"SELECT MAX(%@) FROM %@ WHERE %@",
					 key,table,where];    	
	sqlite3_stmt *statement;
	if ((statement = [self prepare:sql])) {
		if (sqlite3_step(statement) == SQLITE_ROW) {		
			tableMax = sqlite3_column_int(statement,0);
		}
	}
	sqlite3_finalize(statement);
	return tableMax;
	
}

- (int)lookupSum:(NSString *)key Where:(NSString *)where forTable:(NSString *)table {
	
	int tableSum = 0;
	NSString *sql = [NSString stringWithFormat:@"SELECT SUM(%@) FROM %@ WHERE %@",
					 key,table,where];    	
	sqlite3_stmt *statement;
	if ((statement = [self prepare:sql])) {
		if (sqlite3_step(statement) == SQLITE_ROW) {		
			tableSum = sqlite3_column_int(statement,0);
		}
	}
	sqlite3_finalize(statement);
	return tableSum;
	
}

// INSERTing and UPDATing

- (void)insertArray:(NSArray *)dbData forTable:(NSString *)table {
	
	NSMutableString *sql = [NSMutableString stringWithCapacity:16];
	[sql appendFormat:@"INSERT INTO %@ (",table];
	
	for (int i = 0 ; i < [dbData count] ; i++) {
		[sql appendFormat:@"%@",[[dbData objectAtIndex:i] objectForKey:@"key"]];
		if (i + 1 < [dbData count]) {
			[sql appendFormat:@", "];
		}
	}
	[sql appendFormat:@") VALUES("];
	for (int i = 0 ; i < [dbData count] ; i++) {
		if ([[[dbData objectAtIndex:i] objectForKey:@"value"] intValue])
        {
			[sql appendFormat:@"%@",[[dbData objectAtIndex:i] objectForKey:@"value"]];
		} else {
			[sql appendFormat:@"'%@'",[[dbData objectAtIndex:i] objectForKey:@"value"]];
		}
		if (i + 1 < [dbData count]) {
			[sql appendFormat:@", "];
		}
	}
	[sql appendFormat:@")"];
	[self runDynamicSQL:sql forTable:table];
}

- (void)insertDictionary:(NSDictionary *)dbData forTable:(NSString *)table {
	
	NSMutableString *sql = [NSMutableString stringWithCapacity:16];
	[sql appendFormat:@"INSERT INTO %@ (",table];
	
	NSArray *dataKeys = [dbData allKeys];
	for (int i = 0 ; i < [dataKeys count] ; i++) {
		[sql appendFormat:@"%@",[dataKeys objectAtIndex:i]];
		if (i + 1 < [dbData count]) {
			[sql appendFormat:@", "];
		}
	}
	
	[sql appendFormat:@") VALUES("];
	for (int i = 0 ; i < [dataKeys count] ; i++) {
		if ([[dbData objectForKey:[dataKeys objectAtIndex:i]] intValue]) {
			[sql appendFormat:@"%@",[dbData objectForKey:[dataKeys objectAtIndex:i]]];
		} else {
			[sql appendFormat:@"'%@'",[dbData objectForKey:[dataKeys objectAtIndex:i]]];
		}
		if (i + 1 < [dbData count]) {
			[sql appendFormat:@", "];
		}
	}
	
	[sql appendFormat:@")"];
	[self runDynamicSQL:sql forTable:table];
}

#pragma mark -
#pragma mark -
- (BOOL)insertIntoLocation:(NSArray *)locationsArr
{
    int i;  
    BOOL success = TRUE;
    const char *query = "insert into location(address1, city, zipcode, latitude, longitude, name, state, updatedDateTime, id, phoneNumber, delete_flag) Values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";  
    sqlite3_stmt *addStmt; 
    for (i = 0; i < [locationsArr count]; i++)  
    {  
        if(sqlite3_prepare_v2(dbh, query, -1, &addStmt, NULL) == SQLITE_OK)   
        {  
            sqlite3_bind_text(addStmt, 1, [[[locationsArr objectAtIndex:i] objectForKey:@"address_1"] UTF8String], -1, SQLITE_TRANSIENT);  
            sqlite3_bind_text(addStmt, 2, [[[locationsArr objectAtIndex:i] objectForKey:@"city"] UTF8String], -1, SQLITE_TRANSIENT);  
            sqlite3_bind_text(addStmt, 3, [[[locationsArr objectAtIndex:i] objectForKey:@"zipcode"] UTF8String], -1, SQLITE_TRANSIENT); 
            sqlite3_bind_text(addStmt, 4, [[[locationsArr objectAtIndex:i] objectForKey:@"latitude"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 5, [[[locationsArr objectAtIndex:i] objectForKey:@"longitude"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 6, [[[locationsArr objectAtIndex:i] objectForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 7, [[[locationsArr objectAtIndex:i] objectForKey:@"state"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 8, [[[locationsArr objectAtIndex:i] objectForKey:@"updated_dt_tm"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 9, [[[locationsArr objectAtIndex:i] objectForKey:@"id"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[locationsArr objectAtIndex:i] objectForKey:@"phone_no"] == nil || [[[locationsArr objectAtIndex:i] objectForKey:@"phone_no"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 10, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 10, [[[locationsArr objectAtIndex:i] objectForKey:@"phone_no"] UTF8String], -1, SQLITE_TRANSIENT);
            
            sqlite3_bind_text(addStmt, 11, [[[locationsArr objectAtIndex:i] objectForKey:@"delete_flag"] UTF8String], -1, SQLITE_TRANSIENT);

        }  
        if(SQLITE_DONE != sqlite3_step(addStmt)) {  
            success = FALSE;
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(dbh));  
        }  
        //Reset the add statement.  
        sqlite3_reset(addStmt);  
    }
    
    return success;
}

- (BOOL)insertIntoAnswer:(NSArray *)locationsArr
{
    int i;
    BOOL success = TRUE;
    const char *query = "insert into answer(estimator_instance_id, question_id, question_value_id, answer_value, answer_text) Values(?, ?, ?, ?, ?)";
    sqlite3_stmt *addStmt;
    for (i = 0; i < [locationsArr count]; i++)
    {
        if(sqlite3_prepare_v2(dbh, query, -1, &addStmt, NULL) == SQLITE_OK)
        {
            sqlite3_bind_int(addStmt, 1, [[[locationsArr objectAtIndex:i] objectForKey:@"estimator_instance_id"] intValue]);
            
            sqlite3_bind_int(addStmt, 2, [[[locationsArr objectAtIndex:i] objectForKey:@"question_id"] intValue]);
            
            sqlite3_bind_int(addStmt, 3, [[[locationsArr objectAtIndex:i] objectForKey:@"question_value_id"] intValue]);
            
            sqlite3_bind_int(addStmt, 4, [[[locationsArr objectAtIndex:i] objectForKey:@"answer_value"] intValue]);
            
            sqlite3_bind_text(addStmt, 5, [[[locationsArr objectAtIndex:i] objectForKey:@"answer_text"] UTF8String], -1, SQLITE_TRANSIENT);
            
        }
        if(SQLITE_DONE != sqlite3_step(addStmt)) {
            success = FALSE;
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(dbh));
        }
        //Reset the add statement.
        sqlite3_reset(addStmt);
    }
    
    return success;
}

#pragma mark -
#pragma mark -

- (void)updateArray:(NSArray *)dbData forTable:(NSString *)table { 
	[self updateArray:dbData forTable:table where:NULL];
}

- (void)updateArray:(NSArray *)dbData forTable:(NSString *)table where:(NSString *)where {
	
	NSMutableString *sql = [NSMutableString stringWithCapacity:16];
	[sql appendFormat:@"UPDATE %@ SET ",table];
	
	for (int i = 0 ; i < [dbData count] ; i++) {
		if ([[[dbData objectAtIndex:i] objectForKey:@"value"] intValue]) {
			[sql appendFormat:@"%@=%@",
			 [[dbData objectAtIndex:i] objectForKey:@"key"],
			 [[dbData objectAtIndex:i] objectForKey:@"value"]];
		} else {
			[sql appendFormat:@"%@='%@'",
			 [[dbData objectAtIndex:i] objectForKey:@"key"],
			 [[dbData objectAtIndex:i] objectForKey:@"value"]];
		}		
		if (i + 1 < [dbData count]) {
			[sql appendFormat:@", "];
		}
	}
	if (where != NULL) {
		[sql appendFormat:@" WHERE %@",where];
	} else {
		[sql appendFormat:@" WHERE 1"];
	}		
	[self runDynamicSQL:sql forTable:table];
}

- (void)updateDictionary:(NSDictionary *)dbData forTable:(NSString *)table { 
	[self updateDictionary:dbData forTable:table where:NULL];
}

- (void)updateDictionary:(NSDictionary *)dbData forTable:(NSString *)table where:(NSString *)where {
	
	NSMutableString *sql = [NSMutableString stringWithCapacity:16];
	[sql appendFormat:@"UPDATE %@ SET ",table];
	
	NSArray *dataKeys = [dbData allKeys];
	for (int i = 0 ; i < [dataKeys count] ; i++) {
		if ([[dbData objectForKey:[dataKeys objectAtIndex:i]] intValue]) {
			[sql appendFormat:@"%@=%@",
			 [dataKeys objectAtIndex:i],
			 [dbData objectForKey:[dataKeys objectAtIndex:i]]];
		} else {
			[sql appendFormat:@"%@='%@'",
			 [dataKeys objectAtIndex:i],
			 [dbData objectForKey:[dataKeys objectAtIndex:i]]];
		}		
		if (i + 1 < [dbData count]) {
			[sql appendFormat:@", "];
		}
	}
	if (where != NULL) {
		[sql appendFormat:@" WHERE %@",where];
	}
	[self runDynamicSQL:sql forTable:table];
}

- (void)updateSQL:(NSString *)sql forTable:(NSString *)table {
	[self runDynamicSQL:sql forTable:table];
}

- (void)deleteWhere:(NSString *)where forTable:(NSString *)table {
	
	NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",
					 table,where];
	[self runDynamicSQL:sql forTable:table];
}

- (void) deleteAllFrom:(NSString *)table{
	NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", table];
	[self runDynamicSQL:sql forTable:table];
}

// INSERT/UPDATE/DELETE Subroutines

- (BOOL)runDynamicSQL:(NSString *)sql forTable:(NSString *)table {
	
	int result = 0;
	NSAssert1(self.dynamic == 1,@"Tried to use a dynamic function on a static database",NULL);
	sqlite3_stmt *statement = [self prepare:sql];
	if (statement)
    {
		result = sqlite3_step(statement);
    }		
	sqlite3_finalize(statement);
	if (result)
    {
		if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(databaseTableWasUpdated:)])
        {
			[delegate databaseTableWasUpdated:table];
		}	
		return YES;
	}
    else
    {
		return NO;
	}
	
}

- (NSString *)escapeString:(NSString *)dirtyString{
	NSString *cleanString = [dirtyString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
	return cleanString;
}

// requirements for closing things down

- (void)dealloc
{
	[self close];
    [super dealloc];
}

- (void)close {
	
	if (dbh) {
		sqlite3_close(dbh);
	}
}

- (BOOL)InsertReplaceDepartment:(NSArray *)arr
{
    BOOL success = TRUE;
    const char *query = "INSERT OR REPLACE INTO department (id, department, delete_flag) Values(?, ?, ?)";
    sqlite3_stmt *addStmt;
    for (int i = 0; i < [arr count]; i++)
    {
        if(sqlite3_prepare_v2(dbh, query, -1, &addStmt, NULL) == SQLITE_OK)
        {
            if([[arr objectAtIndex:i] objectForKey:@"id"] == nil || [[[arr objectAtIndex:i] objectForKey:@"id"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 1, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 1, [[[arr objectAtIndex:i] objectForKey:@"id"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"name"] == nil || [[[arr objectAtIndex:i] objectForKey:@"name"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 2, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 2, [[[arr objectAtIndex:i] objectForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"delete_flag"] == nil || [[[arr objectAtIndex:i] objectForKey:@"delete_flag"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 3, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 3, [[[arr objectAtIndex:i] objectForKey:@"delete_flag"] UTF8String], -1, SQLITE_TRANSIENT);
        }
        if(SQLITE_DONE != sqlite3_step(addStmt))
        {
            success = FALSE;
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(dbh));
        }
        //Reset the add statement.
        sqlite3_reset(addStmt);
    }
    return success;
}

- (BOOL)InsertReplaceEstimator:(NSArray *)arr
{
    BOOL success = TRUE;
    const char *query = "INSERT OR REPLACE INTO estimator (delete_flag, id, name, category, icon_on, icon_off, survey_js, fail_rate, info_image, display_order) Values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    sqlite3_stmt *addStmt;
    for (int i = 0; i < [arr count]; i++)
    {
        if(sqlite3_prepare_v2(dbh, query, -1, &addStmt, NULL) == SQLITE_OK)
        {
            if([[arr objectAtIndex:i] objectForKey:@"delete_flag"] == nil || [[[arr objectAtIndex:i] objectForKey:@"delete_flag"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 1, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 1, [[[arr objectAtIndex:i] objectForKey:@"delete_flag"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"id"] == nil || [[[arr objectAtIndex:i] objectForKey:@"id"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 2, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 2, [[[arr objectAtIndex:i] objectForKey:@"id"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"name"] == nil || [[[arr objectAtIndex:i] objectForKey:@"name"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 3, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 3, [[[arr objectAtIndex:i] objectForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"category"] == nil || [[[arr objectAtIndex:i] objectForKey:@"category"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 4, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 4, [[[arr objectAtIndex:i] objectForKey:@"category"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"icon_on"] == nil || [[[arr objectAtIndex:i] objectForKey:@"icon_on"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 5, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
            {
                //NSString *strURL = [NSString stringWithFormat:@"http://centurion.new.cosdevx.com/%@",[[arr objectAtIndex:i] objectForKey:@"icon_on"]];
                NSString *strURL = [NSString stringWithFormat:@"%@",[[arr objectAtIndex:i] objectForKey:@"icon_on"]];
                UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]]];
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *pngFilePath = [NSString stringWithFormat:@"%@/icon_on_%@.png",docDir,[[arr objectAtIndex:i] objectForKey:@"id"]];
                NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
                [data1 writeToFile:pngFilePath atomically:YES];
                [image release];
                
                sqlite3_bind_text(addStmt, 5, [pngFilePath UTF8String], -1, SQLITE_TRANSIENT);
            }
            
            if([[arr objectAtIndex:i] objectForKey:@"icon_off"] == nil || [[[arr objectAtIndex:i] objectForKey:@"icon_off"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 6, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
            {
                //NSString *strURL = [NSString stringWithFormat:@"http://centurion.new.cosdevx.com/%@",[[arr objectAtIndex:i] objectForKey:@"icon_off"]];
                NSString *strURL = [NSString stringWithFormat:@"%@",[[arr objectAtIndex:i] objectForKey:@"icon_off"]];
                UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]]];
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *pngFilePath = [NSString stringWithFormat:@"%@/icon_off_%@.png",docDir,[[arr objectAtIndex:i] objectForKey:@"id"]];
                NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
                [data1 writeToFile:pngFilePath atomically:YES];
                [image release];
                sqlite3_bind_text(addStmt, 6, [pngFilePath UTF8String], -1, SQLITE_TRANSIENT);
            }
            
            if([[arr objectAtIndex:i] objectForKey:@"js_url"] == nil || [[[arr objectAtIndex:i] objectForKey:@"js_url"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 7, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
            {
                NSString *stringURL = [NSString stringWithFormat:@"%@",[[arr objectAtIndex:i] objectForKey:@"js_url"]];
                NSURL  *url = [NSURL URLWithString:stringURL];
                NSData *urlData = [NSData dataWithContentsOfURL:url];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString  *documentsDirectory = [paths objectAtIndex:0];
                NSString  *filePath = [NSString stringWithFormat:@"%@/js_url_%@.js", documentsDirectory, [[arr objectAtIndex:i] objectForKey:@"id"]];
                [urlData writeToFile:filePath atomically:YES];
                
                sqlite3_bind_text(addStmt, 7, [filePath UTF8String], -1, SQLITE_TRANSIENT);
            }
            
            if([[arr objectAtIndex:i] objectForKey:@"fail_rate"] == nil || [[[arr objectAtIndex:i] objectForKey:@"fail_rate"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 8, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 8, [[[arr objectAtIndex:i] objectForKey:@"fail_rate"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"info_image"] == nil || [[[arr objectAtIndex:i] objectForKey:@"info_image"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 9, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
            {
                NSString *strURL = [NSString stringWithFormat:@"%@",[[arr objectAtIndex:i] objectForKey:@"info_image"]];
                UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]]];
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *pngFilePath = [NSString stringWithFormat:@"%@/info_image_%@.png",docDir,[[arr objectAtIndex:i] objectForKey:@"id"]];
                NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
                [data1 writeToFile:pngFilePath atomically:YES];
                [image release];
                sqlite3_bind_text(addStmt, 9, [pngFilePath UTF8String], -1, SQLITE_TRANSIENT);
            }
            
            if([[arr objectAtIndex:i] objectForKey:@"display_order"] == nil || [[[arr objectAtIndex:i] objectForKey:@"display_order"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 10, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 10, [[[arr objectAtIndex:i] objectForKey:@"display_order"] UTF8String], -1, SQLITE_TRANSIENT);
            
        }
        if(SQLITE_DONE != sqlite3_step(addStmt))
        {
            success = FALSE;
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(dbh));
        }
        //Reset the add statement.
        sqlite3_reset(addStmt);
    }
    return success;
}

- (BOOL)InsertReplaceLocation:(NSArray *)arr
{
    BOOL success = TRUE;
    const char *query = "INSERT OR REPLACE INTO location (id, name, contact_name, address_1, address_2, city, state, zip, country, phone_number, email, fax, display_order, default_flag, created_dt_tm, modified_dt_tm, delete_flag, update_flag) Values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ,? ,?, ?)";
    sqlite3_stmt *addStmt;
    for (int i = 0; i < [arr count]; i++)
    {
        if(sqlite3_prepare_v2(dbh, query, -1, &addStmt, NULL) == SQLITE_OK)
        {
            if([[arr objectAtIndex:i] objectForKey:@"id"] == nil || [[[arr objectAtIndex:i] objectForKey:@"id"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 1, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 1, [[[arr objectAtIndex:i] objectForKey:@"id"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"name"] == nil || [[[arr objectAtIndex:i] objectForKey:@"name"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 2, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 2, [[[arr objectAtIndex:i] objectForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"contact_name"] == nil || [[[arr objectAtIndex:i] objectForKey:@"contact_name"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 3, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 3, [[[arr objectAtIndex:i] objectForKey:@"contact_name"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"address_1"] == nil || [[[arr objectAtIndex:i] objectForKey:@"address_1"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 4, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 4, [[[arr objectAtIndex:i] objectForKey:@"address_1"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"address_2"] == nil || [[[arr objectAtIndex:i] objectForKey:@"address_2"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 5, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 5, [[[arr objectAtIndex:i] objectForKey:@"address_2"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"city"] == nil || [[[arr objectAtIndex:i] objectForKey:@"city"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 6, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 6, [[[arr objectAtIndex:i] objectForKey:@"city"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"state"] == nil || [[[arr objectAtIndex:i] objectForKey:@"state"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 7, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 7, [[[arr objectAtIndex:i] objectForKey:@"state"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"zip"] == nil || [[[arr objectAtIndex:i] objectForKey:@"zip"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 8, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 8, [[[arr objectAtIndex:i] objectForKey:@"zip"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"country"] == nil || [[[arr objectAtIndex:i] objectForKey:@"country"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 9, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 9, [[[arr objectAtIndex:i] objectForKey:@"country"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"phone_number"] == nil || [[[arr objectAtIndex:i] objectForKey:@"phone_number"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 10, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 10, [[[arr objectAtIndex:i] objectForKey:@"phone_number"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"email"] == nil || [[[arr objectAtIndex:i] objectForKey:@"email"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 11, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 11, [[[arr objectAtIndex:i] objectForKey:@"email"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"fax"] == nil || [[[arr objectAtIndex:i] objectForKey:@"fax"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 12, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 12, [[[arr objectAtIndex:i] objectForKey:@"fax"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"display_order"] == nil || [[[arr objectAtIndex:i] objectForKey:@"display_order"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 13, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 13, [[[arr objectAtIndex:i] objectForKey:@"display_order"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"default_flag"] == nil || [[[arr objectAtIndex:i] objectForKey:@"default_flag"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 14, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 14, [[[arr objectAtIndex:i] objectForKey:@"default_flag"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"created_dt_tm"] == nil || [[[arr objectAtIndex:i] objectForKey:@"created_dt_tm"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 15, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 15, [[[arr objectAtIndex:i] objectForKey:@"created_dt_tm"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"modified_dt_tm"] == nil || [[[arr objectAtIndex:i] objectForKey:@"modified_dt_tm"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 16, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 16, [[[arr objectAtIndex:i] objectForKey:@"modified_dt_tm"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"delete_flag"] == nil || [[[arr objectAtIndex:i] objectForKey:@"delete_flag"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 17, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 17, [[[arr objectAtIndex:i] objectForKey:@"delete_flag"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"update_flag"] == nil || [[[arr objectAtIndex:i] objectForKey:@"update_flag"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 18, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 18, [[[arr objectAtIndex:i] objectForKey:@"update_flag"] UTF8String], -1, SQLITE_TRANSIENT);
            
        }
        if(SQLITE_DONE != sqlite3_step(addStmt))
        {
            success = FALSE;
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(dbh));
        }
        //Reset the add statement.
        sqlite3_reset(addStmt);
    }
    return success;
}

- (BOOL)InsertReplaceQuestion:(NSArray *)arr
{
    BOOL success = TRUE;
    const char *query = "INSERT OR REPLACE INTO question (delete_flag, estimator_id, display_order, id, survey_asset_id, answer_type_id, question_text, units_prefix, units, min_val, max_val, increments,variable_name_to_js) Values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    sqlite3_stmt *addStmt;
    for (int i = 0; i < [arr count]; i++)
    {
        if(sqlite3_prepare_v2(dbh, query, -1, &addStmt, NULL) == SQLITE_OK)
        {
            if([[arr objectAtIndex:i] objectForKey:@"delete_flag"] == nil || [[[arr objectAtIndex:i] objectForKey:@"delete_flag"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 1, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 1, [[[arr objectAtIndex:i] objectForKey:@"delete_flag"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"estimator_id"] == nil || [[[arr objectAtIndex:i] objectForKey:@"estimator_id"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 2, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 2, [[[arr objectAtIndex:i] objectForKey:@"estimator_id"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"display_order"] == nil || [[[arr objectAtIndex:i] objectForKey:@"display_order"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 3, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 3, [[[arr objectAtIndex:i] objectForKey:@"display_order"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"id"] == nil || [[[arr objectAtIndex:i] objectForKey:@"id"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 4, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 4, [[[arr objectAtIndex:i] objectForKey:@"id"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"survey_asset_id"] == nil || [[[arr objectAtIndex:i] objectForKey:@"survey_asset_id"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 5, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 5, [[[arr objectAtIndex:i] objectForKey:@"survey_asset_id"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"question_type_id"] == nil || [[[arr objectAtIndex:i] objectForKey:@"question_type_id"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 6, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 6, [[[arr objectAtIndex:i] objectForKey:@"question_type_id"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"question_text"] == nil || [[[arr objectAtIndex:i] objectForKey:@"question_text"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 7, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 7, [[[arr objectAtIndex:i] objectForKey:@"question_text"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"prefix_units"] == nil || [[[arr objectAtIndex:i] objectForKey:@"prefix_units"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 8, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 8, [[[arr objectAtIndex:i] objectForKey:@"prefix_units"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"postfix_units"] == nil || [[[arr objectAtIndex:i] objectForKey:@"postfix_units"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 9, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 9, [[[arr objectAtIndex:i] objectForKey:@"postfix_units"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"min_val"] == nil || [[[arr objectAtIndex:i] objectForKey:@"min_val"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 10, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 10, [[[arr objectAtIndex:i] objectForKey:@"min_val"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"max_val"] == nil || [[[arr objectAtIndex:i] objectForKey:@"max_val"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 11, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 11, [[[arr objectAtIndex:i] objectForKey:@"max_val"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"increments"] == nil || [[[arr objectAtIndex:i] objectForKey:@"increments"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 12, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 12, [[[arr objectAtIndex:i] objectForKey:@"increments"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"variable_name_to_js"] == nil || [[[arr objectAtIndex:i] objectForKey:@"variable_name_to_js"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 13, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 13, [[[arr objectAtIndex:i] objectForKey:@"variable_name_to_js"] UTF8String], -1, SQLITE_TRANSIENT);
            
        }
        if(SQLITE_DONE != sqlite3_step(addStmt))
        {
            success = FALSE;
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(dbh));
        }
        //Reset the add statement.
        sqlite3_reset(addStmt);
    }
    return success;
}

- (BOOL)InsertReplaceQuestionValue:(NSArray *)arr
{
    BOOL success = TRUE;
    const char *query = "INSERT OR REPLACE INTO question_value (delete_flag, id, question_id, estimator_id, value_text, fail_rate, display_order, default_flag) Values(?, ?, ?, ?, ?, ?, ?, ?)";
    sqlite3_stmt *addStmt;
    for (int i = 0; i < [arr count]; i++)
    {
        if(sqlite3_prepare_v2(dbh, query, -1, &addStmt, NULL) == SQLITE_OK)
        {
            if([[arr objectAtIndex:i] objectForKey:@"delete_flag"] == nil || [[[arr objectAtIndex:i] objectForKey:@"delete_flag"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 1, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 1, [[[arr objectAtIndex:i] objectForKey:@"delete_flag"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"id"] == nil || [[[arr objectAtIndex:i] objectForKey:@"id"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 2, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 2, [[[arr objectAtIndex:i] objectForKey:@"id"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"question_id"] == nil || [[[arr objectAtIndex:i] objectForKey:@"question_id"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 3, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 3, [[[arr objectAtIndex:i] objectForKey:@"question_id"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"estimator_id"] == nil || [[[arr objectAtIndex:i] objectForKey:@"estimator_id"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 4, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 4, [[[arr objectAtIndex:i] objectForKey:@"estimator_id"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"value_text"] == nil || [[[arr objectAtIndex:i] objectForKey:@"value_text"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 5, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 5, [[[arr objectAtIndex:i] objectForKey:@"value_text"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"fail_rate"] == nil || [[[arr objectAtIndex:i] objectForKey:@"fail_rate"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 6, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 6, [[[arr objectAtIndex:i] objectForKey:@"fail_rate"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"display_order"] == nil || [[[arr objectAtIndex:i] objectForKey:@"display_order"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 7, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 7, [[[arr objectAtIndex:i] objectForKey:@"display_order"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"default_flag"] == nil || [[[arr objectAtIndex:i] objectForKey:@"default_flag"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 8, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 8, [[[arr objectAtIndex:i] objectForKey:@"default_flag"] UTF8String], -1, SQLITE_TRANSIENT);
        }
        if(SQLITE_DONE != sqlite3_step(addStmt))
        {
            success = FALSE;
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(dbh));
        }
        //Reset the add statement.
        sqlite3_reset(addStmt);
    }
    return success;
}

- (BOOL)InsertReplaceSurveyAsset:(NSArray *)arr
{
    BOOL success = TRUE;
    const char *query = "INSERT OR REPLACE INTO survey_assets (page_title, id, estimator_id, display_order, evidence_based_insights, survey_references, delete_flag) Values(?, ?, ?, ?, ?, ?, ?)";
    sqlite3_stmt *addStmt;
    for (int i = 0; i < [arr count]; i++)
    {
        if(sqlite3_prepare_v2(dbh, query, -1, &addStmt, NULL) == SQLITE_OK)
        {
            if([[arr objectAtIndex:i] objectForKey:@"page_title"] == nil || [[[arr objectAtIndex:i] objectForKey:@"page_title"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 1, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 1, [[[arr objectAtIndex:i] objectForKey:@"page_title"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"id"] == nil || [[[arr objectAtIndex:i] objectForKey:@"id"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 2, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 2, [[[arr objectAtIndex:i] objectForKey:@"id"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"estimator_id"] == nil || [[[arr objectAtIndex:i] objectForKey:@"estimator_id"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 3, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 3, [[[arr objectAtIndex:i] objectForKey:@"estimator_id"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"display_order"] == nil || [[[arr objectAtIndex:i] objectForKey:@"display_order"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 4, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 4, [[[arr objectAtIndex:i] objectForKey:@"display_order"] UTF8String], -1, SQLITE_TRANSIENT);
            
            if([[arr objectAtIndex:i] objectForKey:@"evidence_based_insights"] == nil || [[[arr objectAtIndex:i] objectForKey:@"evidence_based_insights"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 5, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
            {
                NSString *strTemp1 = [[arr objectAtIndex:i] objectForKey:@"evidence_based_insights"];
                strTemp1 = [strTemp1 stringByEncodingHTMLEntities];
                //use stringByDecodingHTMLEntities while decoding
                sqlite3_bind_text(addStmt, 5, [strTemp1 UTF8String], -1, SQLITE_TRANSIENT);
            }
            
            if([[arr objectAtIndex:i] objectForKey:@"references"] == nil || [[[arr objectAtIndex:i] objectForKey:@"references"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 6, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
            {
                NSString *strTemp = [[arr objectAtIndex:i] objectForKey:@"references"];
                strTemp = [strTemp stringByEncodingHTMLEntities];
                //use stringByDecodingHTMLEntities while decoding
                sqlite3_bind_text(addStmt, 6, [strTemp UTF8String], -1, SQLITE_TRANSIENT);
            }
            
            if([[arr objectAtIndex:i] objectForKey:@"delete_flag"] == nil || [[[arr objectAtIndex:i] objectForKey:@"delete_flag"] isKindOfClass:[NSNull class]])
                sqlite3_bind_text(addStmt, 7, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            else
                sqlite3_bind_text(addStmt, 7, [[[arr objectAtIndex:i] objectForKey:@"delete_flag"] UTF8String], -1, SQLITE_TRANSIENT);
        }
        if(SQLITE_DONE != sqlite3_step(addStmt))
        {
            success = FALSE;
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(dbh));
        }
        //Reset the add statement.
        sqlite3_reset(addStmt);
    }
    return success;
}

@end
