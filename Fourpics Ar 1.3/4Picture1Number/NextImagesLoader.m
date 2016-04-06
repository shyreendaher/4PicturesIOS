//
//  NextImagesLoader.m
//  What's the movie
//
//  Created by eurisko on 4/22/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "NextImagesLoader.h"
#import "AppDelegate.h"

@implementation NextImagesLoader
@synthesize numberOfImages, object, imageDownloadsInProgress, imagesArray;

- (id)init
{
    self = [super init];
    if (self) {
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        self.imageDownloadsInProgress = tempDictionary;
        [tempDictionary release];
        
        NSMutableArray *tempImagesArray= [[NSMutableArray alloc] init];
        self.imagesArray = tempImagesArray;
        [tempImagesArray release];
    }
    return self;
}

- (void) StartLoading {
    
    NSArray *allDownloads = [imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    [self.imageDownloadsInProgress removeAllObjects];
    [self.imagesArray removeAllObjects];

    for (int i = 0; i< numberOfImages; i++) {
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        [tempDictionary setValue:[[NSString alloc] initWithFormat:@"%d", object.QId] forKey:@"id"];
        [self.imagesArray addObject:tempDictionary];
        [tempDictionary release];
    }
    
    [self fill_images];
}


- (void) fill_images {
    for (int i = 0; i < numberOfImages; i++) {
       if([[self.imagesArray objectAtIndex:i] objectForKey:@"Data"] == NULL){
           [self startIconDownload:[[NSString alloc] initWithFormat:@"%@/%@", appDelegate.imageURL, [[NSString alloc] initWithFormat:@"%@_%d.jpg", [[self.imagesArray objectAtIndex:i]  objectForKey:@"id"], i+1]] forTabNumber:2 arrayIndex:i];
        }
    }
    
}

#pragma mark -
#pragma mark Lazy Image Loading

- (void)startIconDownload:(NSString *)imPath forTabNumber:(int) tabIndex arrayIndex : (int) arrayIndex
{
    iconDownloader = [imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d%d", tabIndex, arrayIndex]];
    if (iconDownloader == nil)
	{	iconDownloader = [[TabIconDownloader alloc] init];
        iconDownloader.path = imPath;
        iconDownloader.tabIndex = tabIndex;
        iconDownloader.index = arrayIndex;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:[NSString stringWithFormat:@"%d%d", tabIndex, arrayIndex]];
        [iconDownloader startDownload];
        [iconDownloader release];
    }
}


- (void)appImageDidLoad:(int)tabNumber data:(NSData *)d arrayIndex : (int) i {
    if(tabNumber == 2) {
        NSString *a=[[NSString alloc] initWithBytes:[d bytes] length:[d length] encoding:NSUTF8StringEncoding];
        if(a!=nil || [a length]!=0)
            return;
        [[self.imagesArray objectAtIndex:i] setObject:d forKey:@"Data"];
    }
}


@end
