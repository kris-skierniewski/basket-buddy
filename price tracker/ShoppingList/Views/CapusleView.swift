//
//  CapusleView.swift
//  price tracker
//
//  Created by Kris Skierniewski on 18/10/2024.
//

import UIKit

class CapsuleView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = bounds.height/2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height/2
    }
}
