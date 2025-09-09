//
//  SearchProductsViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 09/09/2025.
//

class SearchProductsViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var toastContainer: PassThroughView!
    private var toastView: ToastView?
    
    //private var searchController: UISearchController
    private var searchBar = UISearchBar()
    private var viewModel: SearchProductsViewModel
    
    init(viewModel: SearchProductsViewModel) {
        self.viewModel = viewModel
        //searchController = UISearchController(searchResultsController: nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
        setupBarButtons()
        setupUIBindings()
        setupToastView()
        viewModel.loadProducts()
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Add an item to your shopping list"
        navigationItem.titleView = searchBar
        searchBar.delegate = self
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: SearchProductsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SearchProductsTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupUIBindings() {
        viewModel.onRowsUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.onItemAddedToShoppingList = showItemAddedToShoppingListToast
        viewModel.onError = { [weak self] error in
            self?.toastView?.show(withMessage: error.localizedDescription)
        }
    }
    
    private func setupBarButtons() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func setupToastView() {
        toastView = ToastView().viewFromXib()
        toastContainer.addExpandingSubview(toastView!)
        
    }
    
    private func showItemAddedToShoppingListToast() {
        toastView?.show(withMessage: "Added to shopping list")
    }
    
    @objc private func doneButtonTapped() {
        viewModel.done()
    }
}

extension SearchProductsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchString = searchBar.text ?? ""
        viewModel.search(searchString)
    }
}

extension SearchProductsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchProductsTableViewCell.identifier, for: indexPath) as! SearchProductsTableViewCell
        
        let row = viewModel.rows[indexPath.row]
        
        cell.updateForRow(row, currency: viewModel.currency)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.select(row: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
}
