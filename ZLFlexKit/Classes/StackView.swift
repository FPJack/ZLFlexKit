//
//  StackView.swift
//  ZLFlexKit
//
//  Created by admin on 2026/6/5.
//

import UIKit
@objc(ZLStackViewAxis)
public enum StackViewAxis: Int {
    case horizontal = 0   // 水平排列
    case vertical         // 垂直排列
}

@objc(ZLJustify)
public enum Justify: Int {
    case fill
    case fillEqually
    case start
    case center
    case end
    case spaceBetween   // 两边没有间距，中间相等
    case spaceAround    // 两边是中间一半
    case spaceEvenly    // 所有间距都相等
}


@objc(ZLStackView)
open class StackView: UIView {
    
    @objc
    public var axis: StackViewAxis = .horizontal {
        didSet {
            if oldValue != axis {
                markedUpdateConstraints()
            }
        }
    }
    
    @objc
    public var alignment: FlexItemCrossAlign = .center {
        didSet {
            if oldValue != alignment {
                markedUpdateConstraints()
            }
        }
    }
    
    @objc
    public var justifyContent: Justify = .fill {
        didSet {
            if oldValue != justifyContent {
                markedUpdateConstraints()
            }
        }
    }
    
    @objc
    public var insets: UIEdgeInsets = .zero {
        didSet {
            if oldValue != insets {
                layoutManager.updateInsets(insets)
            }
        }
    }
    
    @objc
    public var arrangedViews: [UIView] {
        allViews.filter {!$0.isHidden}
    }
    
    @objc
    public var spacing: CGFloat = -1 {
        didSet {
            if oldValue != spacing {
                markedUpdateConstraints()
            }
        }
    }
    
    
    lazy var layoutManager: FlexManager = {
        let flexManager = FlexManager()
        flexManager.stackView = self
        return flexManager
    }()
    
    private var allViews: [UIView] = []
    
    private var markedDirty: Bool = true
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        layoutMargins = .zero
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(@StackViewBuilder builder: () -> [StackViewDSL]) {
        super.init(frame: .zero)
        addViews(builder: builder)
    }
    
    
    
    
    func markedUpdateConstraints() {
        if markedDirty { return }
        markedDirty = true
        setNeedsUpdateConstraints()
    }
    
    
    @objc
    public func vertical() -> Self {
        axis = .vertical
        return self
    }
    
    @objc
    public func horizontal() -> Self {
        axis = .horizontal
        return self
    }
    
    @objc
    public static func vertical() -> Self {
        let stackView = Self.init()
        stackView.axis = .vertical
        return stackView
    }
    
    @objc
    public static func horizontal() -> Self {
        let stackView = Self.init()
        stackView.axis = .horizontal
        return stackView
    }
    
    
    
    // MARK: - swift链式API
    @discardableResult
    public func axis(_ axis: StackViewAxis) -> Self {
        self.axis = axis
        return self
    }
    
    @discardableResult
    public func align(_ alignment: FlexItemCrossAlign) -> Self {
        self.alignment = alignment
        return self
    }
    
    @discardableResult
    public func justify(_ justifyContent: Justify) -> Self {
        self.justifyContent = justifyContent
        return self
    }
    
    @discardableResult
    public func insets(_ insets: UIEdgeInsets) -> Self {
        self.insets = insets
        return self
    }
    
    @discardableResult
    public func spacing(_ spacing: NumberConvertible) -> Self {
        self.spacing = spacing.cgFloat
        return self
    }
    
    @discardableResult
    open func insertSpacing(_ spacing: NumberConvertible) -> Self {
        allViews.last?.flex.spacing = spacing.cgFloat
        return self
    }
    
    @discardableResult
    open func insertSpacing(min: NumberConvertible) -> Self {
        allViews.last?.flex.minSpacing = min.cgFloat
        return self
    }
    
    @discardableResult
    open func insertSpacing(max: NumberConvertible) -> Self {
        allViews.last?.flex.maxSpacing = max.cgFloat
        return self
    }
    
    @discardableResult
    open func insertSpacing(flexible: Bool) -> Self {
        allViews.last?.flex.isFlexibleSpace = flexible
        return self
    }
    
    @discardableResult
    open func addView(_ flexType: FlexType?) -> Self {
        addArrangedSubview(flexType?.view)
        return self
    }
    
    @discardableResult
    open func addView(if condition: Bool, _ view: FlexType?) -> Self {
        if condition {
            addArrangedSubview(view?.view)
        }
        return self
    }
    
