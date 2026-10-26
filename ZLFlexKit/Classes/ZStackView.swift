//
//  ZStackView.swift
//  ZLFlexKit
//
//  层叠容器：仅提供 DSL 方式添加子视图，后添加的在上层
//  子视图的布局约束由使用者自行设置（可直接在 DSL 中写 view.box 链式约束）
//

import UIKit

// MARK: - DSL

public protocol ZStackViewDSL {
    func getZStackView() -> UIView?
}

extension UIView: ZStackViewDSL {
    public func getZStackView() -> UIView? { self }
}

/// 允许直接放 view.box，例如：red.box.top(16).leading(16).size(w: 80, h: 60)
extension LayoutBox: ZStackViewDSL {
    public func getZStackView() -> UIView? { view }
}

/// 允许可选类型，nil 自动忽略
extension Optional: ZStackViewDSL where Wrapped: ZStackViewDSL {
    public func getZStackView() -> UIView? {
        switch self {
        case .some(let value): return value.getZStackView()
        case .none:            return nil
        }
    }
}

@resultBuilder
public struct ZStackViewBuilder {
    public static func buildBlock(_ components: [ZStackViewDSL]...) -> [ZStackViewDSL] {
        components.flatMap { $0 }
    }
    public static func buildExpression(_ expression: ZStackViewDSL) -> [ZStackViewDSL] {
        [expression]
    }
    public static func buildOptional(_ component: [ZStackViewDSL]?) -> [ZStackViewDSL] {
        component ?? []
    }
    public static func buildEither(first component: [ZStackViewDSL]) -> [ZStackViewDSL] {
        component
    }
    public static func buildEither(second component: [ZStackViewDSL]) -> [ZStackViewDSL] {
        component
    }
    public static func buildArray(_ components: [[ZStackViewDSL]]) -> [ZStackViewDSL] {
        components.flatMap { $0 }
    }
}

// MARK: - ZStackView

@objc(ZLZStackView)
open class ZStackView: UIView {

    /// DSL 构造
    ///
    ///     ZStackView {
    ///         bgView.box.edgesZero()
    ///         red.box.top(16).leading(16).size(w: 80, h: 60)
    ///     }
    public convenience init(@ZStackViewBuilder builder: () -> [ZStackViewDSL]) {
        self.init(frame: .zero)
        addViews(builder: builder)
    }

    /// DSL 追加子视图
    @discardableResult
    public func addViews(@ZStackViewBuilder builder: () -> [ZStackViewDSL]) -> Self {
        builder().forEach { component in
            if let view = component.getZStackView() {
                addSubview(view)
                // DSL 中写的 top/leading/center/edges 等相对父视图的约束，此时才有 superview，统一补上
                view.box.applyPendingSuperviewConstraints()
            }
        }
        return self
    }
}
