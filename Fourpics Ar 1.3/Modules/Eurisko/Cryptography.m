//
//  Cryptography.m
//  Classes
//
//  Created by eurisko on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Cryptography.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Cryptography

+ (NSString*) getKey {
    return @"7YzGnA1k8X!o6H@q";
}

+ (NSString *) SHA1 : (NSString *) text
{
    const char *cstr = [text cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:text.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+ (NSString *)sha1:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15],
                   result[16], result[17], result[18], result[19]
                   ];
    
    return s;
}



+ (int) roundUpTo8 :(NSString*) input {
    if ([input length] % 8 == 0)
        return [input length];
    return [input length] / 8 * 8 + 8;
}


+ (NSString *) TripleDES:(NSString *) plainText algo :(CCOperation)encryptOrDecrypt key:(NSString *) key {
        
    if(plainText == NULL)
        return NULL;
    
    const void *vplainText;
    size_t plainTextBufferSize;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        NSData *EncryptData = [[NSData alloc] initWithBase64Encoding:plainText];
        plainTextBufferSize = [EncryptData length];
        
        vplainText = ( const void *) [EncryptData bytes];
    }
    else
    {
        plainTextBufferSize = [self roundUpTo8:plainText];
        vplainText = ( const void *) [plainText UTF8String];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    uint8_t iv[kCCBlockSizeDES];
    memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *) [key UTF8String];
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithmDES,
                       (kCCOptionPKCS7Padding & kCCModeCBC),
                       vkey, //"123456789012345678901234", //key
                       kCCKeySizeDES,
                       iv, //"init Vec",
                       vplainText, //"Your Name", //plainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    if (ccStatus == kCCSuccess) NSLog(@"");
    else if (ccStatus == kCCParamError) return @"PARAM ERROR";
    else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
    else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
    else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
    else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
    else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED";
    
    NSString *result;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        NSData *dt = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
        
        NSData * responseData = [[NSData alloc] initWithData:[NSData dataWithData:dt]];
        
        result = [NSString stringWithUTF8String:[responseData bytes]];
        
        if(result == NULL) {
            NSMutableString *bytes = [[NSMutableString alloc] init];
            for (NSUInteger i = 0; i < [dt length]; i++) {
                unsigned char byte;
                [dt getBytes:&byte range:NSMakeRange(i, 1)];
                [bytes appendString:[NSString stringWithFormat:@"%x", byte]];
            }
            
            NSString * str = bytes;
            @try {
                if([str length] % 2 != 0 && [str length]- 1>0)
                    str = [str substringToIndex:[str length]-1];
                //          [bytes appendString:@"0"];
            }
            @catch (NSException *exception) {
                
            }
            NSMutableString * newString = [[NSMutableString alloc] init];
            int i = 0;
            while (i < [str length])
            {
                NSString * hexChar = [str substringWithRange: NSMakeRange(i, 2)];
                int value = 0;
                sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
                [newString appendFormat:@"%c", (char)value];
                i+=2;
            }
            result = [[NSString alloc] initWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes encoding:NSUTF8StringEncoding];
            result = newString;
        }
    }
    else
    {
        NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
        result = [Utils Base64Encode:myData];
    }
    return result;
}

+ (NSData *)initCipherData:(NSData *)data key:(NSString*)key{
    return [self aesOperation:kCCEncrypt OnData:data key:key];
}

+ (NSData *)initDecipherData:(NSData *)data key:(NSString*)key{
    return [self aesOperation:kCCDecrypt OnData:data key:key];
}

+ (NSData *)aesOperation:(CCOperation)op OnData:(NSData *)data key:(NSString*)inKey {
    
    const char * key = [inKey UTF8String];
    NSUInteger dataLength = [data length];
    uint8_t unencryptedData[dataLength + kCCKeySizeAES128];
    size_t unencryptedLength;
    
    CCCrypt(op, kCCAlgorithmAES128, kCCOptionECBMode, key, kCCKeySizeAES128, NULL, [data bytes], dataLength, unencryptedData, dataLength, &unencryptedLength);
    
    return [[NSData alloc] initWithBytes:unencryptedData length:unencryptedLength];//[NSData dataWithBytes:unencryptedData length:unencryptedLength];
}

@end
