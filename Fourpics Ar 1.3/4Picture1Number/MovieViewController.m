//
//  MovieViewController.m
//  What's the movie
//
//  Created by eurisko on 4/5/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "MovieViewController.h"
#import "AppDelegate.h"
#import "FacebookFriendsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "GetCoinsViewController.h"
#import <QuartzCore/QuartzCore.h>
#include <stdlib.h>
#import "InstructionViewController.h"
#import "UIViewController+KNSemiModal.h"

@interface MovieViewController ()
@property (nonatomic, retain) AVAudioPlayer* coinsAudioPlayer;
@property (nonatomic, retain) AVAudioPlayer* correctAudioPlayer;
@property (nonatomic, retain) AVAudioPlayer* letterAudioPlayer;
@property (nonatomic, retain) AVAudioPlayer* removeAudioPlayer;
@property (nonatomic, retain) AVAudioPlayer* wrongAudioPlayer;
@end

@implementation MovieViewController
@synthesize imageDownloadsInProgress, imagesArray, charactersArray;
@synthesize movieName, movieGuessName;
@synthesize scrollView, transparentGrayView, congratulationsView, buycoinsView, ConfirmBuyView, NotEnoughLifeView, WrongAnswerView;
@synthesize coinsAudioPlayer, correctAudioPlayer, letterAudioPlayer, removeAudioPlayer, wrongAudioPlayer;
@synthesize selectedLevel, selectedMovie, ShouldAddPoints;
@synthesize animationTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Take note that you need to take ownership of the ViewController that is being presented
        semiVC = [[InstructionViewController alloc] initWithNibName:@"InstructionViewController" bundle:nil];
        
        // You can optionally listen to notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(semiModalPresented:)
                                                     name:kSemiModalDidShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(semiModalDismissed:)
                                                     name:kSemiModalDidHideNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(semiModalResized:)
                                                     name:kSemiModalWasResizedNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Demo

- (IBAction)buttonDidTouch:(id)sender {
    [semiVC SetTextForCategory:movie.QCategory];
    // You can also present a UIViewController with complex views in it
    // and optionally containing an explicit dismiss button for semi modal
    [self presentSemiViewController:semiVC withOptions:@{
     KNSemiModalOptionKeys.pushParentBack    : @(YES),
     KNSemiModalOptionKeys.animationDuration : @(0.5),
     KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
	 }];
    [semiVC SetTextForCategory:movie.QCategory];

}

#pragma mark - Optional notifications

- (void) semiModalResized:(NSNotification *) notification {
    if(notification.object == self){
        //NSLog(@"The view controller presented was been resized");
    }
}

- (void)semiModalPresented:(NSNotification *) notification {
    if (notification.object == self) {
       // NSLog(@"This view controller just shown a view with semi modal annimation");
    }
}
- (void)semiModalDismissed:(NSNotification *) notification {
    if (notification.object == self) {
       // NSLog(@"A view controller was dismissed with semi modal annimation");
    }
}

-(void) dealloc {
    self.coinsAudioPlayer.delegate = nil;
    self.coinsAudioPlayer = nil;
    [coinsAudioPlayer release];
    
    self.correctAudioPlayer.delegate = nil;
    self.correctAudioPlayer = nil;
    [correctAudioPlayer release];
    
    self.letterAudioPlayer.delegate = nil;
    self.letterAudioPlayer = nil;
    [letterAudioPlayer release];
    
    self.removeAudioPlayer.delegate = nil;
    self.removeAudioPlayer = nil;
    [removeAudioPlayer release];
    
    self.wrongAudioPlayer.delegate = nil;
    self.wrongAudioPlayer = nil;
    [wrongAudioPlayer release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload_images:) name:@"ReloadImages" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLives:) name:@"setLives" object:nil];

    levelLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:18];
    scoreLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:22];
    livesLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:22];
    categoryLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:22];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.18f];
    levelLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
    [CATransaction commit];

    [CATransaction begin];
    [CATransaction setAnimationDuration:0.18f];
    categoryLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [CATransaction commit];

    imageLoader = [[NextImagesLoader alloc] init];
    appDelegate.currentLevelQuestionArray = [DATABASE_HELPER read_questions_for_level:self.selectedLevel];
    
