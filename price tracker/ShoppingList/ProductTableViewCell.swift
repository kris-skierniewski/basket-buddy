//
//  ProductTableViewCell.swift
//  price tracker
//
//  Created by Kris Skierniewski on 05/09/2025.
//

class ProductTableViewCell: UITableViewCell {
    
    static let identifier = "ProductTableViewCell"
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    
    func update(forProduct product: Product) {
        nameLabel.text = product.name
        descriptionLabel.text = product.description
    }
    
    func update(forProduct product: ShoppingListProduct) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: nameLabel.font ?? UIFont.systemFont(ofSize: 17),
            .foregroundColor: nameLabel.textColor ?? UIColor.label,
            .strikethroughStyle: product.isChecked ? NSUnderlineStyle.single.rawValue : 0
        ]
        
        nameLabel.attributedText = NSAttributedString(string: product.productWithPrices.product.name, attributes: attributes)
        
        descriptionLabel.text = product.productWithPrices.product.description
    }
}
