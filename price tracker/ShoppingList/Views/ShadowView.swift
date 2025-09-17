//
//  ShadowView.swift
//  price tracker
//
//  Created by Kris Skierniewski on 17/10/2024.
//

import UIKit

class ShadowView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 2, height: 2)
    }
}
