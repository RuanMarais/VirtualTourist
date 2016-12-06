//
//  MapMainViewController.swift
//  Virtual Tourist
//
//  Created by Dr GJK Marais on 2016/12/03.
//  Copyright © 2016 RuanMarais. All rights reserved.
//

import UIKit
import MapKit

class MapMainViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var DeleteEnabledView: UIView!
    @IBOutlet weak var DeleteLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    var deleteEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gesture:)))
        mapView.addGestureRecognizer(gestureRecogniser)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
    }
    
   
    
    func addAnnotation(gesture: UILongPressGestureRecognizer) {
       
        let location = gesture.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        print(coordinate.latitude)
        print(coordinate.longitude)
    
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
            
        }
        
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        //place alert controller here
    }
    
    
}

