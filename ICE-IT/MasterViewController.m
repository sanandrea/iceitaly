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

@interface MasterViewController ()
@property (strong,nonatomic)  NSArray   *numbers;
@property (strong, nonatomic) NSString  *cityName;
@property (strong, nonatomic) NSString  *language;
@property (nonatomic) CGSize leftImageSize;
@property (nonatomic) CGSize rightImageSize;
@property (strong, nonatomic) UILabel *cityTitle;
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
    
    UIImage *img = [APImageStore imageWithImageName:[NSString stringWithFormat:@"%@_img",self.cityName]
                                       scaledToSize:self.leftImageSize];
    _sidebarButton.image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    /*
    _rightbarButton.target = self.revealViewController;
    _rightbarButton.action = @selector(rightRevealToggle:);
     _rightbarButton.image = [[UIImage imageNamed:@"opzioni.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    */

    img = [APImageStore imageWithImageName:[NSString stringWithFormat:@"%@_flag",self.language]
                              scaledToSize:self.rightImageSize];
    _rightbarButton.image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    int temp;
    int sum = 0;
    UILabel *first = [self createFirstTitleLabel:&temp];
    sum += temp;
    UILabel *second = [self createSecondTitleLabel:&temp fromHeight:sum];
    sum += temp;
    self.cityTitle = second;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, sum + 20)];
    
    [titleView addSubview:first];
    [titleView addSubview:second];
    
    self.navigationController.navigationBar.topItem.titleView = titleView;
    self.title = NSLocalizedString(@"Back", @"Main");
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor flatCoffeeColor]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // Set the gesture
    //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[APDBManager sharedInstance] copyDBInData];
    });
    */
    [APDBManager getCityNums:self.cityName forLang:self.language reportTo:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UILabel*) createFirstTitleLabel:(int*)height{
    NSString *content = NSLocalizedString(@"Numeri telefonici", @"Numeri telefonici");
    UIFont *customFont = [UIFont systemFontOfSize:14.0f];
    CGSize size = [content sizeWithAttributes:@{NSFontAttributeName:customFont}];
    
    *height = size.height;
    UILabel *fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 6, 150, size.height)];
    fromLabel.text = content;
    fromLabel.textAlignment = NSTextAlignmentCenter;
    fromLabel.font = customFont;
    fromLabel.clipsToBounds = YES;
    return fromLabel;
}

- (UILabel*) createSecondTitleLabel:(int*)height fromHeight:(int)from{
    NSString * content = [self.cityName uppercaseString];
    UIFont *customFont = [UIFont systemFontOfSize:16.0f];
    CGSize size = [content sizeWithAttributes:@{NSFontAttributeName:customFont}];
    *height = size.height;
    UILabel *fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, from + 8, 150, size.height)];
    fromLabel.text = content;
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
    [self cityOrLanguageChanged];
    
    //save in the preferences the city name
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:newName forKey:kPreferredCity];
}
/*! Called from background queues */
- (void) languageChanged:(NSString*) newLang{
    self.language = newLang;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:newLang forKey:kCurrentLang];

    [self cityOrLanguageChanged];
}

/*! Here we return to main queue to update UI */
- (void) newDataIsReady:(NSArray*) newData{
    _numbers = newData;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *img = [APImageStore imageWithImageName:[NSString stringWithFormat:@"%@_img",self.cityName]
                                           scaledToSize:self.leftImageSize];
        _sidebarButton.image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        img = [APImageStore imageWithImageName:[NSString stringWithFormat:@"%@_flag",self.language]
                                  scaledToSize:self.rightImageSize];
        _rightbarButton.image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.cityTitle.text = [self.cityName uppercaseString];
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
    [self configureCell:cell atIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor flatWhiteColor]];
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
