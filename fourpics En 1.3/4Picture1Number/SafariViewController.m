//
//  SafariViewController.m
//  What's the movie
//
//  Created by eurisko on 4/22/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "SafariViewController.h"
#import "AppDelegate.h"

@interface SafariViewController ()

@end

@implementation SafariViewController
@synthesize path, from;

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
    web.delegate=self;
    web.scalesPageToFit = YES;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSURL *url=[NSURL URLWithString:path];
    
    [web loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activity stopAnimating];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activity stopAnimating];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [web stopLoading];
    activity.hidden = YES;
}

- (IBAction) customBack:(id)sender {
    web.delegate=nil;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
