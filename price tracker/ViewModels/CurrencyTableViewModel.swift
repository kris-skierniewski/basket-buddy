//
//  CurrencyTableViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 17/09/2025.
//

class CurrencyTableViewModel: KTableViewModel {
    
    var rightBarButtonItem: UIBarButtonItem?
    
    private let combinedRepository: CombinedRepositoryProtocol
    
    var preferencesObserverHandle: ObserverHandle?
    private var userPreferences: UserPreferences?
    
    
    var sections: [KTableViewSection] = []
    
    var onSectionsUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    var navigationTitle: String {
        return "Currency"
    }
    
    init(combinedRepository: CombinedRepositoryProtocol) {
        self.combinedRepository = combinedRepository
    }
    
    func loadSections() {
        preferencesObserverHandle = combinedRepository.observePreferences(onChange: { [weak self] prefs in
            if let prefs = prefs {
                self?.userPreferences = prefs
            } else {
                self?.userPreferences = UserPreferences()
            }
            self?.updateSections()
        })
    }
    
    private func updateSections() {
        let rows: [KTableViewRow] = Currency.allCases.map({ [weak self] currency in
            let isCurrencySelected = self?.userPreferences?.currency == currency
            
            let row = KTableViewRow(title: currency.symbol, subtitle: "", accessoryType: isCurrencySelected ? .checkmark : .none)
            row.didSelectBlock = {
                self?.selectCurrency(currency)
            }
            
            return row
        })
        let currencySection = KTableViewSection(title: "Price currency", body: "Choose which currency to display throughout the app", rows: rows)
        sections = [currencySection]
        onSectionsUpdated?()
    }
    
    private func selectCurrency(_ currency: Currency) {
        guard var userPreferences = userPreferences else {
            return
        }
        userPreferences.currency = currency
        combinedRepository.updateUserPreferences(userPreferences) { [weak self] result in
            switch result {
            case .success(()):
                break
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
}
