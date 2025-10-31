//
//  SetQuantityViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 29/10/2025.
//

class SetQuantityViewController: UIViewController {
    
    @IBOutlet private weak var productNameLabel: UILabel!
    @IBOutlet private weak var quantityTextField: UITextField!
    @IBOutlet private weak var unitTextField: UITextField!
    
    @IBOutlet private weak var unitTableViewControllerShadowView: UIView!
    @IBOutlet private weak var unitTableViewControllerContainer: UIView!
    @IBOutlet private weak var unitTableViewControllerHeightConstraint: NSLayoutConstraint!
    private var unitSearchResults: SearchResultsView?
    
    private var viewModel: SetQuantityViewModel
    
    init(viewModel: SetQuantityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "Set quantity"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUnitTableViewController()
        populateFields()
        viewModel.loadShoppingList()
        
        quantityTextField.delegate = self
        quantityTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        
        
    }
    
    private func populateFields() {
        productNameLabel.text = viewModel.productName
        if let quantity = viewModel.quantity {
            
            if quantity.truncatingRemainder(dividingBy: 1) == 0 {
                quantityTextField.text = String(Int(quantity))
            } else {
                quantityTextField.text = String(quantity)
            }
        }
        if let unit = viewModel.unit {
            unitTextField.text = unit.rawValue
        }
    }
    
    private func setupUnitTableViewController() {
        unitTableViewControllerContainer.layer.borderColor = UIColor.gray.cgColor
        unitTableViewControllerContainer.layer.borderWidth = 1
        
        unitTableViewControllerShadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        unitTableViewControllerShadowView.layer.shadowColor = UIColor.black.cgColor
        unitTableViewControllerShadowView.layer.shadowOpacity = 0.3
        
        unitSearchResults = SearchResultsView().viewFromXib()
        unitTableViewControllerContainer.addExpandingSubview(unitSearchResults!)
        
        unitSearchResults?.configure(with: Unit.allCases) { [weak self] item in
            if let unit = item as? Unit {
                self?.selectUnit(unit)
            }
        }
    }
    
    private func selectUnit(_ unit: Unit) {
        viewModel.setUnit(unit)
        unitTextField.text = unit.rawValue
        hideUnitSearchResults()
    }
    
    private func showUnitSearchResults() {
        unitTableViewControllerShadowView.isHidden = false
    }
    
    private func hideUnitSearchResults() {
        unitTableViewControllerShadowView.isHidden = true
    }
    
    private func stopEditing() {
        quantityTextField.resignFirstResponder()
    }
    
    @objc private func done() {
        viewModel.save()
    }
    
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        if textField == quantityTextField {
            if let quantityString = quantityTextField.text {
                viewModel.setQuantity(Double(quantityString) ?? 0.0)
            }
        }
    }
    
    @IBAction private func unitTextFieldTapped() {
        stopEditing()
        showUnitSearchResults()
    }
}

extension SetQuantityViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == quantityTextField {
            hideUnitSearchResults()
        }
    }
}