    @discardableResult
    open func addView<T>(make: @escaping (T) -> (any FlexType)?) -> Self where T: StackView {
        let blockView = make(self as! T)
        addArrangedSubview(blockView?.view)
        return self
    }
    
    
    @discardableResult
    open func addView<T>(if condition: Bool, make: @escaping (T) -> FlexType?) -> Self where T: StackView {
        if condition {
            let blockView = make(self as! T)
            addArrangedSubview(blockView?.view)
        }
        return self
    }
    
    @objc
    @discardableResult
    open func wrapScrollView() -> ScrollView {
        let scrollView = ScrollView()
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.box.edgesZero()
        let axisLayout: NSLayoutConstraint
        if self.axis == .horizontal {
            axisLayout = self.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            let equalWidth = scrollView.widthAnchor.constraint(equalTo: self.widthAnchor)
            equalWidth.priority = .defaultLow
            equalWidth.isActive = true
        } else {
            axisLayout = self.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            let equalHeight = scrollView.heightAnchor.constraint(equalTo: self.heightAnchor)
            equalHeight.priority = .defaultLow
            equalHeight.isActive = true
        }
        axisLayout.isActive = true
        return scrollView
    }
    
    @discardableResult
    open func assignToPtr(_ ptr: AutoreleasingUnsafeMutablePointer<StackView>?) -> StackView {
        if let ptr = ptr {
            ptr.pointee = self
        }
        return self
    }
    
    
    
    
}

// MARK: - OC链式API
extension StackView {
    @objc
    @available(swift, obsoleted: 1, renamed: "axis(_:)")
    public var justifyFillEqually: StackView {
        self.justifyContent = .fillEqually
        return self
    }
    
    @objc
    @available(swift, obsoleted: 1, renamed: "axis(_:)")
    public var justifyFill: StackView {
        self.justifyContent = .fill
        return self
    }
    @objc
    @available(swift, obsoleted: 1, renamed: "axis(_:)")
    public var justifyStart: StackView {
        self.justifyContent = .start
        return self
    }
    @objc
    @available(swift, obsoleted: 1, renamed: "axis(_:)")
    public var justifyCenter: StackView {
        self.justifyContent = .center
        return self
    }
    @objc
    @available(swift, obsoleted: 1, renamed: "axis(_:)")
    public var justifyEnd: StackView {
        self.justifyContent = .end
        return self
    }
    @objc
    @available(swift, obsoleted: 1, renamed: "axis(_:)")
    public var justifySpaceBetween: StackView {
        self.justifyContent = .spaceBetween
        return self
    }
    @objc
    @available(swift, obsoleted: 1, renamed: "axis(_:)")
    public var justifySpaceAround: StackView {
        self.justifyContent = .spaceAround
        return self
    }
    @objc
    @available(swift, obsoleted: 1, renamed: "axis(_:)")
    public var justifySpaceEvenly: StackView {
        self.justifyContent = .spaceEvenly
        return self
    }
    
    @objc
    @available(swift, obsoleted: 1, renamed: "axis(_:)")
    public var alignFill: StackView {
        self.alignment = .fill
        return self
    }
    
    @objc
    @available(swift, obsoleted: 1, renamed: "axis(_:)")
    public var alignStart: StackView {
        self.alignment = .start
        return self
    }
    @objc
    @available(swift, obsoleted: 1, renamed: "axis(_:)")
    public var alignCenter: StackView {
        self.alignment = .center
        return self
    }
    @objc
    @available(swift, obsoleted: 1, renamed: "axis(_:)")
    public var alignEnd: StackView {
        self.alignment = .end
        return self
    }
    
    @objc(setAxis)
    @available(swift, obsoleted: 1, renamed: "axis(_:)")
    public var axisObjc: (_ axis: StackViewAxis) -> StackView {
        {
            axis in self.axis = axis;
            return self
        }
    }
    
    @objc(setAlign)
    @available(swift, obsoleted: 1, renamed: "align(_:)")
    public var alignObjc: (_ alignment: FlexItemCrossAlign) -> StackView {
        {
            alignment in self.alignment = alignment;
            return self
        }
    }
    
    @objc(setJustify)
    @available(swift, obsoleted: 1, renamed: "justify(_:)")
    public var justifyObjc: (_ justifyContent: Justify) -> StackView{
        {
            justifyContent in self.justifyContent = justifyContent;
            return self
        }
    }
    
