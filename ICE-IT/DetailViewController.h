//
//  DetailViewController.h
//  ICE-IT
//
//  Created by Andi Palo on 15/10/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

