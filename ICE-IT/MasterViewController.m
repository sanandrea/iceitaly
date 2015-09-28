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
//  MasterViewController.m
//  ICE-IT
//
//  Created by Andi Palo on 15/10/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "APDBManager.h"
#import "APConstants.h"
#import "APNumberTableViewCell.h"
#import "APCityNumber.h"
#import "APImageStore.h"
#import "APLanguagesViewController.h"
#import "Chameleon.h"
#import "AMPopTip.h"

static int kTitleWidth = 180;
static int kLeftUpperAdjustement = 50;

@interface MasterViewController ()
@property (strong,nonatomic)  NSArray   *numbers;
@property (strong, nonatomic) NSString  *cityName;
@property (strong, nonatomic) NSString  *language;
@property (nonatomic) CGSize leftImageSize;
@property (nonatomic) CGSize rightImageSize;
@property (strong, nonatomic) UILabel *cityTitle;
@property (strong, nonatomic) UILabel *subTitleLabel;
@property (nonatomic) BOOL tipsWereShown;

@property (nonatomic, strong) AMPopTip *cityTip;
@property (nonatomic, strong) AMPopTip *langTip;

@property (nonatomic) NSUInteger commonNames;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    //get user prefs for the preferred car model id
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.cityName = [prefs objectForKey:kPreferredCity];
    self.language = [prefs objectForKey:kCurrentLang];

    
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    //to inform master of reveal add delegate to self
    self.revealViewController.delegate = self;
    
    self.leftImageSize = CGSizeMake(50, 50);
    self.rightImageSize = CGSizeMake(40, 24);
    
    UIImage *img = [APImageStore imageWithImageName:[NSString stringWithFormat:@"%@_img",[self.cityName lowercaseString]]
                                       scaledToSize:self.leftImageSize];
    _sidebarButton.image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    img = [APImageStore imageWithImageName:[NSString stringWithFormat:@"%@_flag",self.language]
                              scaledToSize:self.rightImageSize];
    _rightbarButton.image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self drawTitleView];
    
    self.title = [[APDBManager sharedInstance] getUIStringForCode:@"go_back"];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor flatTealColor]];
    [self.navigationController.navigationBar setTranslucent:NO];

    [APDBManager getCityNums:self.cityName forLang:self.language reportTo:self];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.tableView.allowsSelection = NO;
    
    // Setup Tips
    self.tipsWereShown = [[prefs objectForKey:kUITipsWereShown] intValue];

    if (!self.tipsWereShown) {
        [self setupHintTips];
        [self showHint:kTipLanguage];
        [self showHint:kTipCity];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    if (!self.tipsWereShown) {
//        [self showHint:kTipCity];   
//        [self showHint:kTipLanguage];
//    }
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


- (void)setupHintTips {
    // alloc the tooltip view and customize it
    [[AMPopTip appearance] setFont:[UIFont fontWithName:@"Avenir-Medium" size:12]];
    
    self.cityTip = [AMPopTip popTip];
    self.cityTip.shouldDismissOnTap = YES;
//    self.cityTip.shouldDismissOnTapOutside = NO;
    self.cityTip.edgeMargin = 5;
    self.cityTip.offset = 2;
    self.cityTip.arrowSize = CGSizeMake(10, 55);
    self.cityTip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);

    self.langTip = [AMPopTip popTip];
    self.langTip.shouldDismissOnTap = YES;
//    self.langTip.shouldDismissOnTapOutside = NO;
    self.langTip.edgeMargin = 5;
    self.langTip.offset = 2;
    self.langTip.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    __weak typeof(self) weakSelf = self;
    
    self.cityTip.dismissHandler = ^{
        [prefs setObject:[NSNumber numberWithInt:1] forKey:kUITipsWereShown];
        if (weakSelf.langTip) {
            [weakSelf.langTip hide];
        }
    };
    self.langTip.dismissHandler = ^{
        [prefs setObject:[NSNumber numberWithInt:1] forKey:kUITipsWereShown];
        if (weakSelf.cityTip) {
            [weakSelf.cityTip hide];
        }

    };
}

- (void)showHint:(TIP_TYPE) type {
    CGRect tipFrame;
    CGRect tempFrame = self.navigationController.navigationBar.frame;
    
    if (type == kTipCity) {
        tipFrame = CGRectMake(0, tempFrame.origin.y, kLeftUpperAdjustement, tempFrame.size.height);
        self.cityTip.popoverColor = [UIColor flatOrangeColor];
        NSString * t = [[APDBManager sharedInstance] getUIStringForCode:@"city_tip"];
        [self.cityTip showText: t
                     direction:AMPopTipDirectionDown
                      maxWidth:200
                        inView:self.navigationController.view
                     fromFrame:tipFrame];
        
    }else if (type == kTipLanguage){
        tipFrame = CGRectMake(tempFrame.size.width - kLeftUpperAdjustement, tempFrame.origin.y, kLeftUpperAdjustement, tempFrame.size.height);
        self.langTip.popoverColor = [UIColor flatOrangeColor];
        
        [self.langTip showText:[[APDBManager sharedInstance] getUIStringForCode:@"lang_tip"]
                     direction:AMPopTipDirectionDown
                      maxWidth:200
                        inView:self.navigationController.view
                     fromFrame:tipFrame];
    }
    //ALog("Frame of view is %f %f %f %f",test.origin.x, test.origin.y, test.size.width, test.size.height);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)drawTitleView {
    int temp;
    int sum = 0;
    self.subTitleLabel = [self createFirstTitleLabel:&temp andLabel:[[APDBManager sharedInstance] getUIStringForCode:@"phone_numbers"]];
    sum += temp;
    UILabel *second = [self createSecondTitleLabel:&temp fromHeight:sum];
    sum += temp;
    self.cityTitle = second;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kTitleWidth, sum + 20)];
    
    [titleView addSubview:self.subTitleLabel];
    [titleView addSubview:second];
    
    self.navigationController.navigationBar.topItem.titleView = titleView;
}

