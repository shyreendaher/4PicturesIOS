//
//  TABLE_QUESTIONS.m
//  What's the movie
//
//  Created by eurisko on 4/9/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "TABLE_QUESTIONS.h"

@implementation TABLE_QUESTIONS

@synthesize QId;
@synthesize QLevelId;
@synthesize QAnswer;
@synthesize QHint;
@synthesize QCategory;

@synthesize IsHintShown;
@synthesize IsCharactersRemoved;
@synthesize IsAnswered;

-(id) initWithId:(int)qid QLevelId:(NSString *)qlid QAnswer:(NSString *)qa QHint:(NSString *)qh QCategory: (NSString*)qcat IsHintShown:(BOOL)ihs IsCharactersRemoved:(BOOL)icr IsAnswered: (BOOL)isan{
    self.QId = qid;
    self.QLevelId = qlid;
    self.QAnswer = qa;
    self.QHint = qh;
    self.QCategory = qcat;
    self.IsHintShown = ihs;
    self.IsCharactersRemoved = icr;
    self.IsAnswered = isan;
    return self;
}

-(void) dealloc {
    self.QLevelId = nil;
    [QLevelId release];
    self.QAnswer = nil;
    [QAnswer release];
    self.QHint = nil;
    [QHint release];
    self.QCategory = nil;
    [QCategory release];
    [super dealloc];
}

- (NSString *) toString {
    return [[[NSString alloc] initWithFormat:@"QId: %d, QLevelId: %@, QAnswer: %@, QHint: %@, QCategory: %@, IsHintShown: %d, IsCharactersRemoved: %d, IsAnswered: %d", self.QId, self.QLevelId, self.QAnswer, self.QHint, self.QCategory, self.IsHintShown, self.IsCharactersRemoved, self.IsAnswered] autorelease];
}

@end
