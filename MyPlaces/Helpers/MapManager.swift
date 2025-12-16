//
//  MapManager.swift
//  MyPlaces
//
//  Created by Владислав Близнюк on 16.12.2025.
//

import UIKit
import MapKit

class MapManager {
    let locationManager = CLLocationManager()
    
    private var placeCoordinate: CLLocationCoordinate2D?
    private let regionInMeters: Double = 1000
    private var directionsArray: [MKDirections] = []
    
    //маркер заведения
       func setupPlacemark(place: Place, mapView: MKMapView) {
        
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
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    //проверка доступности сервисов геолокации
       func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAutorization(mapView: mapView, segueIdentifie: segueIdentifier)
            closure()
        } else {
            showAllert(
                title: "Location services are Disabled",
                message: "To enable it go to Settings > Privacy > Location Services and turn it on.")
        }
    }
    
    //проверка авторизации приложения для использования сервисов геолокации
       func checkLocationAutorization(mapView: MKMapView, segueIdentifie: String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifie == "getAddress" { showUserLocation(mapView: mapView) }
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
    
    //фокус карты на местоположении пользователя
      func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
        let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        }
    }
    
    //строим маршрут от местоположения пользователя до заведения
       func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()){
        guard let location = locationManager.location?.coordinate else {
            showAllert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAllert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        
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
               mapView.addOverlay(route.polyline)
               mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                let time = String(format: "%.0f", timeInterval / 60)
                
                print("расстояние \(distance) км, время \(time) мин")
            }
        }
    }
    
    //настройка запроса для расчета маршрута
       func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
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
    
    //меняем отображаемую зону области карты в соответсвии с перемещением пользователя
      func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
      
        closure(center)
    }

    //сброс всех ранее построенных маршрутов перед построением нового
       func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    
    //определение центра отображаемой области карты
       func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
    
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
      private func showAllert(title: String, message: String) {
        let allert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        allert.addAction(okAction)
        let allertWindow = UIWindow(frame: UIScreen.main.bounds)
        allertWindow.rootViewController = UIViewController()
        allertWindow.windowLevel = UIWindow.Level.alert + 1
        allertWindow.makeKeyAndVisible()
        
        allertWindow.rootViewController?.present(allert, animated: true)
    }

}
