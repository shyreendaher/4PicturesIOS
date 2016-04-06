//
//  Utils.h
//  WaterfrontCity
//
//  Created by eurisko on 3/12/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (long long) dateDifference : (NSString *) origDate;
+ (NSString *) getUTCFormateDate:(NSDate *)localDate;
+ (NSString *) local_date_for : (NSString *) origDate with_format : (NSString *) origFormat;
+ (NSString*) get_current_date;
+ (BOOL)date:(NSString*) dateStr isBetweenDate:(NSString*) beginDateStr andDate:(NSString*) endDateStr;
+ (NSString *) cleanupString:(NSString *)theString;
+ (NSString *) Base64Encode:(NSData *)data;
+ (NSString *) base64EncodingFor : (NSString*) str;
+ (NSString *) reverseString : (NSString*) str;
+ (NSString *) select6caractersAtIndex : (NSInteger [])index FromString : (NSString*) str;
+ (NSString *) generateRandomStringOfLength: (int) len;
+ (NSString *) Concatenate2String : (NSString*) str1 : (NSString*) str2;
+ (BOOL) checkIfString : (NSString*) string containsString:(NSString *)str;
+ (NSString*) commaSeperatedNumber : (NSString*) number  WithLanguage : (int) languageFlag;

+ (BOOL) isValidEmail:(NSString *)checkString;
+ (BOOL) isNumbersOnly:(NSString *)checkString;

+ (NSString *)dateDiff:(NSString *)origDate;
+ (NSString *)dateTransform:(NSString *)origDate FromFormat : (NSString*) origFormat ToFormat : (NSString*) destFormat;

+ (BOOL) IsArabicIncluded : (NSString*) text;

+ (NSString*) CapitalWordOF : (NSString*) text;

+ (NSString*) EnglishNumberToArabic : (NSString*) englishNumber;
+ (NSString*) ArabicNumberToEnglish : (NSString*) arabicNumber;

@end
