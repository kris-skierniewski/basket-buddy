//
//  ShopFilterViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 09/09/2025.
//

class ShopFilterViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var viewModel: ShopFilterViewModel
    
    
    init(viewModel: ShopFilterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "Filters"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUIBindings()
        viewModel.loadShops()
        setupDoneButton()
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ShopCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupDoneButton() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc private func doneButtonTapped() {
        viewModel.done()
        dismiss(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUIBindings() {
        viewModel.onContentsChanged = { [weak self] diff in
            self?.tableView.beginUpdates()
            self?.tableView.deleteSections(diff.deletedSections, with: .fade)
            self?.tableView.insertSections(diff.insertedSections, with: .fade)
            self?.tableView.deleteRows(at: diff.deletedRows, with: .fade)
            self?.tableView.insertRows(at: diff.insertedRows, with: .fade)
            self?.tableView.reloadRows(at: diff.updatedRows, with: .fade)
            self?.tableView.endUpdates()
        }
        
        viewModel.onFilterSelected = { [weak self] _ in
            if let visibleCells = self?.tableView.indexPathsForVisibleRows {
                self?.tableView.reconfigureRows(at: visibleCells)
            }
        }
    }
}

extension ShopFilterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopCell", for: indexPath)
        
        let filter = viewModel.sections[indexPath.section].items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = filter.title
        cell.accessoryType = viewModel.selectedFilter == filter ? .checkmark : .none
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectFilter(atIndex: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
}
