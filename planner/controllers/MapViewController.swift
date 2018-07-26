//
//  MapViewController.swift
//  planner
//
//  Created by Daniil Subbotin on 02/07/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var chooseButton: UIButton!
    
    private var selectedPoint: MKPointAnnotation?
    
    var currentAddress: Address?
    
    let moscowLocation = CLLocationCoordinate2D(latitude: 55.751455, longitude: 37.616805)
    
    lazy var locationManager = CLLocationManager()
    lazy var service = GeocodingService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseButton.isEnabled = false
        mapView.userLocation.title = "Я здесь"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    @IBAction func myLocationTap(_ sender: Any) {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            
            let alert = UIAlertController(title: "Геолокация недоступна", message: "Для определения местоположения включите в настройках возможность геолокации", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Открыть настройки", style: .default, handler: openSettingsHandler)
            alert.addAction(settingsAction)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func openSettingsHandler(action: UIAlertAction) {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let centerCoordinate = moscowLocation
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        if let address = currentAddress {
            
            selectedPoint = MKPointAnnotation()
            mapView.addAnnotation(selectedPoint!)
            selectedPoint!.coordinate = CLLocationCoordinate2D(latitude: address.lat, longitude: address.lon)
            addressLabel.text = address.formattedAddress
            
            chooseButton.isEnabled = address.formattedAddress != nil
        }
    }
    
    @IBAction func cancelTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func mapTap(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        
        let tapPoint = sender.location(in: mapView)
        let tapCoordintate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        
        if selectedPoint == nil {
            selectedPoint = MKPointAnnotation()
            mapView.addAnnotation(selectedPoint!)
        }
        selectedPoint?.coordinate = tapCoordintate
        
        requestAddress(for: tapCoordintate)
    }
    
    func requestAddress(for location: CLLocationCoordinate2D) {
        service.getAddress(lat: location.latitude,
                           lon: location.longitude,
                           completion: getAddressHandler)
    }
    
    func getAddressHandler(result: ServiceResult<GeocodingResult>) {
        switch result {
        case .failure(let error):
            print(error)
            
            let alert = UIAlertController(title: "Ошибка", message: "Не удалсь получить адрес. Сервер не отвечает или интернет недоступен.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        case .success(let payload):
            if payload.status == "ZERO_RESULTS" {
                self.addressLabel.text = "Ничего не найдено"
                chooseButton.isEnabled = false
            } else {
                addressLabel.text = payload.results[0].formattedAddress
                chooseButton.isEnabled = true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is TaskViewController {
            currentAddress = Address(context: CoreDataStack.shared.viewContent)
            currentAddress!.lat = selectedPoint!.coordinate.latitude
            currentAddress!.lon = selectedPoint!.coordinate.longitude
            currentAddress!.formattedAddress = addressLabel.text
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let userLocation = locations.last else { return }
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.05
        let lonDelta: CLLocationDegrees = 0.05
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        
        if selectedPoint == nil {
            selectedPoint = MKPointAnnotation()
            mapView.addAnnotation(selectedPoint!)
        }
        selectedPoint?.coordinate = location
        
        requestAddress(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

    }
    
}
