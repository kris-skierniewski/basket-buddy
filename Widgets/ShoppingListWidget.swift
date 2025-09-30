//
//  ShoppingListWidget.swift
//  ShoppingListWidget
//
//  Created by Kris Skierniewski on 26/09/2025.
//

import FirebaseCore
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ShoppingListEntry {
        ShoppingListEntry(date: Date(), items: ["Bread", "Milk", "Butter"], isSignedIn: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (ShoppingListEntry) -> ()) {
        Task {
            let entry = await getShoppingListEntry()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let entry = await getShoppingListEntry()
            
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 25, to: Date())!
            
            let timeline = Timeline(
                entries: [entry],
                policy: .after(nextUpdateDate)
            )
            
            completion(timeline)
        }
    }
    
    func getShoppingListEntry() async -> ShoppingListEntry {
        let authService = FirebaseAuthService()
        if let currentUserId = authService.currentUserId {
            let firebaseService = FirebaseDatabaseService()
            let datatsetRepository = FirebaseDatasetRepository(firebaseService: firebaseService, userId: currentUserId)
            
            do {
                guard let datasetId = try await datatsetRepository.getUserDatasetId() else {
                    return ShoppingListEntry(date: Date(), items: [], isSignedIn: false)
                }
                
                let combinedRepository = CombinedRepository(datasetId: datasetId, firebaseService: firebaseService)
                
                
                guard let shoppingList = try await combinedRepository.getShoppingList() else {
                    return ShoppingListEntry(date: Date(), items: [], isSignedIn: false)
                }
                let allProducts = try await combinedRepository.getProducts()
                
                let items = shoppingList.products.compactMap({ shoppingListItem in
                    if shoppingListItem.isChecked == false {
                        return allProducts.first(where: { $0.id == shoppingListItem.productId })
                    } else {
                        return nil
                    }
                }).map {
                    $0.name
                }
                return ShoppingListEntry(date: Date(), items: items, isSignedIn: true)
                
            } catch {
                return ShoppingListEntry(date: Date(), items: [], isSignedIn: false)
            }
            
            
        } else {
            return ShoppingListEntry(date: Date(), items: [], isSignedIn: false)
        }
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct ShoppingListEntry: TimelineEntry {
    let date: Date
    let items: [String]
    var count: Int {
        items.count
    }
    let isSignedIn: Bool
}

struct WidgetsEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    
    private func shouldShowMoreItems(numberOfLines: Int) -> Bool {
        if entry.isSignedIn == false {
            return false
        }   else if entry.count == 0 {
            return false
        } else if entry.count <= numberOfLines {
            return false
        }
        switch family {
        case .systemSmall:
                return true
        default:
            if entry.count <= numberOfLines*2 {
                return false
            } else {
                return true
            }
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let availableHeight = geo.size.height - UIFont.preferredFont(forTextStyle: .body).lineHeight
            let lineHeight = UIFont.preferredFont(forTextStyle: .caption1).lineHeight
            let numberOfLines = Int(availableHeight / lineHeight) - 1
            let shouldShowMoreItems = shouldShowMoreItems(numberOfLines: numberOfLines)
            
            ZStack {
                WidgetShoppingListBackgrounView(numberOfLines: numberOfLines, itemCount: entry.count, shouldShowMoreItems: shouldShowMoreItems)
                if entry.isSignedIn == false {
                    WidgetShoppingListNotSetupView()
                } else if entry.count == 0 {
                    WidgetShoppingListEmptyView()
                } else {
                    VStack {
                        WidgetShoppingListHeaderView().hidden()
                        WidgetShoppingListContentView(numberOfLines: numberOfLines, entry: entry)
                        if shouldShowMoreItems {
                            Spacer().frame(height: 2)
                            Text("+ x others").font(.caption2).hidden()
                        }
                    }
                }
            }.widgetURL(URL(string: "basketbuddy://appsbykris.com/shoppinglist"))//.padding(.bottom, 1.0)
        }
    }
}

