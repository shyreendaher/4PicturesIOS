//
//  RootViewController.m
//  What's the movie
//
//  Created by eurisko on 3/26/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"
#import "LevelViewController.h"
#import "GetCoinsViewController.h"
#import "AboutViewController.h"

@interface RootViewController ()<FBLoginViewDelegate>
@property (nonatomic, retain) AVAudioPlayer* coinsAudioPlayer;
@property (nonatomic, retain) AVAudioPlayer* letterAudioPlayer;

@end

@implementation RootViewController
@synthesize webData;
@synthesize coinsAudioPlayer;
@synthesize letterAudioPlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.screenName = @"iPhone - home page";
    }
    return self;
}

- (void)dispatch {
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"UI"
                                            action:@"ViewAppear"
                                             label:@"iPhone - home page"
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
    
    AVAudioPlayer *letterAudioPlayerTemp = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"letter-tap" ofType:@"wav"]] error:nil];
    self.letterAudioPlayer = letterAudioPlayerTemp;
    [letterAudioPlayerTemp release];
    self.letterAudioPlayer.delegate=self;
    [self.letterAudioPlayer prepareToPlay];
    
    levelLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:22];
    scoreLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:22];
    LifeLabel.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:22];

    if(appDelegate.SoundEnabled == NO){
        [soundButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sound-off" ofType:@"png"]] forState:UIControlStateNormal];
    }
    else{
        [soundButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sound-on" ofType:@"png"]] forState:UIControlStateNormal];
    }

    appDelegate.currentLevelQuestionArray = [DATABASE_HELPER read_questions_for_level:appDelegate.userLevel];
    if([appDelegate.currentLevelQuestionArray count] != 0){
        playButton.enabled = YES;
    }
    
}

- (void) addObservers {
    
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callQuestionLink:) name:@"HostNameFound" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLives:) name:@"setLives" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RewardsReceived:) name:@"RewardsReceived" object:nil];
}

- (void) RewardsReceived :(NSNotification *)notification {
    scoreLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.score]];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self dispatch];

    levelLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"مرحلة %d", appDelegate.userLevel]];
    scoreLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.score]];
    LifeLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.Lives]];

    if(ShoudReload == 1)
        if([appDelegate.hostName length] != 0)
            [self callQuestionLink:nil];
    
    if(appDelegate.userLevel <=4){
        levelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"easy" ofType:@"png"]];
    }else if(appDelegate.userLevel <=8){
        levelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"medium" ofType:@"png"]];
    }else if(appDelegate.userLevel <=12){
        levelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"smart" ofType:@"png"]];
    }else if(appDelegate.userLevel <=16){
        levelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"outstanding" ofType:@"png"]];
    }else if(appDelegate.userLevel <=20){
        levelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"genius" ofType:@"png"]];
    }else if(appDelegate.userLevel <=24){
        levelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"geniusplus" ofType:@"png"]];
    }
    
}

- (void) setLives :(NSNotification *)notification {
    LifeLabel.text = [Utils EnglishNumberToArabic:[[NSString alloc] initWithFormat:@"%d", appDelegate.livesCycle.lives]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)LifePressed:(id)sender {
    [appDelegate ShowTimerView];
}

- (IBAction)sound_on_or_off:(id)sender {
    if(appDelegate.SoundEnabled == NO) {
        appDelegate.SoundEnabled = YES;
        [self.letterAudioPlayer play];
        [soundButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sound-on" ofType:@"png"]] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"SoundEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [soundButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sound-off" ofType:@"png"]] forState:UIControlStateNormal];
        appDelegate.SoundEnabled = NO;
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"SoundEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)GetCoins:(id)sender {
    if(appDelegate.SoundEnabled)
        [self.coinsAudioPlayer play];
    GetCoinsViewController *instance = [[GetCoinsViewController alloc] init];
    [self.navigationController pushViewController:instance animated:YES];
    [instance release];
}

- (IBAction)Play:(id)sender {
    LevelViewController *instance = [[LevelViewController alloc] init];
    [self.navigationController pushViewController:instance animated:YES];
    [instance release];
}

#pragma mark -
#pragma mark get Question Function

- (void) callQuestionLink :(NSNotification *)notification {
    
    ShoudReload = 0;
    
    if([appDelegate.hostActive isEqualToString:@"down"])
    {
        [AlertMessage Display_internet_error_message_WithLanguage:@"Ar"];
        return ;
    }
    
    @try {
        
        if(appDelegate.questionlevelid == 0)
            appDelegate.questionlevelid = 1;
        
        if(appDelegate.questionlevelid == 1)
            [self get_question_for_current_level];
        else {
            appDelegate.currentLevelQuestionArray = [DATABASE_HELPER read_questions_for_level:appDelegate.userLevel];
            if([appDelegate.currentLevelQuestionArray count] != 0)
            {
                playButton.enabled = YES;
                [self get_question_for_next_level];
            }else {
                [self get_question_for_current_level];
            }
        }
        
        [SimpleKeychain save:@"isLevelLoaded" data:[[NSString alloc] initWithFormat:@"%d", 1]];
        appDelegate.isLevelLoaded = 1;
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception.debugDescription);
    }
    
}
#pragma mark -
#pragma mark get movies for current level Functions

- (void) get_question_for_current_level {
    
    
    if([appDelegate.hostActive isEqualToString:@"down"])
    {
        return ;
    }
    
    if(appDelegate.userLevel <= NumberOfLevels){
        linkNumber = 1;
        
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
        
        @try {
            [DATABASE_HELPER store_questions:appDelegate.currentLevelQuestionArray];
        }
        @catch (NSException *exception) {
            NSLog(@"exception in store_questions %@", exception.debugDescription);
        }
        
        appDelegate.currentLevelQuestionArray = [DATABASE_HELPER read_questions_for_level:appDelegate.userLevel];
        appDelegate.questionlevelid = appDelegate.userLevel + 1;
        [SimpleKeychain save:@"questionlevelid" data:[[NSString alloc] initWithFormat:@"%d", appDelegate.questionlevelid]];
        
        [self get_question_for_next_level];
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception.debugDescription);
    }
    
    playButton.enabled = YES;
    
}


#pragma mark -
#pragma mark get movies for next level Functions

- (void) get_question_for_next_level {
    if([appDelegate.hostActive isEqualToString:@"down"])
    {
        return ;
    }
    
    linkNumber = 2;
    
    if(appDelegate.questionlevelid <= NumberOfLevels){
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
        @try {
            [DATABASE_HELPER store_questions:appDelegate.nextLevelQuestionArray];
        }
        @catch (NSException *exception) {
            NSLog(@"exception in store_questions %@", exception.debugDescription);
        }
        
        appDelegate.nextLevelQuestionArray = [DATABASE_HELPER read_questions_for_level:appDelegate.questionlevelid];
        
        appDelegate.questionlevelid = appDelegate.questionlevelid + 1;
        [SimpleKeychain save:@"questionlevelid" data:[[NSString alloc] initWithFormat:@"%d", appDelegate.questionlevelid]];
        
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
   // [AlertMessage Display_internet_error_message_WithLanguage:@"Ar"];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *XMLData = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSASCIIStringEncoding];
    if(linkNumber == 1 && [XMLData length] != 0)
        [self parse_question_XMLData:XMLData];
    else if(linkNumber == 2 && [XMLData length] != 0)
        [self parse_next_question_XMLData:XMLData];
    [connection release];
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
    
    FacebookShareViewController *instance = [[[FacebookShareViewController alloc] init] autorelease];
    [self.navigationController pushViewController:instance animated:YES];
}

@end
