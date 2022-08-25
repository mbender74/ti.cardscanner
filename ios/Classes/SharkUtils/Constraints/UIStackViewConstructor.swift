//
//  UIStackViewConstructor.swift
//  
//
//  Created by Russell Warwick on 01/05/2021.
//

import UIKit

/**
 This is the old way of creating stack views. Please use SharkStackKit.
 https://github.com/gymshark/shark-stack-kit
 **/

public extension UIStackView {
    
    class func make(
        _ axis: NSLayoutConstraint.Axis,
        spacing: CGFloat? = nil,
        alignment: UIStackView.Alignment? = nil,
        distribution: UIStackView.Distribution? = nil,
        layoutMargins: UIEdgeInsets? = nil) -> Self
    {
        Self().with {
            $0.axis = axis
            if let spacing = spacing {
                $0.spacing = spacing
            }
            if let alignment = alignment {
                $0.alignment = alignment
            }
            if let distribution = distribution {
                $0.distribution = distribution
            }
            if let layoutMargins = layoutMargins {
                $0.isLayoutMarginsRelativeArrangement = true
                $0.layoutMargins = layoutMargins
            }
        }
    }
    class func vertical(
        spacing: CGFloat? = nil,
        alignment: UIStackView.Alignment? = nil,
        distribution: UIStackView.Distribution? = nil,
        layoutMargins: UIEdgeInsets? = nil) -> Self
    {
        make(
            .vertical,
            spacing: spacing,
            alignment: alignment,
            distribution: distribution,
            layoutMargins: layoutMargins
        )
    }
    class func horizontal(
        spacing: CGFloat? = nil,
        alignment: UIStackView.Alignment? = nil,
        distribution: UIStackView.Distribution? = nil,
        layoutMargins: UIEdgeInsets? = nil) -> Self
    {
        make(
            .horizontal,
            spacing: spacing,
            alignment: alignment,
            distribution: distribution,
            layoutMargins: layoutMargins
        )
    }
    
    @discardableResult
    func withArrangedViews(_ content: () -> [UIView]) -> Self {
        content().forEach { contentView in
            contentView.translatesAutoresizingMaskIntoConstraints = false
            if contentView.superview !== self {
                addArrangedSubview(contentView)
            }
        }
        return self
    }
}
