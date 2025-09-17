//
//  TextFieldTableViewCell.swift
//  price tracker
//
//  Created by Kris Skierniewski on 17/09/2025.
//

class TextFieldTableViewCell: UITableViewCell {
    
    static let identifier = "TextFieldTableViewCell"
    
    @IBOutlet private weak var textField: UITextField!
    private var viewModel: KTableViewRow?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        
    }
    
    func updateForModel(_ viewModel: KTableViewRow) {
        self.viewModel = viewModel
        textField.placeholder = viewModel.textFieldPlaceholder
        textField.text = viewModel.textFieldText
        
    }
    
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        viewModel?.didChangeText?(textField.text ?? "")
    }
    
    
}