//    if(appDelegate.window.frame.size.height == 480){
//        backImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"question-back-iphone" ofType:@"jpg"]];
//    }
    
    if(self.selectedLevel <=4){
        levelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"easy-vertical" ofType:@"png"]];
    }else if(self.selectedLevel <=8){
        levelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"medium-vertical" ofType:@"png"]];
    }else if(self.selectedLevel <=12){
        levelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"smart-vertical" ofType:@"png"]];
    }else if(self.selectedLevel <=16){
        levelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"outstanding-vertical" ofType:@"png"]];
    }else if(self.selectedLevel <=20){
        levelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"genius-vertical" ofType:@"png"]];
    }else if(self.selectedLevel <=24){
        levelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"geniusplus-vertical" ofType:@"png"]];
    }
    
    NumberOfPurchasedFeature = 0;
    
    hintLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:16];
    hintLabel.textColor = [UIColor blackColor];

    self.transparentGrayView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.transparentGrayView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    self.congratulationsView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2- 40);
    self.buycoinsView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2- 40);
    self.ConfirmBuyView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2- 40);
    self.NotEnoughLifeView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2- 40);
    self.WrongAnswerView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2- 40);

    disappear=0;
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
    self.imageDownloadsInProgress = tempDictionary;
    [tempDictionary release];
    
    currentMovie = self.selectedMovie;//[[SimpleKeychain load:@"movie"] intValue];
    [semiVC SetTextForCategory:movie.QCategory];
    
    movie = [[TABLE_QUESTIONS alloc] init];
    
    AVAudioPlayer *coinsAudioPlayerTemp = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"coins-tap" ofType:@"wav"]] error:nil];
    self.coinsAudioPlayer = coinsAudioPlayerTemp;
    [coinsAudioPlayerTemp release];
    self.coinsAudioPlayer.delegate=self;
    [self.coinsAudioPlayer prepareToPlay];
    
    AVAudioPlayer *correctAudioPlayerTemp = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"correct" ofType:@"wav"]] error:nil];
    self.correctAudioPlayer = correctAudioPlayerTemp;
    [correctAudioPlayerTemp release];
    self.correctAudioPlayer.delegate=self;
    [self.correctAudioPlayer prepareToPlay];
    
    AVAudioPlayer *letterAudioPlayerTemp = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"letter-tap" ofType:@"wav"]] error:nil];
    self.letterAudioPlayer = letterAudioPlayerTemp;
    [letterAudioPlayerTemp release];
    self.letterAudioPlayer.delegate=self;
    [self.letterAudioPlayer prepareToPlay];
    
    AVAudioPlayer *removeAudioPlayerTemp = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"remove-all" ofType:@"wav"]] error:nil];
    self.removeAudioPlayer = removeAudioPlayerTemp;
    [removeAudioPlayerTemp release];
    self.removeAudioPlayer.delegate=self;
    [self.removeAudioPlayer prepareToPlay];
    
    AVAudioPlayer *wrongAudioPlayerTemp = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"wrong" ofType:@"wav"]] error:nil];
    self.wrongAudioPlayer = wrongAudioPlayerTemp;
    [wrongAudioPlayerTemp release];
    self.wrongAudioPlayer.delegate=self;
    [self.wrongAudioPlayer prepareToPlay];
    
    [self FillView];
        
    if([self.animationTimer isValid])
    {	[self.animationTimer invalidate];
        self.animationTimer=nil;
    }
    self.animationTimer=[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(animateLevel) userInfo:nil repeats:YES];
}

- (void) animateLevel {

    categoryLabel.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(-M_PI_2), 0.002, 0.002);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
    categoryLabel.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(-M_PI_2), 1.2, 1.2);
    [UIView commitAnimations];
}

- (void)bounce1AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
    categoryLabel.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(-M_PI_2), 0.9, 0.9);
    [UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3/2];
    categoryLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [UIView commitAnimations];
}


- (void) setLives :(NSNotification *)notification {
    livesLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.livesCycle.lives]];
}

- (IBAction)LifePressed:(id)sender {
    [appDelegate ShowTimerView];
    if(appDelegate.Lives == 0)
        [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    livesLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.Lives]];
    levelLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"مرحلة %d", self.selectedLevel]];
    scoreLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.score]];
}

