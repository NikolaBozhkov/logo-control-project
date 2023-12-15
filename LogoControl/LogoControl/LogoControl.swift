//
//  LogoControl.swift
//  LogoControl
//
//  Created by Nikola Bozhkov on 13.12.23.
//

import UIKit

protocol Logo {
    var font: UIFont? { get }
    var backgroundColor: UIColor? { get }
    var image: UIImage? { get }
    func setBackgroundColor(_ color: UIColor)
    func setFont(_ font: UIFont)
    func setImage(_ image: UIImage?)
}

class LogoControl: BaseView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var logo: Logo? {
        didSet {
            bgColorControl.colorBox.backgroundColor = logo?.backgroundColor
            fontControl.didSelectFont(logo?.font ?? UIFont.systemFont(ofSize: 18))
        }
    }
    
    var dismissHandler: (() -> Void)?
    
    private let overlayFadeDuration: TimeInterval = 0.15
    
    private let titleLabel = UILabel()
    private let divider = UIView()
    private let closeButton = UIButton()
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let overlayBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let logoType = LogoType.initials
    private let logoTypeControl = SwitchControl(options: [
        (label: "Initials", value: LogoType.initials.rawValue),
        (label: "Image", value: LogoType.image.rawValue)
    ], selectedOption: LogoType.initials.rawValue)!
    
    private let bgColorControl = BackgroundColorControl()
    private let bgColorPicker = BackgroundColorPicker()
    private let fontControl = FontControl(selectedFont: .system)
    private let imageControl = ImageControl()
    private let imagePicker = ImagePicker()
    
    private var paddedWidth: CGFloat {
        bounds.width - Constants.paddingX * 2
    }
    
    init(title: String) {
        super.init()
        
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 19)
        
        var closeButtonConfig = UIButton.Configuration.plain()
        closeButtonConfig.cornerStyle = .capsule
        closeButtonConfig.image = UIImage(systemName: "xmark.circle.fill")
        closeButton.configuration = closeButtonConfig
        
        closeButton.addAction(UIAction(handler: { [unowned self] _ in
            dismissHandler?()
        }), for: .touchUpInside)
        
        closeButton.tintColor = .gray
        
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.borderColor = CGColor(gray: 0.16, alpha: 1)
        view.layer.masksToBounds = true
        
        layer.shadowColor = CGColor(gray: 0, alpha: 1)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.1
        
        logoTypeControl.optionSelectionHandler = { [unowned self] value in
            switchLogoType(value: value)
        }
        
        bgColorControl.pressHandler = { [unowned self] in
            openBgColorPicker()
        }
        
        bgColorPicker.pickColorHandler = { [unowned self] color in
            logo?.setBackgroundColor(color)
            bgColorControl.colorBox.backgroundColor = color
            dismissBgColorPicker()
        }
        
        fontControl.fontSelectionHandler = { [unowned self] font in
            logo?.setFont(font)
        }
        
        imageControl.pressHandler = { [unowned self] in
            openImagePicker()
        }
        
        imagePicker.takePhotoHandler = { [unowned self] in
            presentPickerController(sourceType: .camera)
        }
        
        imagePicker.choosePhotoHandler = { [unowned self] in
            presentPickerController(sourceType: .photoLibrary)
        }
        
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(divider)
        view.addSubview(logoTypeControl)
        
        if logoType == .initials {
            view.addSubview(bgColorControl)
            view.addSubview(fontControl)
        } else {
            view.addSubview(imageControl)
        }
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurView.frame = bounds
        overlayBlurView.frame = bounds
        
        titleLabel.frame = CGRect(origin: CGPoint(x: Constants.paddingX, y: Constants.paddingY),
                                  size: titleLabel.intrinsicContentSize)
        
        let closeButtonSize: CGFloat = 24
        closeButton.frame = CGRect(origin: CGPoint(x: bounds.maxX - Constants.paddingX - closeButtonSize,
                                                   y: titleLabel.frame.midY - closeButtonSize / 2),
                                   size: .one * closeButtonSize)
        
        divider.frame = CGRect(origin: CGPoint(x: Constants.paddingX, y: titleLabel.frame.maxY + Constants.paddingY),
                               size: CGSize(width: paddedWidth, height: 1))
        
        logoTypeControl.layoutSubviews()
        logoTypeControl.frame = CGRect(origin: CGPoint(x: Constants.paddingX, y: divider.frame.maxY + Constants.paddingY),
                                       size: logoTypeControl.intrinsicContentSize)
        
        bgColorControl.frame = CGRect(origin: CGPoint(x: Constants.paddingX,
                                                      y: logoTypeControl.frame.maxY + Constants.paddingY),
                                      size: CGSize(width: paddedWidth, height: bgColorControl.height))
        
        imageControl.frame = CGRect(origin: CGPoint(x: Constants.paddingX, y: logoTypeControl.frame.maxY + Constants.paddingY),
                                    size: CGSize(width: paddedWidth, height: imageControl.height))
        
        bgColorControl.layoutSubviews()
        bgColorPicker.frame = CGRect(origin: CGPoint(x: bgColorControl.convert(bgColorControl.colorBox.frame, to: view).minX
                                                     - bgColorPicker.intrinsicContentSize.width - 6,
                                                     y: bgColorControl.frame.minY),
                                     size: bgColorPicker.intrinsicContentSize)
        
        fontControl.frame = CGRect(origin: CGPoint(x: Constants.paddingX, y: bgColorControl.frame.maxY + Constants.paddingY),
                                   size: CGSize(width: paddedWidth, height: fontControl.getHeight(forWidth: paddedWidth)))
        
        imagePicker.frame = CGRect(origin: CGPoint(x: 0, y: 0.5 * bounds.height),
                                   size: CGSize(width: bounds.width, height: bounds.height * 0.5))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else {
            return
        }
        
        if bgColorPicker.superview != nil && !bgColorPicker.frame.contains(location) {
            dismissBgColorPicker()
        } else if imagePicker.superview != nil && !imagePicker.frame.contains(location) {
            dismissImagePicker()
        }
    }
    
    private func openBgColorPicker() {
        toggleOverlay(true)
        view.addSubview(bgColorPicker)
        
        bgColorPicker.view.layer.transform = CATransform3DMakeTranslation(0, 10, 0)
        bgColorPicker.view.alpha = 0
        UIView.animate(withDuration: 0.15, delay: 0.05, options: .curveEaseOut, animations: {
            self.bgColorPicker.view.layer.transform = CATransform3DIdentity
            self.bgColorPicker.view.alpha = 1
        })
    }
    
    private func dismissBgColorPicker() {
        toggleOverlay(false)
        bgColorPicker.removeFromSuperview()
    }
    
    private func switchLogoType(value: Int) {
        switch LogoType(rawValue: value) {
        case .initials:
            imageControl.removeFromSuperview()
            view.addSubview(bgColorControl)
            view.addSubview(fontControl)
            logo?.setImage(nil)
        case .image:
            bgColorControl.removeFromSuperview()
            fontControl.removeFromSuperview()
            view.addSubview(imageControl)
            
            if let image = imageControl.image {
                logo?.setImage(image)
            }
        default:
            return
        }
    }
    
    private func getImagePickerControlTransform() -> CGAffineTransform {
        return CGAffineTransformMakeTranslation(0, view.bounds.height + imagePicker.frame.minY)
    }
    
    private func openImagePicker() {
        toggleOverlay(true)
        view.addSubview(imagePicker)

        imagePicker.view.transform = getImagePickerControlTransform()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imagePicker.view.transform = .identity
        })
        
        view.addSubview(imagePicker)
    }
    
    private func dismissImagePicker() {
        toggleOverlay(false)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.imagePicker.view.transform = self.getImagePickerControlTransform()
        }, completion: { _ in
            self.imagePicker.removeFromSuperview()
        })
    }
    
    private func toggleOverlay(_ on: Bool) {
        if on {
            view.addSubview(overlayBlurView)
            overlayBlurView.alpha = 0
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.overlayBlurView.alpha = 0.4
            })
        } else {
            UIView.animate(withDuration: overlayFadeDuration, delay: 0, options: .curveEaseOut, animations: {
                self.overlayBlurView.alpha = 0
            }, completion: { _ in
                self.overlayBlurView.removeFromSuperview()
            })
        }
    }
    
    func presentPickerController(sourceType: UIImagePickerController.SourceType) {
        guard let parentViewController = parentViewController else { return }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        imagePickerController.sourceType = sourceType
        parentViewController.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        logo?.setImage(image)
        imageControl.image = image
    }
    
    override func updateTheme() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        view.layer.borderWidth = isDark ? 1 : 0
        titleLabel.textColor = isDark ? Constants.textColorDarkMode : .black
        divider.backgroundColor = isDark ? UIColor(white: 0.2, alpha: 1) : UIColor(white: 0.87, alpha: 1)
        
        if !UIAccessibility.isReduceTransparencyEnabled && isDark {
            view.backgroundColor = UIColor(white: 1, alpha: 0.12)
            view.insertSubview(blurView, at: 0)
        } else {
            view.backgroundColor = isDark ? UIColor(white: 0.05, alpha: 1) : UIColor(hex: "F0F3F5")
            blurView.removeFromSuperview()
        }
        
        closeButton.configuration?.baseForegroundColor = isDark ? UIColor(white: 0.3, alpha: 1) : UIColor(white: 0.75, alpha: 1)
    }
}

