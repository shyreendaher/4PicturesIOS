//
//  FacebookShareViewController.m
//  What's the movie
//
//  Created by eurisko on 6/5/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "FacebookShareViewController.h"
#import "AppDelegate.h"
#import "SafariViewController.h"
#import "AboutViewController.h"
#import "SimpleKeychain.h"
#import "GetCoinsViewController.h"
#import "FacebookFriendsViewController.h"

#import <FacebookSDK/FacebookSDK.h>

@interface FacebookShareViewController () <FBLoginViewDelegate>
@property (nonatomic, retain) FBSession *fbsession;
@property (nonatomic, retain) AVAudioPlayer* coinsAudioPlayer;

@end

@implementation FacebookShareViewController
@synthesize fbsession, coinsAudioPlayer;
@synthesize transparentGrayView, congratulationsView;
@synthesize friendPickerController;
@synthesize friendsParams;
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
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    livesLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:22];
    scoreLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:22];
    
    AVAudioPlayer *coinsAudioPlayerTemp = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"coins-tap" ofType:@"wav"]] error:nil];
    self.coinsAudioPlayer = coinsAudioPlayerTemp;
    [coinsAudioPlayerTemp release];
    self.coinsAudioPlayer.delegate=self;
    [self.coinsAudioPlayer prepareToPlay];
    self.coinsAudioPlayer.numberOfLoops = 1;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RewardsReceived:) name:@"RewardsReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLives:) name:@"setLives" object:nil];

    [iRate sharedInstance].delegate = self;
    
    self.transparentGrayView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.transparentGrayView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    self.congratulationsView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2- 40);
    
    NSString *phoneDate = [Utils dateTransform:[Utils getUTCFormateDate:[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss" ToFormat:@"yyyy-MM-dd"];
    
//    NSLog(@"appDelegate.hostActive %@\n appDelegate.serverDate %@ \n", appDelegate.hostActive, appDelegate.serverDate);
    
    if([appDelegate.hostActive isEqualToString:@"down"] || appDelegate.serverDate == NULL || [appDelegate.serverDate length] == 0)
    {
        shareB.enabled = NO;
        inviteB.enabled = NO;
        rateB.enabled = NO;
        [AlertMessage Display_internet_error_message_WithLanguage:@"Ar"];
    }else {
        if([phoneDate isEqualToString:appDelegate.serverDate]  && appDelegate.serverDate != NULL) {
            if([phoneDate isEqualToString:[SimpleKeychain load:@"shareDate"]]) {
                shareB.enabled = NO;
            }
            
            if([phoneDate isEqualToString:[SimpleKeychain load:@"inviteDate"]]) {
                inviteB.enabled = NO;
            }
            
            if([[SimpleKeychain load:@"isAppRated"] isEqualToString:@"2"])  {
                rateB.enabled = NO;
            }
        }else {
            shareB.enabled = NO;
            inviteB.enabled = NO;
            rateB.enabled = NO;
            [AlertMessage Display_internet_error_message_WithLanguage:@"Ar"];
//            [AlertMessage Display_wrong_date_error_message_WithLanguage:@"Ar"];
        }
        
        if(appDelegate.Lives == 5) {
            shareB.enabled = NO;
        } 
    }
}


- (void) setLives :(NSNotification *)notification {
    livesLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.livesCycle.lives]];
}

- (IBAction) Dismiss:(id)sender {
    [self.transparentGrayView removeFromSuperview];
    [self.congratulationsView removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) RewardsReceived :(NSNotification *)notification {
    scoreLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.score]];
}

- (IBAction)LifePressed:(id)sender {
    [appDelegate ShowTimerView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    livesLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.Lives]];
    scoreLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.score]];
  
    if([[SimpleKeychain load:@"isAppRated"] isEqualToString:@"1"]) {
        
        
        l1.textColor = [UIColor whiteColor];
        l2.textColor = [UIColor whiteColor];
        l3.textColor = [UIColor whiteColor];
        l1.textAlignment = NSTextAlignmentCenter;
        l2.textAlignment = NSTextAlignmentCenter;
        l3.textAlignment = NSTextAlignmentCenter;
        
        [SimpleKeychain save:@"isAppRated" data:@"2"];
        l1.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
        l1.text = @"لقد ربحت";
        l2.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
        l2.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"+%d", 100]];
        l3.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
        l3.text = @"فرصة";
        
        appDelegate.score = appDelegate.score + 100;
        
        [SimpleKeychain save:@"Score" data:[Cryptography TripleDES:[[NSString alloc] initWithFormat:@"%d", appDelegate.score] algo:kCCEncrypt key:@"Sfg$93@B"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RewardsReceived" object:nil];
        
        [self.view addSubview:self.transparentGrayView];
        [self.view addSubview:self.congratulationsView];
        rateB.enabled = NO;
    }
}

