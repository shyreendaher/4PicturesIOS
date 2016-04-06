//
//  TopViewController.h
//  4Picture1Number
//
//  Created by eurisko on 7/10/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;

@interface TopViewController : UIViewController {
    AppDelegate *appDelegate;

    IBOutlet UIImageView *imageView;
    IBOutlet UIButton *b1, *b2,*b3,*b4,*b5,*b6,*b7;
}

@end
