//
//  MapKitNavigator+UITextFieldDelegate.swift
//  mdleypunskiyPW7
//
//  Created by Maksim on 27.01.2022.
//

import UIKit

extension MapKitNavigatorController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.isEqual(endLocation) {
            if endLocation.hasText && startLocation.hasText {
                goButtonWasPressed()
            }
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if startLocation.hasText && endLocation.hasText {
            goButton?.isEnabled = true
            clearButton?.isEnabled = true
        } else {
            if startLocation.hasText || endLocation.hasText {
                clearButton?.isEnabled = true
            } else {
                clearButton?.isEnabled = false
            }
        }
        return true
    }
}
