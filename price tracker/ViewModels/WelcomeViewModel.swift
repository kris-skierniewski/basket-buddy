//
//  WelcomeViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 05/09/2025.
//

class WelcomeViewModel {
    
    var onLinkSelected: ((URL) -> Void)?
    var onContinueTapped: (() -> Void)?
    
    var carouselItems: [CarouselItemModel] = [
        
        CarouselItemModel(image: UIImage(systemName: "rectangle.stack.badge.plus")!, title: "Add your groceries", description: "Keep track of your favorite grocery items and their prices from different stores. Just enter the item, select a shop, and add the cost!"),
        
        CarouselItemModel(image: UIImage(systemName: "list.bullet.clipboard")!, title: "Compare prices", description: "We compare prices for you! See which store offers the best value per 100g, 100ml, or unit."),
        
        CarouselItemModel(image: UIImage(systemName: "tray.full")!, title: "Organised shopping list", description: "Create a shopping list that is automatically organised into categories by AI"),
        
        CarouselItemModel(image: UIImage(systemName: "person.2.badge.plus.fill")!, title: "Collaborate with friends", description: "Add members to your group, to share items and prices, and sync your shopping list."),
        
        CarouselItemModel(image: UIImage(systemName: "rectangle.and.text.magnifyingglass")!, title: "Quick Lookup", description: "Can’t remember where you bought that item? Use our lookup feature to find your last purchase in seconds!"),
        
        CarouselItemModel(image: UIImage(systemName: "tag")!, title: "Let’s Start Saving!", description: "Ready to take control of your grocery budget? Tap below to begin adding your items and discover the best deals!")
        
    ]
    
    
    func continueTapped() {
        onContinueTapped?()
    }
    
    func linkSelected(_ url: URL) {
        onLinkSelected?(url)
    }
    
}
