//
//  ScoreboardViewController.m
//  What's the movie
//
//  Created by eurisko on 4/9/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "ScoreboardViewController.h"
#import "AppDelegate.h"
#import "ScoreboardCell.h"
#import <CoreLocation/CoreLocation.h>

#define TABLEVIEW_START_INDEX 100
#define TABLEVIEW_PAGE_SIZE 10
#define TABLEVIEW_CELL_HEIGHT 44.0

@interface ScoreboardViewController () <FBLoginViewDelegate>
@property (nonatomic, retain) FBSession *fbsession;

@end

@implementation ScoreboardViewController
@synthesize webData, tableArray;

@synthesize facebookUserInfo;
@synthesize fbsession;
@synthesize transparentGrayView, congratulationsView;

@synthesize activityIndicator;
@synthesize activityIndicatorView;
@synthesize footerActivityIndicator;

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
    startItem = [self.tableArray count];
    IsLoading = NO;
    [self.view addSubview:appDelegate.loading];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.tableArray = tempArray;
    [tempArray release];
    
    [self get_scoreboard_list];

    l1.textColor = [UIColor whiteColor];
    l2.textColor = [UIColor whiteColor];
    l3.textColor = [UIColor whiteColor];
    l1.textAlignment = NSTextAlignmentCenter;
    l2.textAlignment = NSTextAlignmentCenter;
    l3.textAlignment = NSTextAlignmentCenter;
    
    l1.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
    l2.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
    l3.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:20];
    l1.text = @"لقد أضفت";
    l2.text = @"نتيجتك بنجاح";
    l3.text = @"";
    
    self.transparentGrayView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.transparentGrayView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    self.congratulationsView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2- 40);
    
}

#pragma mark Template generated code

- (void)viewDidUnload
{
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) PostScore:(id)sender {

}

- (IBAction)getMe:(id)sender {
    [self.view addSubview:appDelegate.loading];
    NSArray *permissions =
    [NSArray arrayWithObjects:@"email", nil];
    
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      /* handle success + failure in block */
                                      if(!error){
                                          NSLog(@"Session started");
                                          [self me];
                                      } else
                                          NSLog(@"Session ended");
                                  }];
}

- (void)me{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
//                 NSLog(@"ME: %@", user);
//                 NSLog(@"usr_id::%@",user.id);
//                 NSLog(@"usr_first_name::%@",user.first_name);
//                 NSLog(@"usr_middle_name::%@",user.middle_name);
//                 NSLog(@"usr_last_nmae::%@",user.last_name);
//                 NSLog(@"usr_Username::%@",user.username);
//                 NSLog(@"usr_b_day::%@",user.birthday);
                 
                 [self post_scoreboard_list_with_facebookID:[[NSString alloc] initWithFormat:@"%@", [user objectForKey:@"id"]] abd_usernamer:user.first_name];
             }
         }];
    }
    
}


#pragma mark -
#pragma mark get scoreboard Functions

- (void) get_scoreboard_list {
    if([appDelegate.hostActive isEqualToString:@"down"])
    {
        return ;
    }
    
    linkNumber = 1;
    if(IsLoading)
        return;
    IsLoading = YES;
    
    NSString *post = [[NSString alloc] initWithFormat:@"secret=5GhzqyJnaQuiVbzb9oPlk1QavbN6YfazBdH6tEaNbp0gDg5EqvCh5aLp67FbdAz5HfaYtcdB7YihNg&platformId=1&start=%d&end=%d&rand=%f", startItem,startItem +10, [NSDate timeIntervalSinceReferenceDate]];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength =  [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[postData length]];
    NSString *path= [[NSString alloc] initWithFormat:@"%@getScores.php", appDelegate.hostName];
    NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10.0];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPBody:postData];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if(theConnection)
    {
        self.webData = NULL;
        self.webData = [[NSMutableData data] retain];
    }
}

- (void) parse_scoreboard_XMLData:(NSString *)XmlString {
    
    @try {
        
        CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString:XmlString options:0 error:nil] autorelease];
        NSArray *nodes = NULL;
        nodes = [doc nodesForXPath:@"//score" error:nil];
        
        for (CXMLElement *node in nodes) {
            
            NSMutableDictionary *category = [[NSMutableDictionary alloc] init];
            
            for(int counter = 0; counter < [node childCount]; counter++)
            {
                if([[node childAtIndex:counter] stringValue] != NULL){
                    NSData *d = [[NSData alloc] initWithData:[Cryptography initDecipherData:[[NSData alloc] initWithData:[NSData dataWithBase64EncodedString:[[node childAtIndex:counter] stringValue]]] key:[Cryptography getKey]]];
                    @try {
                        [category setObject:[[NSString alloc] initWithString:[NSString stringWithUTF8String:[d bytes]]] forKey:[[node childAtIndex:counter] name]];
                        
                    }
                    @catch (NSException *exception) {
                        
                    }
                    [d release];
                }
            }
            [self.tableArray addObject:category];

            [category release];
        }
                
        [table reloadData];
        
        [appDelegate.loading removeFromSuperview];
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception.debugDescription);
    }
    IsLoading = NO;

}

#pragma mark -
#pragma mark post score Functions

- (void) post_scoreboard_list_with_facebookID :(NSString*) userID abd_usernamer :(NSString*) username {
    
    if([appDelegate.hostActive isEqualToString:@"down"])
    {
        return ;
    }
    linkNumber = 2;    
    NSString *post = [[NSString alloc] initWithFormat:@"secret=5GhzqyJnaQuiVbzb9oPlk1QavbN6YfazBdH6tEaNbp0gDg5EqvCh5aLp67FbdAz5HfaYtcdB7YihNg&facebookId=%@&name=%@&score=%@&rand=%f", userID, username, [Cryptography TripleDES:[SimpleKeychain load:@"Score"] algo:kCCDecrypt key:@"Sfg$93@B"],[NSDate timeIntervalSinceReferenceDate]];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength =  [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[postData length]];
    NSString *path= [[NSString alloc] initWithFormat:@"%@addScore.php", appDelegate.hostName];
    NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:30.0];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPBody:postData];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if(theConnection)
    {
        self.webData = NULL;
        self.webData = [[NSMutableData data] retain];
    }
}

- (void) parse_post_XMLData:(NSString *)XmlString {
    [appDelegate.loading removeFromSuperview];
    if([XmlString isEqualToString:@"1"]){
        [self.view addSubview:self.transparentGrayView];
        [self.view addSubview:self.congratulationsView];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark -
#pragma mark Connection Functions

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webData setLength: 0];
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{   [webData appendData:data];
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
   // [AlertMessage Display_internet_error_message_WithLanguage:@"Ar"];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *XMLData = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSASCIIStringEncoding];    
    if([XMLData length] != 0 && linkNumber == 1)
        [self parse_scoreboard_XMLData:XMLData];
    else if([XMLData length] != 0 && linkNumber == 2)
        [self parse_post_XMLData:XMLData];
    
    [connection release];
    
}

#pragma mark - table lifecycle

-(NSInteger) numberOfSectionsInTableView : (UITableView *) tableView {
	return 1;
}


-(NSInteger) tableView : (UITableView *)tableView numberOfRowsInSection : (NSInteger) section {
    return [self.tableArray count];
}


-(UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath : (NSIndexPath *) indexPath {
    
    static NSString *MyIdentifier = @"MyIdentifier";
	MyIdentifier = @"tblCellView";
	
    
    ScoreboardCell *cell = (ScoreboardCell *)[table dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ScoreboardCell" owner:self options:nil];
        cell = customCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
