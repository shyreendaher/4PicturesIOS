//
//  AlertMessage.h
//  WaterfrontCity
//
//  Created by eurisko on 3/12/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertMessage : NSObject

+ (void) Display_internet_error_message_WithLanguage : (NSString*) LanguageFlag;
+ (void) Display_empty_level_error_message_WithLanguage : (NSString*) LanguageFlag;
+ (void) Display_wrong_date_error_message_WithLanguage : (NSString*) LanguageFlag;
+ (void) Display_no_lives_error_message_WithLanguage : (NSString*) LanguageFlag;
+ (void) Display_Empty_error_message_WithLanguage : (NSString*) LanguageFlag;
+ (void) Display_Facebook_error_message_WithLanguage : (NSString*) LanguageFlag;

@end
