//
//  LevelDetailsViewController.m
//  4Picture1Number
//
//  Created by eurisko on 6/4/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "LevelDetailsViewController.h"
#import "AppDelegate.h"
#import "MovieViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookFriendsViewController.h"
#import "GetCoinsViewController.h"

@interface LevelDetailsViewController ()

@end

@implementation LevelDetailsViewController
@synthesize levelId;
@synthesize QArray;
@synthesize transparentGrayView, congratulationsView, newLifeView;
@synthesize selectedLevel,ShouldAddPoints;
@synthesize NotEnoughLifeView;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CheckIfLevelCompleted:) name:@"CheckIfLevelCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLives:) name:@"setLives" object:nil];
    
    livesLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:22];
    scoreLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:22];
    
    ShouldGoBack = NO;
}

- (void) setLives :(NSNotification *)notification {
    livesLabel.text = [[NSString alloc] initWithFormat:@"%d", appDelegate.livesCycle.lives];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    livesLabel.text = [[NSString alloc] initWithFormat:@"%d", appDelegate.Lives];
    scoreLabel.text = [[NSString alloc] initWithFormat:@"%d", appDelegate.score];
    [[scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self display_Questions];
}

- (IBAction)GetCoins:(id)sender {

    GetCoinsViewController *instance = [[GetCoinsViewController alloc] init];
    [self.navigationController pushViewController:instance animated:YES];
    [instance release];
}

- (void) display_Questions {
    
    int x= 10.0;
    int y= 0.0;
    

    self.QArray = [DATABASE_HELPER read_questions_for_level:self.selectedLevel];
    AnsweredMoviesCount = 0;

    movie = [[TABLE_QUESTIONS alloc] init];
    
    for (int i=0; i<[self.QArray count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(x, y, 140.0, 70.0);
        
        [button addTarget:self action:@selector(gotoMovie:) forControlEvents:UIControlEventTouchDown];
        
        [scrollView addSubview: button];
        movie = [self.QArray objectAtIndex:i];
        
        if(movie.IsAnswered) {
            AnsweredMoviesCount ++;
            if(self.selectedLevel <=4){
                [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"L1OK" ofType:@"png"]] forState:UIControlStateNormal];
            }else if(self.selectedLevel <=8){
                [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"L2OK" ofType:@"png"]] forState:UIControlStateNormal];
            }else if(self.selectedLevel <=12){
                [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"L3OK" ofType:@"png"]] forState:UIControlStateNormal];
            }else if(self.selectedLevel <=16){
                [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"L4OK" ofType:@"png"]] forState:UIControlStateNormal];
            }else if(self.selectedLevel <=20){
                [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"L5OK" ofType:@"png"]] forState:UIControlStateNormal];
            }else if(self.selectedLevel <=24){
                [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"L6OK" ofType:@"png"]] forState:UIControlStateNormal];
            }
        }else {
            if(self.selectedLevel <=4){
                [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"L1NO" ofType:@"png"]] forState:UIControlStateNormal];
            }else if(self.selectedLevel <=8){
                [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"L2NO" ofType:@"png"]] forState:UIControlStateNormal];
            }else if(self.selectedLevel <=12){
                [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"L3NO" ofType:@"png"]] forState:UIControlStateNormal];
            }else if(self.selectedLevel <=16){
                [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"L4NO" ofType:@"png"]] forState:UIControlStateNormal];
            }else if(self.selectedLevel <=20){
                [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"L5NO" ofType:@"png"]] forState:UIControlStateNormal];
            }else if(self.selectedLevel <=24){
                [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"L6NO" ofType:@"png"]] forState:UIControlStateNormal];
            }
        }
        
        // instantaneously make the image view small (scaled to 1% of its actual size)
        button.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            button.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            // if you want to do something once the animation finishes, put it here
        }];

        if(x != 170.0 ){
            x += 160.0;
        }else {
            x = 10.0;
            y += 80.0;
        }
    }
    scrollView.contentSize=CGSizeMake(320, 80*([self.QArray count]/2));
}

- (IBAction) Scoreboard:(id)sender {
    FacebookFriendsViewController *instance = [[FacebookFriendsViewController alloc] init];
    [self.navigationController pushViewController:instance animated:YES];
    [instance release];
}

