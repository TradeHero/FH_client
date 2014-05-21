#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "SwrveReceiptProvider.h"

@interface SwrveReceiptProvider()
@end

@implementation SwrveReceiptProvider

BOOL SwrveSystemVersionGreaterThan(NSString* desired);

// Return the transaction receipt data from a device running iOS7.
// In this case the data is in a file stored in the main bundle of the app.
static NSString* receipt_ios7() {
    NSData* receipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    if (!receipt) {
        NSLog(@"Error reading receipt from iOS7 device");
        return nil;
    }
    return [receipt base64EncodedStringWithOptions:0];
}

// Return the transaction receipt data from a device that is running iO6.
// This required a reference to the SKPaymentTransaction, since the receipt data
// is embedded inside it.
static NSString* receipt_ios6(SKPaymentTransaction* transaction) {
    NSData* receipt = [transaction transactionReceipt];
    if (!receipt) {
        NSLog(@"Error reading receipt from iOS6 device");
        return nil;
    }
    return [receipt base64Encoding];
}

- (NSString*)base64EncodedReceiptForTransaction:(SKPaymentTransaction*)transaction {
    const int iOS7 = SwrveSystemVersionGreaterThan(@"7.0");

    // Do things differently on iOS7 devices
    if (iOS7) {
        return receipt_ios7();
    } else {
        return receipt_ios6(transaction);
    }
}

@end
