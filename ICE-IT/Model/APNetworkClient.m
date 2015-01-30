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

@interface  APNetworkClient()
@property (strong, nonatomic) NSURLSessionDownloadTask* dbDownloadTask;
@property NSUInteger totalImageTasks;
@property NSUInteger remainingImageTasks;
@property double dbDownloadProgress;
@end

@implementation APNetworkClient{
    id<UpdateReleased> _myDelegate;
    BOOL _newDB;
    int _newDBVersion;
}

- (id) init{
    self = [super init];
    
    if (self) {
        self.totalImageTasks = 0;
        self.remainingImageTasks = 0;
    }
    return self;
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
                           _newDBVersion = [responseJSON[@"latest_ver"] intValue];
                           [self downloadFile:session
                                     fileName:LATEST_DB
                                         isDB:YES];
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

- (void) downloadFile:(NSURLSession*)session fileName:(NSString*)name isDB:(BOOL)isDB{
    NSString *callString;
    if (isDB) {
        callString = [NSString stringWithFormat:@"%@%@",SERVER_PREFIX,name];
    }else{
        callString = [NSString stringWithFormat:@"%@image/%@",SERVER_PREFIX,name];
    }

    NSURLSessionDownloadTask *getFileTask = [session downloadTaskWithURL:[NSURL URLWithString:callString]];

    if (isDB) {
        self.dbDownloadTask = getFileTask;
    }else{
        self.totalImageTasks ++;
        self.remainingImageTasks ++;
    }

    // 4
    [getFileTask resume];
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
                   
//                   ALog("JSON IS: %@",responseJSON);
                   
                   if (!jsonError) {
                       NSArray *localImages = [APImageStore getCurrentStoredImages];
                       for (NSDictionary *item in responseJSON[@"items"]) {
                           if ([localImages indexOfObject:item[@"image"]] == NSNotFound){
                               [self downloadFile:session
                                         fileName:item[@"image"]
                                             isDB:NO];
                           }
                       }
                   }
               }
           }];
    
    // 4
    [getDBTask resume];
}

#pragma mark - NSURLSessionDownloadDelegate

-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
     didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"%f / %f", (double)totalBytesWritten,(double)totalBytesExpectedToWrite);
    
//    ALog("Total tasks %lu",(unsigned long)self.totalImageTasks);
//    ALog("Remaining image tasks %lu", (unsigned long)self.remainingImageTasks);
    
    //Distribute equally all tasks
    if (downloadTask == self.dbDownloadTask) {
        self.dbDownloadProgress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
        double imageProgress = (self.totalImageTasks == 0) ? 0 : (1 - (double)self.remainingImageTasks) / (1 + (double)self.totalImageTasks);
        [_myDelegate updateProgress:((self.dbDownloadProgress / (1 + self.totalImageTasks)) + imageProgress)];
    }
}


- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{

    NSString *filePath;
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL isDB = (downloadTask == self.dbDownloadTask) ? YES : NO;
    if (isDB) {
        filePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:kNewDBName]];
    }else{
        filePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:[[downloadTask response] suggestedFilename]]];
    }
    //File already exists, it is not normal, replace file silently!
    if ([fileManager fileExistsAtPath:filePath]){
        [fileManager replaceItemAtURL:[NSURL URLWithString:filePath]
                        withItemAtURL:location
                       backupItemName:nil
                              options:NSFileManagerItemReplacementUsingNewMetadataOnly
                     resultingItemURL:nil
                                error:&error];
    }else{
        [fileManager moveItemAtPath:[location path] toPath:filePath error:&error];
    }
    
    //Now that DB is downloaded write new version and begin checks
    if (isDB) {
#warning Uncomment
        //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        //[prefs setObject:[NSNumber numberWithInt:_newDBVersion] forKey:kCurrentDBVersion];
        
        if ([[APDBManager sharedInstance] checkNewDBInstance]) {
            [_myDelegate reloadNewData];
        }
    }else{
        self.remainingImageTasks --;
        [_myDelegate updateProgress:((self.dbDownloadProgress / (1 + self.totalImageTasks)) + ((1 - (double)self.remainingImageTasks) / ((double)self.totalImageTasks + 1)))];

    }
    
}






@end