struct WidgetShoppingListContentView: View {
    @Environment(\.widgetFamily) var family
    var numberOfLines: Int
    var entry: Provider.Entry
    var body: some View {
        switch family {
        case .systemSmall:
            VStack {
                ForEach(0..<min(numberOfLines, entry.count), id: \.self) { index in
                    HStack {
                        Text("\u{2022} \(entry.items[index])").font(.caption).fontWeight(.medium)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                if entry.count < numberOfLines {
                    Spacer()
                }
            }
        default:
            HStack(alignment: .top) {
                VStack {
                    ForEach(0..<min(numberOfLines, entry.count), id: \.self) { index in
                        HStack {
                            Text("\u{2022} \(entry.items[index])").font(.caption).fontWeight(.medium)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if entry.count < numberOfLines {
                        Spacer()
                    }
                }
                if entry.count > numberOfLines {
                    VStack {
                        ForEach(numberOfLines..<min(numberOfLines*2, entry.count), id: \.self) { index in
                            HStack {
                                Text("\u{2022} \(entry.items[index])").font(.caption).fontWeight(.medium)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }
                        if entry.count < (numberOfLines*2) {
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

struct WidgetShoppingListHeaderView: View {
    var body: some View {
        HStack {
            Text("Shopping list").underline().fontWeight(.regular)
            Image("BasketBuddy-appIcon").resizable().frame(width: 16, height: 16).clipShape(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4)))
        }
    }
}

struct WidgetShoppingListBackgrounView: View {
    @Environment(\.widgetFamily) var family
    var numberOfLines: Int
    var itemCount: Int
    var shouldShowMoreItems: Bool
    var body: some View {
        VStack {
            WidgetShoppingListHeaderView()
            Spacer()
            if shouldShowMoreItems {
                Text("+ ^[\(calculateNumberOfOtherItems()) more items](inflect: true)").font(.caption2).foregroundStyle(Color.secondary)
            }
        }
    }
    
    func calculateNumberOfOtherItems() -> Int {
        if family == .systemSmall {
            if itemCount <= numberOfLines {
                return 0
            } else {
                return itemCount - numberOfLines
            }
        } else {
            if itemCount <= (numberOfLines*2) {
                return 0
            } else {
                return itemCount - (numberOfLines*2)
            }
        }
    }
}

struct WidgetShoppingListEmptyView: View {
    var body: some View {
        VStack() {
            WidgetShoppingListHeaderView().hidden()
            Text("All done!\nYour shopping list is empty.").multilineTextAlignment(.center).foregroundStyle(Color.secondary)
        }.frame(maxWidth: .infinity)
    }
}

struct WidgetShoppingListNotSetupView: View {
    var body: some View {
        VStack {
            WidgetShoppingListHeaderView().hidden()
            Text("Sign in and finish setting up to see your shopping list.").multilineTextAlignment(.center).foregroundStyle(Color.secondary)
        }.frame(maxWidth: .infinity)
    }
}

struct ShoppingListWidget: Widget {
    let kind: String = "Shopping list widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetsEntryView(entry: entry)
                    .containerBackground(
                        Color("AccentColor").opacity(0.22),
                        for: .widget)
            } else {
                WidgetsEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Shopping list")
        .supportedFamilies([.systemSmall, .systemMedium])
        .description("See what’s left on your shopping list at a glance")
    }
}

#Preview(as: .systemSmall) {
    ShoppingListWidget()
} timeline: {
    ShoppingListEntry(date: Date(), items: ["bug & pest control spray", "milk", //
                                        "asparagus", "bacon", "Comfort fabric conditioner","sausages", "butter",
                                            //"flapjacks", "something else","x","c","v",
                                            //"a","b", "l","k"
                                           ], isSignedIn: true)
    ShoppingListEntry(date: Date(), items: [], isSignedIn: true)
    ShoppingListEntry(date: Date(), items: [], isSignedIn: false)
}
