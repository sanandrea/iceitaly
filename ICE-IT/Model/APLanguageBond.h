//
//  APLanguageBond.h
//  ICE-IT
//
//  Created by Andi Palo on 30/01/15.
//  Copyright (c) 2015 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APLanguageBond : NSObject

@property (strong, nonatomic) NSString *extendedLang;
@property (strong, nonatomic) NSString *codeOfLang;


- (id) initWithLang:(NSString*) lang andCode:(NSString*)code;
@end
