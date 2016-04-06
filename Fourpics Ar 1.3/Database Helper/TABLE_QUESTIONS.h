//
//  TABLE_QUESTIONS.h
//  What's the movie
//
//  Created by eurisko on 4/9/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TABLE_QUESTIONS : NSObject {

}

@property (nonatomic)  int QId;
@property (nonatomic, retain) NSString *QLevelId;
@property (nonatomic, retain) NSString *QAnswer;
@property (nonatomic, retain) NSString *QHint;
@property (nonatomic, retain) NSString *QCategory;

@property (nonatomic) BOOL IsHintShown;
@property (nonatomic) BOOL IsCharactersRemoved;
@property (nonatomic) BOOL IsAnswered;


-(id) initWithId:(int)qid QLevelId:(NSString *)qlid QAnswer:(NSString *)qa QHint:(NSString *)qh QCategory: (NSString*)qcat IsHintShown:(BOOL)ihs IsCharactersRemoved:(BOOL)icr IsAnswered: (BOOL) isan;

- (NSString *) toString;

@end
