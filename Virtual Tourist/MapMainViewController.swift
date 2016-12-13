//
//  MapMainViewController.swift
//  Virtual Tourist
//
//  Created by Dr GJK Marais on 2016/12/03.
//  Copyright © 2016 RuanMarais. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapMainViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var deleteEnabledView: UIView!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var deleteEnabled = false
    var appDelegate: AppDelegate!
    var stack: CoreDataStack!
    var gestureRecogniser: UILongPressGestureRecognizer!
    var UIEnabled: Bool = true
    
    var alertNoPhotos: UIAlertController?
    var alertAPIStatus: UIAlertController?
    var alertNetwork: UIAlertController?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        stack = appDelegate.stack
        
        gestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gesture:)))
        mapView.addGestureRecognizer(gestureRecogniser)
        
        alertAPIStatus = UIAlertController(title: Constants.AlertMessages.APIError, message: Constants.AlertMessages.continuePinPlacementIfNoPhotos , preferredStyle: .alert)
        alertNoPhotos = UIAlertController(title: Constants.AlertMessages.noPhotosAtPin, message: Constants.AlertMessages.continuePinPlacementIfNoPhotos , preferredStyle: .alert)
        alertNetwork = UIAlertController(title: Constants.AlertMessages.networkError, message: Constants.AlertMessages.retryNetwork, preferredStyle: .alert)
        
        let noPinPhotos = UIAlertAction(title: Constants.AlertMessages.OK, style: .cancel) {(parameter) in
            self.dismiss(animated: true, completion: nil)
        }
        let networkError = UIAlertAction(title: Constants.AlertMessages.OK, style: .cancel)
            {(parameter) in
            self.dismiss(animated: true, completion: nil)
        }

        alertNoPhotos?.addAction(noPinPhotos)
        alertAPIStatus?.addAction(noPinPhotos)
        alertNetwork?.addAction(networkError)
    
        let pins = fetchPins()
            if pins.count > 0 {
                mapView.addAnnotations(pins)
            }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
       
        if UserDefaults.standard.bool(forKey: "MapViewHasChanged") {
            setMapLocationToUserDefaults()
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(true, forKey: "MapViewHasChanged")
        saveMapLocationToUserDefaults()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        let height = deleteEnabledView.frame.size.height
        adjustView(height: height)
    }
    
    func addAnnotation(gesture: UILongPressGestureRecognizer) {
        if !deleteEnabled {
            UIEnabled(enabled: false)
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
            let pin = Pin(latitude: Double(coordinate.latitude), longitude: Double(coordinate.longitude), context: stack.context)
            FlickrClient.sharedInstance.loadPhotoCoreDataForPin(pin: pin, context: self.stack.context, replacementNumber: nil){(success, error) in
                performUIUpdatesOnMain {
                    
                    if success {
                        self.UIEnabled(enabled: true)
                        self.mapView.addAnnotation(pin)
                    } else {
                        print(error?.userInfo[NSLocalizedDescriptionKey] as! String)
                        self.handleLoadPhotosError(error: error, pin: pin)
                        self.UIEnabled(enabled: true)
                    }
                }
            }
            stack.save()
        }
    }

    func fetchPins() -> [Pin] {
        
        var pins = [Pin]()
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Pin.fetchRequest()
        
        do {
            let results = try stack.context.fetch(fetchRequest) as! [Pin]
            pins = results
        } catch {
            print("persistent store fetch request failed")
        }
        
        return pins
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = view.annotation! as! Pin
        
        if !deleteEnabled {
            if UIEnabled {
            let fr: NSFetchRequest<NSFetchRequestResult> = CollectionPhoto.fetchRequest()
            fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false), NSSortDescriptor(key: "locationStringBbox", ascending: true), NSSortDescriptor(key: "url", ascending: false)]
            let pred = NSPredicate(format: "ownerPin = %@", argumentArray: [pin])
            fr.predicate = pred
            let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
            
            self.setMapLocationToUserDefaults()
            let collectionVC = self.storyboard!.instantiateViewController(withIdentifier: "Collection") as! CollectionAndMapViewController
            collectionVC.pin = pin
            
            collectionVC.fetchedResultsController = fc
            self.navigationController!.pushViewController(collectionVC, animated: true)
            }
        } else {
            mapView.removeAnnotation(pin)
            stack.context.delete(pin)
            stack.save()
        }
    }
    
}

extension MapMainViewController {
    
    func UIEnabled(enabled: Bool) {
        gestureRecogniser.isEnabled = enabled
        UIEnabled = enabled
    }
    
    func adjustView(height: CGFloat) {
       if !deleteEnabled {
            editButton.style = .done
            editButton.title = "Done"
            
            deleteEnabledView.isHidden = false
            deleteLabel.isHidden = false
            self.mapView.frame.origin.y -= height
            deleteEnabled = true
        } else {
            editButton.style = .plain
            editButton.title = "Edit"
            
            deleteEnabledView.isHidden = true
            deleteLabel.isHidden = true
            self.mapView.frame.origin.y += height
            deleteEnabled = false
        }

    }
    
    func saveMapLocationToUserDefaults() {
        let latitude = self.mapView.region.center.latitude as Double
        let longitude = self.mapView.region.center.longitude as Double
        let latitudeDelta = self.mapView.region.span.latitudeDelta as Double
        let longitudeDelta = self.mapView.region.span.longitudeDelta as Double
        UserDefaults.standard.set(latitude, forKey: "savedLatitude")
        UserDefaults.standard.set(longitude, forKey: "savedLongitude")
        UserDefaults.standard.set(latitudeDelta, forKey: "savedLatitudeDelta")
        UserDefaults.standard.set(longitudeDelta, forKey: "savedLongitudeDelta")
        UserDefaults.standard.synchronize()
    }
    
    func setMapLocationToUserDefaults() {
        let coordinate = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "savedLatitude"), longitude: UserDefaults.standard.double(forKey: "savedLongitude"))
        let span = MKCoordinateSpan(latitudeDelta: UserDefaults.standard.double(forKey: "savedLatitudeDelta"), longitudeDelta: UserDefaults.standard.double(forKey: "savedLongitudeDelta"))
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.region = region
        
    }
    
    func handleLoadPhotosError(error: NSError?, pin: Pin) {
        
    if (error?.userInfo[NSLocalizedDescriptionKey] as! String) == Constants.ErrorMessages.emptyArray {
        if !(alertNoPhotos?.isBeingPresented)! {
        self.present(self.alertNoPhotos!, animated: true, completion: nil)
            self.mapView.addAnnotation(pin)
        }
    } else if (error?.userInfo[NSLocalizedDescriptionKey] as! String) == Constants.ErrorMessages.flickrError {
        if !(alertAPIStatus?.isBeingPresented)! {
            self.present(self.alertAPIStatus!, animated: true, completion: nil)
            self.mapView.addAnnotation(pin)
        }
    } else {
        if !(alertNetwork?.isBeingPresented)! {
            self.present(self.alertNetwork!, animated: true, completion: nil)
            self.mapView.addAnnotation(pin)
            }
        }
    }
    
}
