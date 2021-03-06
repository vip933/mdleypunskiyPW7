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
    var scaleButtonsStackView = UIStackView()
    var textStack = UIStackView()
    var vehiclePanel = UISegmentedControl(items: ["car", "bicycle", "masstransit"])
    var fromAddres = ""
    var toAddres = ""
    var scaleValue: Float = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        locationManager.requestWhenInUseAuthorization()
        setupTextStack()
        setupTapGestures()
        setupDistanceView()
        setupPlusMinusButtons()
        setupVehicleChoicePanel()
        scaleValue = mapView.mapWindow.map.cameraPosition.zoom
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
        
        // Иконка пользователя направлена в сторону куда направлен телефон пользователя.
        userLocationLayer.isHeadingEnabled = true
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
    
    private func setupVehicleChoicePanel() {
        view.addSubview(vehiclePanel)
        vehiclePanel.selectedSegmentIndex = 0
        vehiclePanel.pin(to: goButton!, [.bottom: 70, .left: 0])
        vehiclePanel.layer.cornerRadius = 20
        vehiclePanel.setWidth(to: Double(UIScreen.main.bounds.width) - 50)
        vehiclePanel.setHeight(to: 50)
        vehiclePanel.backgroundColor = .lightGray
    }
    
    private let distanceLabel = UILabel()
    private func setupDistanceView() {
        distanceLabel.text = "Distance: 0 km"
        view.addSubview(distanceLabel)
        distanceLabel.pin(to: textStack, [.bottom: -25, .left: 0])
    }
    
    var drivingSession: YMKDrivingSession?
    var bicycleSession: YMKBicycleSession?
    var masstransitSession: YMKMasstransitSession?
    private func buildPath() {
        let latitudeMid = (coordinates[0].latitude + coordinates[1].latitude) / 2
        let longitudeMid = (coordinates[0].longitude + coordinates[1].longitude) / 2
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(target: YMKPoint(latitude: latitudeMid, longitude: longitudeMid), zoom: scaleValue, azimuth: 0, tilt: 0))
        
        let requestPoints : [YMKRequestPoint] = [
            YMKRequestPoint(point: YMKPoint(latitude: coordinates[0].latitude, longitude: coordinates[0].longitude), type: .waypoint, pointContext: nil),
            YMKRequestPoint(point: YMKPoint(latitude: coordinates[1].latitude, longitude: coordinates[1].longitude), type: .waypoint, pointContext: nil),
        ]
        
        if vehiclePanel.selectedSegmentIndex == 0 {
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
        } else if vehiclePanel.selectedSegmentIndex == 1 {
            let bicycleRouter = YMKTransport.sharedInstance().createBicycleRouter()
            let listener = {(routeResponse: [YMKBicycleRoute]?, error: Error?) -> Void in
                if let routes = routeResponse {
                    self.onBicycleRoutesReceived(routes)
                } else {
                    self.onRoutesError(error!)
                }
            }
            bicycleSession = bicycleRouter.requestRoutes(with: requestPoints, routeListener: listener)
        } else {
            let masstransitRouter = YMKTransport.sharedInstance().createMasstransitRouter()
            let masstransitHandler = {(routesResponse: [YMKMasstransitRoute]?, error: Error?) -> Void in
                if let routes = routesResponse {
                    self.onMasstransitRoutesReceived(routes)
                } else {
                    self.onRoutesError(error!)
                }
            }
            masstransitSession = masstransitRouter.requestRoutes(with: requestPoints, masstransitOptions: YMKMasstransitOptions(), routeHandler: masstransitHandler)
        }
    }
    
    func onMasstransitRoutesReceived(_ routes: [YMKMasstransitRoute]) {
        let mapObjects = mapView.mapWindow.map.mapObjects
        
        mapObjects.addPolyline(with: routes[0].geometry)
        
        distanceLabel.text = "Distance: " + routes[0].metadata.weight.time.text
    }
    
    func onBicycleRoutesReceived(_ routes: [YMKBicycleRoute]) {
        let mapObjects = mapView.mapWindow.map.mapObjects
        
        mapObjects.addPolyline(with: routes[0].geometry)
        
        distanceLabel.text = "Distance: " + String(Int(routes[0].weight.distance.value / 1000)) + "Km " + String(Int((routes[0].weight.distance.value / 1000 - Double(Int(routes[0].weight.distance.value / 1000))) * 1000)) + "M"
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
    
    public var plusButton: UIButton?
    public var minusButton: UIButton?
    private func setupPlusMinusButtons() {
        scaleButtonsStackView.axis = .vertical
        scaleButtonsStackView.spacing = 0
        view.addSubview(scaleButtonsStackView)
        scaleButtonsStackView.layer.cornerRadius = 23
        scaleButtonsStackView.backgroundColor = .lightGray
        scaleButtonsStackView.pin(to: textStack, [.bottom: -105, .right: 0])
        
        let buttonView1 = PlusMinusButton(text: "+")
        let buttonView2 = PlusMinusButton(text: "-")
        
        scaleButtonsStackView.addArrangedSubview(buttonView1)
        scaleButtonsStackView.addArrangedSubview(buttonView2)
        
        plusButton = buttonView1.button
        minusButton = buttonView2.button
        plusButton?.addTarget(self, action: #selector(plusButtonWasPressed), for: .touchUpInside)
        minusButton?.addTarget(self, action: #selector(minusButtonWasPressed), for: .touchUpInside)
        
        buttonView1.setWidth(to: 50)
        buttonView2.setWidth(to: 50)
        
        buttonView1.setHeight(to: 50)
        buttonView2.setHeight(to: 50)
    }
    
    @objc
    private func plusButtonWasPressed() {
        print("plus button was pressed")
        scaleValue += 0.5
        var point: YMKPoint
        if let location = locationManager.location {
            point = YMKPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        } else {
            point = mapView.mapWindow.map.cameraPosition.target
        }
        mapView.mapWindow.map.move(with: YMKCameraPosition(target: point, zoom: scaleValue, azimuth: 0, tilt: 0))
    }
    
    @objc
    private func minusButtonWasPressed() {
        print("minus button was pressed")
        scaleValue -= 0.5
        var point: YMKPoint
        if let location = locationManager.location {
            point = YMKPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        } else {
            point = mapView.mapWindow.map.cameraPosition.target
        }
        mapView.mapWindow.map.move(with: YMKCameraPosition(target: point, zoom: scaleValue, azimuth: 0, tilt: 0))
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