- (UILabel*) createFirstTitleLabel:(int*)height andLabel:(NSString*) content{
    UIFont *customFont = [UIFont systemFontOfSize:16.0f];
    CGSize size = [content sizeWithAttributes:@{NSFontAttributeName:customFont}];
    
    *height = size.height;
    UILabel *fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 6, kTitleWidth, size.height)];
    fromLabel.text = content;
    fromLabel.textColor = [UIColor flatWhiteColor];
    fromLabel.textAlignment = NSTextAlignmentCenter;
    fromLabel.font = customFont;
    fromLabel.clipsToBounds = YES;
    return fromLabel;
}

- (UILabel*) createSecondTitleLabel:(int*)height fromHeight:(int)from{
    NSString * content = [self.cityName uppercaseString];
    UIFont *customFont = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
    CGSize size = [content sizeWithAttributes:@{NSFontAttributeName:customFont}];
    *height = size.height;
    UILabel *fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, from + 8, kTitleWidth, size.height)];
    fromLabel.text = content;
    fromLabel.textColor = [UIColor flatWhiteColor];
    fromLabel.font = customFont;
    fromLabel.textAlignment = NSTextAlignmentCenter;
    fromLabel.clipsToBounds = YES;
    return fromLabel;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showOptions"]) {
        APLanguagesViewController *lvc = [segue destinationViewController];
        lvc.currentLangCode = self.language;
        lvc.delegate = self;
        
        if (self.tipsWereShown == 0) {
            [self.langTip hide];
        }
    }else{
        
    }
}


-(void) cityOrLanguageChanged{
    [APDBManager getCityNums:self.cityName forLang:self.language reportTo:self];
}

/*! Called from background queues */
- (void) cityChanged:(NSString*) newName{
    self.cityName = newName;
    
    dispatch_async(dispatch_get_main_queue(), ^{
    UIImage *img = [APImageStore imageWithImageName:[NSString stringWithFormat:@"%@_img",[self.cityName lowercaseString]]
                                       scaledToSize:self.leftImageSize];
        _sidebarButton.image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.cityTitle.text = [self.cityName uppercaseString];
    });

    //save in the preferences the city name
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:newName forKey:kPreferredCity];
    [self cityOrLanguageChanged];
}
/*! Called from background queues */
- (void) languageChanged:(NSString*) newLang{
    self.language = newLang;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *img = [APImageStore imageWithImageName:[NSString stringWithFormat:@"%@_flag",self.language]
                                           scaledToSize:self.rightImageSize];
        _rightbarButton.image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    });
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:newLang forKey:kCurrentLang];

    [self cityOrLanguageChanged];
}

