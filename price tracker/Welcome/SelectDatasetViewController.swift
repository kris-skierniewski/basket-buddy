//
//  SelectDatasetViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 11/09/2025.
//

class SelectDatasetViewController: UIViewController {
    
    private var viewModel: SelectDatasetViewModel
    
    @IBOutlet private weak var signOutButton: KButton!
    @IBOutlet private weak var inviteCodeTextField: UITextField!
    
    init(viewModel: SelectDatasetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSignOutButton()
        setupUIBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSignOutButton() {
        if #available(iOS 26.0, *) {
            signOutButton.configuration = UIButton.Configuration.clearGlass()
        } else {
            signOutButton.configuration = UIButton.Configuration.filled()
            signOutButton.configuration?.cornerStyle = .capsule
            signOutButton.tintColor = .systemBackground
        }
        signOutButton.configuration?.buttonSize = .medium
        signOutButton.setTitle("Sign out", for: .normal)
    }
    
    private func setupUIBindings() {
        inviteCodeTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        viewModel.onInviteCodeUpdated = { [weak self] in
            self?.inviteCodeTextField.text = self?.viewModel.inviteCode
        }
    }
    
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        if textField == inviteCodeTextField {
            viewModel.inviteCode = textField.text ?? ""
        }
    }
    
    @IBAction private func joinWithCodeButtonTapped() {
        viewModel.joinWithCode()
    }
    
    @IBAction private func joinWithoutCodeButtonTapped() {
        viewModel.joinWithoutCode()
    }
    
    @IBAction private func signOutButtonTapped() {
        viewModel.signOut()
    }
}
