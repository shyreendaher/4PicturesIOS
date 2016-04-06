//
//  FacebookFriendsViewController.m
//  What's the movie
//
//  Created by eurisko on 5/31/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "FacebookFriendsViewController.h"
#import "AppDelegate.h"
#import "ScoreboardCell.h"
#import <CoreLocation/CoreLocation.h>

#define TABLEVIEW_START_INDEX 100
#define TABLEVIEW_PAGE_SIZE 10
#define TABLEVIEW_CELL_HEIGHT 44.0

@interface FacebookFriendsViewController () <FBLoginViewDelegate>
@property (nonatomic, retain) FBSession *fbsession;
@end

@implementation FacebookFriendsViewController

@synthesize webData, tableArray;

@synthesize facebookUserInfo;
@synthesize fbsession;
@synthesize transparentGrayView, congratulationsView;
@synthesize imageDownloadsInProgress;
@synthesize commaSeperatedFriends;

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
    
    [self getFacebookFriends:nil];

}

-(void) viewWillAppear:(BOOL)animated
{
    disappear=0;
	imageDownloadsInProgress = [[NSMutableDictionary dictionary] retain];
}


- (void)viewWillDisappear:(BOOL)animated {
    if(disappear==0)
    {	disappear=1;
        NSArray *allDownloads = [imageDownloadsInProgress allValues];
        [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
        [imageDownloadsInProgress removeAllObjects];
        [imageDownloadsInProgress release];
    }
	[super viewWillDisappear:animated];
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

- (IBAction) cancel:(id)sender {
    [self.congratulationsView removeFromSuperview];
    [self.transparentGrayView removeFromSuperview];
}

- (IBAction) getFacebookFriends:(id)sender {
    self.commaSeperatedFriends = [[NSMutableString alloc] init];
    
    [self.view addSubview:appDelegate.loading];
    
    if ([FBSession.activeSession isOpen])
    {
        if ([[FBSession.activeSession permissions]indexOfObject:@"email"] == NSNotFound) {
            [FBSession.activeSession requestNewReadPermissions:[NSArray arrayWithObjects:@"publish_actions", @"email", @"user_friends", nil]
                                             completionHandler:^(FBSession *session,NSError *error){
                                                 [self getFriendList];
                                             }];
        }
        else
            [self getFriendList];
    }
    else
    {
        if (appDelegate.session.state != FBSessionStateCreated) {
            NSArray *permission = [NSArray arrayWithObjects:@"publish_actions", @"email", @"user_friends", nil];
            appDelegate.session = [[FBSession alloc] initWithPermissions:permission];
        }
        
        if (appDelegate.session.state != FBSessionStateOpen) {
            [appDelegate.session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                if (!error) {
                    [self getFriendList];
                }
                else
                    [appDelegate.loading removeFromSuperview];
            }];
        }
        
        [FBSession setActiveSession:appDelegate.session];
    }
}

- (void) getFriendList {
    self.commaSeperatedFriends = [[NSMutableString alloc] init];
    
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 self.commaSeperatedFriends = [[NSMutableString alloc] initWithFormat:@"%lld,", [[user objectForKey:@"id"] longLongValue]];
                 [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:@"id"] forKey:@"myFacebookID"];
             }
         }];
    }
    
    if([self.commaSeperatedFriends length] == 0 || self.commaSeperatedFriends == NULL)
        self.commaSeperatedFriends = [[NSMutableString alloc] initWithFormat:@"%@,", [[NSUserDefaults standardUserDefaults] objectForKey:@"myFacebookID"]];
    
    
    FBRequest *request = [FBRequest requestWithGraphPath:@"me/friends"
                                              parameters:@{@"fields":@"name,installed,first_name"}
                                              HTTPMethod:@"GET"];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection,
                                          id result,
                                          NSError *error){
        if (!error) {
            NSArray *friendInfo = (NSArray *) [result objectForKey:@"data"];
            
            for (int i =0; i < [friendInfo count]; i++) {
                [commaSeperatedFriends appendString:[[NSString alloc] initWithFormat:@"%@,",[[friendInfo objectAtIndex:i] objectForKey:@"id"]]];
            }
            
            if([commaSeperatedFriends length] != 0) {
                [commaSeperatedFriends substringToIndex:[commaSeperatedFriends length]-1];
                NSLog(@"commaSeperatedFriends %@", commaSeperatedFriends);
                [self get_scoreboard_list];
            }
            else
                [appDelegate.loading removeFromSuperview];
        }
        else
            [appDelegate.loading removeFromSuperview];
    }];
}


