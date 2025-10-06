//
//  ComposeShoppingListViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 12/11/2024.
//

import FirebaseAnalytics
import Foundation

class ComposeShoppingListViewController: UIViewController {
    
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var shoppingListEmptyView: UIView!
    @IBOutlet private weak var shoppingListEmptyLabel: UILabel!
    @IBOutlet private weak var startButton: KButton!
    @IBOutlet private weak var cleanUpButton: KButton!
    
    private var viewModel: ComposeShoppingListViewModel
    
    init(viewModel: ComposeShoppingListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Shopping list"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupAddButton()
        setupEmptyView()
        setupButtons()
        
        viewModel.loadShoppingList()
        setupUIBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset.bottom = startButton.frame.height + 40
    }
    
    
    private func setupTableView() {
        tableView.register(UINib(nibName: ProductTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ProductTableViewCell.identifier)
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupButtons() {
        
        if #available(iOS 26.0, *) {
            startButton.configuration = UIButton.Configuration.prominentGlass()
        } else {
            startButton.configuration = UIButton.Configuration.filled()
            startButton.configuration?.cornerStyle = .capsule
        }
        startButton.configuration?.buttonSize = .large
        startButton.tintColor = .accent
        startButton.setTitle("Start", for: .normal)
        
        
        if #available(iOS 26.0, *) {
            cleanUpButton.configuration = UIButton.Configuration.clearGlass()
        } else {
            cleanUpButton.configuration = UIButton.Configuration.filled()
            cleanUpButton.configuration?.cornerStyle = .capsule
            cleanUpButton.tintColor = .systemBackground
        }
        cleanUpButton.configuration?.buttonSize = .medium
        cleanUpButton.setTitle("Clean up", for: .normal)
        
    }
    
    private func setupAddButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProductButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupEmptyView() {
        shoppingListEmptyLabel.text = "You haven't added any items yet"
    }
    
    private func setupUIBindings() {
        startButton.isEnabled = false
        cleanUpButton.isEnabled = false
        
        viewModel.onContentsChanged = { [weak self] diff in
            
            if self?.viewModel.numberOfItems == 0 {
                self?.shoppingListEmptyView.isHidden = false
                self?.startButton.isEnabled = false
                self?.cleanUpButton.isEnabled = false
            } else {
                self?.shoppingListEmptyView.isHidden = true
                self?.startButton.isEnabled = true
                self?.cleanUpButton.isEnabled = true
            }
            
            if diff.isEmpty {
                self?.tableView.reloadData() //currency updated, reload rows
            } else {
                self?.tableView.beginUpdates()
                self?.tableView.deleteSections(diff.deletedSections, with: .fade)
                self?.tableView.insertSections(diff.insertedSections, with: .fade)
                self?.tableView.deleteRows(at: diff.deletedRows, with: .fade)
                self?.tableView.insertRows(at: diff.insertedRows, with: .fade)
                self?.tableView.reloadRows(at: diff.updatedRows, with: .fade)
                self?.tableView.endUpdates()
            }
        }
        
    }
    
    @IBAction private func startButtonTapped() {
        viewModel.start()
        Analytics.logEvent("ComposeShoppingList_StartTapped", parameters: nil)
    }
    
    @IBAction private func cleanUpButtonTapped() {
        viewModel.cleanUp()
        Analytics.logEvent("ComposeShoppingList_CleanUpTapped", parameters: nil)
    }
    
    @objc private func addProductButtonTapped() {
        viewModel.addProduct()
    }
}

extension ComposeShoppingListViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let product = viewModel.sections[indexPath.section].products[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as! ProductTableViewCell
        cell.update(forProduct: product, currency: viewModel.currency)
        cell.onInfoButtonTapped = { [weak self] in
            self?.viewModel.selectProduct(atIndexPath: indexPath)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].products.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if viewModel.sections.count == 0 {
            return nil
        }
        return viewModel.sections[section].title
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            viewModel.removeProduct(atIndexPath: indexPath)
        }
    }
}
