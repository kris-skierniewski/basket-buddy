//
//  PriceRecordTableViewCell.swift
//  price tracker
//
//  Created by Kris Skierniewski on 07/09/2024.
//

import UIKit

class PriceRecordTableViewCell: UITableViewCell {
    
    static let identifier = "PriceRecordTableViewCell"
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    
    @IBOutlet private weak var shopNameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var pricePerUnitLabel: UILabel!
    @IBOutlet private weak var quantityAndUnitLabel: UILabel!
    @IBOutlet private weak var notesLabel: UILabel!
    
    func update(withPriceRecord price: PriceWithShop, currency: Currency) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d yyyy"
        
        dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: price.price.timestamp))
        authorLabel.text = price.author.displayName
        
        shopNameLabel.text = price.shop.name
        
        quantityAndUnitLabel.text = price.price.quantityAndUnitString()
        
        pricePerUnitLabel.text = price.price.perUnitPriceString(currency: currency)
        
        priceLabel.text = price.price.priceString(currency: currency)
        
        notesLabel.text = price.price.notes
        
    }
    
}
