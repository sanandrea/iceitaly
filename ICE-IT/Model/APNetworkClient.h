//
//  APNetworkClient.h
//  ICE-IT
//
//  Created by Andi Palo on 14/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APNetworkClient : NSObject <NSURLSessionDelegate>


+ (void) getLastDBVersion:(void (^)(NSInteger))lastVersion;
- (void) dowloadLatestDB:(void (^)())ready;

@end
