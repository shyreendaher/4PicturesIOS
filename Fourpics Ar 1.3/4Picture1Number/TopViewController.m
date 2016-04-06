//
//  TopViewController.m
//  4Picture1Number
//
//  Created by eurisko on 7/10/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "TopViewController.h"
#import "AppDelegate.h"

@interface TopViewController ()

@end

@implementation TopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextpage1:(id)sender {
    b1.hidden = YES;
    [UIView transitionWithView:imageView duration:0.8
                       options:UIViewAnimationOptionTransitionCurlUp animations:^{
                           if(appDelegate.window.frame.size.height == 480)
                               imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"2-4" ofType:@"jpg"]];
                           else
                               imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"2-5" ofType:@"jpg"]];
                       } completion:^(BOOL finished){
                           b2.hidden = NO;
                       }];
}

- (IBAction)nextpage2:(id)sender {
    b2.hidden = YES;
    [UIView transitionWithView:imageView duration:0.8
                       options:UIViewAnimationOptionTransitionCurlUp animations:^{
                           if(appDelegate.window.frame.size.height == 480)
                               imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"3-4" ofType:@"jpg"]];
                           else
                               imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"3-5" ofType:@"jpg"]];                       } completion:^(BOOL finished){
                           b3.hidden = NO;
                       }];
}

- (IBAction)nextpage3:(id)sender {
    b3.hidden = YES;
    [UIView transitionWithView:imageView duration:0.8
                       options:UIViewAnimationOptionTransitionCurlUp animations:^{
                           if(appDelegate.window.frame.size.height == 480)
                               imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"4-4" ofType:@"jpg"]];
                           else
                               imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"4-5" ofType:@"jpg"]];                       } completion:^(BOOL finished){
                           b4.hidden = NO;
                       }];
}

- (IBAction)nextpage4:(id)sender {
    b4.hidden = YES;
    [UIView transitionWithView:imageView duration:0.8
                       options:UIViewAnimationOptionTransitionCurlUp animations:^{
                           if(appDelegate.window.frame.size.height == 480)
                               imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"5-4" ofType:@"jpg"]];
                           else
                               imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"5-5" ofType:@"jpg"]];                       } completion:^(BOOL finished){
                           b5.hidden = NO;
                       }];
}

- (IBAction)nextpage5:(id)sender {
    b5.hidden = YES;
    [UIView transitionWithView:imageView duration:0.8
                       options:UIViewAnimationOptionTransitionCurlUp animations:^{
                           if(appDelegate.window.frame.size.height == 480)
                               imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"6-4" ofType:@"jpg"]];
                           else
                               imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"6-5" ofType:@"jpg"]];                       } completion:^(BOOL finished){
                           b6.hidden = NO;
                       }];
}

- (IBAction)nextpage6:(id)sender {
    b6.hidden = YES;
    [UIView transitionWithView:imageView duration:0.8
                       options:UIViewAnimationOptionTransitionCurlUp animations:^{
                           if(appDelegate.window.frame.size.height == 480)
                               imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"7-4" ofType:@"jpg"]];
                           else
                               imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"7-5" ofType:@"jpg"]];                       } completion:^(BOOL finished){
                           b7.hidden = NO;
                       }];
}

- (IBAction)nextpage7:(id)sender {
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRunForInst"]){
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRunForInst"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController popViewControllerAnimated:NO];
    }else
        [self.navigationController popViewControllerAnimated:YES];
}

@end
