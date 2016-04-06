//
//  LevelViewController.m
//  What's the movie
//
//  Created by eurisko on 4/4/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "LevelViewController.h"
#import "AppDelegate.h"
#import "MovieViewController.h"
#import "GetCoinsViewController.h"
#import "FacebookFriendsViewController.h"
#import "SafariViewController.h"
#import "AboutViewController.h"
#import "LevelDetailsViewController.h"
#import "FacebookShareViewController.h"

@interface LevelViewController ()
@property (nonatomic, retain) AVAudioPlayer* coinsAudioPlayer;

@end

@implementation LevelViewController
@synthesize webData;
@synthesize NotEnoughLifeView;
@synthesize categoryCompleteView, username, categoryName, firstname;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.screenName = @"iPhone - Levels";
    }
    return self;
}

- (IBAction) Home:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)dispatch {
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"UI"
                                            action:@"ViewAppear"
                                             label:[[NSString alloc] initWithFormat:@"iPhone - Levels %d", appDelegate.userLevel]
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    ShoudReload = 0;
    
    AVAudioPlayer *coinsAudioPlayerTemp = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"coins-tap" ofType:@"wav"]] error:nil];
    self.coinsAudioPlayer = coinsAudioPlayerTemp;
    [coinsAudioPlayerTemp release];
    self.coinsAudioPlayer.delegate=self;
    [self.coinsAudioPlayer prepareToPlay];
    self.coinsAudioPlayer.numberOfLoops = 1;
    
    
    livesLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:22];
    scoreLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:22];
    
    self.transparentGrayView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.transparentGrayView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    self.congratulationsView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2- 40);
    self.categoryCompleteView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2- 40);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelComplete:) name:@"LevelCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLives:) name:@"setLives" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RewardsReceived:) name:@"RewardsReceived" object:nil];

    easyView.frame = CGRectMake(-320,0,320,73);
    mediumView.frame = CGRectMake(-320,72,320,55);
    smartView.frame = CGRectMake(-320,127,320,55);
    masterView.frame = CGRectMake(-320,182,320,55);
    geniusView.frame = CGRectMake(-320,237,320,55);
    geniusPlusView.frame = CGRectMake(-320,292,320,74);
    
    if(appDelegate.window.frame.size.height != 480){
        scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y + 50, scrollView.frame.size.width, scrollView.frame.size.height);
    }
    
    for(UIView *subview in [scrollView subviews]) {
        [subview removeFromSuperview];
    }
    
    [self performSelector:@selector(animateScroll) withObject:nil afterDelay:1];
}

- (IBAction)LifePressed:(id)sender {
    [appDelegate ShowTimerView];
}

- (void) setLives :(NSNotification *)notification {
    livesLabel.text = [[NSString alloc] initWithFormat:@"%d", appDelegate.livesCycle.lives];
}

