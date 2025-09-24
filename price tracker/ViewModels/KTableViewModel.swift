//
//  KTableViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 17/09/2025.
//

protocol KTableViewModel {
    var sections: [KTableViewSection] { get }
    var onSectionsUpdated: (() -> Void)? { get set }
    func loadSections()
    var navigationTitle: String { get }
    
    var rightBarButtonItem: UIBarButtonItem? { get }
}

class KTableViewSection {
    var title: String
    var body: String
    var rows: [KTableViewRow]
    
    init(title: String, body: String, rows: [KTableViewRow]) {
        self.title = title
        self.body = body
        self.rows = rows
    }
}

class KTableViewRow {
    //basic
    var title: String
    var subtitle: String
    var accessoryType: UITableViewCell.AccessoryType
    var didSelectBlock: (() -> Void)?
    
    //textfield
    var textFieldPlaceholder: String?
    var textFieldText: String?
    var didChangeText: ((String) -> Void)?
    
    //swipe to delete block
    var deleteBlock: (() -> Void)?
    
    init(title: String, subtitle: String, accessoryType: UITableViewCell.AccessoryType, didSelectBlock: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.accessoryType = accessoryType
        self.didSelectBlock = didSelectBlock
    }
    
    init(placeholder: String, text: String?, didChangeText: ((String) -> Void)? = nil) {
        self.textFieldPlaceholder = placeholder
        self.textFieldText = text
        self.didChangeText = didChangeText
        self.title = ""
        self.subtitle = ""
        self.accessoryType = .none
    }
    
}
