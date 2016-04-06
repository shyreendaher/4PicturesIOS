//
//  Utils.m
//  WaterfrontCity
//
//  Created by eurisko on 3/12/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

//
//  Utils.m
//  Classes
//
//  Created by eurisko on 10/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (long long) dateDifference : (NSString *) origDate {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSDate *convertedDate = [df dateFromString:origDate];
    [df release];
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    long long diff = round(ti / 60);
    return diff;
}

+ (NSString *) getUTCFormateDate:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    [dateFormatter release];
    return dateString;
}

+ (NSString *) local_date_for : (NSString *) origDate with_format : (NSString *) origFormat {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:origFormat];
    NSDate *date = [formatter dateFromString:origDate];
    
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: date];
    NSDate *local_date = [NSDate dateWithTimeInterval: seconds sinceDate: date];
    
    return [[[NSString alloc] initWithFormat:@"%@", [formatter stringFromDate:local_date]] autorelease];
}

+ (NSString*) get_current_date {
    NSDate *date=[NSDate date];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    
    return [[[NSString alloc] initWithFormat:@"%@", [dateFormatter stringFromDate:date]] autorelease];
}

+ (BOOL)date:(NSString*) dateStr isBetweenDate:(NSString*) beginDateStr andDate:(NSString*) endDateStr
{
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:dateStr];
    
    NSDateFormatter *beginDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [beginDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *beginDate = [beginDateFormatter dateFromString:beginDateStr];
    
    NSDateFormatter *endDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [endDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *endDate = [endDateFormatter dateFromString:endDateStr];
    
    if ([date compare:beginDate] == NSOrderedAscending)
    	return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
    	return NO;
    
    return YES;
}

+ (NSString *)cleanupString:(NSString *)theString
{	NSString *theStringTrimmed = [theString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
	NSArray *wordsInStringArray = [theStringTrimmed componentsSeparatedByString:@"\n"];
	NSString *returnString = [[[NSString alloc] init] autorelease];
    
	for (int h=0; h<[wordsInStringArray count]; h++)
	{	NSString *thisElement=[wordsInStringArray objectAtIndex:h];
		returnString =[returnString stringByAppendingString:thisElement];
	}
	return returnString;
}


+ (NSString *)Base64Encode:(NSData *)data {
    //Point to start of the data and set buffer sizes
    int inLength = [data length];
    int outLength = ((((inLength * 4)/3)/4)*4) + (((inLength * 4)/3)%4 ? 4 : 0);
    const char *inputBuffer = [data bytes];
    char *outputBuffer = malloc(outLength);
    outputBuffer[outLength] = 0;
    
    //64 digit code
    static char Encode[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    //start the count
    int cycle = 0;
    int inpos = 0;
    int outpos = 0;
    char temp;
    
    //Pad the last to bytes, the outbuffer must always be a multiple of 4
    outputBuffer[outLength-1] = '=';
    outputBuffer[outLength-2] = '=';
    
    /* http://en.wikipedia.org/wiki/Base64
     Text content   M           a           n
     ASCII          77          97          110
     8 Bit pattern  01001101    01100001    01101110
     
     6 Bit pattern  010011  010110  000101  101110
     Index          19      22      5       46
     Base64-encoded T       W       F       u
     */
    
    
    while (inpos < inLength){
        switch (cycle) {
            case 0:
                outputBuffer[outpos++] = Encode[(inputBuffer[inpos]&0xFC)>>2];
                cycle = 1;
                break;
            case 1:
                temp = (inputBuffer[inpos++]&0x03)<<4;
                outputBuffer[outpos] = Encode[temp];
                cycle = 2;
                break;
            case 2:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xF0)>> 4];
                temp = (inputBuffer[inpos++]&0x0F)<<2;
                outputBuffer[outpos] = Encode[temp];
                cycle = 3;
                break;
            case 3:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xC0)>>6];
                cycle = 4;
                break;
            case 4:
                outputBuffer[outpos++] = Encode[inputBuffer[inpos++]&0x3f];
                cycle = 0;
                break;
            default:
                cycle = 0;
                break;
        }
    }
    NSString *pictemp = [NSString stringWithUTF8String:outputBuffer];
    free(outputBuffer);
    return pictemp;
}


+ (NSString *) base64EncodingFor : (NSString*) str {
    const char *cStr = [str UTF8String];
    
    NSData *base64Data = [[NSData alloc] initWithBytes:cStr length: [str length]];
    // NSString *base64 = [base64Data base64Encoding];// removed due to the warnig
    NSString *base64 = [self Base64Encode:base64Data];
    base64 = [base64 substringToIndex:[base64 length] -1];
    [base64Data release];
    return base64;
}