- (void) get_scoreboard_list {
    if([appDelegate.hostActive isEqualToString:@"down"])
    {
        return ;
    }
    
    linkNumber = 1;
    if(IsLoading)
        return;
    IsLoading = YES;
    
    NSString *post = [[NSString alloc] initWithFormat:@"secret=5GhzqyJnaQuiVbzb9oPlk1QavbN6YfazBdH6tEaNbp0gDg5EqvCh5aLp67FbdAz5HfaYtcdB7YihNg&platformId=1&ids=%@&rand=%f", commaSeperatedFriends, [NSDate timeIntervalSinceReferenceDate]];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength =  [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[postData length]];
    NSString *path= [[NSString alloc] initWithFormat:@"%@getFriendsScores.php", appDelegate.hostName];
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
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.tableArray = tempArray;
    [tempArray release];
    
    @try {
        
        CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString:XmlString options:0 error:nil] autorelease];
        NSArray *nodes = NULL;
        nodes = [doc nodesForXPath:@"//score" error:nil];
        
        for (CXMLElement *node in nodes) {
            
            NSMutableDictionary *category = [[NSMutableDictionary alloc] init];
            
            for(int counter = 0; counter < [node childCount]; counter++)
            {
                if([[node childAtIndex:counter] stringValue] != NULL){
                    @try {
                        [category setObject:[[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[[node childAtIndex:counter] stringValue]] encoding:NSUTF8StringEncoding] forKey:[[node childAtIndex:counter] name]];
                    }
                    @catch (NSException *exception) {
                        
                    }
                }
            }
            [self.tableArray addObject:category];
            [category release];
        }
        
//        NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"level" ascending:NO];
//        [self.tableArray sortUsingDescriptors:[NSArray arrayWithObject:sort]];

//        [self.tableArray sortUsingComparator: ^(id a, id b) {
//            if ( [[a objectForKey:@"level"] intValue] < [[b objectForKey:@"level"] intValue]) {
//                return (NSComparisonResult)NSOrderedDescending;
//            } else if ( [[a objectForKey:@"level"] intValue] > [[b objectForKey:@"level"] intValue]) {
//                return (NSComparisonResult)NSOrderedAscending;
//            }
//            return (NSComparisonResult)NSOrderedSame;
//        }];

        [table reloadData];
        
        if([self.tableArray count] == 0) {
            [AlertMessage Display_Empty_error_message_WithLanguage:@"Ar"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
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
    NSString *post = [[NSString alloc] initWithFormat:@"secret=5GhzqyJnaQuiVbzb9oPlk1QavbN6YfazBdH6tEaNbp0gDg5EqvCh5aLp67FbdAz5HfaYtcdB7YihNg&facebookId=%@&name=%@&score=%d&level=%d&rand=%f", userID, username, appDelegate.score, appDelegate.userLevel,[NSDate timeIntervalSinceReferenceDate]];

    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength =  [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[postData length]];
    NSString *path= [[NSString alloc] initWithFormat:@"%@addScore.php", appDelegate.hostName];
    NSLog(@"path %@" , path);
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
        //[self.view addSubview:self.transparentGrayView];
        //[self.view addSubview:self.congratulationsView];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self getFriendList];
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
  //  [AlertMessage Display_Empty_error_message_WithLanguage:@"Ar"];
//    NSLog(@"error %@", error.debugDescription);
    [appDelegate.loading removeFromSuperview];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *XMLData = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSASCIIStringEncoding];
    
//    NSLog(@"XMLData %@", XMLData);
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
    if([self.tableArray count]%4 == 0)
        return [self.tableArray count]/4;
    else
        return [self.tableArray count]/4 + 1;
    
}


