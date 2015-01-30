//
//  APLanguageBond.m
//  ICE-IT
//
//  Created by Andi Palo on 30/01/15.
//  Copyright (c) 2015 Andi Palo. All rights reserved.
//

#import "APLanguageBond.h"

@implementation APLanguageBond

- (id) initWithLang:(NSString*) lang andCode:(NSString*)code{
    self = [super init];
    if (self){
        self.extendedLang = lang;
        self.codeOfLang = code;
    }
    return self;
}

@end
