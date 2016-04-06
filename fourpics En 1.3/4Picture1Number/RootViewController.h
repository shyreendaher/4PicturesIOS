//
//  RootViewController.h
//  What's the movie
//
//  Created by eurisko on 3/26/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "FacebookShareViewController.h"
#import "GAITrackedViewController.h"

#import "ATMHudDelegate.h"

@class AppDelegate;
@class ATMHud;

@interface RootViewController : GAITrackedViewController <AVAudioPlayerDelegate, ATMHudDelegate>{
    AppDelegate *appDelegate;
    IBOutlet UILabel *levelLabel, *scoreLabel, *LifeLabel;
    IBOutlet UIButton *playButton, *soundButton;
    IBOutlet UIImageView *backImage;
    IBOutlet UILabel *l1,*l2,*l3;
    
    int linkNumber;
    IBOutlet UIImageView *levelImage;
    
    ATMHud *hud;
    float expectedLength, progressValue;
    
}
@property (nonatomic) BOOL ShoudReload;
@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, retain) FacebookShareViewController *fbShareView;
@property (nonatomic, retain) ATMHud *hud;

- (void) callQuestionLink :(NSNotification *)notification;

- (void) get_question_for_current_level;
- (void) parse_question_XMLData:(NSString *)XmlString;

- (void) get_question_for_next_level;
- (void) parse_next_question_XMLData:(NSString *)XmlString;

@end
