//
//  AppDelegate.m
//  4Picture1Number
//
//  Created by eurisko on 5/17/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "RootViewController.h"
#import "iRate.h"

#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "TopViewController.h"
#import <sqlite3.h>
#import "GAI.h"
#import "PushNotificationAPI.h"

#define TimeForNewLife 30 // in minutes

@implementation AppDelegate
@synthesize navigationController;

@synthesize loading, loadingLabel, activity, loaderImage, DefaultImage;
@synthesize internetActive, hostActive;
@synthesize token, webData;
@synthesize hostName, sharetext, imageURL, serverDate, serverDateWithTime;
@synthesize currentLevelQuestionArray, nextLevelQuestionArray;
@synthesize userLevel, score, Lives, isLevelLoaded, SoundEnabled, questionlevelid;
@synthesize rewardsVal, rewardsDate, rewardsEndDate, rewardsServerDate;
@synthesize livesCycle;
@synthesize congratulationsView, transparentGrayView;
@synthesize livesCounterView;
@synthesize timer;

@synthesize adImageUrl, adItunesUrl, adImageView, adView;
@synthesize tracker;

@synthesize fixesArray;
@synthesize session;

+ (void)initialize
{
    //set the bundle ID. normally you wouldn't need to do this
    //as it is picked up automatically from your Info.plist file
    //but we want to test with an app that's actually on the store
    [iRate sharedInstance].applicationBundleID = @"com.zackanton.fourpicsarabic";
    [iRate sharedInstance].appStoreID = 675596996;
    //prevent automatic prompt
    [iRate sharedInstance].promptAtLaunch = NO;
}

// FBSample logic
// If we have a valid session at the time of openURL call, we handle Facebook transitions
// by passing the url argument to handleOpenURL; see the "Just Login" sample application for
// a more detailed discussion of handleOpenURL
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // FBSample logic
    // if the app is going away, we close the session object
    [FBSession.activeSession close];
}

- (void)dealloc
{
    [_window release];
    [navigationController release];
    [super dealloc];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (!self.session.isOpen) {
        NSArray *permission = [NSArray arrayWithObjects:@"publish_actions", @"email", @"publish_stream", @"user_friends", nil];
        self.session = [[FBSession alloc] initWithPermissions:permission];
        
        [self.session closeAndClearTokenInformation];
        
        if (self.session.state == FBSessionStateCreatedTokenLoaded) {
            [self.session openWithCompletionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
            }];
        }
    }
    
    [FBSession setActiveSession:self.session];
    
