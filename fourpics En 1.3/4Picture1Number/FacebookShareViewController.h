//
//  FacebookShareViewController.h
//  What's the movie
//
//  Created by eurisko on 6/5/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "iRate.h"
#import <AVFoundation/AVAudioPlayer.h>

@class AppDelegate;

@interface FacebookShareViewController : UIViewController <iRateDelegate, FBFriendPickerDelegate, AVAudioPlayerDelegate>{
    AppDelegate *appDelegate;
    IBOutlet UILabel *livesLabel, *scoreLabel;
    IBOutlet UILabel *l1,*l2,*l3;
    IBOutlet UIButton *inviteB, *shareB, *rateB;
}

@property (nonatomic, retain) IBOutlet UIView *transparentGrayView;
@property (nonatomic, retain) IBOutlet UIView *congratulationsView;
@property (nonatomic, retain) IBOutlet UIView *inviteFacebookView;
@property (nonatomic, retain) IBOutlet UIView *lifeAlertView;
@property (nonatomic, retain) IBOutlet UIView *oncePerDayAlertView;
@property (nonatomic, retain) IBOutlet UIView *onceAlertView;

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (nonatomic, retain) NSMutableDictionary *friendsParams;

- (IBAction) DismissAlert:(id)sender;
- (IBAction) DismissInvite:(id)sender;
- (IBAction) InviteAgain:(id)sender;

- (IBAction) DismissOnce:(id)sender;
- (IBAction) DismissOncePerDay:(id)sender;


@end
