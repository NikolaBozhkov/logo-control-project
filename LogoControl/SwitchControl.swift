//
//  SwitchControl.swift
//  LogoControl
//
//  Created by Nikola Bozhkov on 13.12.23.
//

import UIKit

class SwitchControl: BaseView {
    var optionSelectionHandler: ((Int) -> Void)?
    
    override var intrinsicContentSize: CGSize {
        return stackView.frame.size
    }
    
    private let padding: CGFloat = 3
    
    private let stackView = UIStackView()
    private let selectionView = UIView()
    private var selectedView: UIView?
    
    init?(options: [Option], selectedOption: Int) {
        guard !options.isEmpty else {
            preconditionFailure("Options cannot be empty")
        }
        
        super.init()
        
        options.forEach {
            let optionView = OptionLabel(option: $0, isSelected: $0.value == selectedOption)
            optionView.owner = self
            stackView.addArrangedSubview(optionView)
        }
        
        selectedView = stackView.arrangedSubviews[0]
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        view.layer.cornerRadius = 7
        view.layer.cornerCurve = .continuous
        
        selectionView.layer.cornerRadius = view.layer.cornerRadius
        selectionView.layer.cornerCurve = .continuous
        
        view.addSubview(selectionView)
        view.addSubview(stackView)
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        selectionView.frame.origin.x = padding
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = stackView.arrangedSubviews.reduce(0, { $0 + $1.intrinsicContentSize.width })
        let height = stackView.arrangedSubviews[0].intrinsicContentSize.height * 1.8 + padding * 2
        stackView.frame = CGRect(origin: .zero, size: CGSize(width: width * 2.5, height: height))
        
        selectionView.frame.origin.y = padding
        selectionView.frame.size = CGSize(width: stackView.bounds.midX - padding,
                                          height: stackView.bounds.height - padding * 2)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.selectionView.frame.origin.x = max(self.selectedView?.frame.origin.x ?? 0, self.padding)
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = touches.first?.view else { return }
        selectedView = view
        
        for case let label as OptionLabel in stackView.arrangedSubviews {
            label.isSelected = label === selectedView
        }
        
        layoutSubviews()
    }
    
    func didSelectOption(value: Int) {
        optionSelectionHandler?(value)
    }
    
    override func updateTheme() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        view.backgroundColor = isDark ? .white.withAlphaComponent(0.06) : UIColor(white: 0.92, alpha: 1)
        selectionView.backgroundColor = isDark ? .black.withAlphaComponent(0.27) : UIColor(white: 1, alpha: 1)
        
        selectionView.layer.borderWidth = 1
        selectionView.layer.borderColor = isDark ? CGColor(gray: 0.2, alpha: 1) : CGColor(gray: 0.83, alpha: 1)
        selectionView.layer.shadowRadius = 3
        selectionView.layer.shadowColor = CGColor(gray: 0, alpha: 1)
        selectionView.layer.shadowOpacity = isDark ? 0.63 : 0.1
        selectionView.layer.shadowOffset = .zero
    }
}

extension SwitchControl {
    typealias Option = (label: String, value: Int)
    
    class OptionLabel: UILabel {
        weak var owner: SwitchControl?
        
        var isSelected: Bool {
            didSet {
                updateTheme()
            }
        }
        
        private var option: Option
        
        init(option: Option, isSelected: Bool) {
            self.option = option
            self.isSelected = isSelected
            
            super.init(frame: .zero)
            
            text = option.label
            font = .systemFont(ofSize: 15, weight: .semibold)
            textAlignment = .center
            isUserInteractionEnabled = true
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
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.transform = CGAffineTransformMakeScale(0.96, 0.96)
            })
            
            super.touchesBegan(touches, with: event)
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.transform = .identity
            })
            
            owner?.didSelectOption(value: option.value)
            
            super.touchesEnded(touches, with: event)
        }
        
        private func updateTheme() {
            let isDark = traitCollection.userInterfaceStyle == .dark
            let colorSelected = isDark ? UIColor.white : .black
            let colorNonSelected = isDark ? UIColor(white: 0.75, alpha: 1) : UIColor(white: 0.4, alpha: 1)
            textColor = isSelected ? colorSelected : colorNonSelected
        }
    }
}
