//
//  MapKitNavigatorController.swift
//  mdleypunskiyPW7
//
//  Created by Maksim on 27.01.2022.
//

import UIKit
import CoreLocation
import MapKit

class MapKitNavigatorController: UIViewController {
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        locationManager.requestWhenInUseAuthorization()
    }
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 5
        mapView.clipsToBounds = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        return mapView
    }()
    
    private func configureUI() {
        self.view.addSubview(mapView)
        mapView.pin(to: self.view)
    }
    
}
