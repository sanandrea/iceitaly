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
//  APCityTableMenu.m
//  IceItaly
//
//  Created by Andi Palo on 9/20/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APCityTableMenu.h"
#import "APDBManager.h"
#import "APImageStore.h"
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newDBIsReady:)
                                                 name:kNewDBDownloaded object:nil];
    
    [APDBManager getCityListWhenReady:^(NSArray *result) {
        _cities = result;
        //        ALog("result: %@",_cities);
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *cityName = [prefs objectForKey:kPreferredCity];
        NSUInteger counter = 0;
        for (NSString *str in result) {
            if ([str isEqualToString:cityName]) {
                self.mySelectedIndexRow = counter;
            }
            counter++;
        }
    }];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


//This is in background thread
- (void) newDBIsReady:(NSNotification*)notification{
    if ([[notification name] isEqualToString:kNewDBDownloaded]) {
        [APDBManager getCityListWhenReady:^(NSArray *result) {
            _cities = result;
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *cityName = [prefs objectForKey:kPreferredCity];
    NSUInteger counter = 0;
    for (NSString *str in _cities) {
        if ([str isEqualToString:cityName]) {
            self.mySelectedIndexRow = counter;
        }
        counter++;
    }
}

- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
            sectionName = [[APDBManager sharedInstance] getUIStringForCode:@"where_am_i"];
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

    CGSize imSize  = CGSizeMake(80, 55);
    
    cell.cityLogo.image = [APImageStore imageWithImageName:[NSString stringWithFormat:@"%@_img",[name lowercaseString]]
                                       scaledToSize:imSize];
    
    if (indexPath.row == self.mySelectedIndexRow) {
        [cell setBackgroundColor:[UIColor flatPowderBlueColor]];
    }else{
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
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
    
    //set this city to the Map ViewController
    [mvc cityChanged:city];

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
