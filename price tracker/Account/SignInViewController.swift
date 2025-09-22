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
    
    @IBOutlet private weak var inviteNoticeView: UIView!
    @IBOutlet private weak var inviteNoticeLabel: UILabel!
    
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
        
        setupInviteNoticeView()
        setupUIBindings()
        setupResetPasswordButton()
        setupSignInAndCreateAccountButtons()
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
                self?.inviteNoticeView.isHidden = true
            } else {
                self?.signInButton.isEnabled = true
                self?.createAccountButton.isEnabled = true
                self?.resetPasswordButton.isEnabled = true
                self?.activityIndicator.stopAnimating()
                self?.updateInviteNoticeView()
            }
        }
        
        viewModel.onInviteNoticeStringChanged = { [weak self] in
            self?.updateInviteNoticeView()
        }
    }
    
    private func setupSignInAndCreateAccountButtons() {
        if #available(iOS 26.0, *) {
            createAccountButton.configuration = UIButton.Configuration.prominentGlass()
        } else {
            createAccountButton.configuration = UIButton.Configuration.filled()
            createAccountButton.configuration?.cornerStyle = .capsule
        }
        createAccountButton.configuration?.buttonSize = .large
        createAccountButton.tintColor = .accent
        createAccountButton.setTitle("Create an account", for: .normal)
        
        if #available(iOS 26.0, *) {
            signInButton.configuration = UIButton.Configuration.prominentGlass()
        } else {
            signInButton.configuration = UIButton.Configuration.filled()
            signInButton.configuration?.cornerStyle = .capsule
        }
        signInButton.configuration?.buttonSize = .large
        signInButton.tintColor = .accent
        signInButton.setTitle("Sign in", for: .normal)
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
    
    private func setupInviteNoticeView() {
        inviteNoticeView.backgroundColor = .accent.withAlphaComponent(0.3)
        inviteNoticeView.isHidden = true
    }
    
    private func updateInviteNoticeView() {
        if viewModel.inviteNoticeString.count == 0 {
            inviteNoticeView.isHidden = true
            inviteNoticeLabel.text = ""
        } else {
            inviteNoticeView.isHidden = false
            inviteNoticeLabel.text = viewModel.inviteNoticeString
        }
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
    
}
