//
//  LevelDetailsViewController.h
//  4Picture1Number
//
//  Created by eurisko on 6/4/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TABLE_QUESTIONS.h"

@class AppDelegate;

@interface LevelDetailsViewController : UIViewController {
    AppDelegate *appDelegate;
    IBOutlet UILabel *livesLabel, *scoreLabel;
    IBOutlet UILabel *l1,*l2,*l3;
    IBOutlet UILabel *l4,*l5,*l6;

    IBOutlet UIScrollView *scrollView;
    TABLE_QUESTIONS *movie;
    IBOutlet UIImageView *levelImage;
    int AnsweredMoviesCount;
    BOOL LevelComplete;
    IBOutlet UIButton *facebookButton;
    BOOL ShouldGoBack;
    
    NSString *userName;
}

@property (nonatomic) int levelId;
@property (nonatomic, retain) NSMutableArray *QArray;

@property (nonatomic, retain) IBOutlet UIView *transparentGrayView;
@property (nonatomic, retain) IBOutlet UIView *congratulationsView;

@property (nonatomic) BOOL ShouldAddPoints;
@property (nonatomic) int selectedLevel;
@property (nonatomic, retain) IBOutlet UIView *NotEnoughLifeView;

@end
