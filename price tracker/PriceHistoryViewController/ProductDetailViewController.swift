//
//  ProductViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 07/09/2024.
//

import UIKit

class ProductDetailViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var addButton: KButton!
    
    private var viewModel: ProductDetailViewModel
    
    init(viewModel: ProductDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Overview"
        
        viewModel.loadProduct()
        setupTableView()
        
        viewModel.onProductUpdated = { [weak self] oldProduct, updatedProduct in
            self?.updateTableView(oldProduct: oldProduct, newProduct: updatedProduct)
        }
        viewModel.onCurrencyUpdated = { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        setupAddButton()
        
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        navigationItem.rightBarButtonItem = editButton
    }
    
    private func setupAddButton() {
        if #available(iOS 26.0, *) {
            addButton.configuration = UIButton.Configuration.prominentGlass()
        } else {
            addButton.configuration = UIButton.Configuration.filled()
            addButton.configuration?.cornerStyle = .capsule
        }
        addButton.configuration?.buttonSize = .large
        addButton.tintColor = .accent
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.setTitle("Add", for: .normal)
        addButton.configuration?.imagePadding = 5
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset.bottom = addButton.frame.height + 30
    }
    
    @objc private func editTapped() {
        viewModel.onEditProductButtonTapped?(viewModel.product)
    }
    
    private func setupTableView() {
        //tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: ProductDetailTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ProductDetailTableViewCell.identifier)
        tableView.register(UINib(nibName: PriceRecordTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: PriceRecordTableViewCell.identifier)
        tableView.register(UINib(nibName: PriceHistoryTableViewHeaderCell.identifier, bundle: nil), forCellReuseIdentifier: PriceHistoryTableViewHeaderCell.identifier)
        tableView.register(UINib(nibName: EmptyPriceRecordTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: EmptyPriceRecordTableViewCell.identifier)
        tableView.reloadData()
    }
    
    private func editPriceRecord(withIndexPath indexPath: IndexPath) {
        viewModel.editPrice(at: indexPath.row)
    }
    
    private func removePriceRecord(atIndexPath indexPath: IndexPath) {
        viewModel.removePrice(at: indexPath.row)
        tableView.performBatchUpdates {
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }
    }
    
    @IBAction private func addPriceRecordButtonTapped() {
        viewModel.onAddPriceButtonTapped?()
    }
}

extension ProductDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            return max(viewModel.prices.count, 1)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 2 {
            let removeAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
                self?.removePriceRecord(atIndexPath: indexPath)
                completionHandler(true)
            }
            let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
                self?.editPriceRecord(withIndexPath: indexPath)
                completionHandler(true)
            }
            editAction.backgroundColor = .gray
            
            let configuration = UISwipeActionsConfiguration(actions: [removeAction, editAction])
            return configuration
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductDetailTableViewCell.identifier, for: indexPath) as! ProductDetailTableViewCell
            cell.update(forProduct: viewModel.product, currency: viewModel.currency)
            cell.selectionStyle = .none
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PriceHistoryTableViewHeaderCell.identifier, for: indexPath) as! PriceHistoryTableViewHeaderCell
            cell.selectionStyle = .none
            cell.updateWithTitle("Price history")
            return cell
        } else if viewModel.prices.count == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyPriceRecordTableViewCell.identifier, for: indexPath) as! EmptyPriceRecordTableViewCell
            cell.selectionStyle = .none
            return cell
            
        } else {
            
            let priceRecord = viewModel.prices[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: PriceRecordTableViewCell.identifier, for: indexPath) as! PriceRecordTableViewCell
            cell.update(withPriceRecord: priceRecord, currency: viewModel.currency)
            cell.selectionStyle = .none
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 2 && viewModel.prices.count > 0 {
            return true
        }
        return false
    }
    
    private func updateTableView(oldProduct: ProductWithPrices, newProduct: ProductWithPrices) {
        if newProduct.priceHistory.count >= oldProduct.priceHistory.count {
            tableView.reloadData()
            //only handle changes and additions here, removals are animated
        }
    }
    
    
}