- (IBAction) Home:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction) gotopolicy:(id)sender {
    SafariViewController *instance = [[[SafariViewController alloc] init] autorelease];
    instance.path = @"https://policy-portal.truste.com/core/privacy-policy/Eurisko-Mobility/112679d7-d95a-47b8-9ca6-ada02dec025f";
    [self.navigationController pushViewController:instance animated:YES];
}

- (IBAction) gotoabout:(id)sender {
    AboutViewController *instance = [[[AboutViewController alloc] init] autorelease];
    [self.navigationController pushViewController:instance animated:YES];
}

- (IBAction)GetCoins:(id)sender {
    if(appDelegate.SoundEnabled)
        [self.coinsAudioPlayer play];
    GetCoinsViewController *instance = [[GetCoinsViewController alloc] init];
    [self.navigationController pushViewController:instance animated:YES];
    [instance release];
}

- (IBAction) Scoreboard:(id)sender {
    FacebookFriendsViewController *instance = [[FacebookFriendsViewController alloc] init];
    [self.navigationController pushViewController:instance animated:YES];
    [instance release];
}

#pragma mark -
#pragma mark invite methods

- (IBAction) invite:(id)sender {
    NSString *phoneDate = [Utils dateTransform:[Utils getUTCFormateDate:[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss" ToFormat:@"yyyy-MM-dd"];
    
    if(![phoneDate isEqualToString:appDelegate.serverDate] && (appDelegate.serverDate != NULL || [appDelegate.serverDate length] != 0)) {
//        [AlertMessage Display_wrong_date_error_message_WithLanguage:@"Ar"];
        [AlertMessage Display_internet_error_message_WithLanguage:@"Ar"];
        return ;
    }
    
    if ([[FBSession activeSession]isOpen]) {
        /*
         * if the current session has no publish permission we need to reauthorize
         */
        if ([[[FBSession activeSession]permissions]indexOfObject:@"email"] == NSNotFound) {
            
            [[FBSession activeSession] requestNewPublishPermissions:[NSArray arrayWithObject:@"email"] defaultAudience:FBSessionDefaultAudienceFriends
                                                  completionHandler:^(FBSession *session,NSError *error){
                                                      [self invite:sender];
                                                  }];
            return ;
        }
    }else{
        /*
         * open a new session with publish permission
         */
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"email"]
                                           defaultAudience:FBSessionDefaultAudienceOnlyMe
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             if (!error && status == FBSessionStateOpen) {
                                                 [self invite:sender];
                                             }else{
                                                 NSLog(@"error %@", error.localizedDescription);
                                                 [appDelegate.loading removeFromSuperview];
                                             }
                                         }];
        return ;
    }
    
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:appDelegate.sharetext
                                                    title:@"أربع صور"
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if(error)
                                                      {
                                                          NSLog(@"Some errorr: %@", [error description]);
                                                          UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"فشل في إرسال الدعوة" message:@" تعذر إرسال الدعوة في هذه اللحظة، من فضلك تأكد من اتصالك بالإنترنت" delegate:nil cancelButtonTitle:@"موافق" otherButtonTitles: nil];
                                                          [alrt show];
                                                          [alrt release];
                                                      }
                                                      else
                                                      {
                                                          if (![resultURL query])
                                                          {
                                                              return;
                                                          }
                                                          
                                                          NSDictionary *params = [self parseURLParams:[resultURL query]];
                                                          NSMutableArray *recipientIDs = [[[NSMutableArray alloc] init] autorelease];
                                                          for (NSString *paramKey in params)
                                                          {
                                                              if ([paramKey hasPrefix:@"to["])
                                                              {
                                                                  [recipientIDs addObject:[params objectForKey:paramKey]];
                                                              }
                                                          }
                                                          if ([params objectForKey:@"request"])
                                                          {
                                                              NSLog(@"Request ID: %@", [params objectForKey:@"request"]);
                                                          }
                                                          if ([recipientIDs count] > 0)
                                                          {
                                                              //[self updateScore];
                                                          }
                                                          
                                                      }
                                                  }];
    
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

