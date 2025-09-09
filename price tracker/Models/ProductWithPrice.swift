//
//  ProductWithPrice.swift
//  price tracker
//
//  Created by Kris Skierniewski on 02/09/2025.
//

struct ProductWithPrices: Equatable, Comparable {
    
    let product: Product
    var priceHistory: [PriceWithShop]
    
    var cheapestPrice: PriceWithShop? {
        
        var shopDictionary: [String: PriceWithShop] = [:]
        
        priceHistory.forEach({
            if let cheapestPriceForShop = shopDictionary[$0.price.shopId],
               $0.price.perUnitPrice() < cheapestPriceForShop.price.perUnitPrice(),
               $0.price.timestamp > cheapestPriceForShop.price.timestamp {
                shopDictionary[$0.price.shopId] = $0
            } else if shopDictionary[$0.price.shopId] == nil {
                shopDictionary[$0.price.shopId] = $0
            }
        })
        
        var cheapestRecord: PriceWithShop?
        
        for shopId in shopDictionary.keys {
            
            if cheapestRecord == nil {
                cheapestRecord = shopDictionary[shopId]
            }
            
            if shopDictionary[shopId]!.price.perUnitPrice() < cheapestRecord!.price.perUnitPrice() {
                cheapestRecord = shopDictionary[shopId]!
            }
            
            
        }
        
        return cheapestRecord
    }
    
    static func < (lhs: ProductWithPrices, rhs: ProductWithPrices) -> Bool {
        return lhs.product.name.lowercased() < rhs.product.name.lowercased()
    }
    
}
