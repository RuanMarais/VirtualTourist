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

class CoreDataCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var collectionViewInView: UICollectionView?
    var collectionViewUpdates = [NSFetchedResultsChangeType: [IndexPath]]()
    var collectionViewMoves = [(IndexPath, IndexPath)]()
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchedResultsController?.delegate = self
            executeSearch()
            collectionViewInView?.reloadData()
        }
    }
    
    // MARK: Initializers
    
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>, nibName: String?, bundle: Bundle?) {
        fetchedResultsController = fc
        super.init(nibName: nibName, bundle: bundle)
        collectionViewUpdates.removeAll()
        collectionViewMoves.removeAll()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}

// MARK: - CoreDataCollectionController (Subclass Must Implement)

extension CoreDataCollectionController {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("This method MUST be implemented by a subclass of CoreDataCollectionController")
    }
}

// MARK: -  Data Source

extension CoreDataCollectionController {
    
    
    @objc(numberOfSectionsInCollectionView:) func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
  
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print("called did change section")
        let set = IndexSet(integer: sectionIndex)
                
            switch (type) {
            case .insert:
                self.collectionViewInView?.insertSections(set)
            case .delete:
                self.collectionViewInView?.deleteSections(set)
            default:
                break
        }
    }
    
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
            switch(type) {
            case .insert:
                self.collectionViewUpdates[.insert]?.append(newIndexPath!)
            case .delete:
                self.collectionViewUpdates[.delete]?.append(indexPath!)
            case .update:
                self.collectionViewUpdates[.update]?.append(indexPath!)
            case .move:
                self.collectionViewMoves.append((indexPath!, newIndexPath!))
        }
    }
    
    func performCollectionViewUpdates() {
        
        for (changeType, value) in collectionViewUpdates {
            
            switch (changeType) {
            case .delete:
                collectionViewInView?.deleteItems(at: value)
            case .insert:
                collectionViewInView?.insertItems(at: value)
            case .update:
                collectionViewInView?.reloadItems(at: value)
            default:
                continue
                
            }
            
            for (valueOld, valueNew) in collectionViewMoves {
                collectionViewInView?.moveItem(at: valueOld, to: valueNew)
            }
        }
        
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("called did change content")
        collectionViewInView?.performBatchUpdates({ 
            self.performCollectionViewUpdates()
        }, completion: { (completed) in
            if completed {
                self.collectionViewMoves.removeAll()
                self.collectionViewUpdates.removeAll()
            }
        })
    }
  
}


    

