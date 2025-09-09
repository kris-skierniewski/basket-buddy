//
//  SimpleTableViewHeaderView.swift
//  price tracker
//
//  Created by Kris Skierniewski on 22/10/2024.
//

import UIKit

class SimpleTableViewHeaderView: UIView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //?
    }
    
    func updateWithTitle(_ title: String) {
        titleLabel.text = title
    }
}
