//
//  AccountViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 30/09/2024.
//

import UIKit
import FirebaseAuth

class AccountViewController: UIViewController {
    
    @IBOutlet private weak var emailLabel: UILabel!
    
    @IBOutlet private weak var currencyTextField: UITextField!
    @IBOutlet private weak var displayNameTextField: UITextField!
    
    @IBOutlet private weak var displayNameTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var saveButtonContainer: UIView!
    
    @IBOutlet private weak var currencyTableViewControllerShadowView: UIView!
    @IBOutlet private weak var currencyTableViewControllerContainer: UIView!
    private var currencySearchResults: SearchResultsView?
    
    private var viewModel: AccountViewModel
    
    init(viewModel: AccountViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "Your account"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadUser()
        setupUIBindings()
        setupCurrencyTableViewController()
        setupTapGestureOnBackground()
    }
    
    private func setupUIBindings() {
        currencyTextField.text = viewModel.currency.symbol
        emailLabel.text = viewModel.emailAddress
        displayNameTextField.text = viewModel.displayName
        
        displayNameTrailingConstraint.constant = 0
        saveButtonContainer.isHidden = true
        
        displayNameTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        displayNameTextField.delegate = self
        
        viewModel.onCurrencyChanged = { [weak self] currency in
            self?.currencyTextField.text = currency.symbol
        }
        viewModel.onEmailAddressChanged = { [weak self] email in
            self?.emailLabel.text = email
        }
        
        viewModel.onDisplayNameChanged = { [weak self] displayName in
            self?.displayNameTextField.text = displayName
            self?.viewModel.newDisplayName = displayName
        }
        
        viewModel.onIsEditingChanged = { [weak self] isEditing in
            
            if !isEditing {
                self?.displayNameTextField.resignFirstResponder()
            }
            
            self?.displayNameTrailingConstraint.constant = isEditing ? 100 : 0
            UIView.animate(withDuration: 0.3) {
                self?.saveButtonContainer.isHidden = !isEditing
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    private func setupTapGestureOnBackground() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedBackground))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction private func signOutTapped() {
        hideCurrencySearchResults()
        viewModel.signOut()
    }
    
    @IBAction private func deleteAccountTapped() {
        hideCurrencySearchResults()
        
        let alertController = UIAlertController(title: "Sorry to see you go", message: "Are you sure you would like to permanently delete your account? All your data will be deleted.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.deleteAccount()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    private func setupCurrencyTableViewController() {
        currencyTableViewControllerContainer.layer.borderColor = UIColor.gray.cgColor
        currencyTableViewControllerContainer.layer.borderWidth = 1
        
        currencySearchResults = SearchResultsView().viewFromXib()
        
        
        currencySearchResults?.configure(with: Currency.allCases) { [weak self] item in
            if let currency = item as? Currency {
                self?.didSelectCurrency(currency)
            }
        }
        currencyTableViewControllerContainer.addExpandingSubview(currencySearchResults!)
        
        hideCurrencySearchResults()
        
    }
    
    func didSelectCurrency(_ currency: Currency) {
        viewModel.setCurrencyPreference(currency)
        hideCurrencySearchResults()
    }
    
    @IBAction private func didSelectCurrencyTextField() {
        showCurrencySearchResults()
    }
    
    @objc private func tappedBackground(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        let hitView = view.hitTest(location, with: nil)
        
        // Only respond if the tap was directly on the main view
        if hitView == view {
            hideCurrencySearchResults()
        }
    }
    
    @IBAction private func saveButtonTapped() {
        viewModel.saveUser()
    }
    
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        if textField == displayNameTextField {
            viewModel.newDisplayName = textField.text ?? ""
        }
    }
    
    private func hideCurrencySearchResults() {
        currencyTableViewControllerShadowView.isHidden = true
    }
    private func showCurrencySearchResults() {
        currencyTableViewControllerShadowView.isHidden = false
    }
}

extension AccountViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewModel.isEditing = true
    }
}
