//
//  MovieViewController.h
//  What's the movie
//
//  Created by eurisko on 4/5/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabIconDownloader.h"
#import "TABLE_QUESTIONS.h"
#import <AVFoundation/AVAudioPlayer.h>
#import "NextImagesLoader.h"

@class AppDelegate;
@class InstructionViewController;

@interface MovieViewController : UIViewController <TabIconDownloaderDelegate, AVAudioPlayerDelegate> {
    AppDelegate *appDelegate;
    InstructionViewController * semiVC;

    IBOutlet UILabel *levelLabel, *scoreLabel, *livesLabel, *hintLabel;
    IBOutlet UILabel *categoryLabel;
    IBOutlet UIImageView *levelImage;
    IBOutlet UIScrollView *scrollView;
    
    IBOutlet UIButton *moreButton, *hintButton;
    NextImagesLoader *imageLoader;
    TabIconDownloader *iconDownloader;
	BOOL disappear;
    NSMutableDictionary *imageDownloadsInProgress;
    
    int numberOfImages;
    int currentMovie, nextMovie;
    
    IBOutlet UIImageView *backImage;

    IBOutlet UIView *emptyBoxView;
    int answerLetterIndex;

    IBOutlet UIButton *letterb1, *letterb2, *letterb3, *letterb4, *letterb5, *letterb6, *letterb7, *letterb8, *letterb9, *letterb10, *letterb11, *letterb12;
    
    TABLE_QUESTIONS *movie;
    
    IBOutlet UILabel *l1,*l2,*l3;

    IBOutlet UIImageView *ConfirmBuyImage;
    IBOutlet UIButton *fullImageButton;
    
    NSString *allNumbers;
    NSString *tempallNumbers;
    
    int NumberOfPurchasedFeature;
}

@property (nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic,retain) NSMutableArray *imagesArray;
@property (nonatomic,retain) NSMutableArray *charactersArray;
@property (nonatomic,retain) NSString *movieName;
@property (nonatomic,retain) NSString *movieGuessName;

@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *transparentGrayView;
@property (nonatomic, retain) IBOutlet UIView *congratulationsView;
@property (nonatomic, retain) IBOutlet UIView *buycoinsView;
@property (nonatomic, retain) IBOutlet UIView *ConfirmBuyView;
@property (nonatomic, retain) IBOutlet UIView *NotEnoughLifeView;
@property (nonatomic, retain) IBOutlet UIView *WrongAnswerView;

@property (nonatomic) BOOL ShouldAddPoints;
@property (nonatomic) int selectedLevel, selectedMovie;
@property (nonatomic, retain) NSTimer *animationTimer;

- (void)startIconDownload:(NSString *)imPath forTabNumber:(int) tabIndex arrayIndex : (int) arrayIndex;

- (void)appImageDidLoad:(int)tabNumber data:(NSData *)d arrayIndex : (int) i;

@end
