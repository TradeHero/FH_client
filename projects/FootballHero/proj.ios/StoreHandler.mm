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
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"---------updatedTransactions count:%d", (int)transactions.count);
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"---------updatedTransactions %s------------", [transaction.payment.productIdentifier UTF8String]);
        if (transaction.transactionState == SKPaymentTransactionStatePurchasing) {
            return;
        } else if (transaction.transactionState == SKPaymentTransactionStatePurchased){
            //消费成功
            NSLog(@"---------updatedTransactions success------------");
            Utils::Store::sharedDelegate()->buyResult(true);
        }
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }
}
@end

static StoreHandler* instance = NULL;

StoreHandler* StoreHandler::getInstance()
{
    if (instance == NULL)
    {
        instance = new StoreHandler();
        iAPTransactionObserver *observer = [[iAPTransactionObserver alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:observer];
    }
    return instance;
}

StoreHandler::StoreHandler(){
}


void StoreHandler::requestProductPrice(const char* data)
{
    NSLog(@"---------StoreHandler::requestProductPrize------------");
    NSError *error = nil;
    NSData *jsonData = [[NSString stringWithUTF8String:data] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableSet *idSet = [NSJSONSerialization JSONObjectWithData:jsonData
                                                          options:NSJSONReadingAllowFragments
                                                            error:&error];
    if (error == NULL)
    {
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:idSet];
        iAPProductsRequestDelegate *delegate = [[iAPProductsRequestDelegate alloc] init];
        delegate.iosiap = this;
        productsRequest.delegate = delegate;
        [productsRequest start];
    } else {
        NSLog(@"error==>%@", error);
    }
}

void StoreHandler::buy(const char *name)
{
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"---------StoreHandler::can buy(%s)---------", name);
        paymentWithProduct(iOSProductByIdentifier(name));
    } else {
        NSLog(@"---------StoreHandler::can not buy(%s)---------", name);
    }
}

void StoreHandler::setSkProducts(void *products){
    if (skProducts) {
        [(NSArray *)skProducts release];
    }
    // record new product
    skProducts = products;
}

void StoreHandler::addIOSProduct(IOSProduct *product){
    iOSProducts.push_back(product);
}

IOSProduct *StoreHandler::iOSProductByIdentifier(const char* identifier)
{
    NSLog(@"---------StoreHandler::iOSProductByIdentifier(%s)------------",identifier);
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
}

@implementation iAPProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *myProduct = response.products;
    NSUInteger count = [myProduct count];
    if(count == 0){
        NSLog(@"--------------并没有商品------------------");
        Utils::Store::sharedDelegate()->requestProductResult("no products", false);
        return;
    }
    _iosiap->setSkProducts([myProduct retain]);
    
    NSMutableArray *productArray = [NSMutableArray arrayWithCapacity:count];
    for (int index = 0; index < count; index++) {
        SKProduct *skProduct = [myProduct objectAtIndex:index];
        NSMutableDictionary *product = [NSMutableDictionary dictionaryWithCapacity:4];
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
        if (skProduct.productIdentifier != NULL){
            iosProduct->productIdentifier = std::string([skProduct.productIdentifier UTF8String]);
            [product setObject:skProduct.productIdentifier forKey:@"id"];
        } else {
            iosProduct->productIdentifier = "";
        }
        
        if (skProduct.localizedTitle != NULL){
            iosProduct->localizedTitle = std::string([skProduct.localizedTitle UTF8String]);
            [product setObject:skProduct.localizedTitle forKey:@"title"];
        } else {
            iosProduct->localizedTitle = "";
        }
        
        if (skProduct.localizedDescription != NULL){
            iosProduct->localizedDescription = std::string([skProduct.localizedDescription UTF8String]);
            [product setObject:skProduct.localizedDescription forKey:@"description"];
        } else {
            iosProduct->localizedDescription = "";
        }
        
        // locale price to string
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:skProduct.priceLocale];
        NSString *priceStr = [formatter stringFromNumber:skProduct.price];
        [formatter release];
        iosProduct->localizedPrice = std::string([priceStr UTF8String]);
        [product setObject:priceStr forKey:@"price"];
        
        iosProduct->index = index;
        iosProduct->isValid = isValid;
        _iosiap->addIOSProduct(iosProduct);
        [productArray addObject:product];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:productArray
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    Utils::Store::sharedDelegate()->requestProductResult([jsonString UTF8String], true);
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
