#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol SwrveTransactionCompleteListener <NSObject>

@required

- (void)transactionComplete:(SKPaymentTransaction*)transaction forProduct:(SKProduct*)product;

@end
