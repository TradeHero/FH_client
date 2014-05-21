#import "SwrveTransactionListener.h"

@class SwrveProductFinder;

@interface SwrveTransactionListener()
@property (retain, nonatomic) id<SwrveTransactionCompleteListener> listener;
// Store a set of pending request delegates to keep iOS ARC happy.
@property (retain, nonatomic) NSMutableSet* pendingProductRequests;
-(void)product:(SKProduct*)product wasFoundForTransaction:(SKPaymentTransaction*)transaction;
-(void)productFindRequestCompleted:(id)finder;
@end

// Finder
@interface SwrveProductFinder : NSObject

- (instancetype)initWithTransactionCompleteListener:(SwrveTransactionListener*)listener andTransaction:(SKPaymentTransaction*)transaction;

@end

@interface SwrveProductFinder() <SKProductsRequestDelegate>
@property (nonatomic, retain) SwrveTransactionListener* listener;
@property (nonatomic, retain) SKPaymentTransaction* transaction;
@property (nonatomic, retain) SKProductsRequest* productsRequest;

@end

@implementation SwrveProductFinder

-(instancetype)initWithTransactionCompleteListener:(SwrveTransactionListener*)listener andTransaction:(SKPaymentTransaction*)transaction {
    self = [super init];
    if (self) {
        self.listener = listener;
        self.transaction = transaction;

        NSString* product = transaction.payment.productIdentifier;
        NSSet* productIdentifers = [NSSet setWithObject:product];
        NSLog(@"Initiated product request for for %@", product);
        self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifers];
        self.productsRequest.delegate = self;
        [self.productsRequest start]; // go!
    }
    return self;
}

// There are 3 callbacks that can be fired from a payment request.
// - requestDidFinish:
// - didFailWithError:
// - didReceiveResponse:
// It is only safe to unregister a delegate after the request has finished, or
// errored.
// StoreKit will call didReceiveResponse and then call requestDidFinish.
// Read this thread before changing any of this code.
// https://github.com/mattt/CargoBay/issues/33
- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"Finished product request");
    [self.listener productFindRequestCompleted:self];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Error loading products %@", error);
    [self.listener productFindRequestCompleted:self];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    for (SKProduct* product in [response products]) {
        NSLog(@"Received product request response for %@", [product productIdentifier]);
        [self.listener product:product wasFoundForTransaction:self.transaction];
    }
}

@end

@implementation SwrveTransactionListener

-(instancetype)initWithPaymentQueue:(SKPaymentQueue*) paymentQueue andTransactionCompleteListener:(id<SwrveTransactionCompleteListener>) listener {
    self = [super init];
    if (self != nil) {
        self.listener = listener;
        self.pendingProductRequests = [[NSMutableSet alloc] init];
        [paymentQueue addTransactionObserver:self];
    }
    return self;
}

/*
#define TRANS_ENUM_CASE(x) case (x): state = @""#x; break;
-(void)log:(SKPaymentTransaction*)transaction {
    NSString* state = @"unknown";
    switch (transaction.transactionState) {
        TRANS_ENUM_CASE(SKPaymentTransactionStatePurchasing);
        TRANS_ENUM_CASE(SKPaymentTransactionStatePurchased);
        TRANS_ENUM_CASE(SKPaymentTransactionStateFailed);
        TRANS_ENUM_CASE(SKPaymentTransactionStateRestored);
    }
    NSLog(@"Transaction %@ %@ for product %@", state, transaction.transactionIdentifier, transaction.payment.productIdentifier);
}
#undef TRANS_ENUM_CASE
 */

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {

    for (SKPaymentTransaction* transaction in transactions) {
        //[self log:transaction];
        switch ([transaction transactionState]) {
            case SKPaymentTransactionStatePurchased:
                [self transactionComplete:transaction];
                break;

            default:
                // Ignore other transaction states.
                break;
        }
    }
}

- (void)transactionComplete:(SKPaymentTransaction*)transaction {

    NSString* transactionIdentifier = [transaction transactionIdentifier];
    NSString* productIdentifier = [[transaction payment] productIdentifier];
    NSLog(@"Swrve received product data for transaction %@ and product %@", transactionIdentifier, productIdentifier);

    SwrveProductFinder* finder = [[SwrveProductFinder alloc] initWithTransactionCompleteListener:self andTransaction:transaction];
    // Add a reference to the finder to keep it alive.
    [self.pendingProductRequests addObject:finder];
}

-(void)product:(SKProduct*)product wasFoundForTransaction:(SKPaymentTransaction*)transaction{
    [self.listener transactionComplete:transaction forProduct:product];
}

-(void)productFindRequestCompleted:(id)finder {
    [self.pendingProductRequests removeObject:finder];
}

@end

