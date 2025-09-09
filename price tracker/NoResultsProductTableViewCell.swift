//
//  NoResultsProductTableViewCell.swift
//  price tracker
//
//  Created by Kris Skierniewski on 17/10/2024.
//

import UIKit

class NoResultsProductTableViewCell: UITableViewCell {
    
    static let identifier = "NoResultsProductTableViewCell"
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var myBackgroundView: UIView!
    
    func updateForSearchString(_ searchString: String) {
        
        if searchString.isEmpty {
            topLabel.text = "It's empty here! Lets get started and add some items."
        } else {
            let boldAttributes: [NSAttributedString.Key: Any] =
            [
                .font: UIFont.systemFont(ofSize: topLabel.font.pointSize, weight: .semibold)
            ]
            
            let fullString = String(format:"I can't find anything for %@, do you want to add this?", searchString)
            let searchStringRange = (fullString as NSString).range(of: searchString)
            
            var attributedString = NSMutableAttributedString(string: fullString)
            attributedString.addAttributes(boldAttributes, range: searchStringRange)
            
            topLabel.attributedText = attributedString
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        myBackgroundView.alpha = selected ? 0 : 1
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        myBackgroundView.alpha = highlighted ? 0 : 1
    }
}
