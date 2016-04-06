//
//  TabIconDownloader.m
//  WaterfrontCity
//
//  Created by eurisko on 3/13/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "TabIconDownloader.h"

@implementation TabIconDownloader

@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize path;
@synthesize tabIndex;
@synthesize index;

#pragma mark

- (void)dealloc
{
    [activeDownload release];
	[imageConnection cancel];
    [imageConnection release];
    [super dealloc];
}

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    NSURLConnection *conn = nil;
    self.path=[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
	conn=[[NSURLConnection alloc] initWithRequest:
          [NSURLRequest requestWithURL:
           [NSURL URLWithString:path]] delegate:self];
    self.imageConnection = conn;
    [conn release];
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	[self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{   self.activeDownload = nil;
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [delegate appImageDidLoad:tabIndex data:activeDownload arrayIndex:index];
	self.activeDownload = nil;
	self.imageConnection = nil;
}

@end
