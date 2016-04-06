//
//  LivesCounter.m
//  4Picture1Number
//
//  Created by eurisko on 5/27/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "LivesCounter.h"

#define NumberOfMaxLife 5
#define TimeForNewLife 30 // in minutes

int numberOfLife;

@implementation LivesCounter
@synthesize timer, lives;

- (id) initWithLives : (int) l {
    if (self = [super init]) {
        numberOfLife = l;
        if(numberOfLife < NumberOfMaxLife){
            [self startLifeTimer];
        }
    }
    return self;
}

- (void) startLifeTimer {
    NSLog(@"startLifeTimer");
    if([self.timer isValid])
    {	[self.timer invalidate];
        self.timer=nil;
    }
    self.timer=[NSTimer scheduledTimerWithTimeInterval:TimeForNewLife*60 target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
}

- (void) stopLifeTimer {
    if([self.timer isValid])
    {	[self.timer invalidate];
        self.timer=nil;
    }
}

- (void) fireTimer:(NSTimer *)aTimer {
    
    if (numberOfLife < NumberOfMaxLife) {
        numberOfLife++;
        [self setLife:numberOfLife IsDateCorrect:YES];
    }else {
        if([self.timer isValid])
        {	[self.timer invalidate];
            self.timer=nil;
        }
    }
}

- (void) restartLifeTimerAfterBackground : (BOOL) isDateCorrect{
    NSLog(@"restartLifeTimerAfterBackground");
    if([self.timer isValid])
    {	[self.timer invalidate];
        self.timer=nil;
    }
    
    if(numberOfLife >= NumberOfMaxLife)
        return ;
        
    long long diffrenceInSeconds = [self dateDifference:[self getLastDate]];
    long long diffrenceInMinutes = diffrenceInSeconds/60;

    int life = (int)diffrenceInMinutes/TimeForNewLife;
    long long remaingMinutes = diffrenceInMinutes%TimeForNewLife;
    long long remaingTimeInSeconds =  remaingMinutes*60 + diffrenceInSeconds%60;

    if(life == 0) {
        if (remaingMinutes != 0 || remaingTimeInSeconds != 0) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setValue:[[NSString alloc] initWithFormat:@"%lld", remaingMinutes] forKey:@"minutes"];
            [dict setValue:[[NSString alloc] initWithFormat:@"%lld", remaingTimeInSeconds] forKey:@"remaingTimeInSeconds"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StartTimerWith" object:self userInfo:dict];
        }else if(remaingMinutes == 0){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StartTimer" object:nil];
        }
        
        if(isDateCorrect == 1 && [self getLastDate] == NULL)
            [self saveLastDate];
    }else {
        numberOfLife = numberOfLife + life;
        if(numberOfLife >= NumberOfMaxLife)
            numberOfLife = NumberOfMaxLife;

        if(isDateCorrect)
            [self saveLastDate];
        
        self.lives = numberOfLife;
        
        if(self.lives < NumberOfMaxLife) {
            if (remaingMinutes != 0) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setValue:[[NSString alloc] initWithFormat:@"%lld", remaingMinutes] forKey:@"minutes"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"StartTimerWith" object:self userInfo:dict];
            } else
                [[NSNotificationCenter defaultCenter] postNotificationName:@"StartTimer" object:nil];
            
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StopTimer" object:nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setLives" object:nil];
    }
    
}

- (void) setLifeForWrongDate {
    if(self.lives < NumberOfMaxLife) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StartTimer" object:nil];
        
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StopTimer" object:nil];
    }
}

- (void) setLife : (int) l IsDateCorrect : (BOOL) isDateCorrect{
    
    if(isDateCorrect && (l>self.lives || self.lives == NumberOfMaxLife))
        [self saveLastDate];
    
    numberOfLife = l;
    self.lives = l;
    if(self.lives < NumberOfMaxLife) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StartTimer" object:nil];

    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StopTimer" object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setLives" object:nil];
}

- (void) saveLastDate {
    [SimpleKeychain save:@"LastDate" data:[Utils get_current_date]];
}

- (NSString *) getLastDate {
    return [SimpleKeychain load:@"LastDate"];
}

- (long long) calculateLivesCountForTime : (NSString*) time {
    return [self dateDifference:time]/TimeForNewLife;
}

- (long long) dateDifference : (NSString *) origDate {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSDate *convertedDate = [df dateFromString:origDate];
    [df release];
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    long long diff = round(ti);
    return diff;
}

@end
