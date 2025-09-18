//
//  Untitled.swift
//  price tracker
//
//  Created by Kris Skierniewski on 16/09/2025.
//

class DatasetMemberTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var displayNameLabel: UILabel!
    @IBOutlet private weak var leaveButton: KButton!
    @IBOutlet private weak var leaveButtonHiddenWidthConstraint: NSLayoutConstraint!
    
    private var viewModel: DatasetMemberRow?
    
    static var identifier = "DatasetMemberTableViewCell"
    
    func update(for row: DatasetMemberRow) {
        self.viewModel = row
        if row.isCurrentUser {
            displayNameLabel.text = "\(row.displayName) (You)"
        } else {
            displayNameLabel.text = row.displayName
        }
        
        if row.showLeaveButton {
            leaveButton.isHidden = false
            leaveButtonHiddenWidthConstraint.priority = .defaultLow
        } else {
            leaveButton.isHidden = true
            leaveButtonHiddenWidthConstraint.priority = .required
        }
        
    }
    
    @IBAction private func leaveButtonTapped() {
        viewModel?.leaveButtonTappedBlock?()
    }
}
