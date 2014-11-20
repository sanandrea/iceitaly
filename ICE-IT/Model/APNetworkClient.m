//
//  APNetworkClient.m
//  ICE-IT
//
//  Created by Andi Palo on 14/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "APNetworkClient.h"
#import "APConstants.h"
#import "APDBManager.h"
#import "APImageStore.h"

static NSString * const SERVER_PREFIX = @"https://ice-ita.appspot.com/blob/";
static NSString * const LATEST_DB = @"serve/icedb.sqlite";
static NSString * const DB_VERSION = @"https://ice-ita.appspot.com/_ah/api/iceserver/v1/db_version";
static NSString * const IMAGE_LIST = @"https://ice-ita.appspot.com/_ah/api/iceserver/v1/image_list";


@implementation APNetworkClient{
    id<UpdateReleased> _myDelegate;
    BOOL _newDB;
}

- (void) getLastDBVersion:(NSURLSession*)session{
    NSString *callString = DB_VERSION;
    NSURLSessionDataTask *getDBTask =
    [session dataTaskWithURL:[NSURL URLWithString:callString]
     
           completionHandler:^(NSData *data,
                               NSURLResponse *response,
                               NSError *error) {
               if (error){
                   ALog("Error is %@", [error description]);
               }

               NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
               if (httpResp.statusCode == 200) {
                   
                   NSError *jsonError;
                   
                   // 2
                   NSDictionary *responseJSON =
                   [NSJSONSerialization JSONObjectWithData:data
                                                   options:NSJSONReadingAllowFragments
                                                     error:&jsonError];
                   
                   //ALog("JSON IS: %@",responseJSON);
                   
                   if (!jsonError) {
                       NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                       NSUInteger currentVersion = [[prefs objectForKey:kCurrentDBVersion] integerValue];
                       if ([responseJSON[@"latest_ver"] integerValue] > currentVersion) {
                           _newDB = YES;
                           [self downloadNewDB:session];
                           [self checkForNewImages:session];
                       }
                   }
               }
           }];
    
    // 4
    [getDBTask resume];
    
}
- (void) dowloadLatestDBIfNewerThan:(NSUInteger)currentVersion reportTo:(id<UpdateReleased>)delegate{
    _myDelegate = delegate;
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // 3
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:sessionConfig
                                  delegate:self
                             delegateQueue:nil];
    
    [self getLastDBVersion:session];
}

- (void) downloadNewDB:(NSURLSession*)session{
    NSString *callString = [NSString stringWithFormat:@"%@%@",SERVER_PREFIX,LATEST_DB];
    
    NSURLSessionDataTask *getDBTask =
    [session dataTaskWithURL:[NSURL URLWithString:callString]
     
           completionHandler:^(NSData *data,
                               NSURLResponse *response,
                               NSError *error) {
               if (error){
                   
               }
               ALog("Data size is %lu", (unsigned long)data.length);
               NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
               NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:kNewDBName]];
               
               [data writeToFile:databasePath atomically:YES];
               [[APDBManager sharedInstance] checkNewDBInstance];
               
           }];
    
    // 4
    [getDBTask resume];
}

- (void) checkForNewImages:(NSURLSession*)session{
    NSString *callString = IMAGE_LIST;
    NSURLSessionDataTask *getDBTask =
    [session dataTaskWithURL:[NSURL URLWithString:callString]
     
           completionHandler:^(NSData *data,
                               NSURLResponse *response,
                               NSError *error) {
               if (error){
                   ALog("Error is %@", [error description]);
               }
               
               NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
               if (httpResp.statusCode == 200) {
                   
                   NSError *jsonError;
                   
                   // 2
                   NSDictionary *responseJSON =
                   [NSJSONSerialization JSONObjectWithData:data
                                                   options:NSJSONReadingAllowFragments
                                                     error:&jsonError];
                   
                   //ALog("JSON IS: %@",responseJSON);
                   
                   if (!jsonError) {
                       NSArray *localImages = [APImageStore getCurrentStoredImages];
                       for (NSString *im in responseJSON[@"items"]) {
                           if ([localImages indexOfObject:im] == NSNotFound){
                               
                           }
                       }
                       NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                       NSUInteger currentVersion = [[prefs objectForKey:kCurrentDBVersion] integerValue];
                       if ([responseJSON[@"latest_ver"] integerValue] > currentVersion) {
                           _newDB = YES;
                           [self downloadNewDB:session];
                       }
                   }
               }
           }];
    
    // 4
    [getDBTask resume];
    
}


@end