    @objc(setInsets)
    @available(swift, obsoleted: 1, renamed: "insets(_:)")
    public var insetsObjc: (_ top: CGFloat,_ leading: CGFloat,_ bottom: CGFloat, _ trailing: CGFloat) -> StackView {
        {
            top,leading,bottom,trailing in self.insets = .init(top: top, left: leading, bottom: bottom, right: trailing);
            return self
        }
    }
    
    @objc(setSpacing)
    @available(swift, obsoleted: 1, renamed: "spacing(_:)")
    public var spacingObjc: (_ spacing: CGFloat) -> StackView {
        {
            spacing in self.spacing = spacing;
            return self
        }
    }
    
    @objc(insertSpacing)
    @available(swift, obsoleted: 1, renamed: "insertSpacing(_:)")
    open var insertSpacingObjc: (_ spacing: CGFloat) -> StackView {
        {
            spacing in self.allViews.last?.flex.spacing = spacing;
            return self
        }
    }
    
    @objc(insertMinSpacing)
    @available(swift, obsoleted: 1, renamed: "insertSpacing(min:)")
    open var insertMinSpacingObjc: (_ spacing: CGFloat) -> StackView {
        {
            spacing in self.allViews.last?.flex.minSpacing = spacing;
            return self
            
        }
    }
    
    @objc(insertMaxSpacing)
    @available(swift, obsoleted: 1, renamed: "insertSpacing(max:)")
    open var insertMaxSpacingObjc: (_ spacing: CGFloat) -> StackView {
        {
            spacing in self.allViews.last?.flex.maxSpacing = spacing;
            return self
        }
    }
    
    @objc(insertFlexibleSpacing)
    @available(swift, obsoleted: 1, renamed: "insertSpacing(flexible:)")
    open var insertFlexibleSpacingObjc: (_ flexible: Bool) -> StackView {
        {
            flexible in self.allViews.last?.flex.isFlexibleSpace = flexible;
            return self
        }
    }
    
    @objc(addView)
    @available(swift, obsoleted: 1, renamed: "addView(_:)")
    open var addViewObjc: (_ view: UIView?) -> StackView {
        {
            view in self.addArrangedSubview(view);
            return self
        }
    }
    
    @objc(addViewIf)
    @available(swift, obsoleted: 1, renamed: "addView(if:_:)")
    open var addViewIfObjc: (_ condition: Bool, _ view: UIView?) -> StackView {
        {
            condition, view in
            if condition {
                self.addArrangedSubview(view)
            }
            return self
        }
    }
    
    @objc(addViewMake)
    @available(swift, obsoleted: 1, renamed: "addView(make:)")
    open var addViewMakeObjc: (_ make: @escaping (StackView) -> UIView?) -> StackView {
        {
            make in let blockView = make(self);
            self.addArrangedSubview(blockView);
            return self
        }
    }
    
    @objc(addViewIfMake)
    @available(swift, obsoleted: 1, renamed: "addView(if:make:)")
    open var addViewIfMakeObjc: (_ condition: Bool, _ make: @escaping (StackView) -> UIView?) -> StackView {
        {
            condition, make in
            if condition {
                let blockView = make(self);
                self.addArrangedSubview(blockView)
            }
            return self
        }
    }
    
    @objc(assignToPtr)
    @available(swift, obsoleted: 1, renamed: "assignToPtr(_:)")
    open var assignToPtrObjc: (AutoreleasingUnsafeMutablePointer<StackView>?) -> StackView {
        return { ptr in
            if let ptr = ptr {
                ptr.pointee = self
            }
            return self
        }
    }
}

extension StackView {
    
    // MARK: - Add / Insert
    
    /// 添加 view 到 stackView，默认添加到最后
    @objc
    open func addArrangedSubview(_ view: UIView?) {
        guard let view = view, view.isKind(of: UIView.self) else { return }
        
        guard !allViews.contains(view) else { return }
        
        view.flex.stackView = self
        
        allViews.append(view)
        
        adjustLabelCompression(view)
        
        adjustStackView(view)
        
        addSubview(view)
        
        if view.isHidden { return }
        
        markedUpdateConstraints()
        
    }
    
    /// 添加 view 并配置 view 的布局属性
    @objc
    open func addArrangedSubview(
        _ view: UIView,
        layout config: ((_ view: UIView, _ flexItem: FlexItem) -> Void)?
    ) {
        addArrangedSubview(view)
        config?(view, view.flex)
    }
    
