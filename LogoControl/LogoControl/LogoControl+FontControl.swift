//
//  LogoControl+FontControl.swift
//  LogoControl
//
//  Created by Nikola Bozhkov on 14.12.23.
//

import UIKit

extension LogoControl {
    class FontControl: BaseView {
        var fontSelectionHandler: ((UIFont) -> Void)?
        
        private let label = UILabel()
        private let fontOptionsContainer = UIView()
        
        private let optionSpacing: CGFloat = 5
        private let verticalSpacing: CGFloat = 10
    
        init(selectedFont: FontType) {
            super.init()
            
            FontType.all.forEach {
                let optionView = OptionView(fontType: $0, isSelected: $0 == selectedFont)
                optionView.owner = self
                fontOptionsContainer.addSubview(optionView)
            }
            
            label.text = "Font".uppercased()
            label.font = .systemFont(ofSize: 13, weight: .bold)
            
            view.addSubview(label)
            view.addSubview(fontOptionsContainer)
            
            updateTheme()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            label.frame = CGRect(origin: .zero, size: label.intrinsicContentSize)
            
            let optionViewSize = getOptionViewSize(forWidth: bounds.width)
            fontOptionsContainer.frame = CGRect(origin: CGPoint(x: 0, y: label.frame.maxY + verticalSpacing),
                                                size: CGSize(width: bounds.width, height: optionViewSize))
                                                
            for (i, optionView) in fontOptionsContainer.subviews.enumerated() {
                optionView.frame = CGRect(origin: CGPoint(x: CGFloat(i) * (optionViewSize + optionSpacing), y: 0),
                                          size: .one * optionViewSize)
            }
        }
        
        override func updateTheme() {
            let isDark = traitCollection.userInterfaceStyle == .dark
            label.textColor = isDark ? UIColor(white: 0.5, alpha: 1) : UIColor(white: 0.5, alpha: 1)
        }
        
        func getHeight(forWidth width: CGFloat) -> CGFloat {
            return label.intrinsicContentSize.height + verticalSpacing + getOptionViewSize(forWidth: width)
        }
        
        func didSelectFont(_ font: UIFont) {
            fontSelectionHandler?(font)
            
            for case let view as OptionView in fontOptionsContainer.subviews {
                view.isSelected = font.fontName == view.font?.fontName
            }
        }
        
        private func getOptionViewSize(forWidth width: CGFloat) -> CGFloat {
            let optionCount = CGFloat(fontOptionsContainer.subviews.count)
            return (width - (optionCount - 1) * optionSpacing) / optionCount
        }
    }
}

extension LogoControl.FontControl {
    class OptionView: BaseView {
        weak var owner: LogoControl.FontControl?
        
        var isSelected: Bool {
            didSet {
                updateTheme()
            }
        }
        
        let font: UIFont?
        
        private let previewLabel = UILabel()
        private let fontNameLabel = UILabel()
        
        init(fontType: LogoControl.FontType, isSelected: Bool) {
            self.isSelected = isSelected
            
            font = fontType.createFont()
            
            super.init()
            
            view.layer.cornerRadius = 7
            view.layer.cornerCurve = .continuous
            
            previewLabel.text = fontType.rawValue.preview
            previewLabel.font = UIFont(name: fontType.rawValue.name, size: 21)
            fontNameLabel.text = fontType.rawValue.displayName
            fontNameLabel.font = UIFont(name: fontType.rawValue.name, size: 11)
            
            view.addSubview(previewLabel)
            view.addSubview(fontNameLabel)
            
            updateTheme()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let combinedHeight = bounds.height * 0.6
            
            previewLabel.frame = CGRect(origin: CGPoint(x: bounds.midX - previewLabel.bounds.width / 2,
                                                        y: bounds.midY - combinedHeight / 2),
                                        size: previewLabel.intrinsicContentSize)
            
            fontNameLabel.frame = CGRect(origin: CGPoint(x: bounds.midX - fontNameLabel.bounds.width / 2,
                                                         y: bounds.midY + combinedHeight / 2 - fontNameLabel.intrinsicContentSize.height),
                                         size: fontNameLabel.intrinsicContentSize)
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layer.transform = CATransform3DMakeScale(0.955, 0.955, 1)
            })
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layer.transform = CATransform3DIdentity
            })
            
            if let touch = touches.first,
               bounds.contains(touch.location(in: self)) {
                owner?.didSelectFont(font ?? .systemFont(ofSize: 18))
            }
        }
        
        override func updateTheme() {
            let isDark = traitCollection.userInterfaceStyle == .dark
            
            previewLabel.textColor = isDark ? UIColor(white: 0.85, alpha: 1) : UIColor(white: 0.3, alpha: 1)
            fontNameLabel.textColor = isDark ? UIColor(white: 0.65, alpha: 1) : UIColor(white: 0.5, alpha: 1)
            
            let bgColorNonSelected = isDark ? .white.withAlphaComponent(0.06) : UIColor(white: 0.92, alpha: 1)
            let bgColorSelected = UIColor(hex: "18AEFF").lighten(byPercent: 0.2).withAlphaComponent(0.12)
            
            view.layer.borderWidth = isSelected ? 2 : 0
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.view.backgroundColor = self.isSelected ? bgColorSelected : bgColorNonSelected
                self.view.layer.borderColor = self.isSelected ? UIColor(hex: "3ABAFF").cgColor : UIColor.clear.cgColor
            })
        }
    }
}
