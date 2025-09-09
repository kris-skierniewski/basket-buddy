//
//  UITextFieldExtensions.swift
//  price tracker
//
//  Created by Kris Skierniewski on 30/09/2024.
//

import UIKit

extension UITextField {
    
    func hasValidEmailAddress() -> Bool {
        
        guard let text = text else {
            return false
        }
        
        if text.isEmpty {
            return false
        }
        
        if text.contains("@") == false {
            return false
        }
        
        
        return true
    }
    
    
}
