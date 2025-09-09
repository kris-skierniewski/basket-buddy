//
//  SearchProductTableViewCell.swift
//  price tracker
//
//  Created by Kris Skierniewski on 09/09/2025.
//

class SearchProductsTableViewCell: UITableViewCell {
    
    static let identifier = "SearchProductsTableViewCell"
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var cheapestShopLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var myBackgroundView: UIView!
    
    func updateForRow(_ row: SearchProductsRow, currency: Currency) {
        nameLabel.text = row.product.product.name
        descriptionLabel.text = row.product.product.description
        
        if row.isInShoppingList {
            statusLabel.text = "IN SHOPPING LIST"
        } else if !row.exists {
            statusLabel.text = "NEW ITEM"
        } else {
            statusLabel.text = nil
        }
        
        if let cheapestPriceRecord = row.product.cheapestPrice {
            priceLabel.text = String(format: "\(currency.symbol)%.2f", cheapestPriceRecord.price.price)
            cheapestShopLabel.text = cheapestPriceRecord.shop.name
        } else {
            priceLabel.text = nil
            cheapestShopLabel.text = nil
        }
        
        iconImageView.image = UIImage(named: row.product.product.category.iconName)?.withRenderingMode(.alwaysTemplate)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        myBackgroundView.alpha = selected ? 0 : 1
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        myBackgroundView.alpha = highlighted ? 0 : 1
    }
    
}
