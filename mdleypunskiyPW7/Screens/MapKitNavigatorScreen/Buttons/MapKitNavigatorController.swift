//
//  MapKitNavigatorController.swift
//  mdleypunskiyPW7
//
//  Created by Maksim on 27.01.2022.
//

import UIKit
import CoreLocation
import MapKit
import YandexMapsMobile

class MapKitNavigatorController: UIViewController, MKMapViewDelegate {
    
    var locationManager = CLLocationManager()
    var buttonStackView = UIStackView()
    var textStack = UIStackView()
    var fromAddres = ""
    var toAddres = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        locationManager.requestWhenInUseAuthorization()
        setupTextStack()
        setupTapGestures()
        setupDistanceView()
        
    }
    
    private let mapView: YMKMapView = {
        let mapView = YMKMapView()
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 5
        mapView.clipsToBounds = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        let mapKit = YMKMapKit.sharedInstance()
        let userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)
        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.isHeadingEnabled = true
        //let trafficLayer = mapKit.createTrafficLayer(with: mapView.mapWindow)
        //trafficLayer.setTrafficVisibleWithOn(true)
        return mapView
    }()
    
    @objc
    public func goButtonWasPressed() {
        distanceLabel.text = "Distance: 0 km"
        coordinates.removeAll()
        mapView.mapWindow.map.mapObjects.clear()
        guard
            let first = startLocation.text,
            let second = endLocation.text,
            first != second
        else {
            return
        }
        let group = DispatchGroup()
        group.enter()
        getCoordinatesFrom(address: first, completion: {
            [weak self] coords, _ in
            if let coords = coords {
                self?.coordinates.append(coords)
            }
            group.leave()
        })
        
        group.enter()
        getCoordinatesFrom(address: second, completion: {
            [weak self] coords, _ in
            if let coords = coords {
                self?.coordinates.append(coords)
            }
            group.leave()
        })
        
        group.notify(queue: .main) {
            DispatchQueue.main.async {
                [weak self] in self?.buildPath()
            }
        }
        
        print("go button was pressed")
    }
    
    private let distanceLabel = UILabel()
    private func setupDistanceView() {
        distanceLabel.text = "Distance: 0 km"
        view.addSubview(distanceLabel)
        distanceLabel.pin(to: textStack, [.bottom: -25, .left: 0])
    }
    
    var drivingSession: YMKDrivingSession?
    private func buildPath() {
        let latitudeMid = (coordinates[0].latitude + coordinates[1].latitude) / 2
        let longitudeMid = (coordinates[0].longitude + coordinates[1].longitude) / 2
        mapView.mapWindow.map.move(
                    with: YMKCameraPosition(target: YMKPoint(latitude: latitudeMid, longitude: longitudeMid), zoom: 5, azimuth: 0, tilt: 0))
                
                let requestPoints : [YMKRequestPoint] = [
                    YMKRequestPoint(point: YMKPoint(latitude: coordinates[0].latitude, longitude: coordinates[0].longitude), type: .waypoint, pointContext: nil),
                    YMKRequestPoint(point: YMKPoint(latitude: coordinates[1].latitude, longitude: coordinates[1].longitude), type: .waypoint, pointContext: nil),
                    ]
                
                let responseHandler = {(routesResponse: [YMKDrivingRoute]?, error: Error?) -> Void in
                    if let routes = routesResponse {
                        self.onRoutesReceived(routes)
                    } else {
                        self.onRoutesError(error!)
                    }
                }
                
                let drivingRouter = YMKDirections.sharedInstance().createDrivingRouter()
                drivingSession = drivingRouter.requestRoutes(
                    with: requestPoints,
                    drivingOptions: YMKDrivingDrivingOptions(),
                    vehicleOptions: YMKDrivingVehicleOptions(),
                    routeHandler: responseHandler)
    }
    
    func onRoutesReceived(_ routes: [YMKDrivingRoute]) {
        let mapObjects = mapView.mapWindow.map.mapObjects
        
        // Found:
        // https://github.com/yandex/mapkit-ios-demo/issues/101
        
        let coloredPolyline = mapObjects.addColoredPolyline()
        YMKRouteHelper.updatePolyline(withPolyline: coloredPolyline, route: routes[0], style: YMKRouteHelper.createDefaultJamStyle())
        
        distanceLabel.text = "Distance: " + String(Int(routes[0].metadata.weight.distance.value / 1000)) + "Km " + String(Int((routes[0].metadata.weight.distance.value / 1000 - Double(Int(routes[0].metadata.weight.distance.value / 1000))) * 1000)) + "M"
    }
        
        func onRoutesError(_ error: Error) {
            let routingError = (error as NSError).userInfo[YRTUnderlyingErrorKey] as! YRTError
            var errorMessage = "Unknown error"
            if routingError.isKind(of: YRTNetworkError.self) {
                errorMessage = "Network error"
            } else if routingError.isKind(of: YRTRemoteError.self) {
                errorMessage = "Remote server error"
            }
            
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    
    public let startLocation: UITextField = {
        let control = UITextField()
        control.backgroundColor = UIColor.lightGray
        control.textColor = UIColor.white
        control.attributedPlaceholder = NSAttributedString(
            string: "From",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        control.layer.cornerRadius = 2
        control.clipsToBounds = false
        control.font = UIFont.systemFont(ofSize: 15)
        control.borderStyle = UITextField.BorderStyle.roundedRect
        control.autocorrectionType = UITextAutocorrectionType.yes
        control.keyboardType = UIKeyboardType.default
        control.returnKeyType = UIReturnKeyType.done
        control.clearButtonMode = UITextField.ViewMode.whileEditing
        control.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return control
    }()
    
    public let endLocation: UITextField = {
        let control = UITextField()
        control.backgroundColor = UIColor.lightGray
        control.textColor = UIColor.white
        control.attributedPlaceholder = NSAttributedString(
            string: "To",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        control.layer.cornerRadius = 2
        control.clipsToBounds = false
        control.font = UIFont.systemFont(ofSize: 15)
        control.borderStyle = UITextField.BorderStyle.roundedRect
        control.autocorrectionType = UITextAutocorrectionType.yes
        control.keyboardType = UIKeyboardType.default
        control.returnKeyType = UIReturnKeyType.done
        control.clearButtonMode = UITextField.ViewMode.whileEditing
        control.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return control
    }()
    
    private func setupTapGestures() {
        let tapRecogniser = UITapGestureRecognizer()
        tapRecogniser.addTarget(self, action: #selector(didTapView))
        self.view.addGestureRecognizer(tapRecogniser)
    }
    
    @objc
    private func didTapView(){
      self.view.endEditing(true)
    }
    
    @objc
    private func clearButtonWasPressed() {
        distanceLabel.text = "Distance: 0 km"
        [startLocation, endLocation].forEach { textField in
            textField.text = ""
        }
        coordinates.removeAll()
        mapView.mapWindow.map.mapObjects.clear()
        print("clear button was pressed")
    }
    
    private func setupTextStack() {
        textStack.axis = .vertical
        view.addSubview(textStack)
        textStack.spacing = 10
        textStack.pin(to: self.view, [.top: 50, .left: 10, .right: 10])
        [startLocation, endLocation].forEach { textField in
            textField.setHeight(to: 40)
            textField.delegate = self
            textStack.addArrangedSubview(textField)
        }
    }
    
    public var goButton: UIButton?
    public var clearButton: UIButton?
    private func configureUI() {
        self.view.addSubview(mapView)
        mapView.pin(to: self.view)
        
        self.view.addSubview(buttonStackView)
        buttonStackView.pinBottom(to: self.view)
        buttonStackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)
        buttonStackView.isLayoutMarginsRelativeArrangement = true
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalCentering
        buttonStackView.spacing = 20
        
        let buttonView1 = BottomButton(text: "Go", color: .green)
        buttonView1.setWidth(to: (Double(UIScreen.main.bounds.width) - 70) / 2)
        buttonView1.setHeight(to: 50)
        buttonView1.button.addTarget(self, action: #selector(goButtonWasPressed), for: .touchUpInside)
        buttonView1.button.isEnabled = false
        buttonView1.button.setTitleColor(.gray, for: .disabled)
        
        let buttonView2 = BottomButton(text: "Clear", color: .red)
        buttonView2.setWidth(to: (Double(UIScreen.main.bounds.width) - 70) / 2)
        buttonView2.setHeight(to: 50)
        buttonView2.button.addTarget(self, action: #selector(clearButtonWasPressed), for: .touchUpInside)
        buttonView2.button.isEnabled = false
        buttonView2.button.setTitleColor(.gray, for: .disabled)
        
        buttonStackView.addArrangedSubview(buttonView1)
        buttonStackView.addArrangedSubview(buttonView2)
        goButton = buttonView1.button
        clearButton = buttonView2.button
    }
    
    var coordinates: [CLLocationCoordinate2D] = []
    private func getCoordinatesFrom(
        address: String,
        completion: @escaping(
            _ coordinates: CLLocationCoordinate2D?,
            _ error: Error?
        ) -> ()) {
        DispatchQueue.global(qos: .background).async {
            CLGeocoder().geocodeAddressString(address) {
                completion($0?.first?.location?.coordinate, $1) }
        }
    }
}
