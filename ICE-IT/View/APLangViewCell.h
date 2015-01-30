//
//  APLangViewCell.h
//  ICE-IT
//
//  Created by Andi Palo on 12/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APLanguageBond.h"
@interface APLangViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *langName;
@property (nonatomic, weak) IBOutlet UIImageView *flag;

@property (nonatomic, strong) NSString* code;

@end
