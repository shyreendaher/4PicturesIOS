//
//  FacebookFriendsViewController.h
//  What's the movie
//
//  Created by eurisko on 5/31/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "IconDownloaderForCards.h"

@class ScoreboardCell;
@class AppDelegate;

@interface FacebookFriendsViewController : UIViewController  <IconDownloaderForCardsDelegate>{
    AppDelegate *appDelegate;
    IBOutlet ScoreboardCell *customCell;
    IBOutlet UITableView *table;
    int startItem;
    int linkNumber;
    
    IBOutlet UILabel *l1,*l2,*l3;
    
    BOOL isAllInfoLoaded, IsLoading;
    
    NSMutableDictionary *imageDownloadsInProgress;
	IconDownloaderForCards *iconDownloader;
    BOOL disappear;
}

@property(nonatomic, retain) NSMutableData *webData;
@property(nonatomic, retain) NSMutableArray *tableArray;
@property (nonatomic, retain) NSMutableDictionary *facebookUserInfo;

@property (nonatomic, retain) IBOutlet UIView *transparentGrayView;
@property (nonatomic, retain) IBOutlet UIView *congratulationsView;

@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

@property (nonatomic, retain) NSMutableString *commaSeperatedFriends;

- (void) get_scoreboard_list;
- (void) parse_scoreboard_XMLData:(NSString *)XmlString;

- (void) post_scoreboard_list_with_facebookID :(NSString*) userID abd_usernamer :(NSString*) username;
- (void) parse_post_XMLData:(NSString *)XmlString;

- (IBAction)getMe:(id)sender;

- (void)startIconDownload:(NSString *)imPath forIndexPath:(NSIndexPath *)indexPath turnInRow:(int)turn;
- (void)appImageDidLoad:(NSIndexPath *)indexPath data:(NSData *)d turn:(int)t;
- (void)loadImagesForOnscreenRows;

@end
