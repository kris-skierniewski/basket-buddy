//
//  PassThroughView.swift
//  price tracker
//
//  Created by Kris Skierniewski on 05/10/2024.
//

import UIKit

class PassThroughView: UIView {
    
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isHidden {
            return false
        }
        return super.point(inside: point, with: event)
    }
}