    /// 在某个位置插入 view
    @objc
    open func insertArrangedSubview(_ view: UIView?, at stackIndex: Int) {
        guard let view = view, view.isKind(of: UIView.self) else { return }
        
        guard !allViews.contains(view) else { return }
        
        adjustStackView(view)
        
        addSubview(view)
        
        view.flex.stackView = self
        
        allViews.insert(view, at: stackIndex)
        
        adjustLabelCompression(view)
        
        if view.isHidden { return }
        
        markedUpdateConstraints()
    }
    
    
    // MARK: - Remove
    
    /// 移除 view
    @objc
    open func removeArrangedSubview(_ view: UIView?) {
        guard let view = view,view.isKind(of: UIView.self) else { return }
        
        guard let index = allViews.firstIndex(of: view) else { return }
        
        view.removeFromSuperview()
        
        allViews.remove(at: index)
        
        markedUpdateConstraints()
    }
    
    
    // MARK: - Spacing Control
    
    /// 设置 view 在主轴方向的间距
    @objc
    open func setCustomSpacing(_ spacing: CGFloat, after view: UIView?) {
        guard let view = view,view.isKind(of: UIView.self) else { return }
        
        guard allViews.contains(view) else { return }
        guard view.isKind(of: UIView.self) else { return }
        let viewCfg = view.flex
        guard viewCfg.spacing != spacing else { return }
        viewCfg._spacing = spacing
        guard !view.isHidden else { return }
        guard !layoutManager.constraints.isEmpty else { return }
        let matched = filterConstraint { constraint in
            let cfg = constraint.item
            return cfg.view == view && cfg.type == .spacing
        }
        if let constraint = matched.first {
            constraint.constant = max(0, spacing)
        } else {
            markedUpdateConstraints()
        }
    }
    
    /// 设置 view 在主轴方向的最小间距
    @objc
    open func setCustomMinSpacing(_ minSpacing: CGFloat, after view: UIView?) {
        guard let view = view,view.isKind(of: UIView.self) else { return }
        
        guard allViews.contains(view) else { return }
        guard view.isKind(of: UIView.self) else { return }
        let viewCfg = view.flex
        guard viewCfg.minSpacing != minSpacing else { return }
        viewCfg._minSpacing = minSpacing
        guard !view.isHidden else { return }
        guard !layoutManager.constraints.isEmpty else { return }
        let matched = filterConstraint { constraint in
            let cfg = constraint.item
            return cfg.view == view && cfg.type == .minSpacing
        }
        if !matched.isEmpty {
            let value = max(0, minSpacing)
            matched.first?.constant = value
            matched.last?.constant = value
        } else {
            markedUpdateConstraints()
        }
    }
    
    /// 设置 view 在主轴方向的最大间距
    @objc
    open  func setCustomMaxSpacing(_ maxSpacing: CGFloat, after view: UIView?) {
        guard let view = view,view.isKind(of: UIView.self) else { return }
        
        guard allViews.contains(view) else { return }
        
        guard !layoutManager.constraints.isEmpty else { return }
        
        let viewCfg = view.flex
        
        guard viewCfg.maxSpacing != maxSpacing else { return }
        viewCfg._maxSpacing = maxSpacing
        
        guard !view.isHidden else { return }
        
        let matched = filterConstraint {
            let cfg = $0.item
            return cfg.view == view && cfg.type == .maxSpacing
        }
        
        if let constraint = matched.first {
            constraint.constant = max(0, maxSpacing)
        } else {
            markedUpdateConstraints()
        }
    }
    
    
    // MARK: - Flex
    
    /// 设置 view 在主轴方向的权重
    @objc(setFlex:forView:)
    open func setFlex(_ flex: Int, for view: UIView?) {
        guard let view = view,view.isKind(of: UIView.self) else { return }
        
        guard allViews.contains(view) else { return }
        
        let cfg = view.flex
        
        guard flex >= 0, cfg.flex != flex else { return }
        
        cfg.flex = flex
        
        guard !view.isHidden else { return }
        
        markedUpdateConstraints()
    }
    
    /// 是否弹性空间（仅 ZLJustify.fill 生效）
    @objc(setFlexibleSpacing:forView:)
    open func setFlexibleSpacing(_ flexible: Bool, after view: UIView?) {
        guard let view = view,view.isKind(of: UIView.self) else { return }
        
        guard allViews.contains(view) else { return }
        
        let flex = view.flex
        
        guard flex.isFlexibleSpace != flexible else { return }
        
        flex.isFlexibleSpace = flexible
        
        guard !view.isHidden else { return }
        
        markedUpdateConstraints()
    }
    
    
    // MARK: - Alignment
    
