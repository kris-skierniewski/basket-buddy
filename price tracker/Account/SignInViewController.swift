//
//  SignInViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 30/09/2024.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBOutlet private weak var resetPasswordButtonLabel: UILabel!
    
    @IBOutlet private weak var signInButton: KButton!
    @IBOutlet private weak var createAccountButton: KButton!
    @IBOutlet private weak var resetPasswordButton: KButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var viewModel: SignInViewModel
    
    init(viewModel: SignInViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIBindings()
        setupResetPasswordButton()
    }
    
    private func setupUIBindings() {
        emailTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        
        viewModel.onLoading = { [weak self] isLoading in
            if isLoading {
                self?.signInButton.isEnabled = false
                self?.createAccountButton.isEnabled = false
                self?.resetPasswordButton.isEnabled = false
                self?.activityIndicator.startAnimating()
            } else {
                self?.signInButton.isEnabled = true
                self?.createAccountButton.isEnabled = true
                self?.resetPasswordButton.isEnabled = true
                self?.activityIndicator.stopAnimating()
            }
        }
    }

    private func setupResetPasswordButton() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .heavy),
            .foregroundColor: UIColor(named: "AccentColor")!,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor(named: "AccentColor")!
        ]
        
        resetPasswordButtonLabel.attributedText = NSAttributedString(string: "Reset password", attributes: attributes)
    }
    
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        if textField == emailTextField {
            let email = emailTextField.text ?? ""
            viewModel.emailAddress = email
        } else if textField == passwordTextField {
            let password = passwordTextField.text ?? ""
            viewModel.password = password
        }
    }
    
    @IBAction private func signInTapped() {
        viewModel.signIn()
        
    }
    
    @IBAction private func resetPasswordButtonTapped() {
        viewModel.sendPasswordReset()
    }
    
    @IBAction private func createAccountTapped() {
        viewModel.createAccount()
       
    }
    
    private func showPasswordResetDialog() {
        //TODO: here or in coordinator?
    }
    
}
