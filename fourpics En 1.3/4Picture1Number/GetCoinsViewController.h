//
//  GetCoinsViewController.h
//  What's the movie
//
//  Created by eurisko on 4/13/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@class CoinsCell;

@interface GetCoinsViewController : UIViewController {
    AppDelegate *appDelegate;
    IBOutlet UITableView *table;
    IBOutlet CoinsCell *customCell;
    
    IBOutlet UILabel *levelLabel, *scoreLabel, *livesLabel;

    int coinsPurchased;
    float price;
}

@end