- (void) reload_images :(NSNotification *)notification {
    if([appDelegate.hostActive isEqualToString:@"down"])
    {
        return ;
    }
    
    NSArray *allDownloads = [imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    [imageDownloadsInProgress removeAllObjects];
    
    for (int i = 0; i < numberOfImages; i++) {
        if([[self.imagesArray objectAtIndex:i] objectForKey:@"Data"] == NULL){
            if(self.selectedLevel <= 12)
                ;
            else
                [self startIconDownload:[[NSString alloc] initWithFormat:@"%@/%@", appDelegate.imageURL, [[NSString alloc] initWithFormat:@"%@_%d.jpg", [[self.imagesArray objectAtIndex:i]  objectForKey:@"id"], i+1]] forTabNumber:1 arrayIndex:i];
        }
    }
}


- (void) FillView {
    
    answerLetterIndex = 0;
    @try {
        movie = [appDelegate.currentLevelQuestionArray objectAtIndex:currentMovie];
    }
    @catch (NSException *exception) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    imageLoader.numberOfImages = 4;
    
    self.movieGuessName = @"";
    
    [self.imageDownloadsInProgress removeAllObjects];
    
    NSMutableArray *charactersTempArray = [[NSMutableArray alloc] initWithCapacity:20];
    self.charactersArray = charactersTempArray;
    [charactersTempArray release];
    
    NSMutableArray *temparray = [[NSMutableArray alloc] init];
    self.imagesArray = [[NSMutableArray alloc] init];
    [temparray release];
    
    numberOfImages = 4;
   
    
    if(movie.IsHintShown == 1){
        hintLabel.text = movie.QHint;
        hintButton.hidden = YES;
    }else {
        hintButton.hidden = NO;
    }
    
    NSArray *allDownloads = [imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    [imageDownloadsInProgress removeAllObjects];
    
    
    for (int i = 0; i< numberOfImages; i++) {
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        [tempDictionary setValue:[[NSString alloc] initWithFormat:@"%d", movie.QId] forKey:@"id"];
        
        @try {
            if([[imageLoader.imagesArray objectAtIndex:i] objectForKey:@"Data"] != NULL)
                [tempDictionary setValue:[[imageLoader.imagesArray objectAtIndex:i] objectForKey:@"Data"] forKey:@"Data"];
        }
        @catch (NSException *exception) {
        }
        
        [self.imagesArray addObject:tempDictionary];
        [tempDictionary release];
    }
    
    nextMovie = currentMovie;
    [self downloadNextImages];
    
    self.movieName = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%@", [Utils CapitalWordOF:movie.QAnswer]]];

    categoryLabel.text = movie.QCategory;
    
    [self fill_images];
    [self fill_empty_characters];
    
    allNumbers = @"١٢٣٤٥٦٧٨٩:٠,";
    tempallNumbers = allNumbers;
    [self performSelector:@selector(fill_characters) withObject:nil afterDelay:0.5];
}

- (void) FillViewWithNewQuestion {
    
    answerLetterIndex = 0;
    movie = [appDelegate.currentLevelQuestionArray objectAtIndex:currentMovie];
    
    if(movie.IsAnswered)
    {
        currentMovie = currentMovie + 1;
       
        if(currentMovie < [appDelegate.currentLevelQuestionArray count])
            [self FillViewWithNewQuestion];
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CheckIfLevelCompleted" object:self userInfo:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        return;
    }
    
    imageLoader.numberOfImages = 4;
    
    self.movieGuessName = @"";
    
    [self.imageDownloadsInProgress removeAllObjects];
    
    NSMutableArray *charactersTempArray = [[NSMutableArray alloc] initWithCapacity:20];
    self.charactersArray = charactersTempArray;
    [charactersTempArray release];
    
    NSMutableArray *temparray = [[NSMutableArray alloc] init];
    self.imagesArray = [[NSMutableArray alloc] init];
    [temparray release];
    
    numberOfImages = 4;
    
    
    if(movie.IsHintShown == 1){
        hintLabel.text = movie.QHint;
        hintButton.hidden = YES;
    }else {
        hintButton.hidden = NO;
    }
    
    NSArray *allDownloads = [imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    [imageDownloadsInProgress removeAllObjects];
    
    
    for (int i = 0; i< numberOfImages; i++) {
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        [tempDictionary setValue:[[NSString alloc] initWithFormat:@"%d", movie.QId] forKey:@"id"];
        
        @try {
            if([[imageLoader.imagesArray objectAtIndex:i] objectForKey:@"Data"] != NULL)
                [tempDictionary setValue:[[imageLoader.imagesArray objectAtIndex:i] objectForKey:@"Data"] forKey:@"Data"];
        }
        @catch (NSException *exception) {
        }
        
        [self.imagesArray addObject:tempDictionary];
        [tempDictionary release];
    }
    
    nextMovie = currentMovie;
    [self downloadNextImages];
    
    self.movieName = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%@", [Utils CapitalWordOF:movie.QAnswer]]];

    categoryLabel.text = movie.QCategory;    
    [self fill_images];
    [self fill_empty_characters];
    
    allNumbers = @"١٢٣٤٥٦٧٨٩:٠,";
    tempallNumbers = allNumbers;
    [self performSelector:@selector(fill_characters) withObject:nil afterDelay:0.5];
}

- (void) downloadNextImages {
    if(self.selectedLevel <= 8)
        return;
    
    if(nextMovie < [appDelegate.currentLevelQuestionArray count] - 1){
        imageLoader.object = [appDelegate.currentLevelQuestionArray objectAtIndex:nextMovie+1];
        if(imageLoader.object.IsAnswered){
            nextMovie = nextMovie + 1;
            [self downloadNextImages];
            return ;
        }
        [imageLoader StartLoading];
    }
}


- (void) viewDidAppear:(BOOL)animated {
    [self reload_images:nil];
}

- (void) viewWillDisappear:(BOOL)animated{
    if(disappear!=1)
    {	NSArray *allDownloads = [imageDownloadsInProgress allValues];
        [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
        [imageDownloadsInProgress removeAllObjects];
        disappear=1;
    }
    //    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) Back:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CheckIfLevelCompleted" object:self userInfo:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) Scoreboard:(id)sender {
    FacebookFriendsViewController *instance = [[FacebookFriendsViewController alloc] init];
    [self.navigationController pushViewController:instance animated:YES];
    [instance release];
}

- (IBAction) PlayHint:(id)sender {
    if(appDelegate.SoundEnabled)
        [self.removeAudioPlayer play];
    NumberOfPurchasedFeature = 1;
    ConfirmBuyImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"show-hint-dialog" ofType:@"png"]];
    [self.view addSubview:self.transparentGrayView];
    [self.view addSubview:self.ConfirmBuyView];
}

- (IBAction) remove_characters:(id)sender {
    if(appDelegate.SoundEnabled)
        [self.removeAudioPlayer play];
    
    if(movie.IsCharactersRemoved == 1){
        [self Remove_All_Added_Characters];
        return;
    }
    if([tempallNumbers length] == 0){
        return;
    }
    NumberOfPurchasedFeature = 2;
    ConfirmBuyImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"remove-letters" ofType:@"png"]];
    [self.view addSubview:self.transparentGrayView];
    [self.view addSubview:self.ConfirmBuyView];
}

- (IBAction) More_images:(id)sender {
    if(appDelegate.SoundEnabled)
        [self.removeAudioPlayer play];
    NumberOfPurchasedFeature = 3;
    ConfirmBuyImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"more-pics" ofType:@"png"]];
    [self.view addSubview:self.transparentGrayView];
    [self.view addSubview:self.ConfirmBuyView];
}

