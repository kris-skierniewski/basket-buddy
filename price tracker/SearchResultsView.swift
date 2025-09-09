//
//  SearchResultsView.swift
//  price tracker
//
//  Created by Kris Skierniewski on 04/09/2025.
//

class SearchResultsView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var tableview: UITableView!
    private var items: [Any] = []
    private var onItemSelected: ((Any) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func configure(with items: [Any], onItemSelected: @escaping (Any) -> Void) {
        self.items = items
        self.onItemSelected = onItemSelected
        tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        
        if let shop = item as? Shop {
            content.text = shop.name
        } else if let unit = item as? Unit {
            content.text = unit.rawValue
        } else if let currency = item as? Currency {
            content.text = currency.symbol
        } else if let category = item as? ProductCategory {
            content.text = category.rawValue.capitalized
        }
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        onItemSelected?(item)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
