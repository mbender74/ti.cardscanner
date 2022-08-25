//
//  GenericArrayBuilder.swift
//  
//
//  Created by Russell Warwick on 01/05/2021.
//

import Foundation

@resultBuilder
public struct GenericArrayBuilder<I> {

    public typealias Expression = I
    public typealias Component = [I]

    public static func buildExpression(_ expression: Expression) -> Component {
        return [expression]
    }

    public static func buildExpression(_ expression: Component) -> Component {
        return expression
    }

    public static func buildExpression(_ expression: Expression?) -> Component {
        guard let expression = expression else { return [] }
        return [expression]
    }

    public static func buildBlock(_ children: Component...) -> Component {
        return children.flatMap { $0 }
    }

    public static func buildBlock(_ component: Component) -> Component {
        return component
    }

    public static func buildOptional(_ children: Component?) -> Component {
        return children ?? []
    }

    public static func buildEither(first child: Component) -> Component {
        return child
    }

    public static func buildEither(second child: Component) -> Component {
        return child
    }

    public static func buildArray(_ components: [Component]) -> Component {
        return components.flatMap { $0 }
    }
}
