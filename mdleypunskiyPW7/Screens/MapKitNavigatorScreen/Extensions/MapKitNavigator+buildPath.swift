//
//  MapKitNavigator+buildPath.swift
//  mdleypunskiyPW7
//
//  Created by Maksim on 27.01.2022.
//

import UIKit
import CoreLocation
import MapKit

extension MKMapView {

  public func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
    let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
    let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
    
    let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
    let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
    
    let sourceAnnotation = MKPointAnnotation()
    
    if let location = sourcePlacemark.location {
        sourceAnnotation.coordinate = location.coordinate
    }
    
    let destinationAnnotation = MKPointAnnotation()
    
    if let location = destinationPlacemark.location {
        destinationAnnotation.coordinate = location.coordinate
    }
    
    self.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
    
    let directionRequest = MKDirections.Request()
    directionRequest.source = sourceMapItem
    directionRequest.destination = destinationMapItem
    directionRequest.transportType = .automobile
    
    // Calculate the direction
    let directions = MKDirections(request: directionRequest)
    
    directions.calculate {
        (response, error) -> Void in
        
        guard let response = response else {
            if let error = error {
                print("Error: \(error)")
            }
            
            return
        }
        let route = response.routes[0]
        self.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
        let rect = route.polyline.boundingMapRect
        self.setRegion(MKCoordinateRegion(rect), animated: true)
    }
  }
}
