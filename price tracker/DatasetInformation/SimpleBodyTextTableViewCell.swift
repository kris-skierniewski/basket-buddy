//
//  SimpleBodyTextTableViewCell.swift
//  price tracker
//
//  Created by Kris Skierniewski on 16/09/2025.
//

class SimpleBodyTextTableViewCell: UITableViewCell {
    
    static var identifier = "SimpleBodyTextTableViewCell"
    
    @IBOutlet private weak var bodyLabel: UILabel!
    
    
    func update(with text: String) {
        bodyLabel.text = text
    }
    
}
