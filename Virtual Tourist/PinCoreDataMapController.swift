//
//  PinCoreDataMapController.swift
//  Virtual Tourist
//
//  Created by Dr GJK Marais on 2016/12/07.
//  Copyright © 2016 RuanMarais. All rights reserved.
//

import Foundation
import CoreData
import MapKit
import UIKit

class PinCoreDataMapController: MKMapView, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            
            fetchedResultsController?.delegate = self
            executeSearch()
            self.reloadInputViews()
        }
    }
    
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>, view: CGRect) {
        fetchedResultsController = fc
        super.init(frame: view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
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
