//
//  TeamSpaceLogo.swift
//  LogoControl
//
//  Created by Nikola Bozhkov on 13.12.23.
//

import UIKit

class TeamSpaceLogo: UIView, Logo {
    var font: UIFont? {
        didSet {
            updateInitials()
        }
    }
    
    var name: String {
        didSet {
            updateInitials()
        }
    }
    
    var image: UIImage?
    
    let initialsLabel = UILabel()
    let imageView = UIImageView()
    
    override var backgroundColor: UIColor? {
        didSet {
            var white: CGFloat = 0
            backgroundColor?.getWhite(&white, alpha: nil)
            initialsLabel.textColor = white < 0.5 ? .white : .black
        }
    }
    
    init(name: String, size: CGFloat) {
        self.name = name
        super.init(frame: CGRect(origin: .zero, size: .one * size))
        
        layer.cornerRadius = size * 0.25
        layer.masksToBounds = true
        
        initialsLabel.textAlignment = .center
    
        addSubview(initialsLabel)
        addSubview(imageView)
        updateInitials()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        initialsLabel.frame = bounds
        imageView.frame = bounds
    }
    
    private func updateInitials() {
        initialsLabel.text = name.components(separatedBy: " ").map({ String($0.first ?? Character("")) }).joined()
        initialsLabel.font = font ?? .systemFont(ofSize: 18)
    }
    
    func setBackgroundColor(_ color: UIColor) {
        backgroundColor = color
    }
    
    func setFont(_ font: UIFont) {
        initialsLabel.font = font
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
}
