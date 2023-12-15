//
//  BaseView.swift
//  LogoControl
//
//  Created by Nikola Bozhkov on 15.12.23.
//

import UIKit

protocol WrappedView: UIView {
    var view: UIView { get }
}

class BaseView: UIView, WrappedView {
    let view = UIView()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            updateTheme()
        }
    }
    
    override func layoutSubviews() {
        view.bounds = bounds
        view.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    func updateTheme() {
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}
