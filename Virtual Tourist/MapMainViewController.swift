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
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        stack = appDelegate.stack
        
        let gestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gesture:)))
        mapView.addGestureRecognizer(gestureRecogniser)
        
        let pins = fetchPins()
            if pins.count > 0 {
                mapView.addAnnotations(pins)
            }
    }

    @IBAction func editButtonPressed(_ sender: Any) {
        
        let height = deleteEnabledView.frame.size.height
        
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
    
    func addAnnotation(gesture: UILongPressGestureRecognizer) {
       
        let location = gesture.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let pin = Pin(latitude: Double(coordinate.latitude), longitude: Double(coordinate.longitude), context: stack.context)
        
        mapView.addAnnotation(pin)
        stack.save()
    
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
        
        if !deleteEnabled {
            performSegue(withIdentifier: "CollectionPresent", sender: self)
        } else {
            mapView.removeAnnotation(view.annotation!)
            
        }
        
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        //place alert controller here
    }
    
}

