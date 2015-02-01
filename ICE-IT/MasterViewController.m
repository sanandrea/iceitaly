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
#import "APImageStore.h"
#import "APLanguagesViewController.h"
#import "Chameleon.h"

static int kTitleWidth = 180;

@interface MasterViewController ()
@property (strong,nonatomic)  NSArray   *numbers;
@property (strong, nonatomic) NSString  *cityName;
@property (strong, nonatomic) NSString  *language;
@property (nonatomic) CGSize leftImageSize;
@property (nonatomic) CGSize rightImageSize;
@property (strong, nonatomic) UILabel *cityTitle;
@property (strong, nonatomic) UILabel *subTitleLabel;
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
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
    [cell setBackgroundColor:[UIColor flatWhiteColor]];
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
    
    cell.descLabel.numberOfLines = 0;

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
    cell.layoutMargins = UIEdgeInsetsZero;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
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
    
    APCityNumber *cn = [self.numbers objectAtIndex:ipath.row];
    ALog("Selected number: %@",cn.number);
    //    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:cn.number];
    NSString *phoneNumber = [@"tel://" stringByAppendingString:cn.number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}
@end
