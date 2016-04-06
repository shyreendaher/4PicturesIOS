//
//  PushNotificationAPI.m
//  Unity-iPhone
//
//  Created by eurisko on 9/17/13.
//
//

#import "PushNotificationAPI.h"
#import "OpenUDID.h"
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation PushNotificationAPI
@synthesize webData;

- (void) SaveTokenForPushNotification : (NSString*) token andAppID : (NSString*) appId {
    NSString *deviceUDID ;
    // Get UDID
    if(SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        deviceUDID = [OpenUDID value];
    }else {
        deviceUDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    
    NSString *post = [[NSString alloc] initWithFormat:@"UDID=%@&Token=%@&appId=%@", deviceUDID, token, appId];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString *path=[[NSString alloc] initWithFormat:@"https://www.euriskomobility.biz/Push/apple/addNewUser.php"];
    
    NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPBody:postData];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if(theConnection)
    {
        self.webData = NULL;
        self.webData = [[NSMutableData alloc] init];
    }
}


#pragma mark - connection life cycle

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{   [self.webData setLength: 0];
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{   [self.webData appendData:data];
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error --------->>>>> %@", error.localizedDescription);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *str = [[NSString alloc] initWithBytes: [self.webData mutableBytes] length:[self.webData length] encoding:NSASCIIStringEncoding];
    NSLog(@"str %@", str);
}

@end
