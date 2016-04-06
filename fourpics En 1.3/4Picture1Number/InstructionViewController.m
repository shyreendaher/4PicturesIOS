//
//  KNThirdViewController.m
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "InstructionViewController.h"
#import "UIViewController+KNSemiModal.h"
#import <QuartzCore/QuartzCore.h>

@interface InstructionViewController ()

@end

@implementation InstructionViewController
@synthesize helpLabel;
@synthesize dismissButton;
@synthesize resizeButton;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  dismissButton.layer.cornerRadius  = 10.0f;
  dismissButton.layer.masksToBounds = YES;
  resizeButton.layer.cornerRadius   = 10.0f;
  resizeButton.layer.masksToBounds  = YES;
}

- (void)viewDidUnload {
  [self setHelpLabel:nil];
  [self setDismissButton:nil];
  [self setResizeButton:nil];
  [super viewDidUnload];
}

- (void) SetTextForCategory :  (NSString *) category {
    if([category isEqualToString:@"Sequence"]) {
        helpLabel.text = @"Fun and gets Harder : the 4 pics describe a mathematical sequence. Example: 1,3,5,7 next answer is 7+2= 9";
    }else if([category isEqualToString:@"Logic"]) {
        helpLabel.text = @"Starts Easy and Gets Harder:  The 4 pics have a logical sequence or logical equation.";
    }else if([category isEqualToString:@"Code"]) {
        helpLabel.text = @"Tricky and fun: The 4 pics indicate a number, you often need to search for that number online :)";
    }else if([category isEqualToString:@"Astronomy"]) {
        helpLabel.text = @"Also requires some search, the hidden number is related to our solar system. Follow the 4 pics.";
    }else if([category isEqualToString:@"Equation"]) {
        helpLabel.text = @"Fun and Tricky : The 4 pics indicate a logical or mathematical equation. Most of the times mathematical operations are required like addition multiplication subtraction or division.";
    }else if([category isEqualToString:@"Clock"]) {
        helpLabel.text = @"A sequence of clock times, or clock around the world . Note to players, you need to use the : in the keyboard";
    }else if([category isEqualToString:@"Shapes"]) {
        helpLabel.text = @"Simple and easy : The 4 pics indicate a sequence of shapes";
    }else if([category isEqualToString:@"Geometry"]) {
        helpLabel.text = @"Usually easy, basic geometry";
    }else if([category isEqualToString:@"Symbols"]) {
        helpLabel.text = @"The 4 pics are symbols that should conclude to 1 number";
    }else if([category isEqualToString:@"Year"]) {
        helpLabel.text = @"Requires Search : the 4 pics describe a famous event , the answer is the year of that event.";
    }else if([category isEqualToString:@"Biology"]) {
        helpLabel.text = @"The 4 pictures indicate a number related to Human biology.";
    }else if([category isEqualToString:@"Physics"]) {
        helpLabel.text = @"Search for basic physics described by the pictures. It should lead you to the correct number.";
    }else if([category isEqualToString:@"Sports"]) {
        helpLabel.text = @"Famous records by world's top athletes.";
    }else {
        helpLabel.text = @"";
    }
}
- (IBAction)dismissButtonDidTouch:(id)sender {

//  // Here's how to call dismiss button on the parent ViewController
//  // be careful with view hierarchy
//  UIViewController * parent = [self.view containingViewController];
//  if ([parent respondsToSelector:@selector(dismissSemiModalView)]) {
//    [parent dismissSemiModalView];
//  }
//    
    [self dismissSemiModalView];

}

- (IBAction)resizeSemiModalView:(id)sender {
    
  UIViewController * parent = [self.view containingViewController];
  if ([parent respondsToSelector:@selector(resizeSemiView:)]) {
    [parent resizeSemiView:CGSizeMake(320, arc4random() % 280 + 180)];
  }
}

@end
