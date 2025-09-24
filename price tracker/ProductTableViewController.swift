//
//  ProductTableViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2024.
//

import Foundation
import UIKit

class ProductTableViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var addButton: KButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var toastContainer: PassThroughView!
    private var toastView: ToastView?
    private var navigationTitleView: NavigationTitleView?
    
    private var viewModel: ProductTableViewModel
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var filterButton: UIBarButtonItem?
    
    private var baseContentInsetBottom: CGFloat = 0
    private var currentKeyboardHeight: CGFloat = 0
    private var keyboardObservers: [NSObjectProtocol] = []
    
    init(viewModel: ProductTableViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        
        navigationTitleView = NavigationTitleView().viewFromXib()
        navigationTitleView?.updateWith(title: "Your items", subtitle: nil)
        navigationItem.titleView = navigationTitleView
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUIBindings()
        setupToastView()
        viewModel.loadProducts()
        setupBarButtons()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        
        if #available(iOS 26.0, *) {
            addButton.configuration = UIButton.Configuration.prominentGlass()
        } else {
            addButton.configuration = UIButton.Configuration.filled()
            addButton.configuration?.cornerStyle = .capsule
        }
        addButton.configuration?.buttonSize = .large
        addButton.tintColor = .accent
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.setTitle("Add", for: .normal)
        addButton.configuration?.imagePadding = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startKeyboardObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopKeyboardObservers()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: ProductWithPriceTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ProductWithPriceTableViewCell.identifier)
        tableView.register(UINib(nibName: NoResultsProductTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: NoResultsProductTableViewCell.identifier)
        tableView.separatorStyle = .none
    }
    
    private func setupToastView() {
        toastView = ToastView().viewFromXib()
        toastContainer.addExpandingSubview(toastView!)
        
    }
    
    private func setupUIBindings() {
        viewModel.onProductsUpdated = { [weak self] products in
            self?.tableView.reloadData()
            
            if case .shop(let shop) = self?.viewModel.selectedFilter {
                self?.filterButton?.image = UIImage(systemName: "line.3.horizontal.decrease.circle.fill")
                self?.navigationTitleView?.updateWith(title: "Your items", subtitle: "Showing items cheapest at \(shop.name)")
            } else {
                self?.filterButton?.image = UIImage(systemName: "line.3.horizontal.decrease.circle")
                self?.navigationTitleView?.updateWith(title: "Your items", subtitle: nil)
            }
            
        }
        
        viewModel.onLoading = { [weak self] isLoading in
            if isLoading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.onProductDeleted = { [weak self] index in
            if self?.viewModel.filteredProducts.count == 0 {
                self?.tableView.reloadRows(at:  [IndexPath(row: index, section: 0)], with: .fade)
            } else {
                self?.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
            }
        }
        
        viewModel.onShoppingListUpdated = { [weak self] in
            if let visibleCells = self?.tableView.indexPathsForVisibleRows {
                self?.tableView.reconfigureRows(at: visibleCells)
            }
            
        }
        
        viewModel.onCurrencyUpdated = { [weak self] _ in
            self?.tableView.reloadData()
        }
        
         
    }
    
    private func setupBarButtons() {
        filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(filterButtonTapped))
        
        navigationItem.rightBarButtonItems = [filterButton!]
        
    }
    
    @objc private func filterButtonTapped() {
        viewModel.showShopFilters()
    }
    
    @IBAction private func addProductButtonTapped() {
        viewModel.onAddProductButtonTapped?(nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Base inset to keep content clear of the Add button
        baseContentInsetBottom = addButton.frame.height + 30
        let bottom = max(baseContentInsetBottom, currentKeyboardHeight + 8)
        tableView.contentInset.bottom = bottom
        tableView.verticalScrollIndicatorInsets.bottom = bottom
    }
    
    
    
    private func showItemAddedToShoppingListToast() {
        toastView?.show(withMessage: "Added to shopping list")
    }
    
    private func showDeleteProductAlert(productIndex: Int) {
        
        let product = viewModel.filteredProducts[productIndex]
        
        let alert = UIAlertController(title: "Delete", message: "Are you sure you would like to permanently delete \(product.product.name)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.deleteProduct(atIndex: productIndex)
        }))
        
        present(alert, animated: true)
    }
    
    // MARK: - Keyboard Handling
    private func startKeyboardObservers() {
        stopKeyboardObservers()
        let center = NotificationCenter.default
        let willChange = center.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { [weak self] notification in
            self?.handleKeyboard(notification: notification)
        }
        let willHide = center.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] notification in
            self?.handleKeyboard(notification: notification)
        }
        keyboardObservers = [willChange, willHide]
    }

    private func stopKeyboardObservers() {
        let center = NotificationCenter.default
        for obs in keyboardObservers {
            center.removeObserver(obs)
        }
        keyboardObservers.removeAll()
    }

    private func handleKeyboard(notification: Notification) {
        guard isViewLoaded else { return }
        let userInfo = notification.userInfo ?? [:]
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        // Convert to this view's coordinate space
        let endFrameInView = view.convert(endFrame, from: nil)
        // How much of the view is covered by the keyboard
        let overlap = max(0, view.bounds.maxY - endFrameInView.origin.y)
        // Subtract the bottom safe area so we don't double-count it
        currentKeyboardHeight = max(0, overlap - view.safeAreaInsets.bottom)

        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? UIView.AnimationCurve.easeInOut.rawValue
        let options = UIView.AnimationOptions(rawValue: UInt(curveRaw << 16))

        let bottom = max(baseContentInsetBottom, currentKeyboardHeight + 8)
        UIView.animate(withDuration: duration, delay: 0, options: [options, .beginFromCurrentState]) { [weak self] in
            guard let self = self else { return }
            self.tableView.contentInset.bottom = bottom
            self.tableView.verticalScrollIndicatorInsets.bottom = bottom
        }
    }
}

