//
//  PinningConstraintHelpers.swift
//  
//
//  Created by Russell Warwick on 01/05/2021.
//

import UIKit

public struct Pinning {
    public var top: CGFloat?
    public var leading: CGFloat?
    public var bottom: CGFloat?
    public var trailing: CGFloat?
    public init(top: CGFloat? = 0, trailing: CGFloat? = 0, bottom: CGFloat? = 0, leading: CGFloat? = 0) {
        self.top = top
        self.trailing = trailing
        self.bottom = bottom
        self.leading = leading
    }
}

public extension Pinning {
    static func all(_ value: CGFloat?) -> Self {
        Pinning(top: value, trailing: value, bottom: value, leading: value)
    }
    static func top(_ value: CGFloat?, others: CGFloat? = 0) -> Self {
        Pinning(top: value, trailing: others, bottom: others, leading: others)
    }
    static func trailing(_ value: CGFloat?, others: CGFloat? = 0) -> Self {
        Pinning(top: others, trailing: value, bottom: others, leading: others)
    }
    static func bottom(_ value: CGFloat?, others: CGFloat? = 0) -> Self {
        Pinning(top: others, trailing: others, bottom: value, leading: others)
    }
    static func axes(vertical: CGFloat?, horizontal: CGFloat?) -> Self {
        Pinning(top: vertical, trailing: horizontal, bottom: vertical, leading: horizontal)
    }
    static func verticalOnly(_ value: CGFloat) -> Self {
        Pinning(top: value, trailing: nil, bottom: value, leading: nil)
    }
    static func horizontalOnly(_ value: CGFloat?) -> Self {
        Pinning(top: nil, trailing: value, bottom: nil, leading: value)
    }
    static func topRight(_ value: CGFloat, others: CGFloat? = 0) -> Self {
        Pinning(top: value, trailing: value, bottom: others, leading: others)
    }
}

/**
 TL;DR:
 Helpers you write code that highlights the nested structure of your views
 
 Details:
 
 Method chaining where the called instance is returned as the result in cases where there would not usualy be a returned value,
 is a none standard but still popluar parttern used in languages and APIs
 
 One of the main objectives of it's use is to reduce the amount of local variables (often avoiding them all together),
 how often there are interacted with, or allowing them to be mutated prior to assignment to a const.
 
 Or overall try to make thing more declaritive while still handling some mutation.
 
 In iOS the most common use case is test data `Builder`s for some reason. In that use case I find just using `Chainable`
 will do mostly do things fine and avoid a lot of boiler place `Builder` code.
 
 The less common iOS use case is in UI; maybe because Interface Builder is more popular than code. This allows you to write
 something not a million miles away from SwiftUI (but long pre dates it).
 
 Subviews are added and constaints are applied at the same time; althought here adding as subview is optional to avoid method duplication.
 It is NOT a layout API, and is expected to be used in combination with some manual constraints less general basice stuff.
 */
public extension UIView {
    
    @discardableResult
    func withSubviews(_ content: () -> [UIView]) -> Self {
        content().forEach { contentView in
            contentView.translatesAutoresizingMaskIntoConstraints = false
            if contentView.superview !== self {
                addSubview(contentView)
            }
        }
        return self
    }
    
    @discardableResult
    func withEdgePinnedContent(
        _ pinning: Pinning = .all(0),
        priority: UILayoutPriority = .required,
        add: Bool = true,
        safeArea: Bool = false,
        content: () -> UIView) -> Self
    {
        withEdgePinnedContent(
            pinning,
            priority: priority,
            add: add,
            safeArea: safeArea,
            content: { [content()] }
        )
    }
    
    @discardableResult
    func withEdgePinnedContent(
        _ pinning: Pinning = .all(0),
        priority: UILayoutPriority = .required,
        add: Bool = true,
        safeArea: Bool = false,
        content: () -> [UIView]) -> Self
    {
        let contentViews = content()
        if add {
            withSubviews { contentViews }
        }
        let guideSoure: LayoutGuideSource = safeArea ? safeAreaLayoutGuide : self
        contentViews.forEach { contentView in
            NSLayoutConstraint.activate(
                [
                    pinning.leading.flatMap { contentView.leadingAnchor.constraint(equalTo: guideSoure.leadingAnchor, constant: $0) },
                    pinning.trailing.flatMap { contentView.trailingAnchor.constraint(equalTo: guideSoure.trailingAnchor, constant: -$0) },
                    pinning.top.flatMap { contentView.topAnchor.constraint(equalTo: guideSoure.topAnchor, constant: $0) },
                    pinning.bottom.flatMap { contentView.bottomAnchor.constraint(equalTo: guideSoure.bottomAnchor, constant: -$0) }
                ]
                .compactMap {
                    $0?.priority = priority
                    return $0
                }
            )
        }
        return self
    }
    
    @discardableResult
    func withCenteredContent(add: Bool = true, safeArea: Bool = false, x: CGFloat? = 0, y: CGFloat? = 0, priority: UILayoutPriority = .required, content: () -> [UIView]) -> Self {
        let contentViews = content()
        if add {
            withSubviews { contentViews }
        }
        let guideSoure: LayoutGuideSource = safeArea ? safeAreaLayoutGuide : self
        contentViews.forEach { contentView in
            NSLayoutConstraint.activate(
                [
                    x.flatMap { contentView.centerXAnchor.constraint(equalTo: guideSoure.centerXAnchor, constant: $0) },
                    y.flatMap { contentView.centerYAnchor.constraint(equalTo: guideSoure.centerYAnchor, constant: $0) }
                ]
                .compactMap {
                    $0?.priority = priority
                    return $0
                }
            )
        }
        return self
    }
    
    @discardableResult
    func withVerticallyCenteredContent(add: Bool = true, safeArea: Bool = false, y: CGFloat? = 0, horizontalEdgePin: CGFloat? = 0, priority: UILayoutPriority = .required, content: () -> [UIView]) -> Self {
        let contentViews = content()
        if add {
            withSubviews { contentViews }
        }
        withCenteredContent(add: false, safeArea: safeArea, x: nil, y: y, priority: priority, content: { contentViews })
        withEdgePinnedContent(.horizontalOnly(horizontalEdgePin), add: false, content: { contentViews })
        return self
    }

    @discardableResult
    func withScrollableContent(scrollView: UIScrollView = UIScrollView(), pinnedAxes: AxesSet = .horizontal, content: () -> UIView) -> Self {
        let contentView = content()
        withEdgePinnedContent {[
            scrollView.withEdgePinnedContent {[
                contentView
            ]}
        ]}
        if pinnedAxes.contains(.vertical) {
            heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        }
        if pinnedAxes.contains(.horizontal) {
            widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        }
        return self
    }
    
    @discardableResult
    func withRoundedCorners(corners: UIRectCorner, radius: CGFloat) -> Self {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        return self
    }
    
    static func spacer(priority: UILayoutPriority = .init(50)) -> UIView {
        let result = UIView()
        result.setContentHuggingPriority(priority, for: .vertical)
        result.setContentHuggingPriority(priority, for: .horizontal)
        return result
    }
    
    @discardableResult
    func withAspectFilled(_ content: () -> UIView) -> Self {
        let view = content()
        withCenteredContent {[
            view
        ]}
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalTo: widthAnchor).with { $0.priority = .defaultLow },
            view.heightAnchor.constraint(equalTo: heightAnchor).with { $0.priority = .defaultLow },
            view.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor),
            view.heightAnchor.constraint(greaterThanOrEqualTo: heightAnchor)
        ])
        return self
    }
}