- (void) updateScore {
    
    NSString *phoneDate = [Utils dateTransform:[Utils getUTCFormateDate:[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss" ToFormat:@"yyyy-MM-dd"];
    
    [SimpleKeychain save:@"inviteDate" data:phoneDate];
    inviteB.enabled = NO;
    
    
    l1.textColor = [UIColor whiteColor];
    l2.textColor = [UIColor whiteColor];
    l3.textColor = [UIColor whiteColor];
    
    l1.textAlignment = NSTextAlignmentCenter;
    l2.textAlignment = NSTextAlignmentCenter;
    l3.textAlignment = NSTextAlignmentCenter;
    
    l1.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
    l1.text = @"لقد ربحت";
    l2.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
    l2.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"+%d", 200]];
    l3.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
    l3.text = @"فرصة";
    
    appDelegate.score = appDelegate.score + 200;
        
    [SimpleKeychain save:@"Score" data:[Cryptography TripleDES:[[NSString alloc] initWithFormat:@"%d", appDelegate.score] algo:kCCEncrypt key:@"Sfg$93@B"]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RewardsReceived" object:nil];
    
    [self.view addSubview:self.transparentGrayView];
    [self.view addSubview:self.congratulationsView];
}

#pragma mark -
#pragma mark share methods

- (IBAction) share:(id)sender {
    NSString *phoneDate = [Utils dateTransform:[Utils getUTCFormateDate:[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss" ToFormat:@"yyyy-MM-dd"];
    
    if(![phoneDate isEqualToString:appDelegate.serverDate]  && (appDelegate.serverDate != NULL || [appDelegate.serverDate length] != 0)) {
//        [AlertMessage Display_wrong_date_error_message_WithLanguage:@"Ar"];
        [AlertMessage Display_internet_error_message_WithLanguage:@"Ar"];
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
                                                 NSLog(@"error %@", error.localizedDescription);
                                                 [appDelegate.loading removeFromSuperview];
                                             }
                                         }];
    }
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    
    NSLog(@"state %lu", state);
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
                                                      NSLog(@"error %@", error.localizedDescription);
                                                  }
                                              }];
    } else {
        action();
    }
    
}

- (void)postOnWall
{
    [self.view addSubview:appDelegate.loading];
    [self performPublishAction:^{
        NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           appDelegate.sharetext, @"name",
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
                     [appDelegate.loading removeFromSuperview];
                 }
                 
                 if (result == FBWebDialogResultDialogCompleted) {
                     NSString *phoneDate = [Utils dateTransform:[Utils getUTCFormateDate:[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss" ToFormat:@"yyyy-MM-dd"];
                     
                     [SimpleKeychain save:@"shareDate" data:phoneDate];
                     shareB.enabled = NO;
                     
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
                     
                     appDelegate.Lives = appDelegate.Lives + 1;
                     [SimpleKeychain save:@"Lives" data:[Cryptography TripleDES:[[NSString alloc] initWithFormat:@"%d", appDelegate.Lives] algo:kCCEncrypt key:@"Sfg$93@B"]];
                     [appDelegate.livesCycle setLife:appDelegate.Lives IsDateCorrect:YES];
                     
                     [self.view addSubview:self.transparentGrayView];
                     [self.view addSubview:self.congratulationsView];
                 }
             }
             [appDelegate.loading removeFromSuperview];
             
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
    [appDelegate.loading removeFromSuperview];
    
}


#pragma mark -
#pragma mark iRate methods

- (IBAction) rate:(id)sender {
    NSString *phoneDate = [Utils dateTransform:[Utils getUTCFormateDate:[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss" ToFormat:@"yyyy-MM-dd"];
    
    if(![phoneDate isEqualToString:appDelegate.serverDate]  && (appDelegate.serverDate != NULL || [appDelegate.serverDate length] != 0)) {
//        [AlertMessage Display_wrong_date_error_message_WithLanguage:@"Ar"];
        [AlertMessage Display_internet_error_message_WithLanguage:@"Ar"];
        return ;
    }
    //perform manual check
	[[iRate sharedInstance] promptIfNetworkAvailable];
    //[[iRate sharedInstance] promptForRating];
    NSLog(@"ratedAnyVersion %d", [[iRate sharedInstance] ratedAnyVersion]);
	NSLog(@"Connecting to App Store...");
    [SimpleKeychain save:@"isAppRated" data:@"1"];
	//[progressIndicator startAnimation:self];
}

- (void)iRateCouldNotConnectToAppStore:(NSError *)error
{
	NSLog(@"%@",[error localizedDescription]);
	//[progressIndicator stopAnimation:self];
}

- (BOOL)iRateShouldPromptForRating
{
	//don't show prompt, just open app store
	[[iRate sharedInstance] openRatingsPageInAppStore];
	NSLog(@"Connected.");
	//[progressIndicator stopAnimation:self];
	return NO;
}

@end
