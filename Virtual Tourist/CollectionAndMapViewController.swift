//
//  CollectionAndMapViewController.swift
//  Virtual Tourist
//
//  Created by Dr GJK Marais on 2016/12/08.
//  Copyright © 2016 RuanMarais. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MapKit

class CollectionAndMapViewController: CoreDataCollectionController, MKMapViewDelegate {
    
    @IBOutlet weak var collectionRefreshAndDeleteButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionFlowLayout: UICollectionViewFlowLayout!
    var pin: Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func RefreshAndDelete(_ sender: Any) {
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let collectionPhoto = fetchedResultsController?.object(at: indexPath) as! CollectionPhoto
        let collectionItem = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        let imageURL = URL(string: collectionPhoto.url!)
        if let imageData = NSData(contentsOf: imageURL!) {
            performUIUpdatesOnMain {
                collectionItem.collectionImage.image = UIImage(data: imageData as Data)
            }
        } else {
            
        }
        return collectionItem
    }
 
}