//    NSLog(@"ODIN1 %@",[ODIN1() lowercaseString]);
    // Initialize Google Analytics with a 120-second dispatch interval. There is a
    // tradeoff between battery usage and timely dispatch.
    
    [GAI sharedInstance].optOut =
    ![[NSUserDefaults standardUserDefaults] boolForKey:@"UA-42849956-1"];
    // Initialize Google Analytics with a 120-second dispatch interval. There is a
    // tradeoff between battery usage and timely dispatch.
    [GAI sharedInstance].dispatchInterval = 10;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    self.tracker = [[GAI sharedInstance] trackerWithName:@"4 Pictures 1 Number"
                                              trackingId:@"UA-42849956-1"];
    
    [FBProfilePictureView class];
    
    [[SimpleKeychain alloc] init];
    [[Cryptography alloc] init];
    
    userDefault=[NSUserDefaults standardUserDefaults];
    if (![userDefault objectForKey:@"FirstRun"] || ![SimpleKeychain load:@"Score"]) {
        // Delete values from keychain here
        [SimpleKeychain delete:@"Score"];
        [SimpleKeychain delete:@"level"];
        [SimpleKeychain delete:@"Lives"];
        [SimpleKeychain delete:@"movie"];
        [SimpleKeychain delete:@"deviceUDID"];
        [SimpleKeychain delete:@"questionlevelid"];
        [SimpleKeychain delete:@"isLevelLoaded"];
        [SimpleKeychain delete:@"LastDate"];
        [SimpleKeychain delete:@"rewardsDate"];
        [SimpleKeychain delete:@"rewardsEndDate"];
        
        [SimpleKeychain delete:@"shareDate"];
        [SimpleKeychain delete:@"inviteDate"];
        [SimpleKeychain delete:@"isAppRated"];
        [SimpleKeychain delete:@"facebookID"];

        [SimpleKeychain delete:@"UpdateReward"];

        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
        
        [SimpleKeychain save:@"deviceUDID" data:[ODIN1() lowercaseString]];
        
        [SimpleKeychain save:@"Score" data:[Cryptography TripleDES:@"400" algo:kCCEncrypt key:@"Sfg$93@B"]];
        [SimpleKeychain save:@"Lives" data:[Cryptography TripleDES:@"5" algo:kCCEncrypt key:@"Sfg$93@B"]];

        [SimpleKeychain save:@"level" data:[[NSString alloc] initWithFormat:@"%d", 1]];
        [SimpleKeychain save:@"movie" data:[[NSString alloc] initWithFormat:@"%d", 0]];
        [SimpleKeychain save:@"questionlevelid" data:[[NSString alloc] initWithFormat:@"%d", 1]];
        [SimpleKeychain save:@"isLevelLoaded" data:[[NSString alloc] initWithFormat:@"%d", 0]];
        self.SoundEnabled = YES;
        [userDefault setValue:@"1" forKey:@"SoundEnabled"];
        [userDefault synchronize];
    }

    self.SoundEnabled = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SoundEnabled"] intValue];
    
    counterLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:70];

    databaseName = @"questionsArabic.sqlite";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	databasePath =[documentsDir stringByAppendingPathComponent:databaseName];
	[self checkAndCreateDatabase];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(checkNetworkStatus:)
												 name:kReachabilityChangedNotification
											   object:nil];
    
    internetReachable = [[Reachability reachabilityForInternetConnection] retain];
	[internetReachable startNotifier];
    
	hostReachable = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
    [hostReachable startNotifier];
    
    RootViewController *rootView;
    
    if(self.window.frame.size.height == 480)
        rootView = [[RootViewController alloc] initWithNibName:@"RootView-iPhone4" bundle:nil];
    else
        rootView = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    
    [rootView addObservers];
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:rootView];
    self.navigationController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    self.transparentGrayView.frame = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
    self.transparentGrayView.center = CGPointMake(self.window.bounds.size.width/2, self.window.bounds.size.height/2);
    
    self.congratulationsView.center = CGPointMake(self.window.bounds.size.width/2, self.window.bounds.size.height/2- 40);
    
    self.adView.frame = CGRectMake(0, 20, self.window.bounds.size.width, self.window.bounds.size.height);
    self.adView.center = CGPointMake(self.window.bounds.size.width/2, self.window.bounds.size.height/2);

    self.loading.center = CGPointMake(self.window.bounds.size.width/2, (self.window.bounds.size.height-113)/2);
    self.loading.layer.cornerRadius = 10;
    self.loading.layer.masksToBounds = YES;
    
    self.livesCounterView.center = CGPointMake(self.window.bounds.size.width/2, self.window.bounds.size.height/2);
    
    if(![userDefault objectForKey:@"FirstRunForInst"]) {
        TopViewController *instance;
        if(self.window.frame.size.height == 480)
            instance = [[TopViewController alloc] initWithNibName:@"TopViewiPhone4" bundle:nil];
        else
            instance = [[TopViewController alloc] initWithNibName:@"TopViewController" bundle:nil];
        
        [self.navigationController pushViewController:instance animated:NO];
    }
    
    adRequest = [[AdRequestViewController alloc] init];
    [adRequest CallAd];
    
    // Set the App ID for your app
    [[Harpy sharedInstance] setAppID:@"675596996"];
    
    /* (Optional) Set the Alert Type for your app
     By default, the Singleton is initialized to HarpyAlertTypeOption */
    [[Harpy sharedInstance] setAlertType:HarpyAlertTypeOption];
    
    // Perform check for new version of your app
    [[Harpy sharedInstance] checkVersion];
    
    self.userLevel = [[SimpleKeychain load:@"level"] intValue];
    
    self.score = [[Cryptography TripleDES:[SimpleKeychain load:@"Score"] algo:kCCDecrypt key:@"Sfg$93@B"] intValue];
    
    self.Lives = [[Cryptography TripleDES:[SimpleKeychain load:@"Lives"] algo:kCCDecrypt key:@"Sfg$93@B"] intValue];
    if(self.userLevel == 0)
        self.userLevel = 1;
    self.questionlevelid = [[SimpleKeychain load:@"questionlevelid"] intValue];
    self.isLevelLoaded = [[SimpleKeychain load:@"isLevelLoaded"] intValue];
    
    self.livesCycle = [[LivesCounter alloc] initWithLives:self.Lives];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLives:) name:@"setLives" object:nil];
    
    IsTimerStarted = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLifeTimerWith:) name:@"StartTimerWith" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLifeTimer) name:@"StartTimer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLifeTimer) name:@"StopTimer" object:nil];
    
    
    if(![SimpleKeychain load:@"902updatedAr"]){
        [DATABASE_HELPER update_question902_hint:@"2KfZhNil2KzYp9io2Kkg2KrYqNiv2KMg2Kgg2aHZog=="];
        [SimpleKeychain save:@"902updatedAr" data:@"done"];
    }
    
    if(![SimpleKeychain load:@"UpdateReward"]){
        NSLog(@"UpdateReward");
        [self checkforversion];
    }
    // Open from push
    if (launchOptions != nil)
    {
        NSDictionary* payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (payload != nil)
        {
            NSDictionary *apsInfo = [payload objectForKey:@"aps"];
            
            int badge=[[apsInfo objectForKey:@"badge"] intValue];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
            
            if([[Utils cleanupString:[apsInfo objectForKey:@"url"]] length]!=0)
            {   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[apsInfo objectForKey:@"url"]]];
            }
        }
    }

    return YES;
}

- (void) checkforversion {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    if([version isEqualToString:@"1.1"]){
        l1.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
        l1.text = @"لقد ربحت";
        l2.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
        l2.text = [[NSString alloc] initWithFormat:@"+%@", [Utils EnglishNumberToArabic:@"100"]];
        l3.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
        l3.text = @"نقاط";
        
        l1.textColor = [UIColor whiteColor];
        l2.textColor = [UIColor whiteColor];
        l3.textColor = [UIColor whiteColor];
        
        l1.textAlignment = NSTextAlignmentCenter;
        l2.textAlignment = NSTextAlignmentCenter;
        l3.textAlignment = NSTextAlignmentCenter;
        
        self.score = self.score + 100;
        
        [SimpleKeychain save:@"Score" data:[Cryptography TripleDES:[[NSString alloc] initWithFormat:@"%d", self.score] algo:kCCEncrypt key:@"Sfg$93@B"]];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"RewardsReceived" object:nil];
        
        [self.window addSubview:self.transparentGrayView];
        [self.window addSubview:self.congratulationsView];
        [SimpleKeychain save:@"UpdateReward" data:@"gotRewards"];
        
    }
}

