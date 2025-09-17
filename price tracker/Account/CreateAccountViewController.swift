//
//  CreateAccountViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 30/09/2024.
//

import Foundation
import FirebaseAuth
import UIKit

class CreateAccountViewController: UIViewController {
    
    @IBOutlet private weak var displayNameTextField: UITextField!
    
    @IBOutlet private weak var emailTextField: UITextField!
    
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    
    private var viewModel: CreateAccountViewModel
    
    init(viewModel: CreateAccountViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Create an account"
        setupUIBindings()
    }
    
    private func setupUIBindings() {
        displayNameTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }
    
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        switch textField {
        case displayNameTextField:
            viewModel.displayName = textField.text ?? ""
        case emailTextField:
            viewModel.emailAddress = textField.text ?? ""
        case passwordTextField:
            viewModel.password = textField.text ?? ""
        case confirmPasswordTextField:
            viewModel.confirmPassword = textField.text ?? ""
        default:
            break
        }
    }
    
    @IBAction private func createAccountTapped() {
        
        viewModel.createAccount()
    }
    
    private func showAlert(errorDescription: String?) {
        let alertController = UIAlertController(title: "Failed", message: errorDescription ?? "Sorry, something went wrong", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
}
