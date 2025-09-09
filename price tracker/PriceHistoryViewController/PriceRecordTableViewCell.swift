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
    @IBOutlet private weak var shopNameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var pricePerUnitLabel: UILabel!
    @IBOutlet private weak var quantityAndUnitLabel: UILabel!
    @IBOutlet private weak var notesLabel: UILabel!
    
    func update(withPriceRecord priceRecord: Price, shop: Shop, currency: Currency) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d yyyy"
        
        dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: priceRecord.timestamp))
        shopNameLabel.text = shop.name
        
        quantityAndUnitLabel.text = priceRecord.quantityAndUnitString()
        
        pricePerUnitLabel.text = priceRecord.perUnitPriceString(currency: currency)
        
        priceLabel.text = priceRecord.priceString(currency: currency)
        
        notesLabel.text = priceRecord.notes
        
    }
    
}
