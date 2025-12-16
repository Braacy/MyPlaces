//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Владислав Близнюк on 19.11.2025.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    
    var mapViewConrtrollerDelegate: MapViewControllerDelegate?
    
    let locationManager = CLLocationManager()
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let regionInMeters: Double = 1000
    var incomeSegueIdentifier = ""
    var placeCoordinate: CLLocationCoordinate2D?
    var directionsArray: [MKDirections] = []
    var previosLocation: CLLocation? {
         didSet {
            startTrackingUserLocation()
        }
    }
    
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var doneBtnLabel: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = ""
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
    
    @IBAction func goBtnPressed() {
        getDirections()
    }
    
    
    @IBAction func doneBtnPressed() {
        mapViewConrtrollerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    
    
    private func setupMapView() {
        goButton.isHidden = true
        
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneBtnLabel.isHidden = true
            goButton.isHidden = false
        }
    }
    
    private func resetMapView(withNew directions: MKDirections) {
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
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
            self.placeCoordinate = placemarkLocation.coordinate
            
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
            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
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
    
    private func startTrackingUserLocation() {
        
        guard let previosLocation = previosLocation else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: previosLocation) > 50 else { return }
        self.previosLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showUserLocation()
        }
    }
    
    private func getDirections(){
        guard let location = locationManager.location?.coordinate else {
            showAllert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previosLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionsRequest(from: location) else {
            showAllert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        
        directions.calculate { (response, error)  in
            if let error = error {
                print("Error: \(error)")
                return
            }
            guard let response = response else {
                self.showAllert(title: "Error", message: "Direction is not available")
                return
            }
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                let time = String(format: "%.0f", timeInterval / 60)
                
                print("расстояние \(distance) км, время \(time) мин")
            }
            
        }
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
       
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previosLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showUserLocation()
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print("error: \(error)")
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .systemGreen
        return renderer
    }
}
    
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAutorization()
    }
}
