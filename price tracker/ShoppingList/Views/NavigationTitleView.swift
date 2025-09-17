//
//  NavigationTitleView.swift
//  price tracker
//
//  Created by Kris Skierniewski on 09/09/2025.
//

class NavigationTitleView: UIView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    func updateWith(title: String, subtitle: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
}
