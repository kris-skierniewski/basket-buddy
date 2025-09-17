//
//  Untitled.swift
//  price tracker
//
//  Created by Kris Skierniewski on 16/09/2025.
//

class DatasetMemberTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var displayNameLabel: UILabel!
    
    static var identifier = "DatasetMemberTableViewCell"
    
    func update(for row: DatasetMemberRow) {
        
        if row.isCurrentUser {
            displayNameLabel.text = "\(row.displayName) (You)"
        } else {
            displayNameLabel.text = row.displayName
        }
        
    }
}
