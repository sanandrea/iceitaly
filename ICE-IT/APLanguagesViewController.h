//
//  APLanguagesViewController.h
//  ICE-IT
//
//  Created by Andi Palo on 12/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APNetworkClient.h"
#import "APDBManager.h"

@interface APLanguagesViewController : UITableViewController <UpdateReleased>

@property (strong, nonatomic) id<CityOrLanguageChanges> delegate;
@property (strong, nonatomic) NSString *currentLangCode;

-(IBAction)switchLangMode:(id)sender;

@end
