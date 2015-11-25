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

class StoreHandler
{
public:
    static StoreHandler* getInstance();
    StoreHandler();
    
    void requestProductPrice(const char* json);
    void buy(const char *str);
    
    void setSkProducts(void *products);
    void addIOSProduct(IOSProduct *product);
    
private:
    IOSProduct *iOSProductByIdentifier(const char *identifier);
    void paymentWithProduct(IOSProduct *iosProduct, int quantity = 1);
    
    void *skProducts = NULL;
    std::vector<IOSProduct *> iOSProducts;
};
#endif
