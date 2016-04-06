//
//  AboutViewController.h
//  What's the movie
//
//  Created by eurisko on 4/25/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class AppDelegate;

@interface AboutViewController : UIViewController <MFMailComposeViewControllerDelegate>{
    AppDelegate *appDelegate;

    IBOutlet UILabel *label1, *label2;

}

@end
