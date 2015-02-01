//
//  APNetworkClient.h
//  ICE-IT
//
//  Created by Andi Palo on 14/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UpdateReleased

- (void) reloadNewData;
- (void) updateProgress:(double)progress;
- (void) noUpdate;
- (void) errorOccurred:(NSError*)error;

@end

@interface APNetworkClient : NSObject <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

- (void) dowloadLatestDBIfNewerThan:(NSUInteger)currentVersion reportTo:(id<UpdateReleased>)delegate;


@end
