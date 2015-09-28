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
//  APConstants.m
//  ICE-IT
//
//  Created by Andi Palo on 09/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APConstants.h"

NSString *const kPreferredCity = @"preferredCity";
NSString *const kDBDowloaded = @"dbVersion";
NSString *const kAutomaticLang = @"isAutomatic";
NSString *const kCurrentLangCode = @"langCode";
NSString *const kCurrentLang = @"currentLang";
NSString *const kActiveDBName = @"icedb_current.sqlite";
NSString *const kNewDBName = @"icedb_new.sqlite";
NSString *const kCurrentDBVersion = @"lastDBVers";
NSString *const kLastUpdateDate = @"lastUpdatedDB";
NSString *const kUITipsWereShown = @"showCityTip";
NSString *const kNewDBDownloaded = @"newDBNotification";

NSUInteger const kCommonNumbersMaxPrio = 10;
NSUInteger const kShippingDBVersion = 19;


NSUInteger const kErrorInternalServer = 1000;
NSUInteger const kErrorBadResponse = 1001;
NSUInteger const kErrorNetworkGeneric = 1002;

@implementation APConstants

@end
