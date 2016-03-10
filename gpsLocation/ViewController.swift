//
//  ViewController.swift
//  gpsLocation
//
//  Created by Ricardo on 09/03/2016.
//  Copyright © 2016 Tablaz. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private let controller = CLLocationManager()
    
    private var lastPoint = CLLocation()
    
    // Primera posición
    var oldLocation : CLLocation!
    var totalDistance : Double = 0.0
    var pointDistance : Double = 0.0
    
    var mapDeltaLat : Double = 3000
    var mapDeltaLon : Double = 3000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        controller.delegate = self
        controller.desiredAccuracy = kCLLocationAccuracyBest
        // PARA USARLO EN FOREGROUND
        controller.requestWhenInUseAuthorization()
        // PARA USARLO EN BACKGROUND
        // controller.requestAlwaysAuthorization()()
                
    }
    
    @IBAction func zoomIn(sender: UIBarButtonItem) {
        self.mapDeltaLon = self.mapDeltaLon <= 1000 ? 0 : self.mapDeltaLon - 1000
        self.mapDeltaLat = self.mapDeltaLat <= 1000 ? 0 : self.mapDeltaLat - 1000
                print(self.mapDeltaLat)
        
    }
    
    @IBAction func zoomOut(sender: UIBarButtonItem) {
        self.mapDeltaLon = self.mapDeltaLon >= 10000 ? 10000 : self.mapDeltaLon + 1000
        self.mapDeltaLat = self.mapDeltaLat >= 10000 ? 10000 : self.mapDeltaLat + 1000
        print(self.mapDeltaLat)
    }
    
    
    @IBAction func changeType(sender: UIBarButtonItem) {
        
        switch mapView.mapType {
        case MKMapType.Standard :
            mapView.mapType = MKMapType.Satellite
        case MKMapType.Satellite :
             mapView.mapType = MKMapType.Hybrid
        case MKMapType.Hybrid:
            mapView.mapType = MKMapType.Standard
        default :
            mapView.mapType = MKMapType.Standard
        }

    }
    
    func setPoint(point :CLLocationCoordinate2D, distance : Double) {
        
        let pin = MKPointAnnotation()
        let distanceKm = round( (distance) * 100 ) / 100
        pin.title = "Lat: \(point.latitude) - Log: \(point.longitude)"
        pin.subtitle = "\(distanceKm) mts"
        pin.coordinate = point
        mapView.addAnnotation(pin)
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            controller.startUpdatingLocation()
            // controller.startUpdatingHeading() // INICIAR LA BRUJULA
            
            mapView.showsUserLocation = true
            
            
        } else {
            controller.stopUpdatingLocation()
            // controller.stopUpdatingHeading() // PARAR lA BRUJULA
            mapView.showsUserLocation = false
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let firstLocation = locations.first! as CLLocation! {
            mapView.setCenterCoordinate(firstLocation.coordinate, animated: true)
            
            let region = MKCoordinateRegionMakeWithDistance(firstLocation.coordinate, self.mapDeltaLat, self.mapDeltaLon)
            mapView.setRegion(region, animated: true)
            
            if let oldLocation = oldLocation {
                let delta: CLLocationDistance = firstLocation.distanceFromLocation(oldLocation)
                self.totalDistance += delta
                self.pointDistance += delta
                if pointDistance >= 50 {
                    // MAPA
                    var point = CLLocationCoordinate2D()
                    point.latitude = controller.location!.coordinate.latitude
                    point.longitude = controller.location!.coordinate.longitude
                    self.setPoint(point, distance: self.totalDistance)
                    self.pointDistance = 0
                }
            }
            oldLocation = firstLocation
        }
        
        
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {

    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alert = UIAlertController(title: "Error", message: "Error: \(error.code)", preferredStyle: .Alert)
        let accionOk = UIAlertAction(title: "Ok", style: .Default, handler:
            { accion in
                // ..
        } )
        alert.addAction(accionOk)
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