    /// 设置 view 的 alignment（优先级高于 stackView）
    @objc(setAlignment:forView:)
    open func setAlignment(_ alignment: FlexItemCrossAlign, for view: UIView?) {
        guard let view = view,view.isKind(of: UIView.self) else { return }
        
        guard allViews.contains(view) else { return }
        
        let cfg = view.flex
        
        guard cfg.alignSelf != alignment else { return }
        
        cfg.alignSelf = alignment
        
        guard !view.isHidden else { return }
        
        markedUpdateConstraints()
    }
    
    /// alignment start 方向间距
    @objc(startMarge:forView:)
    open func startMarge(_ marge: CGFloat, for view: UIView?) {
        guard let view = view,view.isKind(of: UIView.self) else { return }
        
        guard allViews.contains(view) else { return }
        
        let cfg = view.flex
        
        guard cfg.startMarge != marge else { return }
        
        cfg.startMarge = marge
        
        //            guard !view.isHidden else { return }
        //
        //            markedUpdateConstraints()
    }
    
    /// alignment end 方向间距
    @objc(endMarge:forView:)
    open func endMarge(_ marge: CGFloat, for view: UIView?) {
        guard let view = view,view.isKind(of: UIView.self) else { return }
        guard allViews.contains(view) else { return }
        
        let cfg = view.flex
        
        guard cfg.endMarge != marge else { return }
        
        cfg.endMarge = marge
        
        //           guard !view.isHidden else { return }
        //
        //            markedUpdateConstraints()
        
    }
}

///DSL
extension StackView {
    @discardableResult
    public func addViews(
        @StackViewBuilder builder: () -> [StackViewDSL]
    ) -> Self {
        addViews(with: builder)
        return self
    }
    func addViews(with builder: () -> [StackViewDSL]) {
        let arr = builder()
        arr.forEach { component in
            if let view = component.getDslView() {
                addView(view)
            }else if let item = component as? Double {
                insertSpacing(CGFloat(item))
            }else if let item = component as? Int {
                insertSpacing(CGFloat(item))
            }else if let item = component as? Float {
                insertSpacing(CGFloat(item))
            }else if let item = component as? FlexItem {
                addView(item)
            }else if let item = component as? Spacer {
                switch item {
                case .normal:
                    insertSpacing(flexible: true)
                case .min(let value):
                    insertSpacing(min: value)
                case .max(let value):
                    insertSpacing(max: value)
                case .value(let value):
                    insertSpacing(value)
                }
            }
        }
    }
}


public protocol FlexType {}
extension FlexType {
    var view: UIView? {
        if let view = self as? UIView {
            return view
        } else if let item = self as? FlexItem {
            return item._view
        }
        return nil
    }
}
extension FlexItem: FlexType {}
extension UIView: FlexType {}


extension StackView {
    override public func updateConstraints() {
        
        guard markedDirty else {
            super.updateConstraints()
            return
        }
        
        layoutManager.removeAllSpacing()
        layoutManager.deactivateConstraints()
        layoutManager.addHorizontalLayoutConstraints()
        layoutManager.addVerticalLayoutConstraints()
        layoutManager.activateConstraints()
        
        markedDirty = false
        
        super.updateConstraints()
    }
    open override var intrinsicContentSize: CGSize {
        .zero
    }
}


extension StackView {
    private func adjustLabelCompression(_ view: UIView) {
        
        guard let label = view as? UILabel else { return }
        
        if label.numberOfLines == 1 { return }
        
        let axis: NSLayoutConstraint.Axis =
        (self.axis == .horizontal)
        ? .horizontal
        : .vertical
        
        let priority = view.contentCompressionResistancePriority(for: axis)
        
        if priority == .defaultHigh {
            view.setContentCompressionResistancePriority(priority - 0.1, for: axis)
        }
    }
    private func adjustStackView(_ view: UIView) {
        
        guard let stackView = view as? StackView else { return }
        // StackView 嵌套时避免约束冲突
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func filterConstraint(
        _ block: (NSLayoutConstraint) -> Bool
    ) -> [NSLayoutConstraint] {
        return layoutManager.constraints.filter { constraint in
            block(constraint)
        }
    }
}

open class VStackView: StackView {
    public override var axis: StackViewAxis {
        get { .vertical }
        set {}
    }
    public override init(builder: () -> [any StackViewDSL]) {
        super.init(builder: builder)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class HStackView: StackView {
    public override var axis: StackViewAxis {
        get { .horizontal }
        set {}
    }
    public override init(builder: () -> [any StackViewDSL]) {
        super.init(builder: builder)
       
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