- (void) RewardsReceived :(NSNotification *)notification {
    scoreLabel.text = [[NSString alloc] initWithFormat:@"%d", appDelegate.score];
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

- (void) levelComplete:(NSNotification*)notification{
    
    appDelegate.nextLevelQuestionArray = [DATABASE_HELPER read_questions_for_level:appDelegate.userLevel + 1];
    
    if([appDelegate.nextLevelQuestionArray count] == 0){
        [self get_question_for_next_level];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    
    [self dispatch];
    livesLabel.text = [[NSString alloc] initWithFormat:@"%d", appDelegate.Lives];
    scoreLabel.text = [[NSString alloc] initWithFormat:@"%d", appDelegate.score];
    [self performSelector:@selector(display_Levels) withObject:nil afterDelay:0.0];
    
    
    if(appDelegate.userLevel == 5 && ![[NSUserDefaults standardUserDefaults] objectForKey:@"easyCategoryComplete"]){
        self.categoryName = @"easy";
        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"easyCategoryComplete"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        categoryImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"easypopup" ofType:@"png"]];
        [self.view addSubview:self.transparentGrayView];
        [self.view addSubview:self.categoryCompleteView];
    }
    else
        if(appDelegate.userLevel == 9 && ![[NSUserDefaults standardUserDefaults] objectForKey:@"mediumCategoryComplete"]){
            self.categoryName = @"medium";
            [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"mediumCategoryComplete"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            categoryImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mediumpopup" ofType:@"png"]];
            [self.view addSubview:self.transparentGrayView];
            [self.view addSubview:self.categoryCompleteView];
        }
    else
        if(appDelegate.userLevel == 13 && ![[NSUserDefaults standardUserDefaults] objectForKey:@"smartCategoryComplete"]){
            self.categoryName = @"smart";
            [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"smartCategoryComplete"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            categoryImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"smartpopup" ofType:@"png"]];
            [self.view addSubview:self.transparentGrayView];
            [self.view addSubview:self.categoryCompleteView];
        }
    else
        if(appDelegate.userLevel == 17 && ![[NSUserDefaults standardUserDefaults] objectForKey:@"masterCategoryComplete"]){
            self.categoryName = @"master";
            [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"masterCategoryComplete"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            categoryImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"masterpopup" ofType:@"png"]];
            [self.view addSubview:self.transparentGrayView];
            [self.view addSubview:self.categoryCompleteView];
        }
    else
        if(appDelegate.userLevel == 21 && ![[NSUserDefaults standardUserDefaults] objectForKey:@"geniusCategoryComplete"]){
            self.categoryName = @"genius";
            [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"geniusCategoryComplete"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            categoryImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"geniuspopup" ofType:@"png"]];
            [self.view addSubview:self.transparentGrayView];
            [self.view addSubview:self.categoryCompleteView];
        }
    else
        if(appDelegate.userLevel == 25 && ![[NSUserDefaults standardUserDefaults] objectForKey:@"geniusplusCategoryComplete"]){
            self.categoryName = @"genius plus";
            [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"geniusplusCategoryComplete"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            categoryImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"geniuspluspopup" ofType:@"png"]];
            [self.view addSubview:self.transparentGrayView];
            [self.view addSubview:self.categoryCompleteView];
        }

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

