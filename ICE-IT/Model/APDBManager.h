//
//  APDBManager.h
//  ICE-IT
//
//  Created by Andi Palo on 09/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APDBManager : NSObject

+ (void)getCityListWhenReady:(void (^)(NSArray *))cityListReady;
+ (void)getCityNums:(NSString*)city whenReady:(void (^)(NSArray *))cityNumsReady;


@end
