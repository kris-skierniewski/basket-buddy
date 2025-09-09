//
//  ProductTableViewCell.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2024.
//

import UIKit

class ProductWithPriceTableViewCell: UITableViewCell {
    
    static let identifier = "ProductWithPriceTableViewCell"
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var cheapestShopLabel: UILabel!
    
    @IBOutlet private weak var iconImageView: UIImageView!
    
    @IBOutlet private weak var shoppingListIconView: UIView!
    
    @IBOutlet private weak var myBackgroundView: UIView!
    
    
    func update(forProduct product: ProductWithPrices, isInShoppingList: Bool, currency: Currency) {
        nameLabel.text = product.product.name
        descriptionLabel.text = product.product.description
        
        if let cheapestPriceRecord = product.cheapestPrice {
            priceLabel.text = String(format: "\(currency.symbol)%.2f", cheapestPriceRecord.price.price)
            cheapestShopLabel.text = cheapestPriceRecord.shop.name
        } else {
            priceLabel.text = nil
            cheapestShopLabel.text = nil
        }
        
        iconImageView.image = UIImage(named: product.product.category.iconName)?.withRenderingMode(.alwaysTemplate)
        
        shoppingListIconView.isHidden = !isInShoppingList
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        myBackgroundView.alpha = selected ? 0 : 1
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        myBackgroundView.alpha = highlighted ? 0 : 1
    }
    
}
