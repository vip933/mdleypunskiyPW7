//
//  BottomButton.swift
//  mdleypunskiyPW7
//
//  Created by Maksim on 27.01.2022.
//

import UIKit

final class BottomButton: UIView {
    private let _button = UIButton(type: .system)
    var button: UIButton {
        get {
            return _button
        }
    }
    private var text: String?
    private var color: UIColor?
    
    init(text: String, color: UIColor) {
        self.text = text
        self.color = color
        super.init(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width - 50) / 2, height: 100))
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        _button.setTitle(text, for: .normal)
        _button.setTitleColor(.white, for: .normal)
        _button.backgroundColor = color
        _button.layer.cornerRadius = 20
        _button.layer.borderWidth = 2
        _button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        self.addSubview(_button)
        _button.pin(to: self)
    }
}
