//
//  APDBManager.m
//  ICE-IT
//
//  Created by Andi Palo on 09/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APDBManager.h"
#import <sqlite3.h>
#import "APConstants.h"
#import "APCityNumber.h"
#import "APLanguageBond.h"

NSString *COMMON_NUMBERS = @"ALL";
NSString *DB_NAME = @"icedb.sqlite";

static NSMutableDictionary *allUIStrings;

@implementation APDBManager

+ (int) openDB:(sqlite3 **)numDB withName:(NSString*)atDBPath{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath: atDBPath] == NO){
        ALog("Error here buddy , could not find new Database file");
        return SQLITE_ERROR;
    }else{
        const char *dbpath = [atDBPath UTF8String];
        
        if (sqlite3_open(dbpath, numDB) != SQLITE_OK){
            ALog("Failed to open/create database");
            return SQLITE_CANTOPEN;
        }else{
            return SQLITE_OK;
        }
    }
    
}


- (void) copyDBInData{
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* dbPath = [docPath stringByAppendingPathComponent:kActiveDBName];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Get Current DB Version
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int dbv = [[prefs objectForKey:kCurrentDBVersion] intValue];
    
    NSString* dbTemplatePath = [[NSBundle mainBundle] pathForResource:@"icedb" ofType:@"sqlite"];
    NSError* error = nil;

    // Check if the database is already copied
    if(![fm fileExistsAtPath:dbPath])
    {
        [fm copyItemAtPath:dbTemplatePath toPath:dbPath error:&error];
        if(error){
            NSLog(@"can't copy db template.");
            assert(false);        
        }

        //save current db version
        [prefs setObject:[NSNumber numberWithInteger:kShippingDBVersion] forKey:kCurrentDBVersion];
        
        //verify this shipping version
    }else if (kShippingDBVersion > dbv){
        [fm removeItemAtPath:dbPath error:&error];
        if (error) {
            ALog("Can't delete old file");
        }
        [fm copyItemAtPath:dbTemplatePath toPath:dbPath error:&error];
        if(error){
            NSLog(@"can't copy db template.");
            assert(false);
        }
        
        //save current db version
        [prefs setObject:[NSNumber numberWithInteger:kShippingDBVersion] forKey:kCurrentDBVersion];
    }else{
        ALog("Not copied because exists");
    }
}

