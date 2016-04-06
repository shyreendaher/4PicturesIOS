//
//  ConnectionViewController.h
//  testtest
//
//  Created by eurisko on 7/3/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;

@interface AdRequestViewController : UIViewController {
    AppDelegate *appDelegate;

}

@property(nonatomic, retain) NSMutableData *webData;

- (void) CallAd;

@end
