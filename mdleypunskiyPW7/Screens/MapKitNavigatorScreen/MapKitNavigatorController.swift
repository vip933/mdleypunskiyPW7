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
    
    @objc
    public func goButtonWasPressed() {
        print("go button was pressed")
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
        [startLocation, endLocation].forEach { textField in
            textField.text = ""
        }
        
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
}