- (void) addLives :(NSNotification *)notification {
    [SimpleKeychain save:@"Lives" data:[Cryptography TripleDES:[[NSString alloc] initWithFormat:@"%d", self.livesCycle.lives] algo:kCCEncrypt key:@"Sfg$93@B"]];
    self.Lives = self.livesCycle.lives;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.livesCycle stopLifeTimer];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NotificationSent = 0;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
    
    [timerActivity startAnimating];
    
    if(![self.internetActive isEqualToString:@"down"] && FromBackground  == 1 )
    {
        [self callToGetTimeLink];
    }else {
        noConLabel.hidden = NO;
        [timerActivity stopAnimating];
    }

    NSLog(@"pushhhhhh");
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    /*
     Perform daily check for new version of your app
     Useful if user returns to you app from background after extended period of time
     Place in applicationDidBecomeActive:
     
     Also, performs version check on first launch.
     */
    [[Harpy sharedInstance] checkVersionDaily];
    
    /*
     Perform weekly check for new version of your app
     Useful if user returns to you app from background after extended period of time
     Place in applicationDidBecomeActive:
     
     Also, performs version check on first launch.
     */
    [[Harpy sharedInstance] checkVersionWeekly];
}

- (void) callToGetTimeLink  {
    if(fromPurchase)
    {
        fromPurchase = 0;
        return ;
    }
    
    if([self.hostActive isEqualToString:@"down"])
    {
        return ;
    }
    linknumber = 4;
    NSString *post = [[NSString alloc] initWithFormat:@"secret=5GhzqyJnaQuiVbzb9oPlk1QavbN6YfazBdH6tEaNbp0gDg5EqvCh5aLp67FbdAz5HfaYtcdB7YihNg&platformId=1&rand=%f",[NSDate timeIntervalSinceReferenceDate]];
    
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength =  [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString *path= [[NSString alloc] initWithFormat:@"https://www.euriskomobility.me/fourpicsonenumberar/getDomain.php"];
    
    NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10.0];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPBody:postData];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if(theConnection)
    {
        self.webData = NULL;
        self.webData = [[NSMutableData data] retain];
    }
}
- (void) parseTimeXMLData:(NSString *)XmlString {
    
    @try {
        
        CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString:XmlString options:0 error:nil] autorelease];
        NSArray *nodes = NULL;
        nodes = [doc nodesForXPath:@"//info" error:nil];
        
        for (CXMLElement *node in nodes) {
            
            NSMutableDictionary *category = [[NSMutableDictionary alloc] init];
            
            for(int counter = 0; counter < [node childCount]; counter++)
            {
                if([[node childAtIndex:counter] stringValue] != NULL)
                    
                    [category setObject:[[node childAtIndex:counter] stringValue] forKey:[[node childAtIndex:counter] name]];
            }
            
            self.hostName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[category objectForKey:@"hosting"]] encoding:NSUTF8StringEncoding];
            self.sharetext = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[category objectForKey:@"share"]] encoding:NSUTF8StringEncoding];
            self.imageURL = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[category objectForKey:@"imageURL"]] encoding:NSUTF8StringEncoding];
            self.serverDate = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[category objectForKey:@"serverDate"]] encoding:NSUTF8StringEncoding];
            
            [category release];
        }
        self.serverDate = [[NSString alloc] initWithFormat:@"%@", [Utils local_date_for:serverDate with_format:@"yyyy/MM/dd HH:mm"]];
        
        if(self.serverDate == NULL || [self.serverDate length] == 0){
            [self.livesCycle restartLifeTimerAfterBackground:NO];
        }else {
            [self.livesCycle restartLifeTimerAfterBackground:YES];
        }
        
        self.serverDate = [Utils dateTransform:self.serverDate FromFormat:@"yyyy/MM/dd HH:mm" ToFormat:@"yyyy-MM-dd"];
        
        if(!NotificationSent) {
            NotificationSent = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HostNameFound" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadImages" object:nil];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception.debugDescription);
    }
    
    [self.DefaultImage removeFromSuperview];
}

- (void) checkNetworkStatus:(NSNotification *)notice
{	internetActive = nil;
    
	NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
	switch (internetStatus)
	{	case NotReachable:
		{
            internetActive = @"down";
			break;
		}
		case ReachableViaWiFi:
		{
            internetActive = @"wifi";
			break;
		}
		case ReachableViaWWAN:
		{
            internetActive = @"wwan";
			break;
		}
	}
	NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
	switch (hostStatus)
	{	case NotReachable:
		{	hostActive = @"down";
			break;
		}
		case ReachableViaWiFi:
		{
            hostActive = @"wifi";
			break;
		}
		case ReachableViaWWAN:
		{
            hostActive = @"wwan";
			break;
		}
	}
    
    if ([self.hostActive isEqualToString:@"down"] && [self.internetActive isEqualToString:@"down"])
    {
        [AlertMessage Display_internet_error_message_WithLanguage:@"Ar"];
        noConLabel.hidden = NO;
        [activity stopAnimating];
        return ;
    }
    
    if([self.hostActive isEqualToString:@"down"] || [self.internetActive isEqualToString:@"down"])
    {
        noConLabel.hidden = NO;
        [timerActivity stopAnimating];
    }else if(FromBackground == 0){
        [activity startAnimating];
        [self callHostLink];
    }
    
}

