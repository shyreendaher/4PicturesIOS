//
//  LevelViewController.h
//  What's the movie
//
//  Created by eurisko on 4/4/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "GAITrackedViewController.h"

@class AppDelegate;

@interface LevelViewController : GAITrackedViewController <AVAudioPlayerDelegate>{
    AppDelegate *appDelegate;
    IBOutlet UILabel *livesLabel, *scoreLabel;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *easyView, *mediumView, *smartView, *masterView, *geniusView, *geniusPlusView;
    IBOutlet UIButton *b1, *b2, *b3, *b4, *b5, *b6, *b7, *b8, *b9, *b10, *b11, *b12, *b13, *b14, *b15, *b16, *b17, *b18, *b19, *b20, *b21, *b22, *b23, *b24;
    IBOutlet UIImageView *levelImage, *categoryImage;
    BOOL ShoudReload;
    int linkNumber;    
}

@property (nonatomic, retain) IBOutlet UIView *transparentGrayView;
@property (nonatomic, retain) IBOutlet UIView *congratulationsView;
@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, retain) IBOutlet UIView *NotEnoughLifeView;
@property (nonatomic, retain) IBOutlet UIView *categoryCompleteView;
@property (nonatomic, retain) NSString *firstname, *username, *categoryName;

- (void) get_question_for_next_level;
- (void) parse_next_question_XMLData:(NSString *)XmlString;

- (void) get_question_for_current_level;
- (void) parse_question_XMLData:(NSString *)XmlString;

@end
