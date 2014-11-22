//
//  APDBManager.h
//  ICE-IT
//
//  Created by Andi Palo on 09/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CityOrLanguageChanges <NSObject>

- (void) cityChanged:(NSString*) newName;
- (void) languageChanged:(NSString*) newLang;
- (void) newDataIsReady:(NSArray*) newData;

@end

@interface APDBManager : NSObject

+ (void)getCityListWhenReady:(void (^)(NSArray *))cityListReady;
+ (void)getLanguageListWhenReady:(void (^)(NSArray *))langListReady;

+ (void)getCityNums:(NSString*)city forLang:(NSString*)language reportTo:(id<CityOrLanguageChanges>)delegate;

/*! Get code from extended language name */
+ (void)getCodeFromLanguage:(NSString*)language reportTo:(id<CityOrLanguageChanges>)delegate;

/*! Get extended language name from code */
+ (void)getLanguageFromCode:(NSString*)code then:(void (^)(NSString*))nameReady;

- (void) copyDBInData;
- (BOOL) checkNewDBInstance;
+ (APDBManager*) sharedInstance;
@end