- (void) display_Levels {
    
    if(appDelegate.userLevel >= 1){
        [b1 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level1" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 2) {
        [b2 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level2" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 3) {
        [b3 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level3" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 4) {
        [b4 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level4" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 5){
        [b5 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level1" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 6) {
        [b6 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level2" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 7) {
        [b7 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level3" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 8) {
        [b8 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level4" ofType:@"png"]] forState:UIControlStateNormal];
    }
    
    if(appDelegate.userLevel >= 9){
        [b9 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level1" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 10) {
        [b10 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level2" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 11) {
        [b11 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level3" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 12) {
        [b12 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level4" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 13){
        [b13 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level1" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 14) {
        [b14 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level2" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 15) {
        [b15 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level3" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 16) {
        [b16 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level4" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 17){
        [b17 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level1" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 18) {
        [b18 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level2" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 19) {
        [b19 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level3" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 20) {
        [b20 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level4" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 21){
        [b21 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level1" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 22) {
        [b22 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level2" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 23) {
        [b23 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level3" ofType:@"png"]] forState:UIControlStateNormal];
    }
    if(appDelegate.userLevel >= 24) {
        [b24 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level4" ofType:@"png"]] forState:UIControlStateNormal];
    }
    
    
    if(appDelegate.userLevel == 1){
        [b1 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level1highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 2) {
        [b2 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level2highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 3) {
        [b3 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level3highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 4) {
        [b4 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level4highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 5){
        [b5 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level1highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 6) {
        [b6 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level2highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 7) {
        [b7 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level3highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 8) {
        [b8 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level4highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 9){
        [b9 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level1highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 10) {
        [b10 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level2highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 11 ) {
        [b11 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level3highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 12) {
        [b12 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level4highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 13){
        [b13 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level1highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 14) {
        [b14 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level2highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 15) {
        [b15 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level3highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 16) {
        [b16 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level4highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 17){
        [b17 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level1highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 18) {
        [b18 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level2highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 19) {
        [b19 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level3highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 20) {
        [b20 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level4highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 21){
        [b21 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level1highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 22) {
        [b22 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level2highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 23) {
        [b23 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level3highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }else if(appDelegate.userLevel == 24) {
        [b24 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level4highlited" ofType:@"png"]] forState:UIControlStateNormal];
    }
}

- (void) animateScroll {
    //animate in within some method called when loading starts
    [scrollView addSubview:easyView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         easyView.frame = CGRectMake(0,0,320,73);
                     }
                     completion:^(BOOL finished){
                         [scrollView addSubview:mediumView];
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              mediumView.frame = CGRectMake(0,72,320,55);
                                          }
                                          completion:^(BOOL finished){
                                              [scrollView addSubview:smartView];
                                              [UIView animateWithDuration:0.3
                                                               animations:^{
                                                                   smartView.frame = CGRectMake(0,128,320,55);
                                                               }
                                                               completion:^(BOOL finished){
                                                                   [scrollView addSubview:masterView];
                                                                   [UIView animateWithDuration:0.3
                                                                                    animations:^{
                                                                                        masterView.frame = CGRectMake(0,183,320,55);
                                                                                    }
                                                                                    completion:^(BOOL finished){
                                                                                        [scrollView addSubview:geniusView];
                                                                                        [UIView animateWithDuration:0.3
                                                                                                         animations:^{
                                                                                                             geniusView.frame = CGRectMake(0,238,320,55);
                                                                                                         }
                                                                                                         completion:^(BOOL finished){
                                                                                                             [scrollView addSubview:geniusPlusView];
                                                                                                             [UIView animateWithDuration:0.3
                                                                                                                              animations:^{
                                                                                                                                  geniusPlusView.frame = CGRectMake(0,293,320,74);
                                                                                                                              }
                                                                                                                              completion:^(BOOL finished){
                                                                                                                                  
                                                                                                                              }];
                                                                                                         }];
                                                                                    }];
                                                               }];
                                          }];
                     }];
    
    scrollView.contentSize=CGSizeMake(320, 366);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) OpenLevelAfterReload :(NSNotification *)notification {
    
}

- (IBAction)selectALevel:(id)sender {
    
    if([sender tag] < appDelegate.userLevel){
        if(appDelegate.Lives == 0){
            [self.transparentGrayView removeFromSuperview];
            [self.NotEnoughLifeView removeFromSuperview];
            [appDelegate ShowTimerView];
            return ;
        }
        appDelegate.currentLevelQuestionArray = [DATABASE_HELPER read_questions_for_level:(int)[sender tag]];

        if ([appDelegate.currentLevelQuestionArray count] != 0){
            [self CheckAdForLevel:(int)[sender tag]];
            LevelDetailsViewController *instance = [[LevelDetailsViewController alloc] init];
            instance.QArray = appDelegate.currentLevelQuestionArray;
            instance.ShouldAddPoints = NO;
            instance.selectedLevel = (int)[sender tag];
            [self.navigationController pushViewController:instance animated:YES];
            [instance release];
        }
        
    }else if([sender tag] == appDelegate.userLevel) {
        if(appDelegate.Lives == 0){
            [self.transparentGrayView removeFromSuperview];
            [self.NotEnoughLifeView removeFromSuperview];
            [appDelegate ShowTimerView];
            return ;
        }
        appDelegate.currentLevelQuestionArray = [DATABASE_HELPER read_questions_for_level:appDelegate.userLevel];
        
        if ([appDelegate.currentLevelQuestionArray count] == 10){
            [self CheckAdForLevel:appDelegate.userLevel];
            LevelDetailsViewController *instance = [[LevelDetailsViewController alloc] init];
            instance.QArray = appDelegate.currentLevelQuestionArray;
            instance.ShouldAddPoints = YES;
            instance.selectedLevel = appDelegate.userLevel;
            [self.navigationController pushViewController:instance animated:YES];
            [instance release];
        }else {
            if(appDelegate.userLevel < 13){
                
                int level = [DATABASE_HELPER reload_questions_for_level:(int)[sender tag]];
                appDelegate.currentLevelQuestionArray = [DATABASE_HELPER read_questions_for_level:level];

                if ([appDelegate.currentLevelQuestionArray count] != 0){
                    [self CheckAdForLevel:appDelegate.userLevel];
                    LevelDetailsViewController *instance = [[LevelDetailsViewController alloc] init];
                    instance.QArray = appDelegate.currentLevelQuestionArray;
                    instance.ShouldAddPoints = YES;
                    instance.selectedLevel = appDelegate.userLevel;
                    [self.navigationController pushViewController:instance animated:YES];
                    [instance release];
                }
            }else {
                if ([appDelegate.internetActive isEqualToString:@"down"])
                {
                    [AlertMessage Display_internet_error_message_WithLanguage:@"En"];
                    return ;
                }
                [self.view addSubview:appDelegate.loading];
                [self get_question_for_current_level];
            }
        }
        
    }else if([sender tag] > appDelegate.userLevel) {
        levelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"locked" ofType:@"png"]];
        
        [self.view addSubview:self.transparentGrayView];
        [self.view addSubview:self.congratulationsView];
    }
}

- (void) CheckAdForLevel : (int) level {
    
    if(level == 1)
        return;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:[[NSString alloc] initWithFormat:@"AdForLevel%d", level]])
        return;
    
    AdRequestViewController *adRequest = [[AdRequestViewController alloc] init];
    [adRequest CallAd];
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:[[NSString alloc] initWithFormat:@"AdForLevel%d", level]];
}

- (IBAction) Dismiss:(id)sender {
    [self.transparentGrayView removeFromSuperview];
    [self.congratulationsView removeFromSuperview];
}

- (IBAction) CancelNotEnoughLives:(id)sender {
    [self.transparentGrayView removeFromSuperview];
    [self.NotEnoughLifeView removeFromSuperview];
}

- (IBAction) PurchaseLives:(id)sender {
    [self.transparentGrayView removeFromSuperview];
    [self.NotEnoughLifeView removeFromSuperview];
    [appDelegate ShowTimerView];
}

- (IBAction) OKCategoryComplete:(id)sender {
    [self.transparentGrayView removeFromSuperview];
    [self.categoryCompleteView removeFromSuperview];
}



- (IBAction) ShareCategoryComplete:(id)sender {
    [self.transparentGrayView removeFromSuperview];
    [self.categoryCompleteView removeFromSuperview];
    if(![SimpleKeychain load:@"facebookName"])
        [self getMe];
    else {
        self.username = [SimpleKeychain load:@"facebookName"];
        self.firstname = [SimpleKeychain load:@"facebookFirstname"];
        [self share];

    }

}

#pragma mark -
#pragma mark facebook login & share Functions


-(IBAction) ShareButtonPressed:(id)sender
{
    if([appDelegate.hostActive isEqualToString:@"down"])
    {
        [AlertMessage Display_internet_error_message_WithLanguage:@"En"];
        return ;
    }
    FacebookShareViewController *fbShareView = [[FacebookShareViewController alloc] init];
    [self.navigationController pushViewController:fbShareView animated:YES];
}


#pragma mark -
#pragma mark category completed lifecycle

- (void) getMe {
    [self.view addSubview:appDelegate.loading];
    
    NSArray *permissions =
    [NSArray arrayWithObjects:@"email", nil];
    
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      /* handle success + failure in block */
                                      if(!error){
                                          NSLog(@"Session started");
                                          [self me];
                                      } else
                                          NSLog(@"Session ended With error %@", error.localizedDescription);
                                  }];
}

- (void)me{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 [SimpleKeychain save:@"facebookID" data:[user objectForKey:@"id"]];
                 [SimpleKeychain save:@"facebookName" data:[[NSString alloc] initWithFormat:@"%@ %@", user.first_name, user.last_name]];
                 [SimpleKeychain save:@"facebookFirstname" data:user.first_name];
                 self.username = [SimpleKeychain load:@"facebookName"];
                 self.firstname = [SimpleKeychain load:@"facebookFirstname"];
                 [self share];
             }else {
                 [appDelegate.loading removeFromSuperview];
                 [AlertMessage Display_Facebook_error_message_WithLanguage:@"En"];
             }
         }];
    }
    
}

#pragma mark -
#pragma mark share methods

- (void) share {
    
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

- (void)postOnWall
{
    [self.view addSubview:appDelegate.loading];
    NSString *LevelText = @"";
        
    if(appDelegate.userLevel == 5)
        LevelText = [[NSString alloc] initWithFormat:@"%@ is playing 4 pics 1 Number. \n%@ just completed the easy level and unlocked the medium level", self.username, self.firstname];
    else
        if(appDelegate.userLevel == 9)
            LevelText = [[NSString alloc] initWithFormat:@"%@ is playing 4pics 1 Number. \n%@ just completed the medium level and unlocked the smart level", self.username, self.firstname];
        else
            if(appDelegate.userLevel == 13)
                LevelText = [[NSString alloc] initWithFormat:@"%@ is playing 4pics 1 Number. \nThat was smart!!! %@ just completed the smart level and unlocked the master level", self.username, self.firstname];
            else
                if(appDelegate.userLevel == 17)
                    LevelText = [[NSString alloc] initWithFormat:@"%@ is playing 4pics 1 Number. \nWowww %@ just completed the master level and unlocked the genius level", self.username, self.firstname];
                else
                    if(appDelegate.userLevel == 21)
                        LevelText = [[NSString alloc] initWithFormat:@"%@ is playing 4pics 1 Number. \nOutstanding %@ just completed the genius level and unlocked the genius plus level", self.username, self.firstname];
                    else
                        if(appDelegate.userLevel == 25)
                            LevelText = [[NSString alloc] initWithFormat:@"%@ is playing 4pics 1 Number. \n%@ just completed the game", self.username, self.firstname];
    
    
    [self performPublishAction:^{
        NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           LevelText, @"name",
                                           @"http://www.euriskomobility.me/share/fourpicsen.php", @"caption",
                                           @"", @"description",
                                           @"http://www.euriskomobility.me/share/fourpicsen.php", @"link",
                                           @"https://www.euriskomobility.me/fourpicsonenumber/icon.png", @"picture",
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
        alertTitle = @"Error";
    } else {
        
        alertMsg = [NSString stringWithFormat:@"Successfully posted."];
        alertTitle = @"Success";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [appDelegate.loading removeFromSuperview];
    
}


#pragma mark -
#pragma mark get question for current level Functions

- (void) get_question_for_current_level {
    
    if([appDelegate.hostActive isEqualToString:@"down"])
    {
        return ;
    }
    
    if(appDelegate.userLevel <= NumberOfLevels){
        linkNumber = 2;
        
        NSString *post = [[NSString alloc] initWithFormat:@"secret=5GhzqyJnaQuiVbzb9oPlk1QavbN6YfazBdH6tEaNbp0gDg5EqvCh5aLp67FbdAz5HfaYtcdB7YihNg&platformId=1&levelId=%d&rand=%f", appDelegate.userLevel,[NSDate timeIntervalSinceReferenceDate]];
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength =  [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[postData length]];
        NSString *path= [[NSString alloc] initWithFormat:@"%@getQuestionsByLevel.php", appDelegate.hostName];
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
    }else {
        ShoudReload = 1;
    }
    
}

- (void) parse_question_XMLData:(NSString *)XmlString {
    
    @try {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        appDelegate.currentLevelQuestionArray = tempArray;
        [tempArray release];
        
        CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString:XmlString options:0 error:nil] autorelease];
        NSArray *nodes = NULL;
        nodes = [doc nodesForXPath:@"//question" error:nil];
        
        for (CXMLElement *node in nodes) {
            
            NSMutableDictionary *category = [[NSMutableDictionary alloc] init];
            
            for(int counter = 0; counter < [node childCount]; counter++)
            {
                if([[node childAtIndex:counter] stringValue] != NULL){
                    @try {
                        [category setObject:[[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[[node childAtIndex:counter] stringValue]] encoding:NSUTF8StringEncoding] forKey:[[node childAtIndex:counter] name]];
                    }
                    @catch (NSException *exception) {
                        
                    }
                    [category setObject:[[node childAtIndex:counter] stringValue] forKey:[[NSString alloc] initWithFormat:@"%@encrypted", [[node childAtIndex:counter] name]]];
                }
            }
            
            TABLE_QUESTIONS *object = [[TABLE_QUESTIONS alloc] initWithId:[[category objectForKey:@"id"] intValue] QLevelId:[[NSString alloc] initWithFormat:@"%d", appDelegate.userLevel] QAnswer:[category objectForKey:@"answerencrypted"] QHint:[category objectForKey:@"hintencrypted"] QCategory:[category objectForKey:@"categoryencrypted"] IsHintShown:0 IsCharactersRemoved:0 IsAnswered:0];
            
            [appDelegate.currentLevelQuestionArray addObject:object];
            [category release];
        }
    
        [DATABASE_HELPER store_questions:appDelegate.currentLevelQuestionArray];
        
        appDelegate.currentLevelQuestionArray = [DATABASE_HELPER read_questions_for_level:appDelegate.userLevel];
        
        appDelegate.questionlevelid = appDelegate.userLevel + 1;
        
        [SimpleKeychain save:@"questionlevelidEn" data:[[NSString alloc] initWithFormat:@"%d", appDelegate.questionlevelid]];
        
        [appDelegate.loading removeFromSuperview];
        
        if ([appDelegate.currentLevelQuestionArray count] != 0){
            [self CheckAdForLevel:appDelegate.userLevel];
            [self get_question_for_next_level];
            LevelDetailsViewController *instance = [[LevelDetailsViewController alloc] init];
            instance.QArray = appDelegate.currentLevelQuestionArray;
            instance.ShouldAddPoints = YES;
            instance.selectedLevel = appDelegate.userLevel;
            [self.navigationController pushViewController:instance animated:YES];
            [instance release];
        }else {
            [AlertMessage Display_empty_level_error_message_WithLanguage:@"En"];
        }
       
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception.debugDescription);
    }
    
}


#pragma mark -
#pragma mark get question for next level Functions

- (void) get_question_for_next_level {
    
    if (appDelegate.questionlevelid < 13) {
        NSLog(@"appDelegate.questionlevelid in get_question_for_next_level %d", appDelegate.questionlevelid);
        return;
    }
    
    if([appDelegate.hostActive isEqualToString:@"down"])
    {
        return ;
    }
    
    if(appDelegate.questionlevelid <= NumberOfLevels){
        linkNumber = 1;
        NSString *post = [[NSString alloc] initWithFormat:@"secret=5GhzqyJnaQuiVbzb9oPlk1QavbN6YfazBdH6tEaNbp0gDg5EqvCh5aLp67FbdAz5HfaYtcdB7YihNg&platformId=1&levelId=%d&rand=%f", appDelegate.questionlevelid,[NSDate timeIntervalSinceReferenceDate]];
        
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength =  [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[postData length]];
        NSString *path= [[NSString alloc] initWithFormat:@"%@getQuestionsByLevel.php", appDelegate.hostName];
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
    }else {
        ShoudReload = 1;
    }
    
}

- (void) parse_next_question_XMLData:(NSString *)XmlString {
    
    @try {
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        appDelegate.nextLevelQuestionArray = tempArray;
        [tempArray release];
        
        CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString:XmlString options:0 error:nil] autorelease];
        NSArray *nodes = NULL;
        nodes = [doc nodesForXPath:@"//question" error:nil];
        
        for (CXMLElement *node in nodes) {
            
            NSMutableDictionary *category = [[NSMutableDictionary alloc] init];
            
            for(int counter = 0; counter < [node childCount]; counter++)
            {
                if([[node childAtIndex:counter] stringValue] != NULL){
                    @try {
                        [category setObject:[[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[[node childAtIndex:counter] stringValue]] encoding:NSUTF8StringEncoding] forKey:[[node childAtIndex:counter] name]];
                    }
                    @catch (NSException *exception) {
                        
                    }
                    [category setObject:[[node childAtIndex:counter] stringValue] forKey:[[NSString alloc] initWithFormat:@"%@encrypted", [[node childAtIndex:counter] name]]];
                }
            }
            
            TABLE_QUESTIONS *object = [[TABLE_QUESTIONS alloc] initWithId:[[category objectForKey:@"id"] intValue] QLevelId:[[NSString alloc] initWithFormat:@"%d", appDelegate.questionlevelid] QAnswer:[category objectForKey:@"answerencrypted"] QHint:[category objectForKey:@"hintencrypted"] QCategory:[category objectForKey:@"categoryencrypted"] IsHintShown:0 IsCharactersRemoved:0 IsAnswered:0];

            [appDelegate.nextLevelQuestionArray addObject:object];
            [category release];
        }
        
        [DATABASE_HELPER store_questions:appDelegate.nextLevelQuestionArray];
        
        appDelegate.nextLevelQuestionArray = [DATABASE_HELPER read_questions_for_level:appDelegate.questionlevelid];
        
        appDelegate.questionlevelid = appDelegate.questionlevelid + 1;
        [SimpleKeychain save:@"questionlevelidEn" data:[[NSString alloc] initWithFormat:@"%d", appDelegate.questionlevelid]];
        
        ShoudReload = 1;
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
    NSLog(@"error %@", error.debugDescription);
    [appDelegate.loading removeFromSuperview];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{    
    NSString *XMLData = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSASCIIStringEncoding];
    if([XMLData length] != 0 && linkNumber ==1)
        [self parse_next_question_XMLData:XMLData];
    else  if([XMLData length] != 0 && linkNumber ==2)
        [self parse_question_XMLData:XMLData];
    
    [connection release];
    
}


@end
