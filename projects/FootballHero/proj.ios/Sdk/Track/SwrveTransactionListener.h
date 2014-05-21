#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "SwrveTransactionCompleteListener.h"

@interface SwrveTransactionListener : NSObject <SKPaymentTransactionObserver>

-(instancetype)initWithPaymentQueue:(SKPaymentQueue*) paymentQueue andTransactionCompleteListener:(id<SwrveTransactionCompleteListener>) listener;

@end