- (IBAction) Dismiss:(id)sender {
    [self.livesCounterView removeFromSuperview];
    [self.transparentGrayView removeFromSuperview];
    [self.congratulationsView removeFromSuperview];
    
    if(self.Lives == 0)
        [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Push Services


- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    if([self.hostActive isEqualToString:@"down"])
    {
    }else {
        
        self.token = [[NSString alloc] initWithFormat:@"%@", deviceToken];
        self.token = [self.token stringByReplacingOccurrencesOfString:@"<" withString:@""];
        self.token = [self.token stringByReplacingOccurrencesOfString:@">" withString:@""];
        self.token = [self.token stringByReplacingOccurrencesOfString:@" " withString:@""];
        [userDefault setObject: self.token forKey:@"token"];
        [userDefault synchronize];
//        NSLog(@"self.token %@", self.token);
        PushNotificationAPI *pushClass = [[PushNotificationAPI alloc] init];
        //[UIPasteboard generalPasteboard].string = token;
        [pushClass SaveTokenForPushNotification:token andAppID:@"100"];
       
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    [userDefault setObject:@"test" forKey:@"token"];
    [userDefault synchronize];
    // [self alertNotice:@"" withMSG:[NSString stringWithFormat:@"Error in registration. Error: %@", err] cancleButtonTitle:@"موافق" otherButtonTitle:@""];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    for (id key in userInfo) {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
    
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    int badge=[[apsInfo objectForKey:@"badge"] intValue];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
    
    if([[Utils cleanupString:[apsInfo objectForKey:@"url"]] length]!=0)
    {   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[apsInfo objectForKey:@"url"]]];
        return;
    }
}


-(void)alertNotice:(NSString *)title withMSG:(NSString *)msg cancleButtonTitle:(NSString *)cancleTitle otherButtonTitle:(NSString *)otherTitle{
    UIAlertView *alert;
    if([otherTitle isEqualToString:@""])
        alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancleTitle otherButtonTitles:nil,nil];
    else
        alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancleTitle otherButtonTitles:otherTitle,nil];
    [alert show];
    [alert release];
}

#pragma mark -
#pragma mark get hostname lifecycle

- (void) callHostLink {
    //[self.window addSubview:self.loading];
    linknumber = 1;
    FromBackground = 1;
    NSString *post = [[NSString alloc] initWithFormat:@"secret=5GhzqyJnaQuiVbzb9oPlk1QavbN6YfazBdH6tEaNbp0gDg5EqvCh5aLp67FbdAz5HfaYtcdB7YihNg&platformId=1&rand=%f",[NSDate timeIntervalSinceReferenceDate]];
    
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength =  [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString *path= [[NSString alloc] initWithFormat:@"https://www.euriskomobility.me/fourpicsonenumberar/getDomain.php"];
    
    NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10.0];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPBody:postData];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if(theConnection)
    {
        self.webData = NULL;
        self.webData = [[NSMutableData alloc] init];
    }
}


- (void) parseXMLData:(NSString *)XmlString {
    
    @try {
        
        CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString:XmlString options:0 error:nil] autorelease];
        NSArray *nodes = NULL;
        nodes = [doc nodesForXPath:@"//info" error:nil];
        
        for (CXMLElement *node in nodes) {
            
            NSMutableDictionary *category = [[NSMutableDictionary alloc] init];
            
            for(int counter = 0; counter < [node childCount]; counter++)
            {
                if([[node childAtIndex:counter] stringValue] != NULL)
                    
                    [category setObject:[[node childAtIndex:counter] stringValue] forKey:[[node childAtIndex:counter] name]];
            }            
            

            self.hostName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[category objectForKey:@"hosting"]] encoding:NSUTF8StringEncoding];
            self.sharetext = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[category objectForKey:@"share"]] encoding:NSUTF8StringEncoding];
            self.imageURL = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[category objectForKey:@"imageURL"]] encoding:NSUTF8StringEncoding];
            self.serverDate = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[category objectForKey:@"serverDate"]] encoding:NSUTF8StringEncoding];

            [category release];
        }
        self.serverDate = [[NSString alloc] initWithFormat:@"%@", [Utils local_date_for:serverDate with_format:@"yyyy/MM/dd HH:mm"]];
        self.serverDateWithTime = [[NSString alloc] initWithFormat:@"%@", [Utils local_date_for:serverDate with_format:@"yyyy/MM/dd HH:mm"]];
        
        if(self.serverDate == NULL || [self.serverDate length] == 0){
            [self.livesCycle restartLifeTimerAfterBackground:NO];
        }else {
            [self.livesCycle restartLifeTimerAfterBackground:YES];
        }
        
        self.serverDate = [Utils dateTransform:self.serverDate FromFormat:@"yyyy/MM/dd HH:mm" ToFormat:@"yyyy-MM-dd"];
        
        if(!NotificationSent) {
            NotificationSent = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HostNameFound" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadImages" object:nil];
        }
        
        self.fixesArray = [[NSMutableArray alloc] init];
        
        NSArray *bodyNodes = [doc nodesForXPath:@"//fix" error:nil];
        
        for (CXMLElement *node in bodyNodes) {
            NSMutableDictionary *category = [[NSMutableDictionary alloc] init];
            for(int counter = 0; counter < [node childCount]; counter++)
            {
                if([[node childAtIndex:counter] stringValue] != NULL)
                    
                    [category setObject:[[node childAtIndex:counter] stringValue] forKey:[[node childAtIndex:counter] name]];
            }
            
            [self.fixesArray addObject:category];
            [category release];
        }
        
        if([self.fixesArray count] >0){
            [DATABASE_HELPER update_questions:self.fixesArray];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception.debugDescription);
    }
    
    [self.DefaultImage removeFromSuperview];
    [self call_Rewards_By_Date];
}


