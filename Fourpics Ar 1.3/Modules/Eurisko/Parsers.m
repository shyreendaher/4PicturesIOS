//
//  Parsers.m
//  WaterfrontCity
//
//  Created by eurisko on 3/12/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "Parsers.h"
#import "AppDelegate.h"


@implementation Parsers

//+ (NSMutableArray*) get_nextgen_gallery_array_forID : (NSString*) galleryID {
//    
//    NSURL *url = [NSURL URLWithString:photoURL];
//    CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
//    
//    NSMutableArray *tempArray = [[[NSMutableArray alloc] init] autorelease];
//    
//    NSArray *galleryNodes = [rssParser nodesForXPath:@"//item" error:nil];
//    
//    for (CXMLElement *node in galleryNodes) {
//        NSMutableDictionary *category = [[NSMutableDictionary alloc] init];
//        for(int counter = 0; counter < [node childCount]; counter++)
//        {
//            if([[node childAtIndex:counter] stringValue] != NULL)
//                [category setObject:[[node childAtIndex:counter] stringValue] forKey:[[node childAtIndex:counter] name]];
//        }
//        if([[category objectForKey:@"GalleryID"] isEqualToString:galleryID])
//            [tempArray addObject:category];
//        [category release];
//    }
//    return tempArray;
//}
//
//+ (NSMutableArray*) get_video_gallery_array {
//    NSURL *url = [NSURL URLWithString:videoURL];
//    CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
//    
//    NSMutableArray *tempArray = [[[NSMutableArray alloc] init] autorelease];
//    
//    NSArray *galleryNodes = [rssParser nodesForXPath:@"//item" error:nil];
//    
//    for (CXMLElement *node in galleryNodes) {
//        NSMutableDictionary *category = [[NSMutableDictionary alloc] init];
//        for(int counter = 0; counter < [node childCount]; counter++)
//        {
//            if([[node childAtIndex:counter] stringValue] != NULL)
//                
//                [category setObject:[[node childAtIndex:counter] stringValue] forKey:[[node childAtIndex:counter] name]];
//        }
//        [tempArray addObject:category];
//        [category release];
//    }    
//    return tempArray;
//}

@end
