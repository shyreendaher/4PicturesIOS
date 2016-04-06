//
//  ConnectionViewController.m
//  testtest
//
//  Created by eurisko on 7/3/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "AdRequestViewController.h"
#import "AppDelegate.h"

@interface AdRequestViewController ()

@end

@implementation AdRequestViewController
@synthesize webData;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) CallAd {
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    if([appDelegate.hostActive isEqualToString:@"down"])
    {
        return ;
    }
    
    NSString *post = [[NSString alloc] initWithFormat:@"secret=6Hjn95Rt1akgbvf8tykmF1Zcvn5Iof56FcsAkl83Erv5f6ZhvdAx5Bvnd4Jf57DaH6gxXx9p1QwbHg&appId=12068&rand=%f",[NSDate timeIntervalSinceReferenceDate]];
    
//    NSLog(@"post %@", post);
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength =  [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString *path= [[NSString alloc] initWithFormat:@"https://www.euriskomobility.me/eurisko-ads/getAd.php"];
    
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


#pragma mark - connection life cycle

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{   [webData setLength: 0];
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{   [webData appendData:data];
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error --------->>>>> %@", error.localizedDescription);
    self.webData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *str = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSASCIIStringEncoding];
    if([str isEqualToString:@""] || str == NULL)
    {
        
    }
    else {
        [self parseXMLData:str];
    }
}

- (void) parseXMLData:(NSString *)XmlString {
    
    @try {
        CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString:XmlString options:0 error:nil] autorelease];
        NSArray *nodes = NULL;
        nodes = [doc nodesForXPath:@"//ad" error:nil];
        
        for (CXMLElement *node in nodes) {
            
            NSMutableDictionary *category = [[NSMutableDictionary alloc] init];
            
            for(int counter = 0; counter < [node childCount]; counter++)
            {
                if([[node childAtIndex:counter] stringValue] != NULL)
                    
                    [category setObject:[[node childAtIndex:counter] stringValue] forKey:[[node childAtIndex:counter] name]];
            }
            
            appDelegate.adImageUrl = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[category objectForKey:@"image"]] encoding:NSUTF8StringEncoding];
            appDelegate.adItunesUrl = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[category objectForKey:@"link"]] encoding:NSUTF8StringEncoding];
            [category release];
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception.debugDescription);
    }
    
    if([appDelegate.adImageUrl length] != 0){
        
        [NSThread detachNewThreadSelector:@selector(downloadAndLoadImage) toTarget:self withObject:nil];
    }
}

- (void) downloadAndLoadImage{
    NSURL *url = [NSURL URLWithString:appDelegate.adImageUrl];
    UIImage *tmpImage = [[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfURL:url]];
    appDelegate.adImageView.image = tmpImage;
    [tmpImage release];
    
    if(tmpImage!=nil)
        [appDelegate showAdView];
}

@end
