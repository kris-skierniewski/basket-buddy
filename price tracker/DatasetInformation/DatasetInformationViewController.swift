//
//  DatasetInformationViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 16/09/2025.
//

class DatasetInformationViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var viewModel: DatasetInformationViewModel
    
    init(viewModel: DatasetInformationViewModel) {
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
        viewModel.loadDatasetInformation()
        navigationItem.title = "Invite friends"
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: DatasetMemberTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: DatasetMemberTableViewCell.identifier)
        tableView.register(UINib(nibName: SimpleBodyTextTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SimpleBodyTextTableViewCell.identifier)
        tableView.register(UINib(nibName: ActionButtonTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ActionButtonTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
    }
    
    private func setupUIBindings() {
        viewModel.onRowsUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    
}

extension DatasetInformationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 2 {
            return 1
        } else {
            return viewModel.rows.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SimpleBodyTextTableViewCell.identifier, for: indexPath) as! SimpleBodyTextTableViewCell
            let bodyText = "Team up on saving money!\n\nInvite members to your group to collaborate and share your items and prices."
            cell.update(with: bodyText)
            cell.selectionStyle = .none
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionButtonTableViewCell.identifier, for: indexPath) as! ActionButtonTableViewCell
            
            let buttonViewModel = ActionButtonTableViewModel(title: "Invite", didSelectBlock: { [weak self] in
                self?.viewModel.invite(sourceView: cell.actionButton)
            })
            
            cell.updateWith(model: buttonViewModel)
            cell.selectionStyle = .none
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: DatasetMemberTableViewCell.identifier, for: indexPath) as! DatasetMemberTableViewCell
        let row = viewModel.rows[indexPath.row]
        cell.update(for: row)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let header = SimpleTableViewHeaderView().viewFromXib() as! SimpleTableViewHeaderView
        header.updateWithTitle("Members")
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 2 {
            return CGFLOAT_MIN
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || section == 2 {
            return CGFLOAT_MIN
        } else {
            return UITableView.automaticDimension
        }
    }
    
    
    
}
