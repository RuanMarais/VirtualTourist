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
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        stack = appDelegate.stack
        fetchedResultsController?.delegate = self
        self.collectionView.reloadData()
        
        let space: CGFloat = 8.0
        let dimension = (min(view.frame.size.width, view.frame.size.height) - (2 * space)) / 3.0
        
        collectionFlowLayout.minimumInteritemSpacing = space
        collectionFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
        collectionView.allowsMultipleSelection = true
        
        mapView.addAnnotation(pin!)
        setMapLocationToUserDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if collectionView.numberOfItems(inSection: 0) == 0 {
            
        }
    }

    @IBAction func RefreshAndDelete(_ sender: Any) {
        var replaceAll: Int? = nil
        if let context = fetchedResultsController?.managedObjectContext {
            if deleteDictionary.count != 0 {
                replaceAll = deleteDictionary.count
                for (_, value) in self.deleteDictionary {
                context.delete(value)
                }
            } else {
                for item in (pin?.pinPhotos)! {
                    context.delete(item as! CollectionPhoto)
                }
            }
            
            FlickrClient.sharedInstance.loadPhotoCoreDataForPin(pin: pin!, context: context, replacementNumber: replaceAll){(success, error) in
                performUIUpdatesOnMain {
                    if success {
                        
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let collectionPhoto = fetchedResultsController?.object(at: indexPath) as! CollectionPhoto
        deleteDictionary[indexPath] = collectionPhoto
        let cell = collectionView.cellForItem(at: indexPath)! as! CollectionViewCell
        cell.isSelected = true
        cell.contentView.alpha = 0.5
        
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        deleteDictionary.removeValue(forKey: indexPath)
        collectionView.cellForItem(at: indexPath)?.isSelected = false
        let cell = collectionView.cellForItem(at: indexPath)! as! CollectionViewCell
        cell.isSelected = false
        cell.contentView.alpha = 1.0
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
        if collectionItem.isSelected {
            collectionItem.contentView.alpha = 0.5
        } else {
            collectionItem.contentView.alpha = 1.0
        }
        
        return collectionItem
        }
 
}

extension CollectionAndMapViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert, .update:
            let element = [type: newIndexPath]
            self.collectionViewUpdates.append(element as! [NSFetchedResultsChangeType : IndexPath])
        case .delete:
            let element = [type: indexPath]
            self.collectionViewUpdates.append(element as! [NSFetchedResultsChangeType : IndexPath])
        case .move:
            self.collectionViewMoves.append((indexPath!, newIndexPath!))
        }
    }
    
    func performCollectionViewUpdates() {
        
        for value in collectionViewUpdates {
            for (changeType, value) in value {
            switch (changeType) {
            case .delete:
                collectionView?.deleteItems(at: [value])
            case .insert:
                collectionView?.insertItems(at: [value])
            case .update:
                collectionView?.reloadItems(at: [value])
            default:
                break
                
            }
        }
            
            for (valueOld, valueNew) in collectionViewMoves {
                collectionView?.moveItem(at: valueOld, to: valueNew)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       
        self.collectionView?.performBatchUpdates({
            self.performCollectionViewUpdates()
        }, completion: { (completed) in
            if completed {
                self.collectionViewMoves.removeAll()
                self.collectionViewUpdates.removeAll()
                self.deleteDictionary.removeAll()
            }
        })
    }
}

extension CollectionAndMapViewController {
    
    func setMapLocationToUserDefaults() {
        let coordinate = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "savedLatitude"), longitude: UserDefaults.standard.double(forKey: "savedLongitude"))
        let span = MKCoordinateSpan(latitudeDelta: UserDefaults.standard.double(forKey: "savedLatitudeDelta"), longitudeDelta: UserDefaults.standard.double(forKey: "savedLongitudeDelta"))
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.region = region
        
    }

}
