//
//  SectionedDiffCalculator.swift
//  price tracker
//
//  Created by Kris Skierniewski on 05/09/2025.
//
import Foundation
import UIKit

protocol DiffableItem: Equatable {
    var diffIdentifier: String { get }
}

struct SectionedDiff {
    let insertedSections: IndexSet
    let deletedSections: IndexSet
    let insertedRows: [IndexPath]
    let deletedRows: [IndexPath]
    let updatedRows: [IndexPath]
    
    var isEmpty: Bool {
        return insertedSections.isEmpty &&
        deletedSections.isEmpty &&
        insertedRows.isEmpty &&
        deletedRows.isEmpty &&
        updatedRows.isEmpty
    }
}

protocol DiffableSectionProtocol {
    associatedtype Item: DiffableItem
    var id: String { get }
    var items: [Item] { get }
}

struct SectionedDiffCalculator {
    
    static func diff<Section: DiffableSectionProtocol>(
        old: [Section],
        new: [Section]
    ) -> SectionedDiff {
        
        var insertedSections = IndexSet()
        var deletedSections = IndexSet()
        var insertedRows: [IndexPath] = []
        var deletedRows: [IndexPath] = []
        var updatedRows: [IndexPath] = []
        
        let oldSectionIDs = old.map { $0.id }
        let newSectionIDs = new.map { $0.id }
        
        // Sections deleted
        for (index, id) in oldSectionIDs.enumerated() where !newSectionIDs.contains(id) {
            deletedSections.insert(index)
        }
        
        // Sections inserted
        for (index, id) in newSectionIDs.enumerated() where !oldSectionIDs.contains(id) {
            insertedSections.insert(index)
        }
        
        // Rows in matching sections
        for (newSectionIndex, newSection) in new.enumerated() {
            guard let oldSectionIndex = oldSectionIDs.firstIndex(of: newSection.id) else { continue }
            let oldSection = old[oldSectionIndex]
            
            let oldIDs = oldSection.items.map { $0.diffIdentifier }
            let newIDs = newSection.items.map { $0.diffIdentifier }
            
            // Deleted rows
            for (rowIndex, id) in oldIDs.enumerated() where !newIDs.contains(id) {
                deletedRows.append(IndexPath(row: rowIndex, section: oldSectionIndex))
            }
            
            // Inserted rows
            for (rowIndex, id) in newIDs.enumerated() where !oldIDs.contains(id) {
                insertedRows.append(IndexPath(row: rowIndex, section: newSectionIndex))
            }
            
            // Updated rows
            for (rowIndex, newItem) in newSection.items.enumerated() {
                if let oldRowIndex = oldSection.items.firstIndex(where: { $0.diffIdentifier == newItem.diffIdentifier }) {
                    let oldItem = oldSection.items[oldRowIndex]
                    if oldItem != newItem { // Equatable check
                        updatedRows.append(IndexPath(row: rowIndex, section: newSectionIndex))
                    }
                }
            }
        }
        
        return SectionedDiff(
            insertedSections: insertedSections,
            deletedSections: deletedSections,
            insertedRows: insertedRows,
            deletedRows: deletedRows,
            updatedRows: updatedRows
        )
    }
}

