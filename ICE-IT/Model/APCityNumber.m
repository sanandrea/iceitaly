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

- (NSString *) callString{
    if ([self.number length] <= 4){
        return self.number;
    }
    
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^800"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:self.number options:0 range:NSMakeRange(0, self.number.length)];
    if (match != nil) {
        
        return self.number;
    }

    return [NSString stringWithFormat:@"+39%@",self.number];
}
@end