+ (NSString *) reverseString : (NSString*) str {
    // first retrieve the text of textField1
    NSString *myString = str;
    NSMutableString *reversedString = [NSMutableString string];
    NSInteger charIndex = [myString length];
    while (myString && charIndex > 0) {
        charIndex--;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reversedString appendString:[myString substringWithRange:subStrRange]];
    }
    
    str = reversedString;
    return str;
}


+ (NSString*) select6caractersAtIndex : (NSInteger [])index FromString : (NSString*) str{
    
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int i = 0; i < 6; i++){
        [result appendString:[str substringWithRange:NSMakeRange(index[i], 1)]];
    }
    return result;
}

NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";//@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

+ (NSString *) generateRandomStringOfLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

+ (NSString*) Concatenate2String : (NSString*) str1 : (NSString*) str2 {
    
    return [[[NSString alloc] initWithFormat:@"%@%@", str1, str2] autorelease];
}

+ (NSData *)dataFromHexString:(NSString *)string
{
    NSMutableData *stringData = [[[NSMutableData alloc] init] autorelease];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [string length] / 2; i++) {
        byte_chars[0] = [string characterAtIndex:i*2];
        byte_chars[1] = [string characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [stringData appendBytes:&whole_byte length:1];
    }
    return stringData;
}

