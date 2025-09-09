//
//  AddProductViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2024.
//

import UIKit

class AddProductViewController: UIViewController {
    
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var descriptionTextField: UITextField!
    @IBOutlet private weak var categoryTextField: UITextField!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var categoryTableViewControllerShadowView: UIView!
    @IBOutlet weak var categoryTableViewControllerContainer: UIView!
    private var categorySearchResults: SearchResultsView?
    
    private var viewModel: AddProductViewModel
    
    init(viewModel: AddProductViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIBindings()
        viewModel.populateTextFields()
        setupCategoryTableViewController()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        
        navigationItem.title = viewModel.viewTitle
        
    }
    
    private func setupUIBindings() {
        nameTextField.autocapitalizationType = .sentences
        descriptionTextField.autocapitalizationType = .sentences
        
        nameTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        nameTextField.delegate = self
        descriptionTextField.delegate = self
        
        viewModel.onLoading = { [weak self] isLoading in
            if isLoading {
                self?.navigationItem.rightBarButtonItem?.isEnabled = false
                self?.nameTextField.isEnabled = false
                self?.descriptionTextField.isEnabled = false
                self?.activityIndicator.startAnimating()
            } else {
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
                self?.nameTextField.isEnabled = true
                self?.descriptionTextField.isEnabled = true
                self?.activityIndicator.stopAnimating()
            }
        }
        viewModel.onProductUpdated = { [weak self] in
            self?.nameTextField.text = self?.viewModel.name
            self?.descriptionTextField.text = self?.viewModel.description
            self?.categoryTextField.text = self?.viewModel.currentCategory.rawValue.capitalized
        }
        
        viewModel.onCategoryUpdated = { [weak self] in
            self?.categoryTextField.text = self?.viewModel.currentCategory.rawValue.capitalized
        }
    }
    
    private func setupCategoryTableViewController() {
        categoryTableViewControllerContainer.layer.borderColor = UIColor.gray.cgColor
        categoryTableViewControllerContainer.layer.borderWidth = 1
        
        categoryTableViewControllerShadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        categoryTableViewControllerShadowView.layer.shadowColor = UIColor.black.cgColor
        categoryTableViewControllerShadowView.layer.shadowOpacity = 0.3
        
        categorySearchResults = SearchResultsView().viewFromXib()
        categoryTableViewControllerContainer.addExpandingSubview(categorySearchResults!)
        
        let categories = viewModel.getCategories()
        categorySearchResults?.configure(with: categories, onItemSelected: { [weak self] item in
            if let category = item as? ProductCategory {
                self?.selectCategory(category)
            }
        })
    }
    
    @objc private func cancel() {
        viewModel.onCancel?()
    }
    
    @objc private func done() {
        viewModel.saveProduct()
        
    }
    
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        if textField == nameTextField {
            viewModel.setName(textField.text ?? "")
        } else if textField == descriptionTextField {
            viewModel.setDescription(textField.text ?? "")
        }
    }
    
    private func selectCategory(_ category: ProductCategory) {
        viewModel.selectCategory(category)
        hideCategorySearchResults()
    }
    
    private func stopEditing() {
        nameTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
    }
    
    private func showCategorySearchResults() {
        categoryTableViewControllerShadowView.isHidden = false
    }
    
    private func hideCategorySearchResults() {
        categoryTableViewControllerShadowView.isHidden = true
    }
    
    @IBAction private func categoryTextFieldTapped() {
        stopEditing()
        showCategorySearchResults()
    }
    
    @IBAction private func backgroundTapped() {
        stopEditing()
        hideCategorySearchResults()
    }
    
}

extension AddProductViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideCategorySearchResults()
    }
}
