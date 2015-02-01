//
//  MasterViewController.h
//  ICE-IT
//
//  Created by Andi Palo on 15/10/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "APDBManager.h"

@interface MasterViewController : UITableViewController<CityOrLanguageChanges, UIStringsUpdate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightbarButton;
- (IBAction)callAction:(id)sender;

@end

