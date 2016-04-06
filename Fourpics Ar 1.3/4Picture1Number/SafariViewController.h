//
//  SafariViewController.h
//  What's the movie
//
//  Created by eurisko on 4/22/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;

@interface SafariViewController : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *web;
    AppDelegate *appDelegate;
	NSString *path;
    IBOutlet UIActivityIndicatorView *activity;
}

@property(nonatomic) int from;
@property(nonatomic, retain) NSString *path;

@end
