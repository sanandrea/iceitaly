// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
@property BOOL dbIsReady;
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
        self.dbIsReady = NO;
    }
    return self;
}
- (void) getLastDBVersion:(NSURLSession*)session{
    NSString *callString = DB_VERSION;
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    NSURLSessionDataTask *getDBTask =
    [session dataTaskWithURL:[NSURL URLWithString:callString]
     
           completionHandler:^(NSData *data,
                               NSURLResponse *response,
                               NSError *error) {
               NSError *errorOther = nil;
               
               if (error){
                   ALog("Error is %@", [error description]);
                   [_myDelegate errorOccurred:error];
                   return;
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
                       }else{
                           [_myDelegate noUpdate];
                       }
                   }else{
                       [details setValue:@"Malformed response" forKey:NSLocalizedDescriptionKey];
                       errorOther = [NSError errorWithDomain:@"Network" code:kErrorBadResponse userInfo:details];
                       [_myDelegate errorOccurred:error];
                   }
               }else if (httpResp.statusCode >= 500){
                   [details setValue:@"Server Error" forKey:NSLocalizedDescriptionKey];
                   errorOther = [NSError errorWithDomain:@"Network" code:kErrorInternalServer userInfo:details];
                   [_myDelegate errorOccurred:error];
               }else{
                   [details setValue:@"Generic Error" forKey:NSLocalizedDescriptionKey];
                   errorOther = [NSError errorWithDomain:@"Network" code:kErrorNetworkGeneric userInfo:details];
                   [_myDelegate errorOccurred:error];
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
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    NSURLSessionDataTask *getDBTask =
    [session dataTaskWithURL:[NSURL URLWithString:callString]
     
           completionHandler:^(NSData *data,
                               NSURLResponse *response,
                               NSError *error) {
               if (error){
                   ALog("Error is %@", [error description]);
                   [_myDelegate errorOccurred:error];
                   return;
               }
               NSError *errorOther = nil;
               
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
                   }else{
                       [details setValue:@"Malformed response" forKey:NSLocalizedDescriptionKey];
                       errorOther = [NSError errorWithDomain:@"Network" code:kErrorBadResponse userInfo:details];
                       [_myDelegate errorOccurred:error];
                   }
               }else if (httpResp.statusCode >= 500){
                   [details setValue:@"Server Error" forKey:NSLocalizedDescriptionKey];
                   errorOther = [NSError errorWithDomain:@"Network" code:kErrorInternalServer userInfo:details];
                   [_myDelegate errorOccurred:error];
               }else{
                   [details setValue:@"Generic Error" forKey:NSLocalizedDescriptionKey];
                   errorOther = [NSError errorWithDomain:@"Network" code:kErrorNetworkGeneric userInfo:details];
                   [_myDelegate errorOccurred:error];
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
        double imageProgress = (self.totalImageTasks == 0) ? 0 :
            ((double)self.totalImageTasks - (double)self.remainingImageTasks) / (1 + (double)self.totalImageTasks);
        [_myDelegate updateProgress:((self.dbDownloadProgress / (1 + self.totalImageTasks)) + imageProgress)];
    }
}


- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    ALog("Dowload");

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
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[NSNumber numberWithInt:_newDBVersion] forKey:kCurrentDBVersion];
        
        if ([[APDBManager sharedInstance] checkNewDBInstance]) {
            self.dbIsReady = YES;
            if (self.remainingImageTasks == 0) {
                [_myDelegate reloadNewData];
            }
        }else{
            //Check was not passed !!
            [_myDelegate noUpdate];
        }
    }else{
        self.remainingImageTasks --;
        [_myDelegate updateProgress:((self.dbDownloadProgress / (1 + self.totalImageTasks)) + (((double)self.totalImageTasks - (double)self.remainingImageTasks) / ((double)self.totalImageTasks + 1)))];
        if(self.dbIsReady && self.remainingImageTasks == 0){
            [_myDelegate reloadNewData];
        }
    }
}


- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error{
    //Handle only error here, normally 'URLSession:downloadTask:didFinishDownloadingToURL:' fires before
    if (error) {
        [_myDelegate errorOccurred:error];
    }
}



@end