- (void) call_Rewards_By_Date {
    
    if([self.hostActive isEqualToString:@"down"])
    {
        return ;
    }
    
    //NSLog(@"call_Rewards_By_Date");
    linknumber = 2;
    NSString *post = [[NSString alloc] initWithFormat:@"secret=5GhzqyJnaQuiVbzb9oPlk1QavbN6YfazBdH6tEaNbp0gDg5EqvCh5aLp67FbdAz5HfaYtcdB7YihNg&platformId=1&date=%@&rand=%f",[Utils dateTransform:[Utils getUTCFormateDate:[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss" ToFormat:@"yyyy-MM-dd"], [NSDate timeIntervalSinceReferenceDate]];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength =  [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString *path= [[NSString alloc] initWithFormat:@"%@getRewardsByDate.php", self.hostName];
    
    NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10.0];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPBody:postData];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if(theConnection)
    {
        self.webData = NULL;
        self.webData = [[NSMutableData data] retain];
    }
}

- (void) parse_Rewards_By_Date_XML:(NSString *)XmlString {
    
    @try {
        
        CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString:XmlString options:0 error:nil] autorelease];
        NSArray *nodes = NULL;
        nodes = [doc nodesForXPath:@"//reward" error:nil];
        
        for (CXMLElement *node in nodes) {
            
            NSMutableDictionary *category = [[NSMutableDictionary alloc] init];
            
            for(int counter = 0; counter < [node childCount]; counter++)
            {
                if([[node childAtIndex:counter] stringValue] != NULL)
                    [category setObject:[[node childAtIndex:counter] stringValue] forKey:[[node childAtIndex:counter] name]];
            }
            
            self.rewardsVal =[[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[category objectForKey:@"val"]] encoding:NSUTF8StringEncoding];
            
            self.rewardsServerDate =[[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[category objectForKey:@"serverdate"]] encoding:NSUTF8StringEncoding];
            
            self.rewardsDate =[[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[category objectForKey:@"date"]] encoding:NSUTF8StringEncoding];
            
            self.rewardsEndDate =[[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[category objectForKey:@"enddate"]] encoding:NSUTF8StringEncoding];


            [SimpleKeychain delete:@"ServerDate"];
            [SimpleKeychain save:@"ServerDate" data:rewardsServerDate];
            
            [category release];
            
            NSString *phoneDate = [Utils dateTransform:[Utils getUTCFormateDate:[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss" ToFormat:@"yyyy-MM-dd"];
            
            if([Utils date:phoneDate isBetweenDate:self.rewardsDate andDate:self.rewardsEndDate]){
                
                if(![self.rewardsDate isEqualToString:[SimpleKeychain load:@"rewardsDate"]] && ![self.rewardsEndDate isEqualToString:[SimpleKeychain load:@"rewardsEndDate"]]){
                    
                    [SimpleKeychain delete:@"rewardsDate"];
                    [SimpleKeychain delete:@"rewardsEndDate"];
                    [SimpleKeychain save:@"rewardsDate" data:self.rewardsDate];
                    [SimpleKeychain save:@"rewardsEndDate" data:self.rewardsEndDate];
                
                    
                    l1.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
                    l1.text = @"لقد ربحت";
                    l2.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
                    l2.text = [[NSString alloc] initWithFormat:@"+%@", [Utils EnglishNumberToArabic:self.rewardsVal]];
                    l3.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
                    l3.text = @"نقاط";
                    
                    l1.textColor = [UIColor whiteColor];
                    l2.textColor = [UIColor whiteColor];
                    l3.textColor = [UIColor whiteColor];
                    
                    l1.textAlignment = NSTextAlignmentCenter;
                    l2.textAlignment = NSTextAlignmentCenter;
                    l3.textAlignment = NSTextAlignmentCenter;
                    
                    self.score = self.score + [self.rewardsVal integerValue];
                                        
                    [SimpleKeychain save:@"Score" data:[Cryptography TripleDES:[[NSString alloc] initWithFormat:@"%d", self.score] algo:kCCEncrypt key:@"Sfg$93@B"]];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RewardsReceived" object:nil];
                    
                    if(self.rewardsVal != NULL){
                        [self.window addSubview:self.transparentGrayView];
                        [self.window addSubview:self.congratulationsView];
                    }
                }
            }else {
                
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception.debugDescription);
    }
    
   

}

#pragma mark -
#pragma mark Connection Functions

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webData setLength: 0];
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{   [webData appendData:data];
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
   // [AlertMessage Display_internet_error_message_WithLanguage:@"Ar"];
    
    [self.DefaultImage removeFromSuperview];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"خطأ في الإتصال، الرجاء المحاولة لاحقاً."
                                                   delegate:self
                                          cancelButtonTitle:@"إعادة الإتصال"
                                          otherButtonTitles:@"إلغاء", nil];
    [alert show];
    [alert release];
  
    
    NSLog(@"error %@", error.debugDescription);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *XMLData = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSASCIIStringEncoding];
    if([XMLData isEqualToString:@"1"] || [XMLData isEqualToString:@"0"] || [XMLData length] == 0){
        
    }else {
        if(linknumber == 1 && [XMLData length] != 0){
            [self parseXMLData:XMLData];
        }
        else if(linknumber == 2){
            
            if(![XMLData isEqualToString:@"<rewards></rewards>"])
                [self parse_Rewards_By_Date_XML:XMLData];
            
        }else if(linknumber == 3){
            
        }else if(linknumber == 4) {
            if([XMLData length] != 0)
                [self parseTimeXMLData:XMLData];
            else
                [self.livesCycle restartLifeTimerAfterBackground:NO];
            
        }
    }

    [connection release];
}

#pragma mark -
#pragma mark database creation

-(void) checkAndCreateDatabase {
	BOOL success=0;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	success = [fileManager fileExistsAtPath:databasePath];
	if(success)
		return;
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
}

//- (void)encryptDB
//{
//    sqlite3 *unencrypted_DB;
//    NSString *path_u = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
//                        stringByAppendingPathComponent:@"unencrypted.db"];
//    
//    if (sqlite3_open([path_u UTF8String], &unencrypted_DB) == SQLITE_OK) {
//        NSLog(@"Database Opened");
//        // Attach empty encrypted database to unencrypted database
//        sqlite3_exec(unencrypted_DB, "ATTACH DATABASE 'encrypted.db' AS encrypted KEY '1234';", NULL, NULL, NULL);
//        
//        // export database
//        sqlite3_exec(unencrypted_DB, "SELECT sqlcipher_export('encrypted');", NULL, NULL, NULL);
//        
//        // Detach encrypted database
//        sqlite3_exec(unencrypted_DB, "DETACH DATABASE encrypted;", NULL, NULL, NULL);
//        
//        NSLog (@"End database copying");
//        sqlite3_close(unencrypted_DB);
//    }
//    else {
//        sqlite3_close(unencrypted_DB);
//        NSAssert1(NO, @"Failed to open database with message '%s'.", sqlite3_errmsg(unencrypted_DB));
//    }
//}
//
//- (void) openCipherDB
//{
//    NSLog(@"database path %@", databasePath);
//    sqlite3 *db;
//    if (sqlite3_open([databasePath UTF8String], &db) == SQLITE_OK)
//    {
//        //sqlite3_exec(_db, "ATTACH DATABASE 'xyz.sqlite' AS encrypted KEY 'test';", NULL, NULL, &t)
//        const char* key = [@"secret" UTF8String];
//        int sqlite3_key(sqlite3 *db, const void *pKey, int nKey);       //i added this after seeing SO
//        sqlite3_key(db, key, strlen(key));
//        if (sqlite3_exec(db, (const char*) "SELECT count(*) FROM sqlite_master;", NULL, NULL, NULL) == SQLITE_OK) {
//            // password is correct, or, database has been initialized
//            NSLog(@"database initialize");
//        }
//        else
//        {
//            NSLog(@"incorrect pass");
//            // incorrect password!
//        }
//        
//        sqlite3_close(db);
//    }
//}

#pragma mark -
#pragma mark Timer


- (void) startLifeTimerWith :(NSNotification *)notification {
    IsTimerStarted = 1;
    NSDictionary *dict = [notification userInfo];

    long long remaingTimeInSeconds = [[dict objectForKey:@"remaingTimeInSeconds"] longLongValue];
    

    minutes = TimeForNewLife - [[dict objectForKey:@"minutes"] intValue];
    
    secondes = remaingTimeInSeconds%60;
    
    counterLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d : %d", minutes, secondes]];
    
    if([self.timer isValid])
    {	[self.timer invalidate];
        self.timer=nil;
    }
    self.timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
}

- (void) startLifeTimer {
 
    if(IsTimerStarted == 1)
        return ;
    
    IsTimerStarted = 1;
    minutes = TimeForNewLife;
    secondes = 0;
    
    counterLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d : %d", minutes, secondes]];
    
    if([self.timer isValid])
    {	[self.timer invalidate];
        self.timer=nil;
    }
    self.timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
}

- (void) stopLifeTimer {
    IsTimerStarted = 0;
    if([self.timer isValid])
    {	[self.timer invalidate];
        self.timer=nil;
    }
    counterLabel.text = @"";
}

- (void) ShowTimerView {
    TimerL4.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:40];
    TimerL4.textColor = [UIColor colorWithRed:214.0/255.0 green:118.0/255.0 blue:87.0/255.0 alpha:1];
    TimerL4.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", self.Lives]];
    
    TimerL1.textColor = [UIColor colorWithRed:214.0/255.0 green:118.0/255.0 blue:87.0/255.0 alpha:1];
    TimerL2.textColor = [UIColor colorWithRed:214.0/255.0 green:118.0/255.0 blue:87.0/255.0 alpha:1];
    TimerL3.textColor = [UIColor colorWithRed:214.0/255.0 green:118.0/255.0 blue:87.0/255.0 alpha:1];

    counterLabel.textColor = [UIColor whiteColor];
    
    TimerL1.textAlignment = NSTextAlignmentCenter;
    TimerL2.textAlignment = NSTextAlignmentCenter;
    TimerL3.textAlignment = NSTextAlignmentCenter;
    counterLabel.textAlignment = NSTextAlignmentCenter;

    if(self.Lives >= 5) {
        TimerL1.text = @"";
        TimerL2.text = @"";//[[NSString alloc] initWithFormat:@" YOU HAVE %d LIVES.", self.Lives];
        facebookButton.hidden = YES;
        TimerL3.text = @"";
        noConLabel.hidden = YES;
        [timerActivity stopAnimating];
        IsTimerStarted = 0;
        if([self.timer isValid])
        {	[self.timer invalidate];
            self.timer=nil;
        }
        counterLabel.text = @"";
    }else {
        TimerL1.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
        TimerL1.text = @"الوقت المتبقي للحياة المقبلة";
        TimerL2.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
        TimerL2.text = @"";//[[NSString alloc] initWithFormat:@" YOU HAVE %d LIVES.", self.Lives];
        
        NSString *phoneDate = [Utils dateTransform:[Utils getUTCFormateDate:[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss" ToFormat:@"yyyy-MM-dd"];
        if([phoneDate isEqualToString:[SimpleKeychain load:@"shareDate"]]) {
            facebookButton.hidden = YES;
            TimerL3.text = @"";
        }else {
            facebookButton.hidden = NO;
            TimerL3.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
            TimerL3.text = @"شارك على الفيسبوك: +١ ♥";
        }
    }
   
    [self.window addSubview:self.livesCounterView];
}

- (IBAction)HideTimerView:(id)sender {
    [self.livesCounterView removeFromSuperview];
    [self.loading removeFromSuperview];
}

- (IBAction)BuyLives:(id)sender {
    if ([SKPaymentQueue canMakePayments]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchaseSuccesful:) name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchaseFailed:) name:kInAppPurchaseManagerTransactionFailedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchaseCancelled:) name:kInAppPurchaseManagerTransactionCancelledNotification object:nil];

        fromPurchase = 1;
        [self.window addSubview:self.loading];
        ConfirmationReceived = NO;
        purchaseManager = [[InAppPurchaseManager alloc] init];
        purchaseManager.productID = @"com.zackanton.fourpicsarabic.lives";
        [purchaseManager loadStore];
    } else {
        // Warn the user that purchases are disabled.
    }
}

