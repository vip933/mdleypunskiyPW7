//
//  PlusMinusButton.swift
//  mdleypunskiyPW7
//
//  Created by Maksim on 28.01.2022.
//

import UIKit

final class PlusMinusButton: UIView {
    private let _button = UIButton(type: .system)
    var button: UIButton {
        get {
            return _button
        }
    }
    private var text: String?
    
    init(text: String) {
        self.text = text
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        _button.setTitle(text, for: .normal)
        _button.setTitleColor(.black, for: .normal)
        _button.backgroundColor = .clear
        _button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 50)
        self.addSubview(_button)
        _button.pin(to: self)
    }
}
