//
//  ZStackView.swift
//  ZLFlexKit
//
//  层叠容器：仅提供 DSL 方式添加子视图，后添加的在上层
//  子视图的布局约束由使用者自行设置（可直接在 DSL 中写 view.box 链式约束）
//

import UIKit

/// 允许直接放 view.box，例如：red.box.top(16).leading(16).size(w: 80, h: 60)
extension LayoutBox: StackViewDSL {
    public func getDslView() -> UIView? {
        view
    }
}

// MARK: - ZStackView

@objc(ZLZStackView)
open class ZStackView: UIView {

    /// 内边距，修改时同步更新 insetsGuide 的四边间距
    public var insets: EdgeInsets = .zero {
        didSet { updateInsetsGuide() }
    }

    /// 根据 insets 内缩后的区域，初始化时自动添加到 ZStackView
    public let insetsGuide = UILayoutGuide()

    private var guideTop:      NSLayoutConstraint!
    private var guideLeading:  NSLayoutConstraint!
    private var guideBottom:   NSLayoutConstraint!
    private var guideTrailing: NSLayoutConstraint!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupInsetsGuide()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupInsetsGuide()
    }

    private func setupInsetsGuide() {
        addLayoutGuide(insetsGuide)
        guideTop      = insetsGuide.topAnchor.constraint(equalTo: topAnchor)
        guideLeading  = insetsGuide.leadingAnchor.constraint(equalTo: leadingAnchor)
        guideBottom   = insetsGuide.bottomAnchor.constraint(equalTo: bottomAnchor)
        guideTrailing = insetsGuide.trailingAnchor.constraint(equalTo: trailingAnchor)
        NSLayoutConstraint.activate([guideTop, guideLeading, guideBottom, guideTrailing])
        updateInsetsGuide()
    }

    private func updateInsetsGuide() {
        guideTop?.constant      = insets.t
        guideLeading?.constant  = insets.s
        guideBottom?.constant   = -insets.b
        guideTrailing?.constant = -insets.e
    }

    /// DSL 构造
    ///
    ///     ZStackView(insets: .init(top: 8, leading: 8, bottom: 8, trailing: 8)) {
    ///         bgView.box.edgesZero()
    ///         red.box.top(16).leading(16).size(w: 80, h: 60)
    ///     }
    ///
    /// - Parameter insets: 内边距，可选，默认 .zero
    public convenience init(insets: EdgeInsets = .zero,
                            @StackViewBuilder builder: () -> [StackViewDSL]) {
        self.init(frame: .zero)
        self.insets = insets
        addViews(builder: builder)
    }

    /// DSL 追加子视图
    @discardableResult
    public func addViews(@StackViewBuilder builder: () -> [StackViewDSL]) -> Self {
        builder().forEach { component in
            if let view = component.getDslView() {
                addSubview(view)
            }
        }
        return self
    }
}
