//
//  APLanguagesViewController.m
//  ICE-IT
//
//  Created by Andi Palo on 12/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "AppDelegate.h"
#import "APLanguagesViewController.h"
#import "APConstants.h"
#import "APLangViewCell.h"
#import "APLangOptionTVC.h"
#import "Chameleon.h"
#import "MasterViewController.h"
#import "SWRevealViewController.h"
#import "APUpdateDBCell.h"
#import "APNetworkClient.h"

#import "M13ProgressHUD.h"
#import "M13ProgressViewRing.h"

@interface APLanguagesViewController ()
@property NSInteger mySelectedIndexRow;
@property NSInteger numCells;
@property BOOL isAutomatic;
@property (weak,nonatomic) UISwitch *mySwitch;
@property (strong, nonatomic) UILabel *lastUpdatedLabel;
@end

@implementation APLanguagesViewController{
    NSArray *_languages;
    M13ProgressHUD *HUD;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [APDBManager getLanguageListWhenReady:^(NSArray *result) {
        _languages = result;
        //        ALog("result: %@",_cities);
        [APDBManager getLanguageFromCode:self.currentLangCode then:^(NSString *extLang) {
            NSUInteger counter = 0;
            for (NSString *str in result) {
                if ([str isEqualToString:extLang]) {
                    self.mySelectedIndexRow = counter;
                    break;
                }
                counter++;
            }
        }];
        
    }];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.isAutomatic = ([[prefs objectForKey:kAutomaticLang] integerValue] == 1) ? YES : NO;
    [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Init Progress View
    HUD = [[M13ProgressHUD alloc] initWithProgressView:[[M13ProgressViewRing alloc] init]];
    HUD.progressViewSize = CGSizeMake(60.0, 60.0);
    HUD.animationPoint = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
    UIWindow *window = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    [window addSubview:HUD];
}

-(IBAction)switchLangMode:(id)sender{
    UISwitch *sw = sender;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([sw isOn]) {
        self.isAutomatic = YES;
        [prefs setObject:[NSNumber numberWithInt:1] forKey:kAutomaticLang];
        NSString *languageID = [[NSBundle mainBundle] preferredLocalizations].firstObject;
        [self.delegate languageChanged:languageID];
    }else{
        self.isAutomatic = NO;
        [prefs setObject:[NSNumber numberWithInt:0] forKey:kAutomaticLang];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (self.isAutomatic) {
        return 2;
    }else{
        return 3;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Modalità", @"Titolo menu lingua");
            break;
        case 1:
            if (self.isAutomatic) {
                sectionName = NSLocalizedString(@"LAST UPDATE", @"Titolo last update");
            }else{
                sectionName = NSLocalizedString(@"Lingua", @"Titolo last update");
            }
            break;
        case 2:
            if (self.isAutomatic) {
                return nil;
            }else{
                sectionName = NSLocalizedString(@"LAST UPDATE", @"Titolo last update");
            }
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section)
    {
        case 0:
            return 1;
            break;
        case 1:
            if (self.isAutomatic) {
                return 1;
            }else{
                self.numCells = [_languages count];
                return self.numCells;
            }
            break;
        case 2:
            return 1;
            break;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45.f;
}

/*
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.text = NSLocalizedString(@"LINGUA  ", @"Titolo menu lingua");
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LangCell";
    static NSString *UpdateCellIdentifier = @"UpdateCell";
    static NSString *OptionCellIdentifier = @"LangOption";

    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = (APLangOptionTVC*) [tableView dequeueReusableCellWithIdentifier:OptionCellIdentifier];
        ((APLangOptionTVC*)cell).titleLabel.text = NSLocalizedString(@"Automatic",@"Language Toggle");
        self.mySwitch = ((APLangOptionTVC*)cell).toggleSwitch;
        if (self.isAutomatic) {
            [self.mySwitch setOn:YES];
        }else{
            [self.mySwitch setOn:NO];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }else if((indexPath.section == 1) && !self.isAutomatic){
        cell = (APLangViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[APLangViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        [self configureCell:(APLangViewCell*)cell atIndexPath:indexPath];
        if (indexPath.row == self.mySelectedIndexRow) {
            [cell setBackgroundColor:[UIColor flatPowderBlueColor]];
        }
    }else if(((indexPath.section == 1) && self.isAutomatic) || (indexPath.section == 2)){
        cell = (APUpdateDBCell*) [tableView dequeueReusableCellWithIdentifier:UpdateCellIdentifier];
        ((APUpdateDBCell *)cell).lastUpdated.text = @"14/11/2014 - 23:23:32";
        self.lastUpdatedLabel = ((APUpdateDBCell *)cell).lastUpdated;
        [((APUpdateDBCell *)cell).update  addTarget:self action:@selector(getLatestDB) forControlEvents:UIControlEventTouchUpInside];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return cell;
    
}

- (void)configureCell:(APLangViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell to show the book's title
    NSString *name = [_languages objectAtIndex:indexPath.row];
    
    cell.langName.text = name;
    //cell.cityLogo.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_img.png",name]];
    
}

#pragma mark - Table view Delegate for Cell Selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isAutomatic) {
        return;
    }else{
        if (indexPath.section != 1) {
            return;
        }
    }

    if (self.mySelectedIndexRow != indexPath.row) {
        self.mySelectedIndexRow = indexPath.row;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [APDBManager getCodeFromLanguage:[_languages objectAtIndex:indexPath.row]
                                    reportTo:self.delegate];
        });
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isAutomatic) {
        return indexPath;
    }else{
        if (indexPath.section != 1) {
            return indexPath;
        }
    }
    
    if (self.mySelectedIndexRow >= 0)
    {
        NSIndexPath *old = [NSIndexPath indexPathForRow:self.mySelectedIndexRow inSection:0];
        [[tableView cellForRowAtIndexPath:old] setBackgroundColor:[UIColor whiteColor]];
    }
    [[tableView cellForRowAtIndexPath:indexPath] setBackgroundColor:[UIColor flatPowderBlueColor]];
    return indexPath;
}
- (void) getLatestDB{
    
    HUD.status = NSLocalizedString(@"Loading", @"Update progress");
    [HUD show:YES];

    APNetworkClient *client = [[APNetworkClient alloc] init];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [client dowloadLatestDBIfNewerThan:[[prefs objectForKey:kCurrentDBVersion] integerValue] reportTo:self];
}


#pragma mark - UpdateReleased Delegate Methods

- (void) reloadNewData{
    [APDBManager getLanguageListWhenReady:^(NSArray *result) {
        _languages = result;
        
        // To update UI go to main thread!!!
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
        [APDBManager getLanguageFromCode:self.currentLangCode then:^(NSString *extLang) {
            NSUInteger counter = 0;
            for (NSString *str in result) {
                if ([str isEqualToString:extLang]) {
                    self.mySelectedIndexRow = counter;
                    break;
                }
                counter++;
            }
        }];
        
    }];
    
    //Update 'Last updated Field'
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy - HH:mm:ss"];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lastUpdatedLabel.text = [dateFormatter stringFromDate:now];
    });
    
    //Dismiss HUD
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setComplete];
    });
}

- (void) updateProgress:(double)progress{
    ALog("Progress is %f",progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        HUD.status = NSLocalizedString(@"Updating", @"Update progress");
        [HUD setProgress:progress animated:YES];
    });
}

#pragma mark - HUD methods
- (void)setComplete
{
    HUD.status = NSLocalizedString(@"Finished", @"Update progress");
    [HUD performAction:M13ProgressViewActionSuccess animated:YES];
    [self performSelector:@selector(reset) withObject:nil afterDelay:1.5];
}

- (void)reset
{
    [HUD hide:YES];
    [HUD performAction:M13ProgressViewActionNone animated:NO];
    [HUD setProgress:0.0 animated:YES];
}

@end
