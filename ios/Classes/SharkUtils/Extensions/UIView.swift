//
//  UIView.swift
//  
//
//  Created by Russell Warwick on 01/05/2021.
//

import UIKit

public extension UIView {
    func setCornerRadius(_ radius: CGFloat, corners: CACornerMask = .all) {
        layer.cornerRadius = radius
        layer.maskedCorners = corners
    }
}
