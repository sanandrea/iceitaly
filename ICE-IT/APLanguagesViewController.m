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
#import "MasterViewController.h"
#import "SWRevealViewController.h"
#import "APUpdateDBCell.h"
#import "APNetworkClient.h"

static NSUInteger kStaticCells = 2;
static NSUInteger kBeginIndex = 1;

@interface APLanguagesViewController ()
@property NSInteger mySelectedIndexRow;
@property NSInteger numCells;
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
    self.numCells = [_languages count] + kStaticCells;
    return self.numCells;
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
    static NSString *UpdateCellIdentifier = @"UpdateCell";
    static NSString *OptionCellIdentifier = @"LangOption";

    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = (APLangOptionTVC*) [tableView dequeueReusableCellWithIdentifier:OptionCellIdentifier];
        ((APLangOptionTVC*)cell).titleLabel.text = @"Automatic";
    }else if(indexPath.row < self.numCells - 1){
        cell = (APLangViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[APLangViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        [self configureCell:(APLangViewCell*)cell atIndexPath:indexPath];
        if (indexPath.row == self.mySelectedIndexRow) {
            [cell setBackgroundColor:[UIColor flatPowderBlueColor]];
        }
    }else{
        cell = (APUpdateDBCell*) [tableView dequeueReusableCellWithIdentifier:UpdateCellIdentifier];
        ((APUpdateDBCell *)cell).lastUpdated.text = @"14/11/2014 - 23:23:32";
        [((APUpdateDBCell *)cell).update  addTarget:self action:@selector(getLatestDB) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
    
}

- (void)configureCell:(APLangViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell to show the book's title
    NSString *name = [_languages objectAtIndex:(indexPath.row - kBeginIndex)];
    
    cell.langName.text = name;
    //cell.cityLogo.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_img.png",name]];
    
}

#pragma mark - Table view Delegate for Cell Selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    self.mySelectedIndexRow = indexPath.row;
    
    //Get MapViewController
    UINavigationController* nvc = (UINavigationController*) self.revealViewController.frontViewController;
    MasterViewController* mvc = (MasterViewController*) nvc.topViewController;
    
    //Get selected car for this index
    NSString *lang = [_languages objectAtIndex:(indexPath.row - kBeginIndex)];
    
    
    //save in the preferences the model ID of the selected CAR
    [APDBManager getCodeFromLanguage:lang then:^(NSString* result){
//        ALog("result is %@",result);
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:result forKey:kCurrentLang];

        //set this car to the Map ViewController
        mvc.language = result;
        [mvc cityOrLanguageChanged];
    }];
    //close side menu
    [self.revealViewController rightRevealToggleAnimated:YES];

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
- (void) getLatestDB{
    ALog("Update DB!!!");
    APNetworkClient *client = [[APNetworkClient alloc] init];
    [client dowloadLatestDBIfNewerThan:1 reportTo:self];

}

@end
