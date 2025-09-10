//
//  ShoppingListProductTableViewCell.swift
//  price tracker
//
//  Created by Kris Skierniewski on 12/11/2024.
//

import Foundation

class ShoppingListProductTableViewCell: UITableViewCell {
    
    static let identifier = "ShoppingListProductTableViewCell"
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var checkBoxImageView: UIImageView!
    
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var cheapestShopLabel: UILabel!
    
    func update(withProduct product: ShoppingListProduct) {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: nameLabel.font ?? UIFont.systemFont(ofSize: 17),
            .foregroundColor: nameLabel.textColor ?? UIColor.label,
            .strikethroughStyle: product.isChecked ? NSUnderlineStyle.single.rawValue : 0
        ]
        
        nameLabel.attributedText = NSAttributedString(string: product.productWithPrices.product.name, attributes: attributes)
        
        descriptionLabel.text = product.productWithPrices.product.description
        
        if product.isChecked {
            checkBoxImageView.image = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            checkBoxImageView.image = UIImage(systemName: "checkmark.circle")?.withRenderingMode(.alwaysTemplate)
        }
        
//        if let cheapestPriceRecord = product.productWithPrices.cheapestPrice {
//            priceLabel.text = String(format: "\(currency.symbol)%.2f", cheapestPriceRecord.price.price)
//            cheapestShopLabel.text = cheapestPriceRecord.shop.name
//        } else {
            priceLabel.text = nil
            cheapestShopLabel.text = nil
//        }
        
    }
    
}
