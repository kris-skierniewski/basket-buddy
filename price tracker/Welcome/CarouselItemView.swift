//
//  CarouselItemView.swift
//  price tracker
//
//  Created by Kris Skierniewski on 07/10/2024.
//

import UIKit

class CarouselItemModel {
    let image: UIImage
    let title: String
    let description: String
    
    init(image: UIImage, title: String, description: String) {
        self.image = image
        self.title = title
        self.description = description
    }
}

class CarouselItemView: UIView {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    @IBOutlet private weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    
    private weak var containingScrollView: UIView?
    
    func updateForModel(_ model: CarouselItemModel, parentScrollView: UIView?) {
        imageView.image = model.image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(named: "AccentColor")
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        containingScrollView = parentScrollView
    }
    
    override func layoutSubviews() {
        if let container = containingScrollView {
            widthConstraint.constant = container.bounds.width
            heightConstraint.constant = container.bounds.height
            
        }
    }
    
}
