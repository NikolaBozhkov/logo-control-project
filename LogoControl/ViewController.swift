//
//  ViewController.swift
//  LogoControl
//
//  Created by Nikola Bozhkov on 13.12.23.
//

import UIKit

class ViewController: UIViewController {
    
    let logoSize: CGFloat = 80
    
    var activeLogoControl: LogoControl?
    
    let teamSpaceLogoControl = LogoControl(title: "Logo Settings")
    let profileLogoControl = LogoControl(title: "Avatar Settings")
    let teamSpaceLogo: TeamSpaceLogo
    let profileLogo: ProfileLogo
    
    let gradient = CAGradientLayer()
    
    private let box = UIView()
    private let circle = UIView()
    
    init() {
        teamSpaceLogo = TeamSpaceLogo(name: "Test Name", size: logoSize)
        profileLogo = ProfileLogo(name: "Test Name", size: logoSize)
        
        super.init(nibName: nil, bundle: nil)
        
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.3, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
        
        teamSpaceLogo.backgroundColor = LogoControl.randomBackgroundColor()
        teamSpaceLogo.font = LogoControl.FontType.system.createFont()
        
        profileLogo.backgroundColor = LogoControl.randomBackgroundColor()
        profileLogo.font = LogoControl.FontType.system.createFont()
        
        teamSpaceLogoControl.logo = teamSpaceLogo
        profileLogoControl.logo = profileLogo
        
        teamSpaceLogoControl.dismissHandler = { [unowned self] in
            dismissLogoControl()
        }
        
        profileLogoControl.dismissHandler = { [unowned self] in
            dismissLogoControl()
        }
        
        view.addSubview(teamSpaceLogo)
        view.addSubview(profileLogo)
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            updateTheme()
        }
    }
    
    override func viewDidLayoutSubviews() {
        gradient.frame = view.bounds
        
        let safeBounds = view.bounds.inset(by: view.safeAreaInsets)
        let contentRegion = safeBounds.insetBy(dx: 20, dy: 20)
        
        let logoArea = contentRegion.divided(atDistance: logoSize, from: .minYEdge)
    
        if let activeLogoControl = activeLogoControl {
            switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
            case (.compact, .regular):
                activeLogoControl.frame = safeBounds.insetBy(dx: 12, dy: 0)
                    .divided(atDistance: safeBounds.maxY * 0.7, from: .maxYEdge).slice
            case (_, .compact):
                let width = view.bounds.height - 24
                activeLogoControl.frame = CGRect(origin: CGPoint(x: safeBounds.maxX - width,
                                                                 y: view.safeAreaInsets.top + 16),
                                                 size: CGSize(width: width, height: safeBounds.height - 20))
            default:
                let defaultWidth: CGFloat = 351
                let defaultHeight: CGFloat = 530
                activeLogoControl.frame = CGRect(origin: CGPoint(x: safeBounds.maxX - defaultWidth - 16,
                                                                 y: view.safeAreaInsets.top + 16),
                                                 size: CGSize(width: defaultWidth, height: min(defaultHeight, safeBounds.height - 32)))
            }
        }
        
        
        let teamSpaceLogoArea = logoArea.slice.divided(atDistance: logoSize, from: .minXEdge)
        teamSpaceLogo.frame = teamSpaceLogoArea.slice
        
        profileLogo.frame = teamSpaceLogoArea.remainder
            .offsetBy(dx: 20, dy: 0)
            .divided(atDistance: logoSize, from: .minXEdge)
            .slice
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: view) else {
            return
        }
        
        if let activeLogoControl = activeLogoControl,
           !activeLogoControl.frame.contains(location) {
            dismissLogoControl()
            return
        }
        
        if teamSpaceLogo.frame.contains(location) {
            activeLogoControl = teamSpaceLogoControl
            openLogoControl()
        } else if profileLogo.frame.contains(location) {
            activeLogoControl = profileLogoControl
            openLogoControl()
        }
    }
    
    private func openLogoControl() {
        guard let activeLogoControl = activeLogoControl,
              activeLogoControl.superview == nil else { return }
        
        activeLogoControl.view.transform = getLogoControlTransform()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            activeLogoControl.view.transform = .identity
        })
        
        view.addSubview(activeLogoControl)
    }
    
    private func dismissLogoControl() {
        guard let activeLogoControl = activeLogoControl else { return }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            activeLogoControl.view.transform = self.getLogoControlTransform()
        }, completion: { _ in
            activeLogoControl.removeFromSuperview()
        })
        
        self.activeLogoControl = nil
    }
    
    private func getLogoControlTransform() -> CGAffineTransform {
        guard let activeLogoControl = activeLogoControl else { return .identity }
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.compact, .regular):
            return CGAffineTransformMakeTranslation(0, view.bounds.height + activeLogoControl.frame.minY)
        default:
            return CGAffineTransformMakeTranslation(view.bounds.width - activeLogoControl.frame.minX, 0)
        }
    }
    
    private func updateTheme() {
        gradient.colors = traitCollection.userInterfaceStyle == .dark
        ? [CGColor(gray: 0.08, alpha: 1), CGColor(gray: 0.03, alpha: 1)]
        : [CGColor(gray: 0.95, alpha: 1), CGColor(gray: 0.85, alpha: 1)]
    }
}

