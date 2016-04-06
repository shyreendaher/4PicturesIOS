//
//  Cryptography.h
//  Classes
//
//  Created by eurisko on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

#import "NSDataAdditions.h"
#import "Utils.h"

@interface Cryptography : NSObject

+ (NSString*) getKey;
+ (NSString *) SHA1 : (NSString *) text;
+ (NSString *)sha1:(NSString *)str;
+ (NSString *) TripleDES:(NSString *) plainText algo:(CCOperation)encryptOrDecrypt key:(NSString *) key;

+ (NSData *)initCipherData:(NSData *)data key:(NSString*)key;
+ (NSData *)initDecipherData:(NSData *)data key:(NSString*)key;

@end