- (IBAction) procceed_buy :(id)sender {
    [self.transparentGrayView removeFromSuperview];
    [self.ConfirmBuyView removeFromSuperview];
    
    if(NumberOfPurchasedFeature == 1){
        if(appDelegate.score - 205 < 0){
            [self.view addSubview:self.transparentGrayView];
            [self.view addSubview:self.buycoinsView];
            return;
        }
        appDelegate.score = appDelegate.score - 205;
        
        [SimpleKeychain save:@"Score" data:[Cryptography TripleDES:[[NSString alloc] initWithFormat:@"%d", appDelegate.score] algo:kCCEncrypt key:@"Sfg$93@B"]];
        scoreLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.score]];
        
        appDelegate.score = [[Cryptography TripleDES:[SimpleKeychain load:@"Score"] algo:kCCDecrypt key:@"Sfg$93@B"] intValue];
        
        hintLabel.text = movie.QHint;
        hintButton.hidden = YES;
        [DATABASE_HELPER set_hint_shown_for_question:movie];
    }else if(NumberOfPurchasedFeature == 2){
        
        if(appDelegate.score - 100 < 0){
            [self.view addSubview:self.transparentGrayView];
            [self.view addSubview:self.buycoinsView];
            return;
        }
        
        appDelegate.score = appDelegate.score - 100;
        
        [SimpleKeychain save:@"Score" data:[Cryptography TripleDES:[[NSString alloc] initWithFormat:@"%d", appDelegate.score] algo:kCCEncrypt key:@"Sfg$93@B"]];
        scoreLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.score]];
        
        appDelegate.score = [[Cryptography TripleDES:[SimpleKeychain load:@"Score"] algo:kCCDecrypt key:@"Sfg$93@B"] intValue];
        
        [self Remove_All_Added_Characters];
        
        [DATABASE_HELPER set_characters_removed_for_question:movie];
        
    }else if(NumberOfPurchasedFeature == 3){
        if(appDelegate.score - 49 < 0){
            [self.view addSubview:self.transparentGrayView];
            [self.view addSubview:self.buycoinsView];
            return;
        }
        appDelegate.score = appDelegate.score - 49;
        
        [SimpleKeychain save:@"Score" data:[Cryptography TripleDES:[[NSString alloc] initWithFormat:@"%d", appDelegate.score] algo:kCCEncrypt key:@"Sfg$93@B"]];
        scoreLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.score]];
        
        appDelegate.score = [[Cryptography TripleDES:[SimpleKeychain load:@"Score"] algo:kCCDecrypt key:@"Sfg$93@B"] intValue];
        
        moreButton.hidden = YES;
        [DATABASE_HELPER set_images_shown_for_question:movie];
        [[scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        if(numberOfImages == 2){
            numberOfImages = 4;
            for (int i = 2; i< numberOfImages; i++) {
                NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
                [tempDictionary setValue:[[NSString alloc] initWithFormat:@"%d", movie.QId] forKey:@"id"];
                [self.imagesArray addObject:tempDictionary];
                [tempDictionary release];
            }
            
            [self fill_images];
        }
    }
    NumberOfPurchasedFeature = 0;
}

- (void) Remove_All_Added_Characters {

    letterb1.hidden = YES;
    letterb2.hidden = YES;
    letterb3.hidden = YES;
    letterb4.hidden = YES;
    letterb5.hidden = YES;
    letterb6.hidden = YES;
    letterb7.hidden = YES;
    letterb8.hidden = YES;
    letterb9.hidden = YES;
    letterb10.hidden = YES;
    letterb11.hidden = YES;
    letterb12.hidden = YES;

    for (int i = 0; i< [tempallNumbers length]; i++) {
        
        for (int j = 0; j < [movieName length]; j++) {

            if([[[NSString alloc] initWithFormat:@"%C", [tempallNumbers characterAtIndex: i]] isEqualToString:[[NSString alloc] initWithFormat:@"%C", [movieName characterAtIndex: j]]])
            {
                if ([[[NSString alloc] initWithFormat:@"%C", [tempallNumbers characterAtIndex: i]] isEqualToString:letterb1.titleLabel.text]) {
                    letterb1.hidden = NO;
                    break ;
                }else if ([[[NSString alloc] initWithFormat:@"%C", [tempallNumbers characterAtIndex: i]] isEqualToString:letterb2.titleLabel.text]) {
                    letterb2.hidden = NO;
                    break ;
                }else if ([[[NSString alloc] initWithFormat:@"%C", [tempallNumbers characterAtIndex: i]] isEqualToString:letterb3.titleLabel.text]){
                    letterb3.hidden = NO;
                    break ;
                }else if ([[[NSString alloc] initWithFormat:@"%C", [tempallNumbers characterAtIndex: i]] isEqualToString:letterb4.titleLabel.text]){
                    letterb4.hidden = NO;
                    break ;
                }else if ([[[NSString alloc] initWithFormat:@"%C", [tempallNumbers characterAtIndex: i]] isEqualToString:letterb5.titleLabel.text]){
                    letterb5.hidden = NO;
                    break ;
                }else if ([[[NSString alloc] initWithFormat:@"%C", [tempallNumbers characterAtIndex: i]] isEqualToString:letterb6.titleLabel.text]){
                    letterb6.hidden = NO;
                    break ;
                }else if ([[[NSString alloc] initWithFormat:@"%C", [tempallNumbers characterAtIndex: i]] isEqualToString:letterb7.titleLabel.text]){
                    letterb7.hidden = NO;
                    break ;
                }else if ([[[NSString alloc] initWithFormat:@"%C", [tempallNumbers characterAtIndex: i]] isEqualToString:letterb8.titleLabel.text]){
                    letterb8.hidden = NO;
                    break ;
                }else if ([[[NSString alloc] initWithFormat:@"%C", [tempallNumbers characterAtIndex: i]] isEqualToString:letterb9.titleLabel.text]){
                    letterb9.hidden = NO;
                    break ;
                }else if ([[[NSString alloc] initWithFormat:@"%C", [tempallNumbers characterAtIndex: i]] isEqualToString:letterb10.titleLabel.text]){
                    letterb10.hidden = NO;
                    break ;
                }else if ([[[NSString alloc] initWithFormat:@"%C", [tempallNumbers characterAtIndex: i]] isEqualToString:letterb11.titleLabel.text]){
                    letterb11.hidden = NO;
                    break ;
                }else if ([[[NSString alloc] initWithFormat:@"%C", [tempallNumbers characterAtIndex: i]] isEqualToString:letterb12.titleLabel.text]){
                    letterb12.hidden = NO;
                    break ;
                }
            }
        }
    }
    tempallNumbers = @"";
}

