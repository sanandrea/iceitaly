// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
