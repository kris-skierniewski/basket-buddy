//
//  SettingsViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 17/09/2025.
//

class SettingsViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var viewModel: SettingsViewModel
    
    let SettingsRowCellIdentifier = "SettingsRowCell"
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUIBindings()
        viewModel.loadUser()
        navigationItem.title = "Account"
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupUIBindings() {
        viewModel.onSectionsUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @IBAction private func signOutTapped() {
        viewModel.signOut()
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsRowCellIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: SettingsRowCellIdentifier)
        
        let row = viewModel.sections[indexPath.section].rows[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = row.title
        content.image = row.isHeader ? UIImage(systemName: "person.fill") : nil
        content.imageProperties.tintColor = .accent
        content.secondaryText = row.subtitle
        cell.contentConfiguration = content
        cell.accessoryType = row.didSelectBlock == nil ? .none : .disclosureIndicator
        cell.selectionStyle = row.isHeader ? .none : .default
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = viewModel.sections[indexPath.section].rows[indexPath.row]
        row.didSelectBlock?()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
}