- (IBAction) cancel_buy :(id)sender {
    NumberOfPurchasedFeature = 0;
    [self.transparentGrayView removeFromSuperview];
    [self.ConfirmBuyView removeFromSuperview];
}

#pragma mark -
#pragma mark movie Lifecyle

- (void) fill_images {
    
    CGRect frame;
    for (int i = 0; i < numberOfImages; i++) {
        if(appDelegate.window.frame.size.height == 480) {
            if(i==1)
                frame = CGRectMake(22, 2, 115, 115);
            else if(i==0)
                frame = CGRectMake(139, 2, 115, 115);
            else if(i==3)
                frame = CGRectMake(22, 119, 115, 115);
            else if(i==2)
                frame = CGRectMake(139, 119, 115, 115);
        }else {
            if(i==1)
                frame = CGRectMake(0, 0, 120, 120);
            else if(i==0)
                frame = CGRectMake(130, 0, 120, 120);
            else if(i==3)
                frame = CGRectMake(0, 130, 120, 120);
            else if(i==2)
                frame = CGRectMake(130, 130, 120, 120);
        }

        
        UIButton *subview = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        subview.tag = i;
        ;
        subview.frame = frame;
        [subview addTarget:self action:@selector(show_image_full_screen:) forControlEvents:UIControlEventTouchDown];
        
        [scrollView addSubview:subview];
        
        
        //Create and add the Activity Indicator to splashView
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.color = [UIColor greenColor];
        activityIndicator.alpha = 1.0;
        if(appDelegate.window.frame.size.height == 480)
            activityIndicator.center = CGPointMake(57, 58);
        else
            activityIndicator.center = CGPointMake(60, 60);
        
        activityIndicator.hidesWhenStopped = YES;
        activityIndicator.tag = i;
        [subview addSubview:activityIndicator];
        [activityIndicator startAnimating];
        [activityIndicator release];
        
        if([[self.imagesArray objectAtIndex:i] objectForKey:@"Data"] != NULL){
            [subview setBackgroundImage:[UIImage imageWithData:[[self.imagesArray objectAtIndex:i]  objectForKey:@"Data"]] forState:UIControlStateNormal];
            [activityIndicator removeFromSuperview];
        }else {
            if(self.selectedLevel <= 12)
            {
                [subview setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[[NSString alloc] initWithFormat:@"%@_%d", [[self.imagesArray objectAtIndex:i]  objectForKey:@"id"], i+1] ofType:@"jpg"]] forState:UIControlStateNormal];
                [activityIndicator removeFromSuperview];
            }
            else
                [self startIconDownload:[[NSString alloc] initWithFormat:@"%@/%@", appDelegate.imageURL, [[NSString alloc] initWithFormat:@"%@_%d.jpg", [[self.imagesArray objectAtIndex:i]  objectForKey:@"id"], i+1]] forTabNumber:1 arrayIndex:i];
        }
        
    }
    
    if(appDelegate.window.frame.size.height == 480)
        scrollView.contentSize = CGSizeMake(220, 220);
    else
        scrollView.contentSize = CGSizeMake(250, 260);
}

- (void) show_image_full_screen : (id) sender {
    
    [fullImageButton setAlpha:1.0];
    
    if(self.selectedLevel <= 12)
        [fullImageButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[[NSString alloc] initWithFormat:@"%d_%ld", movie.QId,[sender tag]+1] ofType:@"jpg"]] forState:UIControlStateNormal];
    else
        if([[self.imagesArray objectAtIndex:[sender tag]] objectForKey:@"Data"] != NULL)
            [fullImageButton setBackgroundImage:[UIImage imageWithData:[[self.imagesArray objectAtIndex:[sender tag]]  objectForKey:@"Data"]] forState:UIControlStateNormal];
    
  
    fullImageButton.center = CGPointMake(self.view.bounds.size.width/2, (self.view.bounds.size.height-113)/2);
    [self.view addSubview: fullImageButton];
    
    CABasicAnimation *theAnimation1;
    theAnimation1=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    theAnimation1.duration=0.5;
    theAnimation1.fromValue=[NSNumber numberWithFloat:0.2];
    theAnimation1.toValue=[NSNumber numberWithFloat:1.0];
    [fullImageButton.layer addAnimation:theAnimation1 forKey:@"animateLayer"];
}

-(IBAction)hide:(id)sender
{
    CABasicAnimation *theAnimation1;
    theAnimation1=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    theAnimation1.duration=0.5;
    theAnimation1.fromValue=[NSNumber numberWithFloat:1.0];
    theAnimation1.toValue=[NSNumber numberWithFloat:0.2];
    [fullImageButton.layer addAnimation:theAnimation1 forKey:@"animateLayer"];
    
    [self performSelector:@selector(finishAnimation) withObject:fullImageButton afterDelay:0.4];
    
}

- (void) finishAnimation{
    [fullImageButton setAlpha:0.0];
}

