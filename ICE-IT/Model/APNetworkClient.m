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

static NSString * const SERVER_PREFIX = @"https://ice-ita.appspot.com/blob/";
static NSString * const LATEST_DB = @"serve/icedb.sqlite";

@implementation APNetworkClient

+ (void) getLastDBVersion:(void (^)(NSInteger))lastVersion{
    
}
- (void) dowloadLatestDB:(void (^)())ready{
    
    NSString *callString = [NSString stringWithFormat:@"%@%@",SERVER_PREFIX,LATEST_DB];
    
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // 3
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:sessionConfig
                                  delegate:self
                             delegateQueue:nil];
    
    NSURLSessionDataTask *getDBTask =
    [session dataTaskWithURL:[NSURL URLWithString:callString]
     
               completionHandler:^(NSData *data,
                                   NSURLResponse *response,
                                   NSError *error) {
                   if (error){
                       
                   }
                   // ALog("Data size is %lu", (unsigned long)data.length);
                   NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                   NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:kNewDBName]];
                   
                   [data writeToFile:databasePath atomically:YES];
                   [[APDBManager sharedInstance] checkNewDBInstance];
                   
               }];
    
    // 4
    [getDBTask resume];
    
}


@end
