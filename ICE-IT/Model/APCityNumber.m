//
//  APCityNumber.m
//  ICE-IT
//
//  Created by Andi Palo on 09/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APCityNumber.h"

@implementation APCityNumber


- (id) initWithNumber:(NSString*)aNumber description:(NSString*)aDesc priority:(NSUInteger)aPrio{
    self = [super init];
    
    if (self) {
        self.desc = aDesc;
        self.number = aNumber;
        self.priority = aPrio;
    }
    return self;
}
@end
