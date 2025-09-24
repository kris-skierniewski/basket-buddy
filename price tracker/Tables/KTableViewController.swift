//
//  KTableViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 17/09/2025.
//

class KTableViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let CellReuseIdentifier = "CellReuseIdentifier"
    
    private var viewModel: KTableViewModel
    
    init(viewModel: KTableViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.navigationTitle
        setupTableView()
        setupRightBarButtonItem()
        setupUIBindings()
        viewModel.loadSections()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: TextFieldTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TextFieldTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupUIBindings() {
        viewModel.onSectionsUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func setupRightBarButtonItem() {
        navigationItem.rightBarButtonItem = viewModel.rightBarButtonItem
    }
    
}

extension KTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].rows.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = viewModel.sections[indexPath.section].rows[indexPath.row]
        
        if row.didChangeText != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier, for: indexPath) as! TextFieldTableViewCell
            
            cell.updateForModel(row)
            cell.selectionStyle = .none
            cell.backgroundColor = .systemBackground
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: CellReuseIdentifier)
        
        var content = cell.defaultContentConfiguration()
        content.text = row.title
        content.secondaryText = row.subtitle
        cell.contentConfiguration = content
        cell.accessoryType = row.accessoryType
        cell.backgroundColor = .systemBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.sections[indexPath.section].rows[indexPath.row].didSelectBlock?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[section].title
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return viewModel.sections[section].body
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let row = viewModel.sections[indexPath.section].rows[indexPath.row]
        if row.deleteBlock == nil {
            return nil
        } else {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
                row.deleteBlock?()
                completionHandler(true)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
    }
    
}
