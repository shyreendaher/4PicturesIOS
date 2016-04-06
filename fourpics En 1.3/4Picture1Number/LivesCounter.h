//
//  LivesCounter.h
//  4Picture1Number
//
//  Created by eurisko on 5/27/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleKeychain.h"
#import "Utils.h"

@interface LivesCounter : NSObject

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic) int lives;

- (id) initWithLives : (int) l;
- (void) setLifeForWrongDate;
- (void) setLife : (int) l IsDateCorrect : (BOOL) isDateCorrect;
- (void) stopLifeTimer;
- (void) restartLifeTimerAfterBackground : (BOOL) isDateCorrect;

@end
