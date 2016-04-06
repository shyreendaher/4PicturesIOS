//
//  NextImagesLoader.h
//  What's the movie
//
//  Created by eurisko on 4/22/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TabIconDownloader.h"
#import "TABLE_QUESTIONS.h"

@class AppDelegate;

@interface NextImagesLoader : NSObject <TabIconDownloaderDelegate> {
    AppDelegate *appDelegate;
    TabIconDownloader *iconDownloader;
}

@property (nonatomic) int numberOfImages;
@property (nonatomic, retain) TABLE_QUESTIONS *object;
@property (nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic,retain) NSMutableArray *imagesArray;

- (void) StartLoading;

- (void)startIconDownload:(NSString *)imPath forTabNumber:(int) tabIndex arrayIndex : (int) arrayIndex;
- (void)appImageDidLoad:(int)tabNumber data:(NSData *)d arrayIndex : (int) i;

@end
