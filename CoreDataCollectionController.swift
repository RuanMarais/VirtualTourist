//
//  CoreDataCollectionController.swift
//  Virtual Tourist
//
//  Created by Dr GJK Marais on 2016/12/08.
//  Copyright © 2016 RuanMarais. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataCollectionController: UICollectionViewController {
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchedResultsController?.delegate = self
            executeSearch()
            collectionView?.reloadData()
        }
    }
    
    // MARK: Initializers
    
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>, layout: UICollectionViewLayout) {
        fetchedResultsController = fc
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - CoreDataCollectionController (Subclass Must Implement)

extension CoreDataCollectionController {
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("This method MUST be implemented by a subclass of CoreDataCollectionController")
    }
}

// MARK: -  Data Source

extension CoreDataCollectionController {
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }

    }
    
}

// MARK: - CoreDataTableViewController (Fetches)

extension CoreDataCollectionController {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}

// MARK: - CoreDataTableViewController: NSFetchedResultsControllerDelegate

extension CoreDataCollectionController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            
            func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
                
                let set = IndexSet(integer: sectionIndex)
                
                switch (type) {
                case .insert:
                    self.collectionView?.insertSections(set)
                case .delete:
                    self.collectionView?.deleteSections(set)
                default:
                    break
                }
            }
            
            func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
                
                switch(type) {
                case .insert:
                    self.collectionView?.insertItems(at: [newIndexPath!])
                case .delete:
                    self.collectionView?.deleteItems(at: [indexPath!])
                case .update:
                    self.collectionView?.reloadItems(at: [indexPath!])
                case .move:
                    self.collectionView?.deleteItems(at: [indexPath!])
                    self.collectionView?.insertItems(at: [newIndexPath!])
                }
            }

        }, completion: nil)
    }
    
}
