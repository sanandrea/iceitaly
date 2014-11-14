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

NSString *COMMON_NUMBERS = @"ALL";
NSString *DB_NAME = @"icedb.sqlite";

@implementation APDBManager
- (void) copyDBInData{
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* dbPath = [docPath stringByAppendingPathComponent:kActiveDBName];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Check if the database is existed.
    if(![fm fileExistsAtPath:dbPath])
    {
        // If database is not existed, copy from the database template in the bundle
        NSString* dbTemplatePath = [[NSBundle mainBundle] pathForResource:@"icedb" ofType:@"sqlite"];
        NSError* error = nil;
        [fm copyItemAtPath:dbTemplatePath toPath:dbPath error:&error];
        if(error){
            NSLog(@"can't copy db template.");
            assert(false);        
        }
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
    
    if ([fileMgr removeItemAtPath:currentDB error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
    if ([fileMgr moveItemAtPath:newDB toPath:currentDB error:&error] != YES){
        NSLog(@"Unable to move file: %@", [error localizedDescription]);
        return YES;
    }else{
        return  NO;
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
    NSString *appDir = [[NSBundle mainBundle] resourcePath];
    
    databasePath = [[NSString alloc] initWithString: [appDir stringByAppendingPathComponent:DB_NAME]];
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
    NSString *appDir = [[NSBundle mainBundle] resourcePath];
    
    databasePath = [[NSString alloc] initWithString: [appDir stringByAppendingPathComponent:DB_NAME]];
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
        
        
        querySQL = [NSString stringWithFormat:@"SELECT distinct(extended) FROM languages"];
        
        //        ALog("Items for car model %@",querySQL);
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(numDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSMutableArray *result = [[NSMutableArray alloc]init];
            //            ALog("Query returns something");
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *lang = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [result addObject:lang];
            }
            sqlite3_finalize(statement);
            langListReady(result);
        }else{
            
        }
        sqlite3_close(numDB);
    }
}

+ (void)getLanguageFromCode:(NSString*)code then:(void (^)(NSString*))nameReady{
    //Root filepath
    static NSMutableDictionary *allSupportedLangs;
    if (allSupportedLangs != nil) {
        nameReady(allSupportedLangs[code]);
        return;
    }
    allSupportedLangs = [[NSMutableDictionary alloc] init];
    NSString *databasePath;
    sqlite3 *numDB;
    NSString *appDir = [[NSBundle mainBundle] resourcePath];
    
    databasePath = [[NSString alloc] initWithString: [appDir stringByAppendingPathComponent:DB_NAME]];
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
        
        
        querySQL = [NSString stringWithFormat:@"SELECT language, extended FROM languages"];
        
        //        ALog("Items for car model %@",querySQL);
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(numDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSString *k, *v;
            while (sqlite3_step(statement) == SQLITE_ROW) {
                k = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                v = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                [allSupportedLangs setValue:v forKey:k];
            }
            sqlite3_finalize(statement);
            nameReady(allSupportedLangs[code]);
        }else{
            
        }
        sqlite3_close(numDB);
    }
}

+ (void)getCodeFromLanguage:(NSString*)language then:(void (^)(NSString*))nameReady{
    //Root filepath
    static NSMutableDictionary *allSupportedCodes;
    if (allSupportedCodes != nil) {
        nameReady(allSupportedCodes[language]);
        return;
    }
    allSupportedCodes = [[NSMutableDictionary alloc] init];
    NSString *databasePath;
    sqlite3 *numDB;
    NSString *appDir = [[NSBundle mainBundle] resourcePath];
    
    databasePath = [[NSString alloc] initWithString: [appDir stringByAppendingPathComponent:DB_NAME]];
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
        
        
        querySQL = [NSString stringWithFormat:@"SELECT language, extended FROM languages"];
        
        //        ALog("Items for car model %@",querySQL);
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(numDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSString *k, *v;
            while (sqlite3_step(statement) == SQLITE_ROW) {
                k = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                v = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [allSupportedCodes setValue:v forKey:k];
            }
            sqlite3_finalize(statement);
//            ALog("Dict: %@ \n language is %@ \n code is %@",allSupportedCodes,language, allSupportedCodes[language]);
            nameReady(allSupportedCodes[language]);
        }else{
            
        }
        sqlite3_close(numDB);
    }
}

+ (void)getCityNums:(NSString*)city forLang:(NSString*)language whenReady:(void (^)(NSArray *))cityNumsReady{
    //Root filepath
    NSString *databasePath;
    sqlite3 *numDB;
    NSString *appDir = [[NSBundle mainBundle] resourcePath];
    
    databasePath = [[NSString alloc] initWithString: [appDir stringByAppendingPathComponent:DB_NAME]];
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
        
        
        querySQL = [NSString stringWithFormat:@"SELECT NUMBER, name_%@ FROM (SELECT NUMBER,DESC from numbers where CITY in ('%@','%@') ORDER BY PRIORITY) as N JOIN (SELECT id, name_%@ FROM names) as M ON N.DESC = M.id",language, COMMON_NUMBERS,city,language];
        
//        ALog("Items for car model %@",querySQL);
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(numDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSMutableArray *result = [[NSMutableArray alloc]init];
            //            ALog("Query returns something");
            APCityNumber *current;
            while (sqlite3_step(statement) == SQLITE_ROW) {
                current = [[APCityNumber alloc] init];
                current.number = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                current.desc = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                [result addObject:current];
            }
            sqlite3_finalize(statement);
            cityNumsReady(result);
        }else{
            
        }
        
        sqlite3_close(numDB);
    }
}

@end