- (BOOL) checkNewDBInstance{
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *currentDB = [docPath stringByAppendingPathComponent:kActiveDBName];
    NSString *newDB = [docPath stringByAppendingPathComponent:kNewDBName];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *error;

    NSMutableSet *oldLanguageCodes = [APDBManager getLanguagesCodesSync:currentDB inCaseOfError:&error];
    if (error) {
        ALog("Check not passed, error occured: %@", [error localizedDescription]);
        return NO;
    }
    NSMutableSet *newLanguageCodes = [APDBManager getLanguagesCodesSync:newDB inCaseOfError:&error];
    if (error) {
        ALog("Check not passed, error occured: %@", [error localizedDescription]);
        return NO;
    }
    
    [newLanguageCodes minusSet:oldLanguageCodes];
    
    //in table names of new db there should be a column for each new language
    NSMutableSet *columnNames = [APDBManager getColumnNames:@"names" ofDB:newDB inCaseOfError:&error];
    if (error) {
        ALog("Check not passed, error occured: %@", [error localizedDescription]);
        return NO;
    }

    for (NSString* newCode in newLanguageCodes) {
        NSString* extendedName = [NSString stringWithFormat:@"name_%@",newCode];
        BOOL found = NO;
        for (NSString* cName in columnNames) {
            if ([extendedName isEqualToString:cName]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            ALog("Check not passed, error occured: No column with such language name");
            return NO;
        }
    }
    
    //in table uistrings of new db there should be a column for each new language
    columnNames = [APDBManager getColumnNames:@"uistrings" ofDB:newDB inCaseOfError:&error];
    if (error) {
        ALog("Check not passed, error occured: %@", [error localizedDescription]);
        return NO;
    }
    
    for (NSString* newCode in newLanguageCodes) {
        NSString* extendedName = [NSString stringWithFormat:@"desc_%@",newCode];
        BOOL found = NO;
        for (NSString* cName in columnNames) {
            if ([extendedName isEqualToString:cName]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            ALog("Check not passed, error occured: No column with such language name");
            return NO;
        }
    }
    
    //At this point remains the last verification for empty values on new columns.

    //finally replace old db with new DB and delete old one
    if ([fileMgr removeItemAtPath:currentDB error:&error] != YES)
        ALog(@"Unable to delete file: %@", [error localizedDescription]);
    
    if ([fileMgr moveItemAtPath:newDB toPath:currentDB error:&error] != YES){
        ALog(@"Unable to move file: %@", [error localizedDescription]);
        return NO;
    }
    
    // Reload UIStrings before returning
    [self loadUIStringsForLang:[[NSUserDefaults standardUserDefaults] objectForKey:kCurrentLang]
                      reportTo:nil];
    
    ALog("All check passed new DB adopted!!");
    return YES;
}

+ (NSMutableSet*) getColumnNames:(NSString*)columnName ofDB:(NSString*)ofDB inCaseOfError:(NSError**)error{
    NSMutableSet *result;
    sqlite3 *numDB;
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    
    if ([APDBManager openDB:&numDB withName:ofDB] != SQLITE_OK){
        [details setValue:@"Generic database error" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Database" code:200 userInfo:details];
        return nil;
    }else{
        NSString *querySQL;
        sqlite3_stmt    *statement;
        querySQL = [NSString stringWithFormat:@"PRAGMA table_info(%@)",columnName];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(numDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            NSString *v;
            result = [[NSMutableSet alloc] init];
            while (sqlite3_step(statement) == SQLITE_ROW) {
                v = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                [result addObject:v];
            }
            sqlite3_finalize(statement);
            sqlite3_close(numDB);
            return result;
        }else{
            [details setValue:@"Error in fetching query" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Database" code:202 userInfo:details];
            sqlite3_close(numDB);
            return nil;
        }
    }
}
+ (NSMutableSet*) getLanguagesCodesSync:(NSString*)atDBPath inCaseOfError:(NSError**)error{
    NSMutableSet *result;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    sqlite3 *numDB;
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    
    if ([fileMgr fileExistsAtPath: atDBPath] == NO){
        
        [details setValue:@"Error in reading DB file" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Database" code:200 userInfo:details];
        
        ALog("Error here buddy , could not find new Database file");
        return nil;
    }else{
        const char *dbpath = [atDBPath UTF8String];
        
        if (sqlite3_open(dbpath, &numDB) != SQLITE_OK){
            [details setValue:@"Failed to open/create database" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Database" code:201 userInfo:details];

            ALog("Failed to open/create database");
            return nil;
        }

        NSString *querySQL;
        sqlite3_stmt    *statement;
        querySQL = [NSString stringWithFormat:@"SELECT distinct(language) FROM languages"];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(numDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            NSString *v;
            result = [[NSMutableSet alloc] init];
            while (sqlite3_step(statement) == SQLITE_ROW) {
                v = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [result addObject:v];
            }
            sqlite3_finalize(statement);
            sqlite3_close(numDB);
            return result;
        }else{
            [details setValue:@"Error in fetching query" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Database" code:202 userInfo:details];
            sqlite3_close(numDB);
            return nil;
        }
    }
}
+ (APDBManager*) sharedInstance{
    static APDBManager* _sharedInstance = nil;

    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[APDBManager alloc] init];
    });
    return _sharedInstance;
}
+ (void)getCityListWhenReady:(void (^)(NSArray *))cityListReady{
    //Root filepath
    NSString *databasePath;
    sqlite3 *numDB;
//  NSString *appDir = [[NSBundle mainBundle] resourcePath];
    NSString* appDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    databasePath = [[NSString alloc] initWithString: [appDir stringByAppendingPathComponent:kActiveDBName]];
//    ALog("DATA base path : %@",databasePath);
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO){
        ALog("Error here buddy , could not find numbers db file");
    }else{
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &numDB) != SQLITE_OK){
            ALog("Failed to open/create database");
        }
        //Load data
        
        
        NSString *querySQL;
        sqlite3_stmt    *statement;
        

        querySQL = [NSString stringWithFormat:@"SELECT distinct(CITY) FROM numbers where CITY <> '%@'",COMMON_NUMBERS];
        
        //        ALog("Items for car model %@",querySQL);
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(numDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSMutableArray *result = [[NSMutableArray alloc]init];
            //            ALog("Query returns something");
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *city = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [result addObject:city];
            }
            sqlite3_finalize(statement);
            cityListReady(result);
        }else{
            
        }
        
        sqlite3_close(numDB);
    }
}

