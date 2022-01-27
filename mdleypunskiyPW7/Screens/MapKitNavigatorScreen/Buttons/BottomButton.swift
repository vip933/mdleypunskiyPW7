//
//  BottomButton.swift
//  mdleypunskiyPW7
//
//  Created by Maksim on 27.01.2022.
//

import UIKit

final class BottomButton: UIView {
    private let button = UIButton(type: .system)
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
        button.setTitle(text, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 2
        self.addSubview(button)
        button.pin(to: self)
    }
}