- (void) gotoMovie:(id)sender {
    if(appDelegate.Lives == 0){
        [appDelegate ShowTimerView];
        return ;
    }
    
    MovieViewController *instance;
    
    if(appDelegate.window.frame.size.height == 480)
        instance = [[MovieViewController alloc] initWithNibName:@"MovieViewiPhone4" bundle:nil];
    else
        instance = [[MovieViewController alloc] initWithNibName:@"MovieViewController" bundle:nil];
    
    if ([appDelegate.currentLevelQuestionArray count] != 0) {
        instance.selectedLevel = self.selectedLevel;
        instance.ShouldAddPoints = movie.IsAnswered;
        instance.selectedMovie = [sender tag];
        [self.navigationController pushViewController:instance animated:YES];
        [instance release];
    }
}

- (IBAction) Dismiss:(id)sender {
    [self.transparentGrayView removeFromSuperview];
    [self.congratulationsView removeFromSuperview];
    [self.newLifeView removeFromSuperview];
    if(ShouldGoBack){
        ShouldGoBack = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (void) CheckIfLevelCompleted:(NSNotification*)notification{
    
    self.QArray = [DATABASE_HELPER read_questions_for_level:self.selectedLevel];
    TABLE_QUESTIONS *movieTemp = [[TABLE_QUESTIONS alloc] init];

    AnsweredMoviesCount = 0;
    for (int i = 0; i < [self.QArray count]; i++) {
        movieTemp = [self.QArray objectAtIndex:i];
        if(movieTemp.IsAnswered)
            AnsweredMoviesCount ++;
    }
    
    [movieTemp release];
    
    if(AnsweredMoviesCount == [self.QArray count]) {
        LevelComplete = YES;
        if(self.selectedLevel == appDelegate.userLevel){
            appDelegate.userLevel ++;
            [SimpleKeychain save:@"levelEn" data:[[NSString alloc] initWithFormat:@"%d", appDelegate.userLevel]];
            if(NumberOfLevels + 1 == appDelegate.userLevel)
                [self allLevelComplete];
            else {
                [self levelComplete];
            }
        }else {
            if(NumberOfLevels + 1 == self.selectedLevel)
                [self allLevelComplete];
            else
                [self levelComplete];
        }
    }
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


- (IBAction) Home:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction) Back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)LifePressed:(id)sender {
    [appDelegate ShowTimerView];
}

- (void) levelComplete {
    
    l1.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:30];
    l1.text = @"A NEW LEVEL IS";
    l2.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:30];
    l2.text = @"UNLOCKED";
    
    l1.textColor = [UIColor colorWithRed:232.0/255.0 green:197.0/255.0 blue:127.0/255.0 alpha:1];
    l2.textColor = [UIColor colorWithRed:232.0/255.0 green:197.0/255.0 blue:127.0/255.0 alpha:1];
    l2.textAlignment = NSTextAlignmentCenter;
    l3.textAlignment = NSTextAlignmentCenter;
    
    facebookButton.hidden = YES;
    l3.text = @"";

    levelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category-complete-dialog" ofType:@"png"]];
    
    ShouldGoBack = YES;
    [self.view addSubview:self.transparentGrayView];
    [self.view addSubview:self.congratulationsView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LevelCompleted" object:self userInfo:nil];
}

- (void) categoryComplete {
    
    l1.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:30];
    l1.text = @"A NEW LEVEL IS";
    l2.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:30];
    l2.text = @"UNLOCKED";
    
    l1.textColor = [UIColor colorWithRed:232.0/255.0 green:197.0/255.0 blue:127.0/255.0 alpha:1];
    l2.textColor = [UIColor colorWithRed:232.0/255.0 green:197.0/255.0 blue:127.0/255.0 alpha:1];
    l2.textAlignment = NSTextAlignmentCenter;
    l3.textAlignment = NSTextAlignmentCenter;
        
    if(appDelegate.Lives < 5){
        NSString *phoneDate = [Utils dateTransform:[Utils getUTCFormateDate:[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss" ToFormat:@"yyyy-MM-dd"];
        if([phoneDate isEqualToString:[SimpleKeychain load:@"shareDateEn"]]) {
            //facebookButton.hidden = YES;
            l3.text = @"";
        }else {
            facebookButton.hidden = NO;
            l3.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
            l3.text = @"Share on Facebook: +1 ♥";
        }
    }else {
        l3.text = @"";
        //facebookButton.hidden = YES;
    }
    
    levelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category-complete-dialog" ofType:@"png"]];
    
    ShouldGoBack = YES;
    [self.view addSubview:self.transparentGrayView];
    [self.view addSubview:self.congratulationsView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LevelCompleted" object:self userInfo:nil];
}

- (void) allLevelComplete {
    ShouldGoBack = YES;
    [self.navigationController popViewControllerAnimated:YES];
}


@end