-(UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath : (NSIndexPath *) indexPath {
    
    static NSString *MyIdentifier = @"MyIdentifier";
	MyIdentifier = @"tblCellView";
	
    
    ScoreboardCell *cell = (ScoreboardCell *)[table dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ScoreboardCell" owner:self options:nil];
        cell = customCell;
    }
    
    cell.numberLabel1.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:16];
    cell.numberLabel2.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:16];
    cell.numberLabel3.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:16];
    cell.numberLabel4.font = [UIFont fontWithName:@"TodaySHOP-Bold" size:16];
    
    cell.numberLabel1.textColor = [UIColor whiteColor];
    cell.numberLabel2.textColor = [UIColor whiteColor];
    cell.numberLabel3.textColor = [UIColor whiteColor];
    cell.numberLabel4.textColor = [UIColor whiteColor];

    if(indexPath.row*4 < [self.tableArray count]) {
        cell.numberLabel1.text = [[NSString alloc] initWithFormat:@"مرحلة %@", [Utils EnglishNumberToArabic:[[self.tableArray objectAtIndex:indexPath.row*4] objectForKey:@"level"]]];
        cell.fbButton1.tag = indexPath.row*4;
        if([[tableArray objectAtIndex:indexPath.row*4] objectForKey:@"Data"] == nil)
        { if(table.dragging == NO && table.decelerating == NO && disappear==0){
            if([[tableArray objectAtIndex:indexPath.row*4] objectForKey:@"fbid"] != NULL)
                [self startIconDownload:[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture", [[tableArray objectAtIndex:indexPath.row*4] objectForKey:@"fbid"]] forIndexPath:indexPath turnInRow:indexPath.row*4];
        }
            
        }else
            cell.fbImage1.image = [UIImage imageWithData:[[tableArray objectAtIndex:indexPath.row*4] objectForKey:@"Data"]];
    }
    if(indexPath.row*4 + 1 < [self.tableArray count]) {
        cell.numberLabel2.text = [[NSString alloc] initWithFormat:@"مرحلة %@", [Utils EnglishNumberToArabic:[[self.tableArray objectAtIndex:indexPath.row*4 + 1] objectForKey:@"level"]]];
        cell.fbButton2.tag = indexPath.row*4 + 1;

        if([[tableArray objectAtIndex:indexPath.row*4 + 1] objectForKey:@"Data"] == nil)
        { if(table.dragging == NO && table.decelerating == NO && disappear==0){
            if([[tableArray objectAtIndex:indexPath.row*4 + 1] objectForKey:@"fbid"] != NULL)
                [self startIconDownload:[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture", [[tableArray objectAtIndex:indexPath.row*4 + 1] objectForKey:@"fbid"]] forIndexPath:indexPath turnInRow:indexPath.row*4 + 1];
        }
            
        }else
            cell.fbImage2.image = [UIImage imageWithData:[[tableArray objectAtIndex:indexPath.row*4 + 1] objectForKey:@"Data"]];
    }
    if(indexPath.row*4 + 2 < [self.tableArray count]) {
        cell.numberLabel3.text = [[NSString alloc] initWithFormat:@"مرحلة %@", [Utils EnglishNumberToArabic:[[self.tableArray objectAtIndex:indexPath.row*4 + 2] objectForKey:@"level"]]];
        cell.fbButton3.tag = indexPath.row*4 + 2;

        if([[tableArray objectAtIndex:indexPath.row*4 + 2] objectForKey:@"Data"] == nil){
            if(table.dragging == NO && table.decelerating == NO && disappear==0){
                if([[tableArray objectAtIndex:indexPath.row*4 + 2] objectForKey:@"fbid"] != NULL)
                    [self startIconDownload:[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture", [[tableArray objectAtIndex:indexPath.row*4 + 2] objectForKey:@"fbid"]] forIndexPath:indexPath turnInRow:indexPath.row*4 + 2];
            }
            
        }else
            cell.fbImage3.image = [UIImage imageWithData:[[tableArray objectAtIndex:indexPath.row*4 + 2] objectForKey:@"Data"]];
    }
    
    if(indexPath.row*4 + 3 < [self.tableArray count]) {
        cell.numberLabel4.text = [[NSString alloc] initWithFormat:@"مرحلة %@", [Utils EnglishNumberToArabic:[[self.tableArray objectAtIndex:indexPath.row*4 + 3] objectForKey:@"level"]]];
        cell.fbButton4.tag = indexPath.row*4 + 3;

        if([[tableArray objectAtIndex:indexPath.row*4 + 3] objectForKey:@"Data"] == nil){
            if(table.dragging == NO && table.decelerating == NO && disappear==0){
                if([[tableArray objectAtIndex:indexPath.row*4 + 3] objectForKey:@"fbid"] != NULL)
                    [self startIconDownload:[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture", [[tableArray objectAtIndex:indexPath.row*4 + 3] objectForKey:@"fbid"]] forIndexPath:indexPath turnInRow:indexPath.row*4 + 3];
            }
            
        }else
            cell.fbImage4.image = [UIImage imageWithData:[[tableArray objectAtIndex:indexPath.row*4 + 3] objectForKey:@"Data"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction) FacebookLink:(id)sender {
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"fb://profile/%@", [[tableArray objectAtIndex:[sender tag]] objectForKey:@"fbid"]]];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - invite friends lifecycle

- (IBAction) inviteFriends:(id)sender {
    
    if ([[FBSession activeSession]isOpen]) {
        /*
         * if the current session has no publish permission we need to reauthorize
         */
        if ([[[FBSession activeSession]permissions]indexOfObject:@"email"] == NSNotFound) {
            [[FBSession activeSession] requestNewPublishPermissions:[NSArray arrayWithObject:@"email"] defaultAudience:FBSessionDefaultAudienceFriends
                                                  completionHandler:^(FBSession *session,NSError *error){
                                                      [self inviteFriends:sender];
                                                  }];
            return ;
        }
    }else{
        /*
         * open a new session with publish permission
         */
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"email"]
                                           defaultAudience:FBSessionDefaultAudienceOnlyMe
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             if (!error && status == FBSessionStateOpen) {
                                                 [self inviteFriends:sender];
                                             }else{
                                                 NSLog(@"error %@", error.localizedDescription);
                                             }
                                         }];
        return ;
    }
    
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:appDelegate.sharetext
                                                    title:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if(error)
                                                      {
                                                          NSLog(@"Some errorr: %@", [error description]);
                                                          UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"فشل في إرسال الدعوة" message:@" تعذر إرسال الدعوة في هذه اللحظة، من فضلك تأكد من اتصالك بالإنترنت" delegate:nil cancelButtonTitle:@"موافق" otherButtonTitles: nil];
                                                          [alrt show];
                                                          [alrt release];
                                                      }
                                                      else
                                                      {
                                                          if (![resultURL query])
                                                          {
                                                              return;
                                                          }
                                                          
                                                          NSDictionary *params = [self parseURLParams:[resultURL query]];
                                                          NSMutableArray *recipientIDs = [[[NSMutableArray alloc] init] autorelease];
                                                          for (NSString *paramKey in params)
                                                          {
                                                              if ([paramKey hasPrefix:@"to["])
                                                              {
                                                                  [recipientIDs addObject:[params objectForKey:paramKey]];
                                                              }
                                                          }
                                                          if ([params objectForKey:@"request"])
                                                          {
                                                              NSLog(@"Request ID: %@", [params objectForKey:@"request"]);
                                                          }
                                                          if ([recipientIDs count] > 0)
                                                          {
                                                             
                                                          }
                                                          
                                                      }
                                                  }];
    
}

- (NSDictionary *)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    for (NSString *pair in pairs)
    {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        
        [params setObject:[[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                   forKey:[[kv objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return params;
}

#pragma mark -
#pragma mark Lazy image loading

- (void)startIconDownload:(NSString *)imPath forIndexPath:(NSIndexPath *)indexPath turnInRow:(int)turn
{
    iconDownloader = [imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%@%d", indexPath, turn]];
    
    if (iconDownloader == nil)
    {	iconDownloader = [[IconDownloaderForCards alloc] init];
        iconDownloader.path = imPath;
        iconDownloader.turnInRow=turn;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:[NSString stringWithFormat:@"%@%d", indexPath, turn]];
        [iconDownloader startDownload];
        [iconDownloader release];
    }
}


- (void)appImageDidLoad:(NSIndexPath *)indexPath data:(NSData *)d turn:(int)t
{
    [[tableArray objectAtIndex:t] setObject:d forKey:@"Data"];
    [table reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)loadImagesForOnscreenRows
{	NSArray *visiblePaths = [table indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {	    [table reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end
