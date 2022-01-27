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
    
    private let startLocation: UITextField = {
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
    
    private let endLocation: UITextField = {
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
        
        let buttonView1 = BottomButton(text: "Fuck u", color: .blue)
        buttonView1.setWidth(to: (Double(UIScreen.main.bounds.width) - 70) / 2)
        buttonView1.setHeight(to: 50)
        let buttonView2 = BottomButton(text: "hello2", color: .red)
        buttonView2.setWidth(to: (Double(UIScreen.main.bounds.width) - 70) / 2)
        buttonView1.setHeight(to: 50)
        
        buttonStackView.addArrangedSubview(buttonView1)
        buttonStackView.addArrangedSubview(buttonView2)
    }
}
