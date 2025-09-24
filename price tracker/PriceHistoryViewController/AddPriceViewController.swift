//
//  AddPriceViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 21/10/2024.
//

import UIKit

class AddPriceViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var currencyLabel: UILabel!
    
    @IBOutlet private weak var unitTextField: UITextField!
    @IBOutlet private weak var quantityTextField: UITextField!
    @IBOutlet private weak var shopNameTextField: UITextField!
    @IBOutlet private weak var priceTextField: UITextField!
    @IBOutlet private weak var notesTextField: UITextField!
    
    @IBOutlet private weak var shopTableViewControllerShadowView: UIView!
    @IBOutlet weak var shopTableViewControllerContainer: UIView!
    @IBOutlet private weak var shopTableViewControllerHeightConstraint: NSLayoutConstraint!
    private var shopSearchResults: SearchResultsView?
    
    
    @IBOutlet private weak var unitTableViewControllerShadowView: UIView!
    @IBOutlet private weak var unitTableViewControllerContainer: UIView!
    @IBOutlet private weak var unitTableViewControllerHeightConstraint: NSLayoutConstraint!
    private var unitSearchResults: SearchResultsView?
    
    private var viewModel: AddPriceViewModel
    
    init(viewModel: AddPriceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = viewModel.viewTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateCurrencyLabel()
        
        setupShopTableViewController()
        setupUnitTableViewController()
        
        viewModel.delegate = self
        viewModel.loadShopsAndUnits()
        
        populateWithExistingPrice()
        
        shopNameTextField.delegate = self
        quantityTextField.delegate = self
        notesTextField.delegate = self
        priceTextField.delegate = self
        
        priceTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        notesTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        quantityTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        shopNameTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        scrollView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        
        viewModel.onCurrencyUpdated = { [weak self] _ in
            self?.updateCurrencyLabel()
        }
    }
    
    private func updateCurrencyLabel() {
        currencyLabel.text = viewModel.currency.symbol
    }
    
    private func populateWithExistingPrice() {
        shopNameTextField.text = viewModel.shopName
        if let price = viewModel.price {
            priceTextField.text = String(price)
        }
        if let quantity = viewModel.quantity {
            quantityTextField.text = String(quantity)
        }
        if let unit = viewModel.unit {
            unitTextField.text = unit.rawValue
        }
        notesTextField.text = viewModel.notes
        
    }
    
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        if textField == shopNameTextField {
            if let shopName = shopNameTextField.text {
                viewModel.filterShops(with: shopName)
                viewModel.setShopName(shopName)
                showShopSearchResults()
            }
        } else if textField == priceTextField {
            if let priceString = priceTextField.text {
                viewModel.setPrice(Double(priceString))
            }
        } else if textField == quantityTextField {
            if let quantityString = quantityTextField.text {
                viewModel.setQuantity(Double(quantityString))
            }
        } else if textField == notesTextField {
            if let notesString = notesTextField.text {
                viewModel.setNotes(notesString)
            }
        }
    }
    
    @objc private func done() {
        viewModel.savePrice()
    }
    
    private func setupShopTableViewController() {
        shopTableViewControllerContainer.layer.borderColor = UIColor.gray.cgColor
        shopTableViewControllerContainer.layer.borderWidth = 1
        
        shopTableViewControllerShadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        shopTableViewControllerShadowView.layer.shadowColor = UIColor.black.cgColor
        shopTableViewControllerShadowView.layer.shadowOpacity = 0.3
        
        shopSearchResults = SearchResultsView().viewFromXib()
        shopTableViewControllerContainer.addExpandingSubview(shopSearchResults!)
    }
    
    private func setupUnitTableViewController() {
        unitTableViewControllerContainer.layer.borderColor = UIColor.gray.cgColor
        unitTableViewControllerContainer.layer.borderWidth = 1
        
        unitTableViewControllerShadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        unitTableViewControllerShadowView.layer.shadowColor = UIColor.black.cgColor
        unitTableViewControllerShadowView.layer.shadowOpacity = 0.3
        
        unitSearchResults = SearchResultsView().viewFromXib()
        unitTableViewControllerContainer.addExpandingSubview(unitSearchResults!)
    }
    
    private func showShopSearchResults() {
        let shops = viewModel.getFilteredShops()
        shopTableViewControllerShadowView.isHidden = shops.count == 0
        shopSearchResults?.configure(with: shops, onItemSelected: { [weak self] item in
            if let shop = item as? Shop {
                self?.selectShop(shop)
            }
        })
    }
    
    private func hideShopSearchResults() {
        shopTableViewControllerShadowView.isHidden = true
    }
    
    private func showUnitSearchResults() {
        unitTableViewControllerShadowView.isHidden = false
    }
    
    private func hideUnitSearchResults() {
        unitTableViewControllerShadowView.isHidden = true
    }
    
    private func selectShop(_ shop: Shop) {
        viewModel.selectShop(shop)
        shopNameTextField.text = shop.name
        hideShopSearchResults()
        shopNameTextField.resignFirstResponder()
    }
    
    private func selectUnit(_ unit: Unit) {
        viewModel.selectUnit(unit)
        unitTextField.text = unit.rawValue
        hideUnitSearchResults()
    }
    
    @IBAction private func unitTextFieldTapped() {
        stopEditing()
        hideShopSearchResults()
        showUnitSearchResults()
    }
    
    @IBAction private func backgroundTapped() {
        stopEditing()
        hideShopSearchResults()
        hideUnitSearchResults()
    }
    
    func stopEditing() {
        shopNameTextField.resignFirstResponder()
        quantityTextField.resignFirstResponder()
        priceTextField.resignFirstResponder()
        notesTextField.resignFirstResponder()
    }
}

extension AddPriceViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == shopNameTextField {
            showShopSearchResults()
            hideUnitSearchResults()
        } else if textField == quantityTextField {
            hideShopSearchResults()
            hideUnitSearchResults()
        } else if textField == notesTextField {
            hideShopSearchResults()
            hideUnitSearchResults()
        } else if textField == priceTextField {
            hideShopSearchResults()
            hideUnitSearchResults()
        }
    }
    
}

extension AddPriceViewController: AddPriceViewModelDelegate {
    func viewModelDidUpdateUnits(_ units: [Unit]) {
        unitSearchResults?.configure(with: units) { [weak self] item in
            if let unit = item as? Unit {
                self?.selectUnit(unit)
            }
        }
    }
    
    func viewModelDidUpdateShops(_ shops: [Shop]) {
        if shopNameTextField.isFirstResponder {
            showShopSearchResults()
        }
    }
    
    func viewModelDidUpdateFilteredShops(_ shops: [Shop]) {
        if shopNameTextField.isFirstResponder {
            showShopSearchResults()
        }
    }
    
}

extension AddPriceViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
