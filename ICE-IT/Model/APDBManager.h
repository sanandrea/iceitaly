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

@protocol UIStringsUpdate

- (void) uiStringsReady;

@end

@interface APDBManager : NSObject

+ (APDBManager*) sharedInstance;

+ (void)getCityListWhenReady:(void (^)(NSArray *))cityListReady;
+ (void)getLanguageListWhenReady:(void (^)(NSArray *))langListReady;
- (void) copyDBInData;
- (BOOL) checkNewDBInstance;
- (NSString*) getUIStringForCode:(NSString*)code;

+ (void)getCityNums:(NSString*)city forLang:(NSString*)language reportTo:(id<CityOrLanguageChanges>)delegate;
- (void) loadUIStringsForLang:(NSString*)langCode reportTo:(id<UIStringsUpdate>)delegate;
@end
