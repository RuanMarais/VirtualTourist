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
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionRefreshAndDeleteButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionFlowLayout: UICollectionViewFlowLayout!
    
    var pin: Pin?
    var deleteDictionary = [IndexPath: CollectionPhoto]()
    var appDelegate: AppDelegate!
    var stack: CoreDataStack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionViewInView = collectionView
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        stack = appDelegate.stack

        
        let space: CGFloat = 8.0
        let dimension = (min(view.frame.size.width, view.frame.size.height) - (2 * space)) / 3.0
        
        collectionFlowLayout.minimumInteritemSpacing = space
        collectionFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
        collectionView.allowsMultipleSelection = true
    }

    @IBAction func RefreshAndDelete(_ sender: Any) {
        
        if let context = fetchedResultsController?.managedObjectContext {
            
            if deleteDictionary.count != 0 {
                
                FlickrClient.sharedInstance.loadFlickrImagesInDeletedSpaces(pin: pin!, context: context, replacementItemsDictionary: deleteDictionary, collectionView: collectionView){(success, error) in
                    performUIUpdatesOnMain {
                        if success {
                            print("donno how")
                            self.collectionView.reloadData()
                            self.deleteDictionary.removeAll()
                        }
                    }
                }
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let collectionPhoto = fetchedResultsController?.object(at: indexPath) as! CollectionPhoto
        deleteDictionary[indexPath] = collectionPhoto
        collectionView.cellForItem(at: indexPath)?.contentView.alpha = 0.5
        print(deleteDictionary.count)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        deleteDictionary.removeValue(forKey: indexPath)
        collectionView.cellForItem(at: indexPath)?.contentView.alpha = 1.0
        print(deleteDictionary.count)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let collectionPhoto = fetchedResultsController?.object(at: indexPath) as! CollectionPhoto
        let collectionItem = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        collectionItem.loadingPicture.isHidden = false
        collectionItem.loadingPicture.startAnimating()
        let imageURL = URL(string: collectionPhoto.url!)
        if let imageData = NSData(contentsOf: imageURL!) {
            performUIUpdatesOnMain {
                collectionItem.collectionImage.image = UIImage(data: imageData as Data)
                collectionItem.loadingPicture.isHidden = true
                collectionItem.loadingPicture.stopAnimating()
            }
        } 
        return collectionItem
        }
 
}
