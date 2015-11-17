//
//  StoreHandler.m
//  FootballHero
//
//  Created by SpiritRain on 15/11/3.
//
//


#include "StoreHandler.h"
#include "Store.h"
#import <StoreKit/StoreKit.h>

@interface iAPProductsRequestDelegate : NSObject<SKProductsRequestDelegate>
@property (nonatomic, assign) StoreHandler *iosiap;
@end

@interface iAPTransactionObserver : NSObject<SKPaymentTransactionObserver>
@property (nonatomic, assign) StoreHandler *iosiap;
@end

@implementation iAPTransactionObserver
// 1.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"---------SKPaymentTransactionStatePurchasing transactions count:%d", transactions.count);
    for (SKPaymentTransaction *transaction in transactions) {
        std::string identifier([transaction.payment.productIdentifier UTF8String]);
        IOSiAPPaymentEvent event;
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"---------SKPaymentTransactionStatePurchasing %s------------", identifier.c_str());
                event = IOSIAP_PAYMENT_PURCHASING;
                return;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"---------SKPaymentTransactionStatePurchased %s------------", identifier.c_str());
                event = IOSIAP_PAYMENT_PURCHAED;
                Utils::Store::sharedDelegate()->buyResult(true);
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"---------SKPaymentTransactionStateFailed %s------------", identifier.c_str());
                event = IOSIAP_PAYMENT_FAILED;
                NSLog(@"==ios payment error:%@", transaction.error);
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"---------SKPaymentTransactionStateRestored %s------------", identifier.c_str());
                // NOTE: consumble payment is NOT restorable
                event = IOSIAP_PAYMENT_RESTORED;
                break;
        }
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }
}

// 3.
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSLog(@"---------removedTransactions------------");
    for (SKPaymentTransaction *transaction in transactions) {
        std::string identifier([transaction.payment.productIdentifier UTF8String]);
    }
}

@end

static StoreHandler* instance;

StoreHandler* StoreHandler::getInstance()
{
    if (instance == NULL)
    {
        instance = new StoreHandler();
        iAPTransactionObserver *observer = [[iAPTransactionObserver alloc] init];
 //       observer.iosiap = this;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:observer];
    }
    return instance;
}


void StoreHandler::buy(int buyType)
{
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"---------StoreHandler::can buy(%d)---------", buyType);
        std::string name;
        switch (buyType) {
            case 1:
                name = "item2";
                 break;
            case 2:
                name = "item3";
                break;
            case 4:
                name = "item5";
                break;
            case 7:
                name = "item6";
                break;
            case 15:
                name = "item4";
                 break;
            default:
                name = "item1";
                break;
        }
        paymentWithProduct(iOSProductByIdentifier(name));
     } else {
        NSLog(@"---------StoreHandler::can not buy(%d)---------", buyType);
    }
}

void StoreHandler::requestProducts()
{
    NSLog(@"---------StoreHandler::requestProducts------------");
    NSMutableSet *set = [NSMutableSet setWithCapacity:6];
    std::vector <std::string>::iterator iterator;
    [set addObject:@"item1"];
    [set addObject:@"item2"];
    [set addObject:@"item3"];
    [set addObject:@"item4"];
    [set addObject:@"item5"];
    [set addObject:@"item6"];
 
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    iAPProductsRequestDelegate *delegate = [[iAPProductsRequestDelegate alloc] init];
    delegate.iosiap = this;
    productsRequest.delegate = delegate;
    [productsRequest start];
}


IOSProduct *StoreHandler::iOSProductByIdentifier(std::string &identifier)
{
    NSLog(@"---------StoreHandler::iOSProductByIdentifier(%s)------------",identifier.c_str());
    std::vector <IOSProduct *>::iterator iterator;
    for (iterator = iOSProducts.begin(); iterator != iOSProducts.end(); iterator++) {
        IOSProduct *iosProduct = *iterator;
        if (iosProduct->productIdentifier == identifier) {
            return iosProduct;
        }
    }
    
    return NULL;
}

void StoreHandler::paymentWithProduct(IOSProduct *iosProduct, int quantity)
{
    NSLog(@"---------StoreHandler::paymentWithProduct------------");
    SKProduct *skProduct = [(NSArray *)(skProducts) objectAtIndex:iosProduct->index];
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:skProduct];
    payment.quantity = quantity;
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
 //   [[SKPaymentQueue defaultQueue]]
}

@implementation iAPProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"-----------收到产品反馈信息--------------");
    NSArray *myProduct = response.products;
    if([myProduct count] == 0){
        NSLog(@"--------------并没有商品------------------");
        return;
    }
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %d", [myProduct count]);
    // populate UI
    for(SKProduct *product in myProduct){
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
    }
    
    // release old
    if (_iosiap->skProducts) {
        [(NSArray *)(_iosiap->skProducts) release];
    }
    // record new product
    _iosiap->skProducts = [response.products retain];
    
    for (int index = 0; index < [response.products count]; index++) {
        SKProduct *skProduct = [response.products objectAtIndex:index];
        
        // check is valid
        bool isValid = true;
        for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
            NSLog(@"invalidIdentifier:%@", invalidIdentifier);
            if ([skProduct.productIdentifier isEqualToString:invalidIdentifier]) {
                isValid = false;
                break;
            }
        }
        
        IOSProduct *iosProduct = new IOSProduct;
        iosProduct->productIdentifier = std::string([skProduct.productIdentifier UTF8String]);
        iosProduct->localizedTitle = std::string([skProduct.localizedTitle UTF8String]);
        iosProduct->localizedDescription = std::string([skProduct.localizedDescription UTF8String]);
        
        // locale price to string
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:skProduct.priceLocale];
        NSString *priceStr = [formatter stringFromNumber:skProduct.price];
        [formatter release];
        iosProduct->localizedPrice = std::string([priceStr UTF8String]);
        
        iosProduct->index = index;
        iosProduct->isValid = isValid;
        _iosiap->iOSProducts.push_back(iosProduct);
    }
    Utils::Store::sharedDelegate()->requestProductResult(true);
}

- (void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"---------requestDidFinish------------");
//    _iosiap->delegate->onRequestProductsFinish();
    [request.delegate release];
    [request release];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"---------didFailWithError------------%@", error);
}

@end
