//
//  ScoreboardViewController.h
//  What's the movie
//
//  Created by eurisko on 4/9/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@class ScoreboardCell;
@class AppDelegate;

@interface ScoreboardViewController : UIViewController {
    AppDelegate *appDelegate;
    IBOutlet ScoreboardCell *customCell;
    IBOutlet UITableView *table;
    int startItem;
    int linkNumber;
    
    IBOutlet UILabel *l1,*l2,*l3;

    BOOL isAllInfoLoaded, IsLoading;
}

@property(nonatomic, retain) NSMutableData *webData;
@property(nonatomic, retain) NSMutableArray *tableArray;
@property (nonatomic, retain) NSMutableDictionary *facebookUserInfo;

@property (nonatomic, retain) IBOutlet UIView *transparentGrayView;
@property (nonatomic, retain) IBOutlet UIView *congratulationsView;

- (void) get_scoreboard_list;
- (void) parse_scoreboard_XMLData:(NSString *)XmlString;

- (void) post_scoreboard_list_with_facebookID :(NSString*) userID abd_usernamer :(NSString*) username;
- (void) parse_post_XMLData:(NSString *)XmlString;

- (IBAction)getMe:(id)sender;


@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,retain) IBOutlet UIView *activityIndicatorView;
@property (nonatomic,retain) UIActivityIndicatorView *footerActivityIndicator;

@end