-(void) updateLabel {
    noConLabel.hidden = YES;
    [timerActivity stopAnimating];
    if(minutes < 10 && secondes > 10)
        counterLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"0%d : %d", minutes, secondes]];
    else if(secondes < 10 && minutes > 10)
        counterLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d : 0%d", minutes, secondes]];
    else if(minutes < 10 && secondes < 10)
        counterLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"0%d : 0%d", minutes, secondes]];
    else
        counterLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d : %d", minutes, secondes]];
}

-(void)countDown {
    if (secondes == 0 && minutes != 0) {
        minutes = minutes -1;
        secondes = 59;
        [self updateLabel];
    }else if (secondes != 0) {
        secondes = secondes - 1;
        [self updateLabel];
    }else if(secondes == 0 && minutes == 0) {
        IsTimerStarted = 0;
        self.Lives = self.Lives + 1;
        [SimpleKeychain save:@"Lives" data:[Cryptography TripleDES:[[NSString alloc] initWithFormat:@"%d", self.Lives] algo:kCCEncrypt key:@"Sfg$93@B"]];
        NSString *phoneDate = [Utils dateTransform:[Utils getUTCFormateDate:[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss" ToFormat:@"yyyy-MM-dd"];
        
        if([self.hostActive isEqualToString:@"down"] || self.serverDate == NULL || [self.serverDate length] == 0)
        {
            [self.livesCycle setLife:self.Lives IsDateCorrect:NO];
        }else {
            if([phoneDate isEqualToString:self.serverDate]) {
                [self.livesCycle setLife:self.Lives IsDateCorrect:YES];
                
            }else {
                [self.livesCycle setLife:self.Lives IsDateCorrect:NO];
            }
        }
        TimerL4.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", self.Lives]];
        if(self.Lives == 5) {
            noConLabel.hidden = NO;
            [timerActivity stopAnimating];
            [self HideTimerView:nil];
        }
    }
}

#pragma mark -
#pragma mark share methods

- (IBAction) share:(id)sender {
    NSString *phoneDate = [Utils dateTransform:[Utils getUTCFormateDate:[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss" ToFormat:@"yyyy-MM-dd"];
    
    if(![phoneDate isEqualToString:self.serverDate] && (self.serverDate != NULL || [self.serverDate length] != 0)) {
        [AlertMessage Display_internet_error_message_WithLanguage:@"Ar"];
//        [AlertMessage Display_wrong_date_error_message_WithLanguage:@"Ar"];
        return ;
    }
    
    if ([[FBSession activeSession]isOpen]) {
        /*
         * if the current session has no publish permission we need to reauthorize
         */
        if ([[[FBSession activeSession]permissions]indexOfObject:@"publish_actions"] == NSNotFound) {
            
            [[FBSession activeSession] requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_action"] defaultAudience:FBSessionDefaultAudienceFriends
                                                  completionHandler:^(FBSession *session,NSError *error){
                                                      [self postOnWall];
                                                  }];
            
        }else{
            [self postOnWall];
        }
    }else{
        /*
         * open a new session with publish permission
         */
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                           defaultAudience:FBSessionDefaultAudienceOnlyMe
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             if (!error && status == FBSessionStateOpen) {
                                                 [self postOnWall];
                                             }else{
                                                 NSLog(@"error");
                                             }
                                         }];
    }
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            [self postOnWall];
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [[FBSession activeSession] closeAndClearTokenInformation];
            break;
        default:
            break;
    }
}

// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void) performPublishAction:(void (^)(void)) action {
    
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [[FBSession activeSession] requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_action"] defaultAudience:FBSessionDefaultAudienceFriends
                                              completionHandler:^(FBSession *session,NSError *error){
                                                  if (!error) {
                                                      action();
                                                  }else {
                                                      NSLog(@"error %@", error);
                                                  }
                                              }];
    } else {
        action();
    }
    
}

- (NSDictionary *)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    for (NSString *pair in pairs)
    {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        
        [params setObject:[[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                   forKey:[[kv objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return params;
}

- (void)postOnWall
{
    [self.window addSubview:self.loading];
    [self performPublishAction:^{
        NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           self.sharetext, @"name",
                                           @"http://www.euriskomobility.me/share/fourpics.php", @"caption",
                                           @"", @"description",
                                           @"http://www.euriskomobility.me/share/fourpics.php", @"link",
                                           @"http://www.euriskomobility.me/fourpicsonenumberar/icon.png", @"picture",
                                           nil];
        
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:postParams
                                                  handler:
         ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
             if (error) {
                 // Error launching the dialog or publishing a story.
                 NSLog(@"Error publishing story.");
                 
             } else {
                 
                 if (result == FBWebDialogResultDialogNotCompleted) {
                     // User clicked the "x" icon
                     NSLog(@"User canceled story publishing.");
                 } else {
                     [self.loading removeFromSuperview];
                     
                     // Handle the publish feed callback
                     NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                     if (![urlParams valueForKey:@"post_id"]) {
                         // User clicked the Cancel button
                         NSLog(@"User canceled story publishing.");
                     } else {
                         NSString *phoneDate = [Utils dateTransform:[Utils getUTCFormateDate:[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss" ToFormat:@"yyyy-MM-dd"];
                         
                         [SimpleKeychain save:@"shareDate" data:phoneDate];
                         facebookButton.enabled = NO;
                         
                         
                         l1.textColor = [UIColor whiteColor];
                         l2.textColor = [UIColor whiteColor];
                         l3.textColor = [UIColor whiteColor];
                         
                         l1.textAlignment = NSTextAlignmentCenter;
                         l2.textAlignment = NSTextAlignmentCenter;
                         l3.textAlignment = NSTextAlignmentCenter;
                         
                         l1.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
                         l1.text = @"لقد ربحت";
                         l2.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
                         l2.text = [Utils EnglishNumberToArabic:@"+ 1"];
                         l3.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
                         l3.text = @"فرصة";
                         
                         self.Lives = self.Lives + 1;
                         [SimpleKeychain save:@"Lives" data:[Cryptography TripleDES:[[NSString alloc] initWithFormat:@"%d", self.Lives] algo:kCCEncrypt key:@"Sfg$93@B"]];
                         [self.livesCycle setLife:self.Lives IsDateCorrect:YES];
                        
                         [self.window addSubview:self.transparentGrayView];
                         [self.window addSubview:self.congratulationsView];
                         
                         [self HideTimerView:nil];
                     }
                 }
                 
            }
             [self.loading removeFromSuperview];
             
         }];
    }];
}

// UIAlertView helper for post buttons
- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error {
    
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertMsg = error.localizedDescription;
        alertTitle = @"خطأ";
    } else {
        
        alertMsg = [NSString stringWithFormat:@"نشرت بنجاح."];
        alertTitle = @"نجاح";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"موافق"
                                              otherButtonTitles:nil];
    [alertView show];
    [self.loading removeFromSuperview];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0){
        NSLog(@"start");
        [activity startAnimating];
        [self callHostLink];
    }else{
        NSLog(@"cancel");

    }
}

#pragma mark - buy lives lifecycle

- (void) productPurchaseSuccesful:(NSNotification*)notification{
    [self.loading removeFromSuperview];
    if(ConfirmationReceived == NO) {
        ConfirmationReceived = YES;
        self.Lives = self.Lives + 5;
        TimerL4.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", self.Lives]];
        [SimpleKeychain save:@"Lives" data:[Cryptography TripleDES:[[NSString alloc] initWithFormat:@"%d", self.Lives] algo:kCCEncrypt key:@"Sfg$93@B"]];
        [self.livesCycle setLife:self.Lives IsDateCorrect:YES];
        [self HideTimerView:nil];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"إتمام!"
                                                        message:@"انتهت عملية شراء المنتج"
                                                       delegate:nil
                                              cancelButtonTitle:@"موافق"
                                              otherButtonTitles:@"إلغاء", nil];
        [alert show];
        [alert release];
    }
}

- (void) productPurchaseFailed:(NSNotification*)notification{
    [timerActivity stopAnimating];
    if(ConfirmationReceived == NO) {
        ConfirmationReceived = YES;
        [self.loading removeFromSuperview];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"خطأ!"
                                                        message:@"فشل عملية شراء المنتج"
                                                       delegate:nil
                                              cancelButtonTitle:@"موافق"
                                              otherButtonTitles:@"إلغاء", nil];
        [alert show];
        [alert release];
    }
}

- (void) productPurchaseCancelled : (NSNotification*)notification {
    [timerActivity stopAnimating];
    [self.loading removeFromSuperview];

}

#pragma mark - Ad lifecycle

- (void) showAdView {
    [self.window addSubview:adView];
    CABasicAnimation *theAnimation1;
    theAnimation1=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    theAnimation1.duration=0.4;
    theAnimation1.fromValue=[NSNumber numberWithFloat:0.2];
    theAnimation1.toValue=[NSNumber numberWithFloat:1.0];
    [adView.layer addAnimation:theAnimation1 forKey:@"animateLayer"];
}

- (IBAction)hideAdView:(id)sender {
    [adView removeFromSuperview];
    self.adImageView.image = nil;
    
    CABasicAnimation *theAnimation1;
    theAnimation1=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    theAnimation1.duration=0.5;
    theAnimation1.fromValue=[NSNumber numberWithFloat:1.0];
    theAnimation1.toValue=[NSNumber numberWithFloat:0.2];
    [adView.layer addAnimation:theAnimation1 forKey:@"animateLayer"];
}

- (IBAction)GoToAdLink:(id)sender {
    if([self.adItunesUrl length] != 0){
        [adView removeFromSuperview];
        self.adImageView.image = nil;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.adItunesUrl]];
    }
}


@end
