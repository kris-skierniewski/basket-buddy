//
//  SelectDatasetViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 11/09/2025.
//

class SelectDatasetViewController: UIViewController {
    
    private var viewModel: SelectDatasetViewModel
    
    @IBOutlet private weak var inviteCodeTextField: UITextField!
    
    init(viewModel: SelectDatasetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUIBindings() {
        inviteCodeTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
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
}
