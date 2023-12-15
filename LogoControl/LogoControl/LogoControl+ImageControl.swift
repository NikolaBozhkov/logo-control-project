//
//  LogoControl+ImageControl.swift
//  LogoControl
//
//  Created by Nikola Bozhkov on 14.12.23.
//

import UIKit

extension LogoControl {
    class ImageControl: BaseView {
        var pressHandler: (() -> Void)?
        
        var image: UIImage? {
            didSet {
                imagePreview.image = image ?? UIImage(systemName: "line.diagonal")
            }
        }
        
        let label = UILabel()
        let imagePreview = UIImageView(frame: CGRect(origin: .zero, size: .one * 28))
        
        var height: CGFloat {
            imagePreview.bounds.height
        }
        
        override init() {
            super.init()
            
            label.text = "Image"
            imagePreview.image = UIImage(systemName: "line.diagonal")
            imagePreview.contentMode = .scaleAspectFill
            imagePreview.layer.cornerRadius = 7
            imagePreview.tintColor = UIColor(hex: "ED254E")
            imagePreview.layer.borderWidth = 1
            imagePreview.layer.masksToBounds = true
            
            view.addSubview(label)
            view.addSubview(imagePreview)
            
            updateTheme()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            label.frame = CGRect(origin: CGPoint(x: 0, y: 0.5 * (height - label.intrinsicContentSize.height)),
                                                 size: label.intrinsicContentSize)
            imagePreview.frame.origin = CGPoint(x: bounds.maxX - imagePreview.bounds.width,
                                                y: label.frame.midY - imagePreview.bounds.midY)
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
        
        override func updateTheme() {
            let isDark = traitCollection.userInterfaceStyle == .dark
            
            imagePreview.backgroundColor = isDark ? .black.withAlphaComponent(0.27) : UIColor(white: 1, alpha: 1)
            imagePreview.layer.borderColor = isDark ? CGColor(gray: 0.2, alpha: 1) : CGColor(gray: 0.83, alpha: 1)
        }
    }
}
