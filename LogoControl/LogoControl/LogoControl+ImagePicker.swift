//
//  LogoControl+ImagePicker.swift
//  LogoControl
//
//  Created by Nikola Bozhkov on 15.12.23.
//

import UIKit

extension LogoControl {
    class ImagePicker: BaseView {
        var takePhotoHandler: (() -> Void)?
        var choosePhotoHandler: (() -> Void)?
        
        let titleLabel = UILabel()

        private let divider = UIView()
        private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        
        private let takePhotoView = OptionView(iconName: "camera", text: "Take Photo")
        private let choosePhotoView = OptionView(iconName: "photo", text: "Photo Library")
        
        private let recentlyUsedLabel = UILabel()
        private let recentlyUsedContainer = UIView()
        
        override init() {
            super.init()
            
            titleLabel.text = "Choose an Image"
            titleLabel.font = .boldSystemFont(ofSize: 19)
            
            view.layer.cornerRadius = Constants.cornerRadius
            view.layer.borderColor = CGColor(gray: 0.16, alpha: 1)
            view.layer.masksToBounds = true
            
            layer.shadowColor = CGColor(gray: 0, alpha: 1)
            layer.shadowRadius = 10
            layer.shadowOpacity = 0.1
            
            recentlyUsedLabel.text = "recently used".uppercased()
            recentlyUsedContainer.backgroundColor = .black
            
            view.addSubview(titleLabel)
            view.addSubview(divider)
            view.addSubview(takePhotoView)
            view.addSubview(choosePhotoView)
//            view.addSubview(recentlyUsedLabel)
//            view.addSubview(recentlyUsedContainer)
            
            updateTheme()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            blurView.frame = bounds
            
            let paddedWidth = bounds.width - Constants.paddingX * 2
            
            titleLabel.frame = CGRect(origin: CGPoint(x: Constants.paddingX, y: Constants.paddingY),
                                      size: titleLabel.intrinsicContentSize)
            
            divider.frame = CGRect(origin: CGPoint(x: Constants.paddingX, y: titleLabel.frame.maxY + Constants.paddingY),
                                   size: CGSize(width: paddedWidth, height: 1))
            
            let spacing: CGFloat = 5
            let optionWidth = (bounds.width - spacing * 2) / 3
            let optionSize = CGSize(width: optionWidth, height: optionWidth * 0.67)
            takePhotoView.frame = CGRect(origin: CGPoint(x: Constants.paddingX, y: divider.frame.maxY + Constants.paddingY),
                                         size: optionSize)
            
            choosePhotoView.frame = CGRect(origin: CGPoint(x: takePhotoView.frame.maxX + spacing, y: takePhotoView.frame.minY),
                                           size: optionSize)
            
            recentlyUsedLabel.frame = CGRect(origin: CGPoint(x: Constants.paddingX,
                                                             y: takePhotoView.frame.maxY + Constants.paddingY),
                                             size: recentlyUsedLabel.intrinsicContentSize)
            
            let y = recentlyUsedLabel.frame.maxY + Constants.paddingY / 2
            recentlyUsedContainer.frame = CGRect(origin: CGPoint(x: Constants.paddingX, y: y),
                                                 size: CGSize(width: paddedWidth, height: bounds.height - y))
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let location = touches.first?.location(in: self) else { return }
            
            if takePhotoView.frame.contains(location) {
                takePhotoHandler?()
            } else if choosePhotoView.frame.contains(location) {
                choosePhotoHandler?()
            }
        }
        
        override func updateTheme() {
            let isDark = traitCollection.userInterfaceStyle == .dark
            
            titleLabel.textColor = isDark ? Constants.textColorDarkMode : .black
            
            divider.backgroundColor = isDark ? UIColor(white: 0.2, alpha: 1) : UIColor(white: 0.87, alpha: 1)
            
            if !UIAccessibility.isReduceTransparencyEnabled && isDark {
                view.backgroundColor = UIColor(white: 1, alpha: 0.12)
                view.insertSubview(blurView, at: 0)
            } else {
                view.backgroundColor = isDark ? UIColor(white: 0.05, alpha: 1) : UIColor(hex: "F0F3F5")
                blurView.removeFromSuperview()
            }
            
            view.layer.borderWidth = isDark ? 1 : 0
        }
    }
}

extension LogoControl.ImagePicker {
    class OptionView: BaseView {
        var pressHandler: (() -> Void)?
        
        private var defaultBgColor: UIColor = .white
        private var defaultTextColor: UIColor = .white
        
        private let label = UILabel()
        private let icon: UIImageView
        
        init(iconName: String, text: String) {
            let iconConfig = UIImage.SymbolConfiguration(pointSize: 24)
            icon = UIImageView(image:  UIImage(systemName: iconName, withConfiguration: iconConfig))
            
            super.init()
            
            view.layer.cornerRadius = 8
            
            label.text = text
            label.font = .systemFont(ofSize: 13, weight: .medium)
            
            view.addSubview(label)
            view.addSubview(icon)
            
            updateTheme()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let combinedHeight = bounds.height * 0.7
            icon.frame.origin = CGPoint(x: bounds.midX - (icon.image?.size.width ?? 0) / 2,
                                        y: bounds.midY - combinedHeight / 2)
            
            label.frame = CGRect(origin: CGPoint(x: bounds.midX - label.bounds.width / 2,
                                                 y: bounds.midY + combinedHeight / 2 - label.intrinsicContentSize.height),
                                         size: label.intrinsicContentSize)
        }
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let isDark = traitCollection.userInterfaceStyle == .dark
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layer.transform = CATransform3DMakeScale(0.96, 0.96, 1)
                let bgColor = isDark ? UIColor(white: 0.5, alpha: 0.06) : self.defaultBgColor.lighten(byPercent: -0.1)
                self.view.backgroundColor = bgColor
                
                self.label.textColor = self.defaultTextColor.lighten(byPercent: -0.1)
                self.icon.tintColor = self.label.textColor
            })
            
            super.touchesBegan(touches, with: event)
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layer.transform = CATransform3DIdentity
                self.view.backgroundColor = self.defaultBgColor
                self.label.textColor = self.defaultTextColor
                self.icon.tintColor = self.defaultTextColor
            })
            
            super.touchesEnded(touches, with: event)
        }
        
        override func updateTheme() {
            let isDark = traitCollection.userInterfaceStyle == .dark
            view.backgroundColor = isDark ? .white.withAlphaComponent(0.06) : UIColor(white: 0.92, alpha: 1)
            defaultBgColor = view.backgroundColor!
            
            label.textColor = isDark ? LogoControl.Constants.textColorDarkMode : UIColor(white: 0.25, alpha: 1)
            defaultTextColor = label.textColor
            icon.tintColor = label.textColor
        }
    }
}
