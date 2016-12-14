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
    
    var collectionViewUpdates = [[NSFetchedResultsChangeType: IndexPath]]()
    var collectionViewMoves = [(IndexPath, IndexPath)]()
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            executeSearch()
        }
    }
    
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

extension CoreDataCollectionController {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("This method MUST be implemented by a subclass of CoreDataCollectionController")
    }
}

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



    

