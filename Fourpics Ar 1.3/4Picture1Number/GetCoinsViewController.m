//
//  GetCoinsViewController.m
//  What's the movie
//
//  Created by eurisko on 4/13/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "GetCoinsViewController.h"
#import "AppDelegate.h"
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "CoinsCell.h"
#import "SafariViewController.h"

@interface GetCoinsViewController () {
    NSNumberFormatter * _priceFormatter;
}

@property (nonatomic, retain)NSArray *_products;


@end

@implementation GetCoinsViewController
@synthesize _products;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    levelLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:22];
    scoreLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:22];
    livesLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:22];
    
    livesLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.Lives]];
    levelLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"مرحلة %d", appDelegate.userLevel]];
    scoreLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.score]];

    [self.view addSubview:appDelegate.loading];

    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self._products = [[NSArray alloc] init];
    
    
    [self reload];
    
    coinsPurchased = 0;
    price = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchaseSuccesful:) name:@"PurchaseManagerTransactionSucceededNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchaseFailed:) name:@"PurchaseManagerTransactionFailedNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLives:) name:@"setLives" object:nil];

}

- (void) setLives :(NSNotification *)notification {
    livesLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.livesCycle.lives]];
}


- (void)reload {
    _products = nil;
    [table reloadData];
    [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            self._products = products;
            [table reloadData];
            [appDelegate.loading removeFromSuperview];
        }else {
            NSLog(@"loading error");
        }
        
    }];
}

- (IBAction)LifePressed:(id)sender {
    [appDelegate ShowTimerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)restoreTapped:(id)sender {
    [[RageIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            *stop = YES;
        }
    }];
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    MyIdentifier = @"tblCellView";
    
    
    CoinsCell *cell = (CoinsCell *)[table dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"CoinsCell" owner:self options:nil];
        cell = customCell;
    }
    
    cell.titleLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
    cell.priceLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:18];
    cell.titleLabel.textColor = [UIColor whiteColor];
    cell.priceLabel.textColor = [UIColor whiteColor];

    SKProduct * product = (SKProduct *) [_products objectAtIndex:indexPath.row];
    cell.titleLabel.text = product.localizedTitle;

    [_priceFormatter setLocale:product.priceLocale];
    cell.priceLabel.text = [_priceFormatter stringFromNumber:product.price];
    
    return cell;
}

- (void)buyButtonTapped:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[buyButton.tag];
    
    [[RageIAPHelper sharedInstance] buyProduct:product];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SKProduct * product = (SKProduct *) [_products objectAtIndex:indexPath.row];
    
    coinsPurchased = [[product.localizedTitle stringByReplacingOccurrencesOfString:@" coins" withString:@""] integerValue];
    [_priceFormatter setLocale:product.priceLocale];
    NSString *priceString = [[NSString alloc] initWithFormat:@"%@", [_priceFormatter stringFromNumber:product.price]];
    
    @try {
        priceString = [priceString substringFromIndex:1];
    }
    @catch (NSException *exception) {
        
    }
    price = [priceString floatValue];
    [[RageIAPHelper sharedInstance] buyProduct:product];
    [self.view addSubview:appDelegate.loading];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}


- (void) productPurchaseSuccesful:(NSNotification*)notification{
    [appDelegate.loading removeFromSuperview];
    if([[UIApplication sharedApplication] isIgnoringInteractionEvents])
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    appDelegate.score = appDelegate.score +coinsPurchased;
     
    [SimpleKeychain save:@"Score" data:[Cryptography TripleDES:[[NSString alloc] initWithFormat:@"%d", appDelegate.score] algo:kCCEncrypt key:@"Sfg$93@B"]];
    
    scoreLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.score]];
    

   // [[MobileAppTracker sharedManager] trackActionForEventIdOrName:@"purchase" eventIsId:NO revenueAmount:price currencyCode:@"USD"];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"إتمام!"
                                                    message:@"انتهت عملية شراء المنتج"
                                                   delegate:self
                                          cancelButtonTitle:@"موافق"
                                          otherButtonTitles:@"إلغاء", nil];
    [alert show];
    [alert release];
}

- (void) productPurchaseFailed:(NSNotification*)notification{
    [appDelegate.loading removeFromSuperview];
    
    if([[UIApplication sharedApplication] isIgnoringInteractionEvents])
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"خطأ!"
                                                    message:@"فشل عملية شراء المنتج"
                                                   delegate:self
                                          cancelButtonTitle:@"موافق"
                                          otherButtonTitles:@"إلغاء", nil];
    [alert show];
    [alert release];
}


- (IBAction) back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