+ (void)getLanguageListWhenReady:(void (^)(NSArray *))langListReady{
    //Root filepath
    NSString *databasePath;
    sqlite3 *numDB;
    
    NSString* appDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    databasePath = [[NSString alloc] initWithString: [appDir stringByAppendingPathComponent:kActiveDBName]];
    //    ALog("DATA base path : %@",databasePath);
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO){
        ALog("Error here buddy , could not find ice db file");
    }else{
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &numDB) != SQLITE_OK){
            ALog("Failed to open/create database");
        }
        //Load data
        
        
        NSString *querySQL;
        sqlite3_stmt    *statement;
        
        
        querySQL = [NSString stringWithFormat:@"SELECT distinct(extended),language FROM languages"];
        
        //        ALog("Items for car model %@",querySQL);
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(numDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSMutableArray *result = [[NSMutableArray alloc]init];
            //            ALog("Query returns something");
            APLanguageBond *lb;
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *lang = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                NSString *code = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                lb = [[APLanguageBond alloc] initWithLang:lang andCode:code];
                [result addObject:lb];
            }
            sqlite3_finalize(statement);
            langListReady(result);
        }else{
            
        }
        sqlite3_close(numDB);
    }
}

+ (void)getCityNums:(NSString*)city forLang:(NSString*)language reportTo:(id<CityOrLanguageChanges>)delegate{
    //Root filepath
    NSString *databasePath;
    sqlite3 *numDB;

    NSString* appDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    databasePath = [[NSString alloc] initWithString: [appDir stringByAppendingPathComponent:kActiveDBName]];
    
    //    ALog("DATA base path : %@",databasePath);
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO){
        ALog("Error here buddy , could not find numbers db file");
    }else{
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &numDB) != SQLITE_OK){
            ALog("Failed to open/create database");
        }
        //Load data
        
        
        NSString *querySQL;
        sqlite3_stmt    *statement;
        
        
        querySQL = [NSString stringWithFormat:@"SELECT NUMBER, name_%@, PRIORITY, CITY FROM (SELECT NUMBER,DESC,PRIORITY, CITY from numbers where CITY in ('%@','%@') ORDER BY PRIORITY) as N JOIN (SELECT id, name_%@ FROM names) as M ON N.DESC = M.id",language, COMMON_NUMBERS,city,language];
        
//        ALog("Items for car model %@",querySQL);
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(numDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSMutableArray *result = [[NSMutableArray alloc]init];
            //            ALog("Query returns something");
            APCityNumber *current;
            NSString *cityName;
            while (sqlite3_step(statement) == SQLITE_ROW) {
                current = [[APCityNumber alloc] init];
                current.number = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                current.desc = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                current.priority = sqlite3_column_int(statement, 2);
                cityName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                current.isCommon = [cityName isEqualToString:COMMON_NUMBERS] ? YES : NO;
                [result addObject:current];
            }
            sqlite3_finalize(statement);
            [delegate newDataIsReady:result];
        }else{
            
        }
        
        sqlite3_close(numDB);
    }
}

#pragma mark - UI Strings

- (void) loadUIStringsForLang:(NSString*)langCode reportTo:(id<UIStringsUpdate>)delegate{
    //Root filepath
    
    if (allUIStrings != nil) {
        [allUIStrings removeAllObjects];
    }else{
        allUIStrings = [[NSMutableDictionary alloc] init];
    }
    NSString *databasePath;
    sqlite3 *numDB;
    
    NSString* appDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    databasePath = [[NSString alloc] initWithString: [appDir stringByAppendingPathComponent:kActiveDBName]];
    
    //    ALog("DATA base path : %@",databasePath);
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO){
        ALog("Error here buddy , could not find numbers db file");
    }else{
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &numDB) != SQLITE_OK){
            ALog("Failed to open/create database");
        }
        //Load data
        
        
        NSString *querySQL;
        sqlite3_stmt    *statement;
        
        
        querySQL = [NSString stringWithFormat:@"SELECT id, desc_%@ from uistrings",langCode];
        
        //        ALog("Items for car model %@",querySQL);
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(numDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSString *k, *v;
            while (sqlite3_step(statement) == SQLITE_ROW) {
                k = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                v = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                [allUIStrings setValue:v forKey:k];
            }
            sqlite3_finalize(statement);
            //            ALog("Dict: %@ \n language is %@ \n code is %@",allSupportedCodes,language, allSupportedCodes[language]);
            [delegate uiStringsReady];
        }else{
            
        }
        sqlite3_close(numDB);
    }
}

- (NSString*) getUIStringForCode:(NSString*)code{
    return allUIStrings[code];
}

@end
