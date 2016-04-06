//
//  SimpleKeychain.h
//  Amex
//
//  Created by eurisko on 12/26/12.
//
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

@class SimpleKeychainUserPass;

@interface SimpleKeychain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end