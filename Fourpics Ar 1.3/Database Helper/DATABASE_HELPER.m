//
//  DATABASE_HELPER.m
//  What's the movie
//
//  Created by eurisko on 4/9/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "DATABASE_HELPER.h"
#import <sqlite3.h>
#import "Cryptography.h"
#import "FBEncryptorAES.h"

@implementation DATABASE_HELPER

+ (void) store_questions : (NSMutableArray *) questions {

    sqlite3 *database;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDir stringByAppendingPathComponent:@"questionsArabic.sqlite"];
    
    for (int i =0; i < [questions count]; i++) {
        TABLE_QUESTIONS * question = (TABLE_QUESTIONS*)[questions objectAtIndex:i];

        if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
            const char * sql = "INSERT INTO `TABLE_QUESTIONS` (`QId`, `QLevelId`, `QAnswer`, `QHint`, `QCategory`,`IsHintShown`, `IsCharactersRemoved`, `IsAnswered`) VALUES (?,?,?,?,?,?,?,?)";
            
            sqlite3_stmt *add_statement = nil;
            
            if(sqlite3_prepare_v2(database, sql, -1, &add_statement, NULL) == SQLITE_OK)
            {
                sqlite3_bind_text(add_statement, 1, [[[NSString alloc] initWithFormat:@"%d", question.QId] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(add_statement, 2, [question.QLevelId UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(add_statement, 3, [[self encrypt:question.QAnswer] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(add_statement, 4, [[self encrypt:question.QHint] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(add_statement, 5, [question.QCategory UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(add_statement, 6, [[[NSString alloc] initWithFormat:@"%d", question.IsCharactersRemoved] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(add_statement, 7, [[[NSString alloc] initWithFormat:@"%d", question.IsHintShown] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(add_statement, 8, [[[NSString alloc] initWithFormat:@"%d", question.IsAnswered] UTF8String], -1, SQLITE_TRANSIENT);
            }
            int success = sqlite3_step(add_statement);
            if (success == SQLITE_ERROR){
                NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
            }
            
            sqlite3_finalize(add_statement);
        }
        sqlite3_close(database);
    }
    
}

+ (NSMutableArray *) read_questions_for_level : (int) level {

    sqlite3 *database;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *databasePath = [documentsDir stringByAppendingPathComponent:@"questionsArabic.sqlite"];
	
    NSMutableArray *questionsArray = [[NSMutableArray alloc] init];
    
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		const char * sql = "select * from TABLE_QUESTIONS where QLevelId=?";
        sqlite3_stmt *read_statement = nil;
        
		if(sqlite3_prepare_v2(database, sql, -1, &read_statement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_text(read_statement, 1, [[[NSString alloc] initWithFormat:@"%d", level] UTF8String], -1, SQLITE_TRANSIENT);
            
            while(sqlite3_step(read_statement) == SQLITE_ROW)
            {
                @try {
                    NSString *QId = @"";
                    if((char *)sqlite3_column_text(read_statement, 0) != NULL)
                        QId=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(read_statement, 0)];
                    
                    NSString *QLevelId = @"";
                    if((char *)sqlite3_column_text(read_statement, 1) != NULL)
                        QLevelId= [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(read_statement, 1)];
                    
                    NSString *QAnswer = @"";
                    if((char *)sqlite3_column_text(read_statement, 2) != NULL)
                        QAnswer= [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(read_statement, 2)];
                    QAnswer = [self decrypt:QAnswer];
                    QAnswer = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:QAnswer] encoding:NSUTF8StringEncoding];

                    NSString *QHint = @"";
                    if((char *)sqlite3_column_text(read_statement, 3) != NULL)
                        QHint=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(read_statement, 3)];
                    QHint = [self decrypt:QHint];
                    QHint = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:QHint] encoding:NSUTF8StringEncoding];

                    NSString *QCategory = @"";
                    if((char *)sqlite3_column_text(read_statement, 4) != NULL)
                        QCategory=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(read_statement, 4)];
                    QCategory = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:QCategory] encoding:NSUTF8StringEncoding];

                    NSString *IsHintShown = @"";
                    if((char *)sqlite3_column_text(read_statement, 5) != NULL)
                        IsHintShown= [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(read_statement, 5)];

                    NSString *IsCharactersRemoved = @"";
                    if((char *)sqlite3_column_text(read_statement, 6) != NULL)
                        IsCharactersRemoved= [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(read_statement, 6)];

                    NSString *IsAnswered = @"";
                    if((char *)sqlite3_column_text(read_statement, 7) != NULL)
                        IsAnswered= [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(read_statement, 7)];
                    
                    TABLE_QUESTIONS *object = [[TABLE_QUESTIONS alloc] initWithId:[QId intValue] QLevelId:QLevelId QAnswer:QAnswer QHint:QHint QCategory:QCategory IsHintShown:[IsHintShown intValue] IsCharactersRemoved:[IsCharactersRemoved intValue] IsAnswered:[IsAnswered intValue]];
                    
                    [questionsArray addObject:object];

                    [QId release];
                    [QAnswer release];
                    [QHint release];
                    [QCategory release];
                    [IsHintShown release];
                    [IsCharactersRemoved release];
                    [IsAnswered release];
                    [object release];
                }
                @catch (NSException *exception) {
                    NSLog(@"exception in read movies %@ ", [exception debugDescription]);
                }
            }
        }
		
        sqlite3_finalize(read_statement);
    }
    sqlite3_close(database);
    
    return questionsArray;
}

+ (BOOL) set_question_answered : (TABLE_QUESTIONS *) question {
  
    sqlite3 *database;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDir stringByAppendingPathComponent:@"questionsArabic.sqlite"];
    NSString *sqlStr;
    
    sqlStr=  [[NSString alloc] initWithFormat:@"UPDATE TABLE_QUESTIONS SET IsAnswered =1 WHERE QId=%d", question.QId];
    
    if(sqlStr){
        if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
            
            sqlite3_stmt *insert_statement;
            const char *sql = [sqlStr UTF8String];
            
            if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            }
            
            int success = sqlite3_step(insert_statement);
            if (success == SQLITE_ERROR) {
                NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
                return NO;
            }
            
            sqlite3_finalize(insert_statement);
            sqlite3_close(database);
            
        }
    }
    return YES;
}