- (void) fill_empty_characters {
    
    int x;    
    if ([movieName length] == 1) {
        x = 134.0;
    }
    else if ([movieName length] == 2) {
        x = 113.0;
    }
    else if([movieName length] == 3) {
        x = 90.0;
    }else if([movieName length] == 4) {
        x = 68.0;
    }else if([movieName length] == 5) {
        x = 45.0;
    }else if([movieName length] == 6) {
        x = 23.0;
    }else if([movieName length] == 7) {
        x = 0.0;
    }
    
    for (int i=0; i<[movieName length] ; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x, 0.0, 45.0, 45.0);
        [button setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"empty-number" ofType:@"png"]] forState:UIControlStateNormal];
        button.titleLabel.textColor = [UIColor colorWithRed:221.0/255.0 green:219/255.0 blue:204/255.0 alpha:1];
        [button.titleLabel setFont:[UIFont fontWithName:@"TodaySHOP-Bold" size:30]];
        [button setTitleColor:[UIColor colorWithRed:221.0/255.0 green:219/255.0 blue:204/255.0 alpha:1] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(DeleteCharacter:) forControlEvents:UIControlEventTouchDown];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(8.0f, 0.0f, 0.0f, 0.0f)];
        
        [emptyBoxView addSubview:button];
        
        button.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            button.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
        }];
        x += 45.0;
    }
    
   
}


- (void) fill_characters {
    
    [letterb1 setTitle:@"١" forState:UIControlStateNormal];
    [letterb2 setTitle:@"٢" forState:UIControlStateNormal];
    [letterb3 setTitle:@"٣" forState:UIControlStateNormal];
    [letterb4 setTitle:@"٤" forState:UIControlStateNormal];
    [letterb5 setTitle:@"٥" forState:UIControlStateNormal];
    [letterb6 setTitle:@"٦" forState:UIControlStateNormal];
    [letterb7 setTitle:@"٧" forState:UIControlStateNormal];
    [letterb8 setTitle:@"٨" forState:UIControlStateNormal];
    [letterb9 setTitle:@"٩" forState:UIControlStateNormal];
    [letterb10 setTitle:@":" forState:UIControlStateNormal];
    [letterb11 setTitle:@"," forState:UIControlStateNormal];
    [letterb12 setTitle:@"٠" forState:UIControlStateNormal];

    letterb1.hidden = NO;
    // instantaneously make the image view small (scaled to 1% of its actual size)
    letterb1.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        letterb1.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        letterb2.hidden = NO;
        // instantaneously make the image view small (scaled to 1% of its actual size)
        letterb2.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            letterb2.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            letterb3.hidden = NO;
            // instantaneously make the image view small (scaled to 1% of its actual size)
            letterb3.transform = CGAffineTransformMakeScale(0.01, 0.01);
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                // animate it to the identity transform (100% scale)
                letterb3.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished){
                letterb4.hidden = NO;
                // instantaneously make the image view small (scaled to 1% of its actual size)
                letterb4.transform = CGAffineTransformMakeScale(0.01, 0.01);
                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    // animate it to the identity transform (100% scale)
                    letterb4.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished){
                    letterb5.hidden = NO;
                    // instantaneously make the image view small (scaled to 1% of its actual size)
                    letterb5.transform = CGAffineTransformMakeScale(0.01, 0.01);
                    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        // animate it to the identity transform (100% scale)
                        letterb5.transform = CGAffineTransformIdentity;
                    } completion:^(BOOL finished){
                        letterb6.hidden = NO;
                        // instantaneously make the image view small (scaled to 1% of its actual size)
                        letterb6.transform = CGAffineTransformMakeScale(0.01, 0.01);
                        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            // animate it to the identity transform (100% scale)
                            letterb6.transform = CGAffineTransformIdentity;
                        } completion:^(BOOL finished){
                            letterb7.hidden = NO;
                            // instantaneously make the image view small (scaled to 1% of its actual size)
                            letterb7.transform = CGAffineTransformMakeScale(0.01, 0.01);
                            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                // animate it to the identity transform (100% scale)
                                letterb7.transform = CGAffineTransformIdentity;
                            } completion:^(BOOL finished){
                                letterb8.hidden = NO;
                                // instantaneously make the image view small (scaled to 1% of its actual size)
                                letterb8.transform = CGAffineTransformMakeScale(0.01, 0.01);
                                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                    // animate it to the identity transform (100% scale)
                                    letterb8.transform = CGAffineTransformIdentity;
                                } completion:^(BOOL finished){
                                    letterb9.hidden = NO;
                                    // instantaneously make the image view small (scaled to 1% of its actual size)
                                    letterb9.transform = CGAffineTransformMakeScale(0.01, 0.01);
                                    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                        // animate it to the identity transform (100% scale)
                                        letterb9.transform = CGAffineTransformIdentity;
                                    } completion:^(BOOL finished){
                                        letterb10.hidden = NO;
                                        // instantaneously make the image view small (scaled to 1% of its actual size)
                                        letterb10.transform = CGAffineTransformMakeScale(0.01, 0.01);
                                        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                            // animate it to the identity transform (100% scale)
                                            letterb10.transform = CGAffineTransformIdentity;
                                        } completion:^(BOOL finished){
                                            letterb11.hidden = NO;
                                            // instantaneously make the image view small (scaled to 1% of its actual size)
                                            letterb11.transform = CGAffineTransformMakeScale(0.01, 0.01);
                                            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                                // animate it to the identity transform (100% scale)
                                                letterb11.transform = CGAffineTransformIdentity;
                                            } completion:^(BOOL finished){
                                                letterb12.hidden = NO;
                                                // instantaneously make the image view small (scaled to 1% of its actual size)
                                                letterb12.transform = CGAffineTransformMakeScale(0.01, 0.01);
                                                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                                    // animate it to the identity transform (100% scale)
                                                    letterb12.transform = CGAffineTransformIdentity;
                                                } completion:^(BOOL finished){
                                                    
                                                }];
                                            }];
                                        }];
                                    }];
                                }];
                            }];
                        }];
                    }];
                }];
            }];
        }];
    }];
    
}

