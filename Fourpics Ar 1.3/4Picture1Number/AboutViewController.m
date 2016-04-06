//
//  AboutViewController.m
//  What's the movie
//
//  Created by eurisko on 4/25/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "AboutViewController.h"
#import "SafariViewController.h"
#import "TopViewController.h"
#import "AppDelegate.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

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
    label1.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
    label2.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:18];
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)GotoEurisko:(id)sender {
    SafariViewController *instance = [[[SafariViewController alloc] init] autorelease];
    instance.path = @"http://www.euriskogaming.com/";
    [self.navigationController pushViewController:instance animated:YES]; 
}

- (IBAction)GotoInstructionPages:(id)sender {
    TopViewController *instance;
    if(appDelegate.window.frame.size.height == 480)
        instance = [[TopViewController alloc] initWithNibName:@"TopViewiPhone4" bundle:nil];
    else
        instance = [[TopViewController alloc] initWithNibName:@"TopViewController" bundle:nil];
    
    [self.navigationController pushViewController:instance animated:YES];
}

- (IBAction) customBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
