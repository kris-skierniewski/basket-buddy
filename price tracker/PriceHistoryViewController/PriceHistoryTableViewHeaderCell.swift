//
//  PriceHistoryHeaderCell.swift
//  price tracker
//
//  Created by Kris Skierniewski on 22/10/2024.
//

import UIKit

class PriceHistoryTableViewHeaderCell: UITableViewCell {
    
    static let identifier = "PriceHistoryTableViewHeaderCell"
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    func updateWithTitle(_ title: String) {
        titleLabel.text = title
    }
    
}
