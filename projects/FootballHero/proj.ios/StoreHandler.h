//
//  StoreHandler.h
//  FootballHero
//
//  Created by SpiritRain on 15/11/3.
//
//

#ifndef FootballHero_StoreHandler_h
#define FootballHero_StoreHandler_h

#include <string>
#include <vector>


#define PRODUCT(x)   @"item($x)"


class IOSProduct
{
public:
    std::string productIdentifier;
    std::string localizedTitle;
    std::string localizedDescription;
    std::string localizedPrice;// has be localed, just display it on UI.
    bool isValid;
    int index;//internal use : index of skProducts
};

typedef enum {
    IOSIAP_PAYMENT_PURCHASING,// just notify, UI do nothing
    IOSIAP_PAYMENT_PURCHAED,// need unlock App Functionality
    IOSIAP_PAYMENT_FAILED,// remove waiting on UI, tall user payment was failed
    IOSIAP_PAYMENT_RESTORED,// need unlock App Functionality, consumble payment No need to care about this.
    IOSIAP_PAYMENT_REMOVED,// remove waiting on UI
} IOSiAPPaymentEvent;

class StoreHandler
{
public:
    static StoreHandler* getInstance();
    
    void buy(int type);
    
    void requestProducts();
    IOSProduct *iOSProductByIdentifier(std::string &identifier);
    void paymentWithProduct(IOSProduct *iosProduct, int quantity = 1);

    void *skProducts;// object-c SKProduct
    void *skTransactionObserver;// object-c TransactionObserver
    std::vector<IOSProduct *> iOSProducts;
};
#endif
