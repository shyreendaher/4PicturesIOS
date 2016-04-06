//
//  DATABASE_HELPER.h
//  What's the movie
//
//  Created by eurisko on 4/9/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TABLE_QUESTIONS.h"

@interface DATABASE_HELPER : NSObject

+ (void) store_questions : (NSMutableArray *) questions;

+ (NSMutableArray *) read_questions_for_level : (int) level;

+ (BOOL) set_question_answered : (TABLE_QUESTIONS *) question;
+ (BOOL) set_hint_shown_for_question : (TABLE_QUESTIONS *) question;
+ (BOOL) set_images_shown_for_question : (TABLE_QUESTIONS *) question;
+ (BOOL) set_characters_removed_for_question : (TABLE_QUESTIONS *) question;

+ (NSString*)encrypt:(NSString*)str;
+ (NSString*)decrypt:(NSString*)str;

+ (BOOL) update_question902_hint : (NSString *) hint;
+ (BOOL) update_questions : (NSMutableArray *) fixesArr;

@end
