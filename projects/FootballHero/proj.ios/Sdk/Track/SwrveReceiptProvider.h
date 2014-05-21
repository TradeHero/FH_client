#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

// The SwrveReceiptProvider takes a transaction and returns a base-64 encoded
// version of the receipt that transaction.
// The location of the receipt data and how to base 64 encode this data differs
// between different versions of iOS, hence the need to create an abstraction.
@interface SwrveReceiptProvider : NSObject

- (NSString*)base64EncodedReceiptForTransaction:(SKPaymentTransaction*)transaction;

@end
