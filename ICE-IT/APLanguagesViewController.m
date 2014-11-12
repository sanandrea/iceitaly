//
//  APLanguagesViewController.m
//  ICE-IT
//
//  Created by Andi Palo on 12/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APLanguagesViewController.h"
#import "APDBManager.h"
#import "APConstants.h"
#import "APLangViewCell.h"
#import "APLangOptionTVC.h"
#import "Chameleon.h"

@interface APLanguagesViewController ()
@property NSInteger mySelectedIndexRow;
@end
@implementation APLanguagesViewController{
    NSArray *_languages;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [APDBManager getLanguageListWhenReady:^(NSArray *result) {
        _languages = result;
        //        ALog("result: %@",_cities);
        self.mySelectedIndexRow = 1;
    }];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"LINGUA", @"Titolo menu lingua");
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return ([_languages count] + 1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45.f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.text = NSLocalizedString(@"LINGUA  ", @"Titolo menu lingua");
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LangCell";
    static NSString *OptionCellIdentifier = @"LangOption";
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = (APLangOptionTVC*) [tableView dequeueReusableCellWithIdentifier:OptionCellIdentifier];
    }else{
        cell = (APLangViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[APLangViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        [self configureCell:(APLangViewCell*)cell atIndexPath:indexPath];
        if (indexPath.row == self.mySelectedIndexRow) {
            [cell setBackgroundColor:[UIColor flatPowderBlueColor]];
        }
    }
    return cell;
    
}

- (void)configureCell:(APLangViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell to show the book's title
    NSString *name = [_languages objectAtIndex:(indexPath.row - 1)];
    
    cell.langName.text = name;
    //cell.cityLogo.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_img.png",name]];
    
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


@end
