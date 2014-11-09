//
//  MasterViewController.h
//  ICE-IT
//
//  Created by Andi Palo on 15/10/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (strong, nonatomic) NSString *cityName;

-(void) cityChanged;
@end

