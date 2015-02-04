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
NSString *const kUITipCityWasShown = @"showCityTip";
NSString *const kUITipLangWasShown = @"showLangTip";

NSUInteger const kCommonNumbersMaxPrio = 10;
NSUInteger const kShippingDBVersion = 1;


NSUInteger const kErrorInternalServer = 1000;
NSUInteger const kErrorBadResponse = 1001;
NSUInteger const kErrorNetworkGeneric = 1002;

@implementation APConstants

@end
