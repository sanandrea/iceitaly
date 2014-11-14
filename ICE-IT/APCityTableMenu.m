//
//  APCityTableMenu.m
//  IceItaly
//
//  Created by Andi Palo on 9/20/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APCityTableMenu.h"
#import "APDBManager.h"
#import "APSideTableViewCell.h"
#import "APConstants.h"
#import "SWRevealViewController.h"
#import "MasterViewController.h"
#import "Chameleon.h"

@interface APCityTableMenu ()

@property (nonatomic) NSInteger mySelectedIndexRow;

@end

@implementation APCityTableMenu{
    NSArray* _cities;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [APDBManager getCityListWhenReady:^(NSArray *result) {
        _cities = result;
//        ALog("result: %@",_cities);
        self.mySelectedIndexRow = 1;
    }];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"IO SONO A", @"Titolo menu laterale");
            break;
        case 1:
            sectionName = NSLocalizedString(@"LAST UPDATE", @"Titolo last update");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_cities count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CityCell";
    APSideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[APSideTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    if (indexPath.row == self.mySelectedIndexRow) {
        [cell setBackgroundColor:[UIColor flatPowderBlueColor]];
    }
    return cell;
}

- (void)configureCell:(APSideTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell to show the book's title
    NSString *name = [_cities objectAtIndex:indexPath.row];
    
    cell.cityName.text = name;
    cell.cityLogo.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_img.png",name]];
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.mySelectedIndexRow >= 0)
    {
        NSIndexPath *old = [NSIndexPath indexPathForRow:self.mySelectedIndexRow inSection:0];
        [[tableView cellForRowAtIndexPath:old] setBackgroundColor:[UIColor whiteColor]];
    }
    [[tableView cellForRowAtIndexPath:indexPath] setBackgroundColor:[UIColor flatPowderBlueColor]];
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.f;
}

- (void)setCellColor:(UIColor *)color ForCell:(UITableViewCell *)cell {
    cell.contentView.backgroundColor = color;
    cell.backgroundColor = color;
}

#pragma mark - Table view Delegate for Cell Selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    self.mySelectedIndexRow = indexPath.row;
    
    //Get MapViewController
    UINavigationController* nvc = (UINavigationController*) self.revealViewController.frontViewController;
    MasterViewController* mvc = (MasterViewController*) nvc.topViewController;
    
    //Get selected car for this index
    NSString *city = [_cities objectAtIndex:indexPath.row];
    
    //set this car to the Map ViewController
    mvc.cityName = city;
    
    //save in the preferences the model ID of the selected CAR
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:city forKey:kPreferredCity];
    
    [mvc cityOrLanguageChanged];
    //close side menu
    [self.revealViewController revealToggleAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
