//
//  AlertMessage.m
//  WaterfrontCity
//
//  Created by eurisko on 3/12/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "AlertMessage.h"

@implementation AlertMessage

+ (void) Display_internet_error_message_WithLanguage : (NSString*) LanguageFlag {
    if([LanguageFlag isEqualToString:@"En"]) {
		UIAlertView *myAlert = [[UIAlertView alloc]
								initWithTitle:@"No Internet Connection"
								message:@"This app requires an internet connection via WiFi or cellular network to work. Please ensure your internet connection is enabled"
								delegate:self
								cancelButtonTitle:@"Ok"
								otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
    }else if([LanguageFlag isEqualToString:@"Fr"]) {
        
    }else if([LanguageFlag isEqualToString:@"Ar"]) {
    }
}

+ (void) Display_empty_level_error_message_WithLanguage : (NSString*) LanguageFlag {
    if([LanguageFlag isEqualToString:@"En"]) {
		UIAlertView *myAlert = [[UIAlertView alloc]
								initWithTitle:@"Level Not Loaded"
								message:@"We found problems while loading this level, please try again later"
								delegate:self
								cancelButtonTitle:@"Ok"
								otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
    }else if([LanguageFlag isEqualToString:@"Fr"]) {
        
    }else if([LanguageFlag isEqualToString:@"Ar"]) {
    }
}

+ (void) Display_wrong_date_error_message_WithLanguage : (NSString*) LanguageFlag {
    if([LanguageFlag isEqualToString:@"En"]) {
		UIAlertView *myAlert = [[UIAlertView alloc]
								initWithTitle:@"Wrong phone date"
								message:@"Please fix your phone date and try again"
								delegate:self
								cancelButtonTitle:@"Ok"
								otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
    }else if([LanguageFlag isEqualToString:@"Fr"]) {
        
    }else if([LanguageFlag isEqualToString:@"Ar"]) {
    }
}

+ (void) Display_no_lives_error_message_WithLanguage : (NSString*) LanguageFlag {
    if([LanguageFlag isEqualToString:@"En"]) {
		UIAlertView *myAlert = [[UIAlertView alloc]
                                initWithTitle:@"Lives"
                                message:@"You don't have any remaining life."
                                delegate:self
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil];
        [myAlert show];
        [myAlert release];
    }else if([LanguageFlag isEqualToString:@"Fr"]) {
        
    }else if([LanguageFlag isEqualToString:@"Ar"]) {
    }
}

+ (void) Display_Empty_error_message_WithLanguage : (NSString*) LanguageFlag {
    if([LanguageFlag isEqualToString:@"En"]) {
		UIAlertView *myAlert = [[UIAlertView alloc]
                                initWithTitle:@"We found problems while loading the scoreboard, please try again later"
                                message:@""
                                delegate:self
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil];
        [myAlert show];
        [myAlert release];
    }else if([LanguageFlag isEqualToString:@"Fr"]) {
        
    }else if([LanguageFlag isEqualToString:@"Ar"]) {
    }
}

+ (void) Display_Facebook_error_message_WithLanguage : (NSString*) LanguageFlag {
    if([LanguageFlag isEqualToString:@"En"]) {
		UIAlertView *myAlert = [[UIAlertView alloc]
                                initWithTitle:@"We found problems while loading facebook, please try again later"
                                message:@""
                                delegate:self
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil];
        [myAlert show];
        [myAlert release];
    }else if([LanguageFlag isEqualToString:@"Fr"]) {
        
    }else if([LanguageFlag isEqualToString:@"Ar"]) {
    }
}


@end
