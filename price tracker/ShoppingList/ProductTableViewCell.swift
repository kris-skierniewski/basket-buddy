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
    private var product: ProductWithPrices?
    
    var onInfoButtonTapped: ((ProductWithPrices) -> Void)?
    
    func update(forProduct product: ShoppingListProduct, currency: Currency) {
        self.product = product.productWithPrices
        let nameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: nameLabel.textColor ?? UIColor.label,
            .strikethroughStyle: product.isChecked ? NSUnderlineStyle.single.rawValue : 0
        ]
        let quantityAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .light),
            .foregroundColor: nameLabel.textColor ?? UIColor.label,
            .strikethroughStyle: product.isChecked ? NSUnderlineStyle.single.rawValue : 0
        ]
        
        let composedName = NSMutableAttributedString(string: product.productWithPrices.product.name, attributes: nameAttributes)
        if product.quantityString.isEmpty == false {
            composedName.append(NSAttributedString(string: "  \(product.quantityString)", attributes: quantityAttributes))
        }
        nameLabel.attributedText = composedName
        
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
        if let product = product {
            onInfoButtonTapped?(product)
        }
    }
}