extension LogoControl {
    enum LogoType: Int {
        case initials, image
    }
    
    enum FontType: RawRepresentable {
        typealias RawValue = (name: String, preview: String, displayName: String)
        
        static let all = [
            FontType.system,
            .arial,
            .courier,
            .futura
        ]
        
        case system, arial, courier, futura
        
        var rawValue: RawValue {
            switch self {
            case .system:
                return (name: UIFont.systemFont(ofSize: 0).fontName, preview: "Aa", displayName: "System")
            case .arial:
                return (name: "ArialRoundedMTBold", preview: "Ar", displayName: "Arial")
            case .courier:
                return (name: "CourierNewPS-BoldMT", preview: "Cr", displayName: "Courier")
            case .futura:
                return (name: "Futura-Medium", preview: "Ft", displayName: "Futura")
            }
        }
        
        init?(rawValue: RawValue) {
            return nil
        }
        
        func createFont() -> UIFont {
            return UIFont(name: self.rawValue.name, size: 26) ?? .systemFont(ofSize: 24)
        }
    }
}

extension LogoControl {
    struct Constants {
        static let paddingY: CGFloat = 18
        static let paddingX: CGFloat = 16
        static let closeButtonSize: CGFloat = 32
        static let cornerRadius: CGFloat = 12
        static let textColorDarkMode = UIColor(white: 0.95, alpha: 1)
    }
}
