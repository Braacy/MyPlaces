//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Владислав Близнюк on 19.11.2025.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let regionInMeters: Double = 1000
    var incomeSegueIdentifier = ""
    
    
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var doneBtnLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkLocationServices()
    }
    
    
    @IBAction func centerViewInUserLocation() {
        showUserLocation()
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    @IBAction func doneBtnPressed() {
    }
    
    private func setupMapView() {
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            adressLabel.isHidden = true
            doneBtnLabel.isHidden = true
        }
    }
    private func setupPlacemark() {
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            if let error = error {
                print("Error: \(error)")
                return
            }
           guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
            
        }
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
         setupLocationManager()
            checkLocationAutorization()
        } else {
            showAllert(
                title: "Location services are Disabled",
                message: "To enable it go to Settings > Privacy > Location Services and turn it on.")
        }
    }
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAutorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAdress" { showUserLocation() }
            break
        case .denied:
            showAllert(
                title: "Your Location is not allowed",
                message: "To give permission go to Settings > Privacy > Location Services and turn it on.")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("new case is available")
        }
    }
    
    private func showUserLocation() {
        
        if let location = locationManager.location?.coordinate {
        let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        }
    }
    
    private func showAllert(title: String, message: String) {
        let allert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationIdentifier") as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
     
        
        return annotationView
    }
    
}
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAutorization()
    }
}