- (IBAction)Letter_selected:(id)sender {
    if(appDelegate.SoundEnabled)
        [self.letterAudioPlayer play];
    
    if([movieName length] > answerLetterIndex) {
        UIButton *button = (UIButton*)sender;
    
        for (int i= 0; i< [movieName length]; i++){
            
            if([[[emptyBoxView subviews] objectAtIndex:i] isKindOfClass:[UIButton class]]){
                UIButton *b = (UIButton*)[[emptyBoxView subviews] objectAtIndex:i];
                if([b.titleLabel.text length] == 0 || b.titleLabel.text == NULL || [b.titleLabel.text isEqualToString:@" "]){
                    [(UIButton*)[[emptyBoxView subviews] objectAtIndex:i] setTitle:button.titleLabel.text forState:UIControlStateNormal];
                    [(UIButton*)[[emptyBoxView subviews] objectAtIndex:i] setTag:[sender tag]];
                    break;
                }
            }
        }
        answerLetterIndex ++;
        
        if([movieName length] == answerLetterIndex) {
            self.movieGuessName = @"";
            for (int i= 0; i< [movieName length]; i++){
                if([[[emptyBoxView subviews] objectAtIndex:i] isKindOfClass:[UIButton class]]){
                    UIButton *b = (UIButton*)[[emptyBoxView subviews] objectAtIndex:i];
                    self.movieGuessName = [self.movieGuessName stringByAppendingString:b.titleLabel.text];
                }
            }
            
            if([self.movieGuessName isEqualToString:self.movieName]){
                if(appDelegate.SoundEnabled)
                    [self.correctAudioPlayer play];
                
                if(!movie.IsAnswered){
                    appDelegate.score = appDelegate.score + 5;
                    
                    [SimpleKeychain save:@"Score" data:[Cryptography TripleDES:[[NSString alloc] initWithFormat:@"%d", appDelegate.score] algo:kCCEncrypt key:@"Sfg$93@B"]];
                    
                    appDelegate.score = [[Cryptography TripleDES:[SimpleKeychain load:@"Score"] algo:kCCDecrypt key:@"Sfg$93@B"] intValue];
                    
                    
                    l2.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:60];
                    l2.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d +", 5]];
                    l3.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
                    l3.text = @"نقاط";
                    
                    l1.textColor = [UIColor whiteColor];
                    l2.textColor = [UIColor colorWithRed:232.0/255.0 green:197.0/255.0 blue:127.0/255.0 alpha:1];
                    l3.textColor = [UIColor colorWithRed:214.0/255.0 green:118.0/255.0 blue:87.0/255.0 alpha:1];
                    l1.textAlignment = NSTextAlignmentCenter;
                    l2.textAlignment = NSTextAlignmentCenter;
                    l3.textAlignment = NSTextAlignmentCenter;
                    
                    scoreLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.score]];
                    [self.view addSubview:self.transparentGrayView];
                    [self.view addSubview:self.congratulationsView];
                    [DATABASE_HELPER set_question_answered:movie];
                    
                }else {
                    
                    l1.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
                    l1.text = @"";
                    l2.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
                    l2.text = @"تمت الإجابة مسبقاً";
                    l3.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
                    l3.text = @"";
                    
                    l1.textColor = [UIColor whiteColor];
                    l2.textColor = [UIColor whiteColor];
                    l3.textColor = [UIColor whiteColor];
                    l1.textAlignment = NSTextAlignmentCenter;
                    l2.textAlignment = NSTextAlignmentCenter;
                    l3.textAlignment = NSTextAlignmentCenter;
                    
                    [self.view addSubview:self.transparentGrayView];
                    [self.view addSubview:self.congratulationsView];
                    
                }
               
            }else {
                if(appDelegate.SoundEnabled)
                    [self.wrongAudioPlayer play];
                
                appDelegate.Lives = appDelegate.Lives - 1;
                [SimpleKeychain save:@"Lives" data:[Cryptography TripleDES:[[NSString alloc] initWithFormat:@"%d", appDelegate.Lives] algo:kCCEncrypt key:@"Sfg$93@B"]];
                
                NSString *phoneDate = [Utils dateTransform:[Utils getUTCFormateDate:[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss" ToFormat:@"yyyy-MM-dd"];
                
                if([appDelegate.hostActive isEqualToString:@"down"] || appDelegate.serverDate == NULL || [appDelegate.serverDate length] == 0)
                {
                    [appDelegate.livesCycle setLife:appDelegate.Lives IsDateCorrect:NO];
                }else {
                    if([phoneDate isEqualToString:appDelegate.serverDate]) {
                        [appDelegate.livesCycle setLife:appDelegate.Lives IsDateCorrect:YES];
                        
                    }else {
                        [appDelegate.livesCycle setLife:appDelegate.Lives IsDateCorrect:NO];
                    }
                }
                
                if(appDelegate.Lives == 0){
                    [self.transparentGrayView removeFromSuperview];
                    [self.NotEnoughLifeView removeFromSuperview];
                    [appDelegate ShowTimerView];
                    if(appDelegate.Lives == 0){
                        [self.navigationController popViewControllerAnimated:YES];
                        [appDelegate ShowTimerView];
                    }
                }else if (![[NSUserDefaults standardUserDefaults] objectForKey:@"NeverShowWrongAnswer"]) {
                    
                    [self.view addSubview:self.transparentGrayView];
                    [self.view addSubview:self.WrongAnswerView];
                }else {
                     [self DeleteAll:nil];
                }
               
            }
        }
    }
}

