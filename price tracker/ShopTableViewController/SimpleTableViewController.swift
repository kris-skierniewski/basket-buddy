//
//  ShopTableViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 07/09/2024.
//

import UIKit

class SimpleTableViewCellModel {
    let title: String
    let didSelectBlock: (() -> Void)?
    
    init(title: String, didSelectBlock: (() -> Void)?) {
        self.title = title
        self.didSelectBlock = didSelectBlock
    }
}

class SimpleTableViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var cellModels: [SimpleTableViewCellModel] = []
    var filteredCellModels: [SimpleTableViewCellModel] = []
    
    var contentHeight: CGFloat {
        
        let cellHeight = tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.bounds.height ?? 0
        let numberOfCells = filteredCellModels.count > 2 ? 3 : filteredCellModels.count
        return cellHeight * CGFloat(numberOfCells)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: SimpleTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SimpleTableViewCell.identifier)
        
    }
    
    func filter(withSearchString searchString: String) {
        if searchString == "" {
            filteredCellModels = cellModels
        } else {
            filteredCellModels = cellModels.filter({
                //TODO: add fuzzy search here?
                $0.title.lowercased().contains(searchString.lowercased().trimmingCharacters(in: .whitespaces))
            })
        }
        tableView.reloadData()
    }
    
    func updateCellModels(_ updatedCellModels: [SimpleTableViewCellModel]) {
        cellModels = updatedCellModels
        filteredCellModels = cellModels
        tableView.reloadData()
    }
    
}

extension SimpleTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return filteredCellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentModel = filteredCellModels[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SimpleTableViewCell.identifier, for: indexPath) as! SimpleTableViewCell
        
        cell.update(withModel: currentModel)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedModel = filteredCellModels[indexPath.row]
        selectedModel.didSelectBlock?()
    }
    
    
}