/*! Here we return to main queue to update UI */
- (void) newDataIsReady:(NSArray*) newData{
    _numbers = newData;
    self.commonNames = 0;
    for (APCityNumber *cn in _numbers) {
        if (cn.isCommon) {
            self.commonNames++;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.commonNames;
    }else{
        return [self.numbers count] - self.commonNames;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] init];
    switch (section)
    {
        case 0:
            [headerView addSubview:[self prepareHeaderLabel:[self tableView:self.tableView titleForHeaderInSection:section]]];
            break;
        case 1:
            [headerView addSubview:[self prepareHeaderLabel:[self tableView:self.tableView titleForHeaderInSection:section]]];
            break;
        default:
            return nil;
            break;
    }

    return headerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = [[APDBManager sharedInstance] getUIStringForCode:@"common_nums"];
            break;
        case 1:
            sectionName = [[APDBManager sharedInstance] getUIStringForCode:@"local_nums"];
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (UILabel*) prepareHeaderLabel:(NSString*)text {
    UIFont *footerFont = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    int margin = 15;
    //Find expected size
    CGSize labelSize =  [text boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 2 * margin, MAXFLOAT)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName : footerFont}
                                           context:nil].size;
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, labelSize.height);
    myLabel.font = footerFont;
    myLabel.text = text;
    myLabel.backgroundColor = [UIColor flatWhiteColorDark];
    myLabel.textAlignment = NSTextAlignmentCenter;
    myLabel.shadowColor = [UIColor flatWhiteColor];
    myLabel.shadowOffset      = CGSizeMake(1, 1);
    myLabel.textColor = [UIColor colorWithRed:0.298 green:0.337 blue:0.423 alpha:1.000];
    myLabel.numberOfLines = 0;
    return myLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NumberCell";
    APNumberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[APNumberTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //[cell setBackgroundColor:[UIColor flatWhiteColor]];
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)configureCell:(APNumberTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    APCityNumber *cn;
    if (indexPath.section == 0 ) {
        cn = [self.numbers objectAtIndex:indexPath.row];
    }else{
        cn = [self.numbers objectAtIndex:(indexPath.row + self.commonNames)];
    }
    
    cell.numberLabel.text = cn.number;
    cell.descLabel.text = cn.desc;
    
    cell.descLabel.numberOfLines = 0;

    
    // No formatting
    /*
    if (cn.priority < kCommonNumbersMaxPrio) {
        if (indexPath.row % 2 == 0) {
//            [cell setBackgroundColor:[UIColor colorWithRed:96/255.0 green:186/255.0 blue:70/255.0 alpha:.5]];
            [cell setBackgroundColor:[UIColor flatWhiteColor]];
        }else{
            [cell setBackgroundColor:[UIColor flatRedColor]];
        }
    }else{
        if (indexPath.row % 2 == 0) {
//            [cell setBackgroundColor:[UIColor colorWithRed:175/255.0 green:238/255.0 blue:238/255.0 alpha:.5]];
            [cell setBackgroundColor:[UIColor flatWhiteColor]];
        }else{
            [cell setBackgroundColor:[UIColor flatGreenColor]];
        }
        
    }
    */
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

#pragma mark - SWReveal

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position{
    if (position == FrontViewPositionRight) {
        [self.langTip hide];
    }
}
#pragma mark - UI Strings when language is changed

- (void) uiStringsReady{
    
    
    //Go to UI queue
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = [[APDBManager sharedInstance] getUIStringForCode:@"go_back"];
        
        self.subTitleLabel.text = [[APDBManager sharedInstance] getUIStringForCode:@"phone_numbers"];
    });
}

- (IBAction)callAction:(id)sender {
    //call button was pressed on a row, find the point of the screen of this info button
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.tableView];
    
    //Find the row that corresponds to this point
    NSIndexPath *ipath = [self.tableView indexPathForRowAtPoint:buttonOriginInTableView];
    APCityNumber *cn;
    if (ipath.section == 0) {
        cn = [self.numbers objectAtIndex:ipath.row];
    }else{
        cn = [self.numbers objectAtIndex:(ipath.row + self.commonNames)];
    }
//    ALog("Selected number: %@",cn.number);
    //    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:cn.number];
    NSString *phoneNumber = [@"tel://" stringByAppendingString:[cn callString]];
//    ALog("CAll string is: %@", [cn callString]);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}
@end
