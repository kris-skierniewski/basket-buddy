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
    
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var cheapestShopLabel: UILabel!
    
    var onInfoButtonTapped: (() -> Void)?
    
    func update(forProduct product: ShoppingListProduct, currency: Currency) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: nameLabel.font ?? UIFont.systemFont(ofSize: 17),
            .foregroundColor: nameLabel.textColor ?? UIColor.label,
            .strikethroughStyle: product.isChecked ? NSUnderlineStyle.single.rawValue : 0
        ]
        
        nameLabel.attributedText = NSAttributedString(string: product.productWithPrices.product.name, attributes: attributes)
        
        descriptionLabel.text = product.productWithPrices.product.description
        
        if let cheapestPriceRecord = product.productWithPrices.cheapestPrice {
            priceLabel.text = String(format: "\(currency.symbol)%.2f", cheapestPriceRecord.price.price)
            cheapestShopLabel.text = cheapestPriceRecord.shop.name
        } else {
            priceLabel.text = nil
            cheapestShopLabel.text = nil
        }
    }
    
    @IBAction private func infoButtonTapped() {
        onInfoButtonTapped?()
    }
}
