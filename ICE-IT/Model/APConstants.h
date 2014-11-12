//
//  APConstants.h
//  ICE-IT
//
//  Created by Andi Palo on 09/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __OBJC__
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif

extern NSString *const kPreferredCity;
extern NSString *const kDBDowloaded;
extern NSString *const kAutomaticLang;
extern NSString *const kCurrentLang;

@interface APConstants : NSObject

@end
