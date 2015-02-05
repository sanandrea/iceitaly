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
#import "APLanguageBond.h"
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
        
        NSUInteger counter = 0;
        for (APLanguageBond *lb in _languages) {
            if ([self.currentLangCode isEqualToString:lb.codeOfLang]) {
                self.mySelectedIndexRow = counter;
            }
            counter++;
        }
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
    
    self.navigationController.navigationBar.tintColor = [UIColor flatWhiteColor];
}

-(IBAction)switchLangMode:(id)sender{
    UISwitch *sw = sender;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([sw isOn]) {
        self.isAutomatic = YES;
        [prefs setObject:[NSNumber numberWithInt:1] forKey:kAutomaticLang];
        NSArray * langs = [NSLocale preferredLanguages];
        NSString *languageID = langs.firstObject;
        
        
        //Check if lang changed to update UI Strings
        if (![self.currentLangCode isEqualToString:languageID]) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                //don't need to make it in background as it is already
                [[APDBManager sharedInstance] loadUIStringsForLang:languageID reportTo:self];
            });
            
            [self.delegate languageChanged:languageID];
        }
        
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
            sectionName = [[APDBManager sharedInstance] getUIStringForCode:@"lang_mode"];
            break;
        case 1:
            if (self.isAutomatic) {
                sectionName = [[APDBManager sharedInstance] getUIStringForCode:@"last_update"];
            }else{
                sectionName = [[APDBManager sharedInstance] getUIStringForCode:@"lang_list"];
            }
            break;
        case 2:
            if (self.isAutomatic) {
                return nil;
            }else{
                sectionName = [[APDBManager sharedInstance] getUIStringForCode:@"last_update"];
            }
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (NSString*) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            return nil;
            break;
        case 1:
            if (self.isAutomatic) {
                sectionName = [[APDBManager sharedInstance] getUIStringForCode:@"update_footer"];
            }else{
                return nil;
            }
            break;
        case 2:
            if (self.isAutomatic) {
                return nil;
            }else{
                sectionName = [[APDBManager sharedInstance] getUIStringForCode:@"update_footer"];
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

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *headerView = nil;
    switch (section)
    {
        case 0:
            break;
        case 1:
            if (self.isAutomatic) {
                headerView = [[UIView alloc] init];
                [headerView addSubview:[self prepareFooterLabel:[self tableView:self.tableView titleForFooterInSection:section]]];
            }else{
                return nil;
            }
            break;
        case 2:
            if (self.isAutomatic) {
                return nil;
            }else{
                headerView = [[UIView alloc] init];
                [headerView addSubview:[self prepareFooterLabel:[self tableView:self.tableView titleForFooterInSection:section]]];
            }
            break;
        default:
            break;
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LangCell";
    static NSString *UpdateCellIdentifier = @"UpdateCell";
    static NSString *OptionCellIdentifier = @"LangOption";

    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = (APLangOptionTVC*) [tableView dequeueReusableCellWithIdentifier:OptionCellIdentifier];
        ((APLangOptionTVC*)cell).titleLabel.text = [[APDBManager sharedInstance] getUIStringForCode:@"lang_mode_auto"];
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
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        ((APUpdateDBCell *)cell).lastUpdated.text = [prefs valueForKey:kLastUpdateDate];
        self.lastUpdatedLabel = ((APUpdateDBCell *)cell).lastUpdated;
        [((APUpdateDBCell *)cell).update  addTarget:self action:@selector(getLatestDB) forControlEvents:UIControlEventTouchUpInside];
        [((APUpdateDBCell *)cell).update setTitle:[[APDBManager sharedInstance] getUIStringForCode:@"update_button"] forState:UIControlStateNormal];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return cell;
    
}

- (void)configureCell:(APLangViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    APLanguageBond *lb = [_languages objectAtIndex:indexPath.row];
    cell.langName.text = lb.extendedLang;
    cell.code = lb.codeOfLang;
}

- (UILabel*) prepareFooterLabel:(NSString*)text {
    UIFont *footerFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    int margin = 15;
    //Find expected size
    CGSize labelSize =  [text boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 2 * margin, MAXFLOAT)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName : footerFont}
                                           context:nil].size;
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(margin, 8, labelSize.width, labelSize.height);
    myLabel.font = footerFont;
    myLabel.text = text;
    myLabel.shadowColor = [UIColor whiteColor];
    myLabel.shadowOffset      = CGSizeMake(0, 1);
    myLabel.textColor = [UIColor colorWithRed:0.298 green:0.337 blue:0.423 alpha:1.000];
    myLabel.numberOfLines = 0;
    return myLabel;
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
        
        NSString *newLangCode = ( (APLanguageBond*)[_languages objectAtIndex:indexPath.row]).codeOfLang;
        [self.delegate languageChanged:newLangCode];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            //don't need to make it in background as it is already
            [[APDBManager sharedInstance] loadUIStringsForLang:newLangCode reportTo:self.delegate];
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
    
    HUD.status = [[APDBManager sharedInstance] getUIStringForCode:@"progress_loading"];
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
        
        NSUInteger counter = 0;
        for (APLanguageBond *lb in _languages) {
            if ([self.currentLangCode isEqualToString:lb.codeOfLang]) {
                self.mySelectedIndexRow = counter;
            }
            counter++;
        }
        
    }];
    
    //Update 'Last updated Field'
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy - HH:mm:ss"];
    NSString *nowDate = [dateFormatter stringFromDate:now];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:nowDate forKey:kLastUpdateDate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lastUpdatedLabel.text = nowDate;
    });
    
    //Dismiss HUD
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setComplete];
    });
}

- (void) updateProgress:(double)progress{
//    ALog("Progress is %f",progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        HUD.status = [[APDBManager sharedInstance] getUIStringForCode:@"progress_updating"];
        [HUD setProgress:progress animated:YES];
    });
}

- (void) noUpdate{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setComplete];
        UIAlertView *aw = [[UIAlertView alloc] initWithTitle: [[APDBManager sharedInstance] getUIStringForCode:@"no_update_title"]
                                                     message: [[APDBManager sharedInstance] getUIStringForCode:@"no_update_msg"]
                                                    delegate:self
                                           cancelButtonTitle: [[APDBManager sharedInstance] getUIStringForCode:@"ok_button"]
                                           otherButtonTitles:nil];
        [aw show];
    });
}

- (void) errorOccurred:(NSError*)error{
    
    if (error.code == kCFURLErrorNotConnectedToInternet) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setComplete];
            UIAlertView *aw = [[UIAlertView alloc] initWithTitle: [[APDBManager sharedInstance] getUIStringForCode:@"no_internet_title"]
                                                         message: [[APDBManager sharedInstance] getUIStringForCode:@"no_internet_msg"]
                                                        delegate:self
                                               cancelButtonTitle: [[APDBManager sharedInstance] getUIStringForCode:@"ok_button"]
                                               otherButtonTitles:nil];
            [aw show];
        });
    }else{
        [self noUpdate];
    }
}

#pragma mark - HUD methods
- (void)setComplete
{
    HUD.status = [[APDBManager sharedInstance] getUIStringForCode:@"progress_finished"];
    [HUD performAction:M13ProgressViewActionSuccess animated:YES];
    [self performSelector:@selector(reset) withObject:nil afterDelay:1.5];
}

- (void)reset
{
    [HUD hide:YES];
    [HUD performAction:M13ProgressViewActionNone animated:NO];
    [HUD setProgress:0.0 animated:YES];
}
-(void) uiStringsReady{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.delegate uiStringsReady];
    });
}

@end
