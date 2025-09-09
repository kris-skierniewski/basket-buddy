//
//  RoundedBorderView.swift
//  price tracker
//
//  Created by Kris Skierniewski on 17/10/2024.
//

import UIKit

class RoundedBorderView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 15
        backgroundColor = .systemGray6
    }
    
}
