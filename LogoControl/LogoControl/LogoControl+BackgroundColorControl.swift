//
//  LogoControl+BackgroundColorControl.swift
//  LogoControl
//
//  Created by Nikola Bozhkov on 14.12.23.
//

import UIKit

extension LogoControl {
    class BackgroundColorControl: BaseView {
        
        var height: CGFloat {
            max(label.intrinsicContentSize.height, colorBox.bounds.height)
        }
        
        var pressHandler: (() -> Void)?
        var colorBox = UIView(frame: CGRect(origin: .zero, size: .one * 28))
        
        private let label = UILabel()
        
        override init() {
            super.init()
            
            label.text = "Background Color"
            colorBox.backgroundColor = .green
            colorBox.layer.cornerRadius = 7
            
            view.addSubview(label)
            view.addSubview(colorBox)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            label.frame = CGRect(origin: CGPoint(x: 0, y: 0.5 * (height - label.intrinsicContentSize.height)),
                                                 size: label.intrinsicContentSize)
            colorBox.frame.origin = CGPoint(x: bounds.maxX - colorBox.bounds.width,
                                            y: label.frame.midY - colorBox.bounds.midY)
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layer.transform = CATransform3DMakeScale(0.992, 0.992, 1)
            })
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layer.transform = CATransform3DIdentity
            })
            
            if let touch = touches.first,
               bounds.contains(touch.location(in: self)) {
                pressHandler?()
            }
        }
    }
}
