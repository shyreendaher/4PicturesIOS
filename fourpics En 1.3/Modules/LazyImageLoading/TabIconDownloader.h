//
//  TabIconDownloader.h
//  WaterfrontCity
//
//  Created by eurisko on 3/13/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TabIconDownloaderDelegate;

@interface TabIconDownloader : NSObject
{
    NSIndexPath *indexPathInTableView;
    id <TabIconDownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
	
	NSString *path;
    int index;
    int turnInRow;
}

@property (nonatomic) int tabIndex;
@property (nonatomic) int index;

@property (nonatomic, assign) id <TabIconDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

@property (nonatomic, retain) NSString *path;


- (void)startDownload;
- (void)cancelDownload;

@end

@protocol TabIconDownloaderDelegate

- (void)appImageDidLoad:(int)tabNumber data:(NSData *)d arrayIndex : (int) i;

@end