extension ProductTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.filteredProducts.count == 0 {
            return 1
        }
        return viewModel.filteredProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if viewModel.filteredProducts.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NoResultsProductTableViewCell.identifier, for: indexPath) as! NoResultsProductTableViewCell
            cell.updateForSearchString(viewModel.searchString)
            return cell
        }
        
        let product = viewModel.filteredProducts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductWithPriceTableViewCell.identifier, for: indexPath) as! ProductWithPriceTableViewCell
        
        let isProductInShoppingList = viewModel.isProductInShoppingList(product: product)
        
        cell.update(forProduct: product,isInShoppingList: isProductInShoppingList, currency: viewModel.currency)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.filteredProducts.count == 0 {
            
            viewModel.onAddProductButtonTapped?(viewModel.searchString)
            
        } else {
            
            let product = viewModel.filteredProducts[indexPath.row]
            viewModel.onProductSelected?(product)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if viewModel.filteredProducts.count == 0 {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard viewModel.filteredProducts.count != 0 else {
            return
        }
        if editingStyle == .delete {
            
            showDeleteProductAlert(productIndex: indexPath.row)
//            viewModel.deleteProduct(atIndex: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if viewModel.filteredProducts.count == 0 {
            return nil
        }
        
        let addToShoppingListAction = UIContextualAction(style: .normal, title: "Add to shopping list") { [weak self] (action, view, completionHandler) in
            
            self?.viewModel.addProductToShoppingList(productIndex: indexPath.row) { result in
                switch result {
                case .success(()):
                    self?.showItemAddedToShoppingListToast()
                    completionHandler(true)
                case .failure(_):
                    completionHandler(false)
                }
            }
            
        }
        
        addToShoppingListAction.image = UIImage(systemName: "cart.badge.plus")
        addToShoppingListAction.backgroundColor = .accent
        
        let configuration = UISwipeActionsConfiguration(actions: [addToShoppingListAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
        
    }
    
}

extension ProductTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        viewModel.filter(with: query)
    }
}
