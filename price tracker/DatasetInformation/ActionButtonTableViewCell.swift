//
//  ActionButtonTableViewCell.swift
//  price tracker
//
//  Created by Kris Skierniewski on 16/09/2025.
//

class ActionButtonTableViewModel {
    var title: String
    var didSelectBlock: (() -> Void)?
    
    init(title: String, didSelectBlock: (() -> Void)? = nil) {
        self.title = title
        self.didSelectBlock = didSelectBlock
    }
}

class ActionButtonTableViewCell: UITableViewCell {
    
    static var identifier = "ActionButtonTableViewCell"
    
    @IBOutlet weak var actionButton: KButton!
    @IBOutlet private weak var actionButtonTitleLabel: UILabel!
    private var model: ActionButtonTableViewModel?
    
    func updateWith(model: ActionButtonTableViewModel) {
        self.model = model
        actionButtonTitleLabel.text = model.title
    }
    
    @IBAction private func actionButtonTapped() {
        model?.didSelectBlock?()
    }
}
