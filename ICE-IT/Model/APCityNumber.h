//
//  APCityNumber.h
//  ICE-IT
//
//  Created by Andi Palo on 09/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCityNumber : NSObject

@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSString *desc;
@property (nonatomic) NSUInteger priority;

- (id) initWithNumber:(NSString*)aNumber description:(NSString*)aDesc priority:(NSUInteger)aPrio;
@end
