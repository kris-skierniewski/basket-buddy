//
//  ShoppingListViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 08/09/2025.
//

class ShoppingListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var cleanUpButton: KButton!
    @IBOutlet private weak var shoppingListEmptyView: UIView!
    
    private var viewModel: ShoppingListViewModel
    
    init(viewModel: ShoppingListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "Shopping List"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUIBindings()
        viewModel.loadShoppingList()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset.bottom = cleanUpButton.frame.height + 40
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: ShoppingListProductTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ShoppingListProductTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    private func setupUIBindings() {
        viewModel.onContentsChanged = { [weak self] diff in
            
            if self?.viewModel.numberOfItems == 0 {
                self?.shoppingListEmptyView.isHidden = false
                self?.cleanUpButton.isHidden = true
            } else {
                self?.shoppingListEmptyView.isHidden = true
                self?.cleanUpButton.isHidden = false
            }
            
            self?.tableView.beginUpdates()
            self?.tableView.deleteSections(diff.deletedSections, with: .fade)
            self?.tableView.insertSections(diff.insertedSections, with: .fade)
            self?.tableView.deleteRows(at: diff.deletedRows, with: .fade)
            self?.tableView.insertRows(at: diff.insertedRows, with: .fade)
            self?.tableView.reloadRows(at: diff.updatedRows, with: .fade)
            self?.tableView.endUpdates()
        }
    }
    
    @IBAction private func cleanUpButtonTapped() {
        viewModel.cleanUp()
    }
    
}

extension ShoppingListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = viewModel.sections[section]
        return section.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ShoppingListProductTableViewCell.identifier, for: indexPath) as! ShoppingListProductTableViewCell
        let product = viewModel.sections[indexPath.section].products[indexPath.row]
        cell.update(withProduct: product)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isCompleted = viewModel.sections[indexPath.section].products[indexPath.row].isChecked
        viewModel.markCompleted(completed: !isCompleted, atIndexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[section].title
    }
    
    
}
