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
+ (void)getCityNums:(NSString*)city forLang:(NSString*)language whenReady:(void (^)(NSArray *))cityNumsReady;

+ (void)getLanguageListWhenReady:(void (^)(NSArray *))langListReady;

/*! Get extended language name from code */
+ (void)getLanguageFromCode:(NSString*)code then:(void (^)(NSString*))nameReady;
/*! Get code from extended language name */
+ (void)getCodeFromLanguage:(NSString*)language then:(void (^)(NSString*))nameReady;


@end
