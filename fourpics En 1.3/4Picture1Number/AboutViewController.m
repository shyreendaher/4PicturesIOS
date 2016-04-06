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

- (IBAction)Gotofacebook:(id)sender {
    SafariViewController *instance = [[[SafariViewController alloc] init] autorelease];
    instance.path = @"https://www.facebook.com/groups/198662693505415/";
    [self.navigationController pushViewController:instance animated:YES];
}

- (IBAction)Gototwitter:(id)sender {
    SafariViewController *instance = [[[SafariViewController alloc] init] autorelease];
    instance.path = @"https://twitter.com/@euriskomobility";
    [self.navigationController pushViewController:instance animated:YES];
}

- (IBAction)GotoGmail:(id)sender {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}

#pragma mark -
#pragma mark Compose Mail

-(void)displayComposerSheet
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
    
    [picker setSubject:@"4 pics 1 number"];
    
    NSString *emailBody=@"";
    [picker setMessageBody:emailBody isHTML:YES];
    
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
			break;
		default:
			break;
	}
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Workaround

-(void)launchMailAppOnDevice
{
    NSString *recipients = [[NSString alloc] initWithFormat:@"mailto:?&subject=%@", @"4 pics 1 number"];
	NSString *body =[[NSString alloc] initWithFormat:@"&body=%@", @""];
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
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