+ (BOOL) checkIfString : (NSString*) string containsString:(NSString *)str {
    NSRange isRange = [string rangeOfString:str options:NSCaseInsensitiveSearch];
    if(isRange.location == 0) {
        return YES;
    } else {
        NSRange isSpacedRange = [string rangeOfString:str options:NSCaseInsensitiveSearch];
        if(isSpacedRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

+ (NSString*) commaSeperatedNumber : (NSString*) number  WithLanguage : (int) languageFlag {
    if(languageFlag == 2) {
        NSString *numberAsString = number;
        
        if([self checkIfString:numberAsString containsString:@"٫"])
            return numberAsString;
        
        return [numberAsString stringByAppendingString:@""/*@"٫٠٠"*/];
    }else {
        NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
        [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        NSString *numberAsString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[number floatValue]]];
        
        @try {
            NSCharacterSet *nonNumbersSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789.,"] invertedSet];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            numberAsString = [numberAsString stringByTrimmingCharactersInSet:nonNumbersSet];
        }
        @catch (NSException *exception) {
            
        }
        
        if([self checkIfString:numberAsString containsString:@"."])
            return numberAsString;
        
        return [numberAsString stringByAppendingString:@".00"];
    }
    
}

+ (BOOL) isValidEmail:(NSString *)checkString
{
    if([[self cleanupString:checkString] length] == 0)
        return YES;
    
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (BOOL) isNumbersOnly:(NSString *)checkString {
    checkString = [checkString stringByReplacingOccurrencesOfString:@" " withString:@""];
    if([[self cleanupString:checkString] length] == 0)
        return YES;
    
    if([[checkString stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]] isEqualToString:@""])
        return YES;
    else
        return NO;
    
}

+ (NSString *)dateDiff:(NSString *)origDate {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
    NSDate *convertedDate = [df dateFromString:origDate];
    [df release];
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if(ti < 1) {
    	return @"never";
    } else 	if (ti < 60) {
    	return @"less than a minute ago";
    } else if (ti < 3600) {
    	int diff = round(ti / 60);
    	return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 86400) {
    	int diff = round(ti / 60 / 60);
    	return[NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 2629743) {
    	int diff = round(ti / 60 / 60 / 24);
    	return[NSString stringWithFormat:@"%d days ago", diff];
    } else {
    	return @"never";
    }
}


+ (NSString *)dateTransform:(NSString *)origDate FromFormat : (NSString*) origFormat ToFormat : (NSString*) destFormat {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:origFormat];
    NSDate *date = [formatter dateFromString:origDate];
    
    [formatter setDateFormat:destFormat];
    return [formatter stringFromDate:date];
    
}

+ (BOOL) IsArabicIncluded : (NSString*) text {
    NSArray *arrayOfStrings = [[[NSArray alloc] initWithObjects:@"ا",@"ب",@"ت",@"ث",@"ج",@"ح",@"خ",@"د",@"ذ",@"ر",@"ز",@"س",@"ش",@"ص",@"ض",@"ط",@"ظ",@"ع",@"غ",@"ف",@"ق",@"ك",@"ل",@"م",@"ن",@"ه",@"و",@"ي", @"٠", @"١", @"٢", @"٣", @"٤", @"٥", @"٦", @"٧", @"٨", @"٩", nil] autorelease];
    
    for (NSString *s in arrayOfStrings)
    {
        if ([text rangeOfString:s].location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

+ (NSString*) CapitalWordOF : (NSString*) text {
    text = [text stringByReplacingOccurrencesOfString:@"a" withString:@"A"];
    text = [text stringByReplacingOccurrencesOfString:@"b" withString:@"B"];
    text = [text stringByReplacingOccurrencesOfString:@"c" withString:@"C"];
    text = [text stringByReplacingOccurrencesOfString:@"d" withString:@"D"];
    text = [text stringByReplacingOccurrencesOfString:@"e" withString:@"E"];
    text = [text stringByReplacingOccurrencesOfString:@"f" withString:@"F"];
    text = [text stringByReplacingOccurrencesOfString:@"g" withString:@"G"];
    text = [text stringByReplacingOccurrencesOfString:@"h" withString:@"H"];
    text = [text stringByReplacingOccurrencesOfString:@"i" withString:@"I"];
    text = [text stringByReplacingOccurrencesOfString:@"j" withString:@"J"];
    text = [text stringByReplacingOccurrencesOfString:@"k" withString:@"K"];
    text = [text stringByReplacingOccurrencesOfString:@"l" withString:@"L"];
    text = [text stringByReplacingOccurrencesOfString:@"m" withString:@"M"];
    text = [text stringByReplacingOccurrencesOfString:@"n" withString:@"N"];
    text = [text stringByReplacingOccurrencesOfString:@"o" withString:@"O"];
    text = [text stringByReplacingOccurrencesOfString:@"p" withString:@"P"];
    text = [text stringByReplacingOccurrencesOfString:@"q" withString:@"Q"];
    text = [text stringByReplacingOccurrencesOfString:@"r" withString:@"R"];
    text = [text stringByReplacingOccurrencesOfString:@"s" withString:@"S"];
    text = [text stringByReplacingOccurrencesOfString:@"t" withString:@"T"];
    text = [text stringByReplacingOccurrencesOfString:@"u" withString:@"U"];
    text = [text stringByReplacingOccurrencesOfString:@"v" withString:@"V"];
    text = [text stringByReplacingOccurrencesOfString:@"w" withString:@"W"];
    text = [text stringByReplacingOccurrencesOfString:@"x" withString:@"X"];
    text = [text stringByReplacingOccurrencesOfString:@"y" withString:@"Y"];
    text = [text stringByReplacingOccurrencesOfString:@"z" withString:@"Z"];
    
    return text;
}

+ (NSString*) EnglishNumberToArabic : (NSString*) englishNumber {
    
    englishNumber = [englishNumber stringByReplacingOccurrencesOfString:@"0" withString:@"٠"];
    englishNumber = [englishNumber stringByReplacingOccurrencesOfString:@"1" withString:@"١"];
    englishNumber = [englishNumber stringByReplacingOccurrencesOfString:@"2" withString:@"٢"];
    englishNumber = [englishNumber stringByReplacingOccurrencesOfString:@"3" withString:@"٣"];
    englishNumber = [englishNumber stringByReplacingOccurrencesOfString:@"4" withString:@"٤"];
    englishNumber = [englishNumber stringByReplacingOccurrencesOfString:@"5" withString:@"٥"];
    englishNumber = [englishNumber stringByReplacingOccurrencesOfString:@"6" withString:@"٦"];
    englishNumber = [englishNumber stringByReplacingOccurrencesOfString:@"7" withString:@"٧"];
    englishNumber = [englishNumber stringByReplacingOccurrencesOfString:@"8" withString:@"٨"];
    englishNumber = [englishNumber stringByReplacingOccurrencesOfString:@"9" withString:@"٩"];
    englishNumber = [englishNumber stringByReplacingOccurrencesOfString:@"." withString:@","];
    
    return englishNumber;
}

+ (NSString*) ArabicNumberToEnglish : (NSString*) arabicNumber {
    
    arabicNumber = [arabicNumber stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    arabicNumber = [arabicNumber stringByReplacingOccurrencesOfString:@"٠" withString:@"0"];
    arabicNumber = [arabicNumber stringByReplacingOccurrencesOfString:@"١" withString:@"1"];
    arabicNumber = [arabicNumber stringByReplacingOccurrencesOfString:@"٢" withString:@"2"];
    arabicNumber = [arabicNumber stringByReplacingOccurrencesOfString:@"٣" withString:@"3"];
    arabicNumber = [arabicNumber stringByReplacingOccurrencesOfString:@"٤" withString:@"4"];
    arabicNumber = [arabicNumber stringByReplacingOccurrencesOfString:@"٥" withString:@"5"];
    arabicNumber = [arabicNumber stringByReplacingOccurrencesOfString:@"٦" withString:@"6"];
    arabicNumber = [arabicNumber stringByReplacingOccurrencesOfString:@"٧" withString:@"7"];
    arabicNumber = [arabicNumber stringByReplacingOccurrencesOfString:@"٨" withString:@"8"];
    arabicNumber = [arabicNumber stringByReplacingOccurrencesOfString:@"٩" withString:@"9"];
    
    return arabicNumber;
}



@end
