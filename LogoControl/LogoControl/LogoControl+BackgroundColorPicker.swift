//
//  LogoControl+BackgroundColorPicker.swift
//  LogoControl
//
//  Created by Nikola Bozhkov on 14.12.23.
//

import UIKit

extension LogoControl {
    static let colorOptions: [UIColor] = [
        UIColor(hex: "048A81"),
        UIColor(hex: "305252"),
        UIColor(hex: "F50031"),
        UIColor(hex: "FF6208"),
        UIColor(hex: "F79AD3"),
        UIColor(hex: "854D27"),
        UIColor(hex: "FAF3DD"),
        UIColor(hex: "C8D5B9"),
        UIColor(hex: "F7C7DB"),
        UIColor(hex: "69995D"),
        UIColor(hex: "8338EC"),
        UIColor(hex: "CDD1DE"),
        UIColor(hex: "FF7E6B"),
        UIColor(hex: "FFCA3A"),
        UIColor(hex: "FFBE0B"),
        UIColor(hex: "FF6392"),
        UIColor(hex: "6E7DAB"),
        UIColor(hex: "5BC0EB"),
    ]
    
    class func randomBackgroundColor() -> UIColor {
        colorOptions.randomElement()!
    }
    
    class BackgroundColorPicker: BaseView {
        private let colorBoxSize: CGFloat = 32
        
        var pickColorHandler: ((UIColor) -> Void)?
        
        override var intrinsicContentSize: CGSize {
            return CGSize(width: 6, height: 3) * colorBoxSize
        }
        
        override init() {
            super.init()
            
            view.layer.cornerRadius = 12
            view.layer.masksToBounds = true
            view.layer.borderWidth = 1
            view.layer.borderColor = CGColor(gray: 1, alpha: 0.7)
            layer.shadowColor = CGColor(gray: 1, alpha: 1)
            layer.shadowRadius = 12
            layer.shadowOpacity = 0.25
            
            let lightnessSortedOptions = colorOptions.sorted(by: { $0.luminance > $1.luminance })
            
            for colorOption in lightnessSortedOptions {
                let colorBox = UIView()
                colorBox.frame.size = .one * colorBoxSize
                colorBox.backgroundColor = colorOption
                view.addSubview(colorBox)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            for (i, subview) in view.subviews.enumerated() {
                subview.frame.origin = CGPoint(x: CGFloat(i % 6) * colorBoxSize,
                                               y: CGFloat(i / 6) * colorBoxSize)
            }
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let location = touches.first?.location(in: view),
                  let view = hitTest(location, with: event),
                  let color = view.backgroundColor,
                  view.superview === self.view else {
                return
            }
            
            pickColorHandler?(color)
        }
    }
}
