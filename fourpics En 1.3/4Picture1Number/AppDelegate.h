//
//  AppDelegate.h
//  4Picture1Number
//
//  Created by eurisko on 5/17/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Reachability.h"
#import "TouchXML.h"
#import "ODIN.h"

#import "AlertMessage.h"
#import "Parsers.h"
#import "Utils.h"
#import "SecKeyWrapper.h"
#import "Cryptography.h"
#import "NSData+CommonCrypto.h"
#import "DATABASE_HELPER.h"
#import "SimpleKeychain.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LivesCounter.h"
#import <StoreKit/StoreKit.h>
#import "InAppPurchaseManager.h"
#import "Harpy.h"
#import "GAI.h"
#import "AdRequestViewController.h"
#import "GAIDictionaryBuilder.h"

#define NumberOfLevels 24
@class RootViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, FBLoginViewDelegate> {
    Reachability* internetReachable;
	Reachability* hostReachable;
	NSString *internetActive, *hostActive;
    NSUserDefaults *userDefault;
    
    RootViewController *rootView;

    NSString *databasePath;
    NSString *databasePathNew;
	NSString *databaseName;
    IBOutlet UILabel *l1,*l2,*l3;
    int linknumber;
    
    IBOutlet UILabel *counterLabel;
    int minutes;
    int secondes;
    
    BOOL IsTimerStarted;
    IBOutlet UIButton *facebookButton;
    IBOutlet UILabel *TimerL1, *TimerL2, *TimerL3, *TimerL4;
    InAppPurchaseManager *purchaseManager;
    BOOL ConfirmationReceived;
    int FromBackground;
    
    IBOutlet UIActivityIndicatorView * timerActivity;
    IBOutlet UILabel * noConLabel;
    AdRequestViewController *adRequest;

    int fromPurchase;

}

@property (nonatomic, retain) NSString *databaseName, *databasePathNew;

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) IBOutlet UIView *loading;
@property (nonatomic, retain) IBOutlet UILabel *loadingLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;
@property (nonatomic, retain) IBOutlet UIImageView *loaderImage;
@property (nonatomic, retain) IBOutlet UIImageView *DefaultImage;

@property (nonatomic, retain) NSString *internetActive, *hostActive;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, retain) NSString *hostName, *sharetext, *imageURL, *serverDate, *serverDateWithTime;

@property (nonatomic, retain) NSMutableArray *currentLevelQuestionArray;
@property (nonatomic, retain) NSMutableArray *nextLevelQuestionArray;
@property (nonatomic) int userLevel, score, Lives, questionlevelid, isLevelLoaded;
@property (nonatomic) BOOL SoundEnabled;

@property (nonatomic, retain) NSString *rewardsVal, *rewardsDate, *rewardsEndDate, *rewardsServerDate;
@property (nonatomic, retain) IBOutlet UIView *transparentGrayView;
@property (nonatomic, retain) IBOutlet UIView *congratulationsView;

@property (nonatomic, retain) IBOutlet UIView *livesCounterView;
@property (nonatomic, retain) LivesCounter *livesCycle;
@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, retain) NSString *adImageUrl, *adItunesUrl;
@property (nonatomic, retain) IBOutlet UIView *adView;
@property (nonatomic, retain) IBOutlet UIImageView *adImageView;
@property(nonatomic, retain) id<GAITracker> tracker;

@property (nonatomic, retain) NSMutableArray *fixesArray;

@property (strong, nonatomic) FBSession *session;

- (void) callHostLink;
- (void) parseXMLData:(NSString *)XmlString ;

- (void) ShowTimerView;

- (void) callToGetTimeLink;
- (void) parseTimeXMLData:(NSString *)XmlString;

- (void) showAdView;
- (IBAction)hideAdView:(id)sender;

- (void) applyupdates;

@end