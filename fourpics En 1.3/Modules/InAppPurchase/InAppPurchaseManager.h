//
//  InAppPurchaseManager.h
//  mHealth
//
//  Created by eurisko on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"
#define kInAppPurchaseManagerTransactionRestoreSucceededNotification @"kInAppPurchaseManagerTransactionRestoreSucceededNotification"
#define kInAppPurchaseManagerTransactionRestoreFailedNotification @"kInAppPurchaseManagerTransactionRestoreFailedNotification"
#define kInAppPurchaseManagerTransactionCancelledNotification @"kInAppPurchaseManagerTransactionCancelledNotification"

typedef void(^DownloadCompletedBlock)(NSString *DownloadCompletedBlock);


@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate>
{
    SKProduct *proUpgradeProduct;
    SKProductsRequest *productsRequest;
}
@property (nonatomic, retain)  NSString *  productID;

// public methods
- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseProUpgrade;
- (void) checkPurchasedItems;

@end
