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
    var reloadFromAlert: Bool = false
    
    
    var alertNoPhotos: UIAlertController?
    var alertAPIStatus: UIAlertController?
    var alertNetwork: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        stack = appDelegate.stack
        fetchedResultsController?.delegate = self
        collectionView.reloadData()
        
        let space: CGFloat = 8.0
        let dimension = (min(view.frame.size.width, view.frame.size.height) - (2 * space)) / 3.0
        
        collectionFlowLayout.minimumInteritemSpacing = space
        collectionFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
        collectionView.allowsMultipleSelection = true
        
        alertAPIStatus = UIAlertController(title: Constants.AlertMessages.APIError, message: Constants.AlertMessages.noPhotosInArray , preferredStyle: .alert)
        alertNoPhotos = UIAlertController(title: Constants.AlertMessages.noPhotosAtPin, message: Constants.AlertMessages.noPhotosInArray , preferredStyle: .alert)
        alertNetwork = UIAlertController(title: Constants.AlertMessages.networkError, message: Constants.AlertMessages.retryNetwork, preferredStyle: .alert)
        
        let noPinPhotosRetrieve = UIAlertAction(title: Constants.AlertMessages.OK, style: .default)
            {(parameter) in
                self.collectionRefreshAndDeleteButton.isEnabled = false
                self.reloadFromAlert = true
                self.updateCollectionContents()
                self.dismiss(animated: true, completion: nil)
            }
        let cancelRetrieve = UIAlertAction(title: Constants.AlertMessages.cancel, style: .cancel) {(parameter) in
                self.dismiss(animated: true, completion: nil)
                self.collectionRefreshAndDeleteButton.isEnabled = true
            }
        let networkError = UIAlertAction(title: Constants.AlertMessages.OK, style: .cancel)
            {(parameter) in
                self.dismiss(animated: true, completion: nil)
                self.collectionRefreshAndDeleteButton.isEnabled = true
            }
        
        alertNoPhotos?.addAction(noPinPhotosRetrieve)
        alertNoPhotos?.addAction(cancelRetrieve)
        alertNetwork?.addAction(networkError)
        alertAPIStatus?.addAction(noPinPhotosRetrieve)
        alertAPIStatus?.addAction(cancelRetrieve)
        
        
        mapView.addAnnotation(pin!)
        setMapLocationToUserDefaults()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if pin?.pinPhotos?.count == 0 {
            present(alertNoPhotos!, animated: true, completion: nil)
        }
        deleteDictionary.removeAll()
    }
    
    @IBAction func refreshAndDelete(_ sender: Any) {
        if collectionRefreshAndDeleteButton.isEnabled {
            collectionRefreshAndDeleteButton.isEnabled = false
            updateCollectionContents()
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
        
        collectionRefreshAndDeleteButton.setTitle("Remove Selected Pictures", for: .normal)
        collectionRefreshAndDeleteButton.titleLabel?.sizeToFit()
        
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
        if deleteDictionary.count == 0 {
            collectionRefreshAndDeleteButton.setTitle("New Collection", for: .normal)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let collectionItem = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        collectionItem.loadingPicture.isHidden = false
        collectionItem.loadingPicture.startAnimating()
        collectionItem.collectionImage.image = #imageLiteral(resourceName: "appIcon")
        
        FlickrClient.sharedInstance.performDataUpdatesOnBackground {
            let collectionPhoto = self.fetchedResultsController?.object(at: indexPath) as! CollectionPhoto
            if let imageData = collectionPhoto.imageData {
                FlickrClient.sharedInstance.performUIUpdatesOnMain {
                    collectionItem.collectionImage.image = UIImage(data: imageData as Data)
                    collectionItem.loadingPicture.isHidden = true
                    collectionItem.loadingPicture.stopAnimating()
                }
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
            collectionViewUpdates.append(element as! [NSFetchedResultsChangeType : IndexPath])
        case .delete:
            let element = [type: indexPath]
            collectionViewUpdates.append(element as! [NSFetchedResultsChangeType : IndexPath])
        case .move:
            collectionViewMoves.append((indexPath!, newIndexPath!))
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
       
        collectionView?.performBatchUpdates({
            self.performCollectionViewUpdates()
        }, completion: { (completed) in
            if completed {
                self.reloadFromAlert = false
                self.resetCollectionUI()
            }
        })
    }
}

extension CollectionAndMapViewController {
    
    func setMapLocationToUserDefaults() {
        let coordinate = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "savedLatitude"), longitude: UserDefaults.standard.double(forKey: "savedLongitude"))
        let span = MKCoordinateSpan(latitudeDelta: UserDefaults.standard.double(forKey: "savedLatitudeDelta"), longitudeDelta: UserDefaults.standard.double(forKey: "savedLongitudeDelta"))
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.region = region
        
    }
    
    func updateCollectionContents() {
        
        if let context = fetchedResultsController?.managedObjectContext {
            if deleteDictionary.count != 0 {
                for (_, value) in deleteDictionary {
                    context.delete(value)
                }
                deleteDictionary.removeAll()
                collectionRefreshAndDeleteButton.isEnabled = true
            } else {
                for item in (self.pin?.pinPhotos)! {
                    context.delete(item as! CollectionPhoto)
                }
                for _ in 0...29 {
                    let photo = CollectionPhoto(name: nil, locationStringBbox: nil, urlString: nil, context: context, data: nil)
                    photo.ownerPin = pin
                }
                FlickrClient.sharedInstance.loadPhotoCoreDataForPin(pin: pin!, context: context, replacementNumber: nil) {(success, array, error) in
                    FlickrClient.sharedInstance.performUIUpdatesOnMain {
                        
                        if success {
                            self.populateCollectionPhotos(photosArray: array!, pin: self.pin!)
                            self.collectionRefreshAndDeleteButton.isEnabled = true
                        } else {
                            print(error?.userInfo[NSLocalizedDescriptionKey] as! String)
                            self.handleLoadPhotosError(error: error, pin: self.pin!)
                            self.collectionRefreshAndDeleteButton.isEnabled = true
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func handleLoadPhotosError(error: NSError?, pin: Pin) {
        
        if (error?.userInfo[NSLocalizedDescriptionKey] as! String) == Constants.ErrorMessages.emptyArray {
            if !(alertNoPhotos?.isBeingPresented)! {
                present(alertNoPhotos!, animated: true, completion: nil)
            }
        } else if (error?.userInfo[NSLocalizedDescriptionKey] as! String) == Constants.ErrorMessages.flickrError {
            if !(alertAPIStatus?.isBeingPresented)! {
                present(alertAPIStatus!, animated: true, completion: nil)
            }
        } else {
            if !(alertNetwork?.isBeingPresented)! {
                present(alertNetwork!, animated: true, completion: nil)
            }
        }
    }

    func resetCollectionUI() {
        collectionViewMoves.removeAll()
        collectionViewUpdates.removeAll()
        if collectionView.indexPathsForSelectedItems?.count == 0 {
            collectionRefreshAndDeleteButton.setTitle("New Collection", for: .normal)
        }
    }
}

extension CollectionAndMapViewController {
    
    func populateCollectionPhotos(photosArray: [[String: AnyObject?]], pin: Pin) {
        FlickrClient.sharedInstance.performDataUpdatesOnBackground {
            var index = 0
            for dictionary in photosArray {
                let indexPath = IndexPath(item: index, section: 0)
                guard let data = NSData(contentsOf: URL(string: (dictionary["urlString"] as? String)!)!) else {
                    continue
                }
                
                let name = dictionary["name"] as? String
                let bbox = dictionary["locationStringBbox"] as? String
                let url = dictionary["urlString"] as? String
                
                let collectionPhoto = self.fetchedResultsController?.object(at: indexPath) as! CollectionPhoto
                
                collectionPhoto.imageData = data
                collectionPhoto.name = name
                collectionPhoto.url = url
                collectionPhoto.locationStringBbox = bbox
                FlickrClient.sharedInstance.performUIUpdatesOnMain {
                    self.collectionView.reloadItems(at: [indexPath])
                }
                
                index += 1
            }
            self.stack.save()
        }
    }
}


