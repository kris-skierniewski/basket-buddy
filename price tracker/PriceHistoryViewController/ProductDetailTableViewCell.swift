//
//  ProductDetailTableViewCell.swift
//  price tracker
//
//  Created by Kris Skierniewski on 07/09/2024.
//

import UIKit

class ProductDetailTableViewCell: UITableViewCell {
    static let identifier = "ProductDetailTableViewCell"
    
    
    private var product: ProductWithPrices?
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    @IBOutlet private weak var iconImageView: UIImageView!
    
    @IBOutlet private weak var shopNameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var pricePerUnitLabel: UILabel!
    @IBOutlet private weak var quantityAndUnitLabel: UILabel!
    @IBOutlet private weak var notesLabel: UILabel!
    
    @IBOutlet private weak var categoryLabel: UILabel!
    
    @IBOutlet private weak var bestValueViewHiddenConstraint: NSLayoutConstraint!
    
    func update(forProduct product: ProductWithPrices, currency: Currency) {
        self.product = product
        nameLabel.text = product.product.name
        descriptionLabel.text = product.product.description
        
        categoryLabel.text = "Category: \(product.product.category.rawValue.capitalized)"
        
        
        if let priceRecord = product.cheapestPrice {
            shopNameLabel.text = priceRecord.shop.name
            priceLabel.text = priceRecord.price.priceString(currency: currency)
            pricePerUnitLabel.text = priceRecord.price.perUnitPriceString(currency: currency)
            quantityAndUnitLabel.text = priceRecord.price.quantityAndUnitString()
            notesLabel.text = priceRecord.price.notes
            bestValueViewHiddenConstraint.priority = .defaultLow
        } else {
            shopNameLabel.text = nil
            priceLabel.text = nil
            pricePerUnitLabel.text = nil
            quantityAndUnitLabel.text = nil
            notesLabel.text = nil
            bestValueViewHiddenConstraint.priority = .required
        }
        
    }
    
    
}