+ (BOOL) set_hint_shown_for_question : (TABLE_QUESTIONS *) question {
    sqlite3 *database;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDir stringByAppendingPathComponent:@"questionsArabic.sqlite"];
    NSString *sqlStr;
    
    sqlStr=  [[NSString alloc] initWithFormat:@"UPDATE TABLE_QUESTIONS SET IsHintShown =1 WHERE QId=%d", question.QId];
    
    if(sqlStr){
        if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
            
            sqlite3_stmt *insert_statement;
            const char *sql = [sqlStr UTF8String];
            
            if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            }
            
            int success = sqlite3_step(insert_statement);
            if (success == SQLITE_ERROR) {
                NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
                return NO;
            }
            
            sqlite3_finalize(insert_statement);
            sqlite3_close(database);
            
        }
    }
    
    return YES;
}

+ (BOOL) set_images_shown_for_question : (TABLE_QUESTIONS *) question {
    sqlite3 *database;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDir stringByAppendingPathComponent:@"questionsArabic.sqlite"];
    NSString *sqlStr;
    
    sqlStr=  [[NSString alloc] initWithFormat:@"UPDATE TABLE_QUESTIONS SET IsImagesShown =1 WHERE QId=%d", question.QId];
    
    if(sqlStr){
        if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
            
            sqlite3_stmt *insert_statement;
            const char *sql = [sqlStr UTF8String];
            
            if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            }
            
            int success = sqlite3_step(insert_statement);
            if (success == SQLITE_ERROR) {
                NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
                return NO;
            }
            
            sqlite3_finalize(insert_statement);
            sqlite3_close(database);
            
        }
    }
    
    return YES;
}

+ (BOOL) set_characters_removed_for_question : (TABLE_QUESTIONS *) question {
    sqlite3 *database;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDir stringByAppendingPathComponent:@"questionsArabic.sqlite"];
    NSString *sqlStr;
    
    sqlStr=  [[NSString alloc] initWithFormat:@"UPDATE TABLE_QUESTIONS SET IsCharactersRemoved =1 WHERE QId=%d", question.QId];
    
    if(sqlStr){
        if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
            
            sqlite3_stmt *insert_statement;
            const char *sql = [sqlStr UTF8String];
            
            if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            }
            
            int success = sqlite3_step(insert_statement);
            if (success == SQLITE_ERROR) {
                NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
                return NO;
            }
            
            sqlite3_finalize(insert_statement);
            sqlite3_close(database);
            
        }
    }
    
    return YES;
}

+ (NSString*)encrypt:(NSString*)str {
    return [FBEncryptorAES encryptBase64String:str
                                     keyString:@"bla@bla34$ttme"
                                    separateLines:YES];
}

+ (NSString*)decrypt:(NSString*)str {
    return [FBEncryptorAES decryptBase64String:str
                                              keyString:@"bla@bla34$ttme"];
}


+ (BOOL) update_question902_hint : (NSString *) hint {
    sqlite3 *database;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDir stringByAppendingPathComponent:@"questionsArabic.sqlite"];

    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        const char * sql = "UPDATE TABLE_QUESTIONS SET QHint = ? WHERE QId=902";
        sqlite3_stmt *update_statement = nil;

        if(sqlite3_prepare_v2(database, sql, -1, &update_statement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_text(update_statement, 1, [[self encrypt:hint] UTF8String], -1, SQLITE_TRANSIENT);
        }
        
        int success = sqlite3_step(update_statement);
        if (success == SQLITE_ERROR){
            NSLog(@"Error: failed to UPDATE the database with message '%s'.", sqlite3_errmsg(database));
        }
        else {
            NSLog(@"Update is done");
        }
        sqlite3_finalize(update_statement);
    }
    
    sqlite3_close(database);
    
    return YES;
}

+ (BOOL) update_questions : (NSMutableArray *) fixesArr {
    sqlite3 *database;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDir stringByAppendingPathComponent:@"questionsArabic.sqlite"];
    
    for (int i =0; i < [fixesArr count]; i++) {
        NSMutableDictionary *dict = [fixesArr objectAtIndex:i];

        if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
            const char * sql = "UPDATE TABLE_QUESTIONS SET QAnswer =? , QHint=? WHERE QId=?";
            sqlite3_stmt *update_statement = nil;
            
            if(sqlite3_prepare_v2(database, sql, -1, &update_statement, NULL) == SQLITE_OK)
            {
                sqlite3_bind_text(update_statement, 1, [[self encrypt:[dict objectForKey:@"answer"]] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(update_statement, 2, [[self encrypt:[dict objectForKey:@"hint"]] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(update_statement, 3, [[[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[dict objectForKey:@"questionId"]] encoding:NSUTF8StringEncoding] UTF8String], -1, SQLITE_TRANSIENT);
            }
            
            int success = sqlite3_step(update_statement);
            if (success == SQLITE_ERROR){
                NSLog(@"Error: failed to UPDATE the database with message '%s'.", sqlite3_errmsg(database));
            }
            else {
                NSLog(@"Update is done");
            }
            sqlite3_finalize(update_statement);
        }
        sqlite3_close(database);
    }
    
    return YES;
}


@end
