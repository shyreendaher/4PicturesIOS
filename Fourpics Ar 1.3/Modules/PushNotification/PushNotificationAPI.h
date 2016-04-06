//
//  PushNotificationAPI.h
//  Unity-iPhone
//
//  Created by eurisko on 9/17/13.
//
//

#import <Foundation/Foundation.h>

@interface PushNotificationAPI : NSObject
@property(nonatomic, retain) NSMutableData *webData;

- (void) SaveTokenForPushNotification : (NSString*) token andAppID : (NSString*) appId;

@end