- (IBAction)CancelWrongAnswer:(id)sender {
    [self.transparentGrayView removeFromSuperview];
    [self.WrongAnswerView removeFromSuperview];
    [self DeleteAll:nil];
    if(appDelegate.Lives == 0)
        [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction) NeverShowAgain:(id)sender {
    [self.transparentGrayView removeFromSuperview];
    [self.WrongAnswerView removeFromSuperview];
    [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"NeverShowWrongAnswer"];
     [self DeleteAll:nil];
    if(appDelegate.Lives == 0)
        [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)CanccelNotEnoughLives:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.transparentGrayView removeFromSuperview];
    [self.NotEnoughLifeView removeFromSuperview];
}

- (IBAction) PurchaseLives:(id)sender {
    [self.transparentGrayView removeFromSuperview];
    [self.NotEnoughLifeView removeFromSuperview];
    [appDelegate ShowTimerView];
    if(appDelegate.Lives == 0)
        [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) DeleteCharacter :(UIButton*)sender{
    if([sender.titleLabel.text isEqualToString:@" "] || [sender.titleLabel.text isEqualToString:@""])
        return;
    if([sender.titleLabel.text length] != 0){
        [sender setTitle:@" " forState:UIControlStateNormal];
        if(answerLetterIndex == 0)
            return;        
        answerLetterIndex --;
    }
}

- (IBAction) DeleteAll:(id)sender{
    // reload view with same data
    answerLetterIndex = 0;
    
    [[emptyBoxView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.transparentGrayView removeFromSuperview];
    [self.congratulationsView removeFromSuperview];

    letterb1.hidden = YES;
    letterb2.hidden = YES;
    letterb3.hidden = YES;
    letterb4.hidden = YES;
    letterb5.hidden = YES;
    letterb6.hidden = YES;
    letterb7.hidden = YES;
    letterb8.hidden = YES;
    letterb9.hidden = YES;
    letterb10.hidden = YES;
    letterb11.hidden = YES;
    letterb12.hidden = YES;

    tempallNumbers = allNumbers;
    self.movieName = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%@", [Utils CapitalWordOF:movieName]]];
    [self fill_empty_characters];
    self.movieName = [Utils EnglishNumberToArabic:[[[NSString alloc] initWithFormat:@"%@", [Utils CapitalWordOF:movieName]] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    [self performSelector:@selector(fill_characters) withObject:nil afterDelay:0.5];
}

- (IBAction) procceed:(id)sender {
    // reload view with new data
    
    hintLabel.text = @"";
    [[scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[emptyBoxView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.transparentGrayView removeFromSuperview];
    [self.congratulationsView removeFromSuperview];
    
    letterb1.hidden = YES;
    letterb2.hidden = YES;
    letterb3.hidden = YES;
    letterb4.hidden = YES;
    letterb5.hidden = YES;
    letterb6.hidden = YES;
    letterb7.hidden = YES;
    letterb8.hidden = YES;
    letterb9.hidden = YES;
    letterb10.hidden = YES;
    letterb11.hidden = YES;
    letterb12.hidden = YES;

    currentMovie ++;
    if(currentMovie < [appDelegate.currentLevelQuestionArray count]){
        [self FillViewWithNewQuestion];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CheckIfLevelCompleted" object:self userInfo:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)GetCoins:(id)sender {
    if(appDelegate.SoundEnabled)
        [self.coinsAudioPlayer play];
    GetCoinsViewController *instance = [[GetCoinsViewController alloc] init];
    [self.navigationController pushViewController:instance animated:YES];
    [instance release];
    
    [self.transparentGrayView removeFromSuperview];
    [self.buycoinsView removeFromSuperview];
}

- (IBAction)CancelCoins:(id)sender {
    
    [self.transparentGrayView removeFromSuperview];
    [self.buycoinsView removeFromSuperview];
}

#pragma mark -
#pragma mark Lazy Image Loading

- (void)startIconDownload:(NSString *)imPath forTabNumber:(int) tabIndex arrayIndex : (int) arrayIndex
{
    iconDownloader = [imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d%d", tabIndex, arrayIndex]];
    if (iconDownloader == nil)
	{	iconDownloader = [[TabIconDownloader alloc] init];
        iconDownloader.path = imPath;
        iconDownloader.tabIndex = tabIndex;
        iconDownloader.index = arrayIndex;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:[NSString stringWithFormat:@"%d%d", tabIndex, arrayIndex]];
        [iconDownloader startDownload];
        [iconDownloader release];
    }
}


- (void)appImageDidLoad:(int)tabNumber data:(NSData *)d arrayIndex : (int) i {
    if(tabNumber == 1){
        NSString *a=[[NSString alloc] initWithBytes:[d bytes] length:[d length] encoding:NSUTF8StringEncoding];
        if(a!=nil || [a length]!=0)
            return;
        [[self.imagesArray objectAtIndex:i] setObject:d forKey:@"Data"];
        
        
        @try {
            if([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[UIButton class]])
                [[[scrollView subviews] objectAtIndex:i] setBackgroundImage:[UIImage imageWithData:d] forState:UIControlStateNormal];
        }
        @catch (NSException *exception) {
            NSLog(@"1 --------------->>>>> exception %@", exception.debugDescription);
        }
        
        for (int j = 0 ; j < [[[[scrollView subviews] objectAtIndex:i] subviews] count]; j++)
        {
            @try {
                if([[[[[scrollView subviews] objectAtIndex:i] subviews] objectAtIndex: j] isKindOfClass:[UIActivityIndicatorView class]])
                    [[[[[scrollView subviews] objectAtIndex:i] subviews] objectAtIndex:j] removeFromSuperview];
            }
            @catch (NSException *exception) {
                NSLog(@"2 --------------->>>>> exception %@", exception.debugDescription);
            }
            
        }
    }
}



@end
