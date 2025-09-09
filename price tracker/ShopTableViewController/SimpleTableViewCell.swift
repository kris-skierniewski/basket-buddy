//
//  ShopTableViewCell.swift
//  price tracker
//
//  Created by Kris Skierniewski on 07/09/2024.
//

import UIKit

class SimpleTableViewCell: UITableViewCell {
    
    static let identifier = "SimpleTableViewCell"
    
    @IBOutlet private weak var nameLabel: UILabel!
    //private var shop: Shop?
    
    func update(withModel model: SimpleTableViewCellModel) {
        
        //self.shop = shop
        nameLabel.text = model.title
        
    }
    
    
}
