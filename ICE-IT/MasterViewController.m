//
//  MasterViewController.m
//  ICE-IT
//
//  Created by Andi Palo on 15/10/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "APDBManager.h"
#import "APConstants.h"
#import "APNumberTableViewCell.h"
#import "APCityNumber.h"

@interface MasterViewController ()
@property (strong,nonatomic) NSArray *numbers;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    _rightbarButton.target = self.revealViewController;
    _rightbarButton.action = @selector(rightRevealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    //get user prefs for the preferred car model id
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.cityName = [prefs objectForKey:kPreferredCity];
    
    [APDBManager getCityNums:self.cityName whenReady:^(NSArray *result) {
        _numbers = result;
//        ALog("Numbers: %@",_numbers );
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
    }
}

-(void) cityChanged{
    [APDBManager getCityNums:self.cityName whenReady:^(NSArray *result) {
        _numbers = result;
        //        ALog("Numbers: %@",_numbers );
        [self.tableView reloadData];
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_numbers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NumberCell";
    APNumberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[APNumberTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)configureCell:(APNumberTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    APCityNumber *cn = [self.numbers objectAtIndex:indexPath.row];
    cell.numberLabel.text = cn.number;
    cell.descLabel.text = cn.desc;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    APCityNumber *cn = [self.numbers objectAtIndex:indexPath.row];
    ALog("Selected number: %@",cn.number);
//    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:cn.number];
    NSString *phoneNumber = [@"tel://" stringByAppendingString:cn.number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    
}


@end
