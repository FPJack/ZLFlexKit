//
//  Button.swift
//  ZLFlexKit
//
//  Created by admin on 2026/6/9.
//

import UIKit

// MARK: - Supporting Types

@objc public enum ButtonAxis: Int {
    case horizontal = 0
    case vertical
}

@objc public enum ButtonOrder: Int {
    case imageFirst = 0
    case titleFirst
}

@objc public enum ButtonAlign: Int {
    case center = 0
    case start
    case end
    case fill
}



public struct StartEndInsets {
    public var start: CGFloat
    public var end: CGFloat
    public static let zero = StartEndInsets(start: 0, end: 0)
    public init(start: CGFloat = 0, end: CGFloat = 0) {
        self.start = start
        self.end = end
    }
}

// MARK: - Button

private let kInsetLeadingId  = "kInsetLeadingId"
private let kInsetTrailingId = "kInsetTrailingId"
private let kInsetTopId      = "kInsetTopId"
private let kInsetBottomId   = "kInsetBottomId"
private let kSpacingId       = "kSpacingId"
private let kCustomPriority  = UILayoutPriority(UILayoutPriority.required.rawValue - 1)

@objc(ZLButton)
open class Button: UIButton,ViewStyleable {

    /// 内容布局轴向，默认为水平
    @objc
    public var axis: ButtonAxis = .horizontal {
        didSet { guard axis != oldValue else { return }; setNeedsUpdateConstraintsIfNeed() }
    }
    
    /// 内容顺序，默认为 imageFirst
    @objc
    public var contentOrder: ButtonOrder = .imageFirst {
        didSet { guard contentOrder != oldValue else { return }; setNeedsUpdateConstraintsIfNeed() }
    }
    
    /// 内容在垂直方向的对齐方式，默认为 center
    @objc
    public var verticalAlign: ButtonAlign = .center {
        didSet { guard verticalAlign != oldValue else { return }; setNeedsUpdateConstraintsIfNeed() }
    }
    
    /// 内容在水平方向的对齐方式，默认为 center
    @objc
    public var horizontalAlign: ButtonAlign = .center {
        didSet { guard horizontalAlign != oldValue else { return }; setNeedsUpdateConstraintsIfNeed() }
    }
    
    
    /// 是否仅图片响应点击事件，默认为 false
    @objc
    public var imgTouchOnly: Bool = false
    
    
    /// 点击事件间隔，默认为 0（不限制）
    @objc
    public var tapInterval: TimeInterval = 0
    
    
    /// 点击区域扩展，默认为 .zero
    @objc
    public var touchAreaEdgeInsets: UIEdgeInsets = .zero

    
    /// 内容间距，默认为 4
    @objc
    public var spacing: CGFloat = 4 {
        didSet {
            guard spacing != oldValue else { return }
            if let cons = constraint(withIdentifier: kSpacingId) {
                cons.constant = spacing
            }
        }
    }
    
    /// 是否在图片文字添加可拉伸的间隔，默认为 false
    @objc
    public var flexibleSpacing: Bool = false {
        didSet { guard flexibleSpacing != oldValue else { return }; setNeedsUpdateConstraintsIfNeed() }
    }
    
    /// 内容与边界的间距，默认为 .zero
    @objc
    public var insets: UIEdgeInsets = .zero {
        didSet {
            guard insets != oldValue else { return }
            constraint(withIdentifier: kInsetLeadingId)?.constant  = insets.left
            constraint(withIdentifier: kInsetTrailingId)?.constant = insets.right
            constraint(withIdentifier: kInsetTopId)?.constant      = insets.top
            constraint(withIdentifier: kInsetBottomId)?.constant   = insets.bottom
            setNeedsUpdateConstraintsIfNeed()
        }
    }
    
    
    /// 标题大小，默认为 CGSize(width: -1, height: -1)，表示不限制
    @objc
    public var titleSize: CGSize = CGSize(width: -1, height: -1) {
        didSet {
            guard titleSize != oldValue else { return }
            guard titleSize != titleLabel?.intrinsicContentSize else { return }
            setNeedsUpdateConstraintsIfNeed()
        }
    }
    
    /// 图片大小，默认为 CGSize(width: -1, height: -1)，表示不限制
    @objc
    public var imageSize: CGSize = CGSize(width: -1, height: -1) {
        didSet { guard imageSize != oldValue else { return }; setNeedsUpdateConstraintsIfNeed() }
    }
    
    
    /// 图片边距，默认为 .zero
    public var imageMarge: StartEndInsets = .zero {
        didSet {
            
            guard imageMarge.start != oldValue.start || imageMarge.end != oldValue.end else { return }
            setNeedsUpdateConstraintsIfNeed()
        }
    }
    
    /// 标题边距，默认为 .zero
    @objc
    public func imageMarge(start: CGFloat, end: CGFloat) {
        imageMarge = StartEndInsets(start: start, end: end)
    }
    
    
    /// 标题边距，默认为 .zero
    @objc
    public func titleMarge(start: CGFloat, end: CGFloat) {
        titleMarge = StartEndInsets(start: start, end: end)
    }
    
    
    /// 标题边距，默认为 .zero
    public var titleMarge: StartEndInsets = .zero {
        didSet {
            guard titleMarge.start != oldValue.start || titleMarge.end != oldValue.end else { return }
            setNeedsUpdateConstraintsIfNeed()
        }
    }
    
    
    private var labelObservation: NSKeyValueObservation?
    private var imgHeighConstraint: NSLayoutConstraint?
    private var imgWidthConstraint: NSLayoutConstraint?
    private var labHeighConstraint: NSLayoutConstraint?
    private var labWidthConstraint: NSLayoutConstraint?
    open override var titleLabel: UILabel? {
        let label = super.titleLabel
        if labelObservation == nil {
            labelObservation = label?.observe(\.isHidden, options: [.new,.old]) { [weak self] _, change in
                guard let self = self else { return }
                if change.newValue != change.oldValue {
                    self.setNeedsUpdateConstraintsIfNeed()
                }
            }
        }
        return label
    }
    
    private var imgViewObservation: NSKeyValueObservation?
    open override var imageView: UIImageView? {
        let imgView = super.imageView
        if imgViewObservation == nil {
            imgViewObservation = imgView?.observe(\.isHidden, options: [.new,.old]) { [weak self] _, change in
                guard let self = self else { return }
                if change.newValue != change.oldValue {
                    self.setNeedsUpdateConstraintsIfNeed()
                }
            }
        }
        return imgView
    }
    

    // MARK: - Private Properties

    private var middleGuide: UILayoutGuide?
    private var startGuide: UILayoutGuide?
    private var endGuide: UILayoutGuide?
    private var customConstraints: [NSLayoutConstraint] = []
    private var orderKey: String?
    private var _needsUpdate: Bool = false

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaults()
    }

    private func setupDefaults() {
        setNeedsUpdateConstraintsIfNeed()
    }

    // MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()
        adjustImageViewCompressionAndHugging()
        viewStyle.layoutSubviews()
    }
    
    
    open override func updateConstraints() {
        if _needsUpdate {
            updateAllConstraints()
            _needsUpdate = false
        }
        super.updateConstraints()
        deactivateSystemConstraints()
    }

    open override var intrinsicContentSize: CGSize {
        CGSize(width: insets.left + insets.right,
               height: insets.top + insets.bottom)
    }

    // MARK: - Action Override

    open override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        if tapInterval > 0 {
            isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + tapInterval) { [weak self] in
                self?.isUserInteractionEnabled = true
            }
        }
        super.sendAction(action, to: target, for: event)
    }

    // MARK: - Hit Test

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isUserInteractionEnabled, isEnabled, !isHidden, alpha >= 0.01 else {
            return super.point(inside: point, with: event)
        }
        var edgeInsets = touchAreaEdgeInsets
        if isRTL {
            swap(&edgeInsets.left, &edgeInsets.right)
        }
        if imgTouchOnly, let iv = imageView {
            let expanded = UIEdgeInsetsInsetRect(iv.bounds, UIEdgeInsets(
                top: -edgeInsets.top, left: -edgeInsets.left,
                bottom: -edgeInsets.bottom, right: -edgeInsets.right))
            let pointInImageView = convert(point, to: iv)
            return expanded.contains(pointInImageView)
        }
        let expanded = UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(
            top: -edgeInsets.top, left: -edgeInsets.left,
            bottom: -edgeInsets.bottom, right: -edgeInsets.right))
        return expanded.contains(point)
    }
    
    
    
    lazy  public var viewStyle: ViewStyle = {
       ViewStyle(view: self)
    }()
    override public var backgroundColor: UIColor? {
        get {
            return viewStyle.backgroundColor
        }
        set {
            viewStyle.backgroundColor = newValue
        }
    }
    public func superBackgroundColor() -> UIColor? {
         super.backgroundColor
    }
    public func superSetBackgroundColor(_ color: UIColor?) {
        super.backgroundColor = color
    }
   
}

// MARK: - Private Helpers

private extension Button {
    var isRTL: Bool {
        if #available(iOS 10.0, *) {
            return effectiveUserInterfaceLayoutDirection == .rightToLeft
        }
        return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
    }

    var effectiveInsets: UIEdgeInsets {
        var i = insets
        if isRTL { swap(&i.left, &i.right) }
        return i
    }

    func setNeedsUpdateConstraintsIfNeed() {
        _needsUpdate = true
        setNeedsUpdateConstraints()
    }

    func constraint(withIdentifier id: String) -> NSLayoutConstraint? {
        customConstraints.first { $0.identifier == id }
    }

    func lazyMiddleGuide() -> UILayoutGuide {
        if let g = middleGuide { return g }
        let g = UILayoutGuide(); g.identifier = "middle-guide"
        addLayoutGuide(g); middleGuide = g; return g
    }
    func lazyStartGuide() -> UILayoutGuide {
        if let g = startGuide { return g }
        let g = UILayoutGuide(); g.identifier = "start-guide"
        addLayoutGuide(g); startGuide = g; return g
    }
    func lazyEndGuide() -> UILayoutGuide {
        if let g = endGuide { return g }
        let g = UILayoutGuide(); g.identifier = "end-guide"
        addLayoutGuide(g); endGuide = g; return g
    }
    
    private func deactivateSystemConstraints() {
        // ① 停用旧的非宽高约束（排除自定义约束和宽高约束）
        let filterConstraints = constraints.filter { c in
            guard !customConstraints.contains(c) else { return false }
            if c.firstItem === self || c.secondItem === self {
                if c.firstAttribute == .width || c.firstAttribute == .height { return false }
            }
            let involvesContent = c.firstItem === titleLabel  || c.secondItem === titleLabel
                                || c.firstItem === imageView  || c.secondItem === imageView
            if involvesContent {
                if c.firstAttribute  == .width  || c.firstAttribute  == .height ||
                   c.secondAttribute == .width  || c.secondAttribute == .height { return false }
            }
            return true
        }
        NSLayoutConstraint.deactivate(filterConstraints)
    }

    
    func updateAllConstraints() {
        // ② 构建参与布局的 view 数组
        var arr: [UIView] = []
        var key = ""

        if let lab = titleLabel, !lab.isHidden {
            let title = self.title(for: state) ?? ""
            if !title.isEmpty {
                lab.translatesAutoresizingMaskIntoConstraints = false
                arr.append(lab)
                key += "0"
            }
        }
        if let iv = imageView, !iv.isHidden {
            let size = self.image(for: state)?.size ?? .zero
            if size.width > 0 && size.height > 0 {
                iv.translatesAutoresizingMaskIntoConstraints = false
                arr.append(iv)
                key += "1"
            }
        }

        // ③ 排序
        if arr.count == 2 {
            if arr[0] === titleLabel && contentOrder != .titleFirst {
                arr.swapAt(0, 1)
            } else if arr[0] === imageView && contentOrder != .imageFirst {
                arr.swapAt(0, 1)
            }
        }

        // ④ 生成 orderKey，没变化直接返回
        let newKey = generateOrderKey(base: key)
        if orderKey == newKey { return }
        orderKey = newKey

        updateImageSize()
        updateTitleSize()

        // ⑤ 清空旧自定义约束
        NSLayoutConstraint.deactivate(customConstraints)
        customConstraints.removeAll()

        var nextX: NSLayoutXAxisAnchor = leadingAnchor
        var nextY: NSLayoutYAxisAnchor = topAnchor
        let count = arr.count
        let ei = effectiveInsets
        let sp = spacing
        
        

        // 单个子视图时设置最小宽高
        if count == 1 && !translatesAutoresizingMaskIntoConstraints {
            var c = widthAnchor.constraint(greaterThanOrEqualToConstant: max(0, ei.left + ei.right))
            c.priority = kCustomPriority; customConstraints.append(c)
            c = heightAnchor.constraint(greaterThanOrEqualToConstant: max(0, ei.top + ei.bottom))
            c.priority = kCustomPriority; customConstraints.append(c)
        }

        for (i, view) in arr.enumerated() {
            let isTitle = view === titleLabel
            let startSp = isTitle ? titleMarge.start : imageMarge.start
            let endSp   = isTitle ? titleMarge.end   : imageMarge.end

            if axis == .horizontal {
                applyHorizontalMainAxis(
                    view: view, index: i, count: count,
                    nextX: &nextX, insets: ei, space: sp,
                    startSp: startSp, endSp: endSp)
            } else {
                applyVerticalMainAxis(
                    view: view, index: i, count: count,
                    nextY: &nextY, insets: ei, space: sp,
                    startSp: startSp, endSp: endSp)
            }
        }

        // frame 布局时降低优先级
        if super.translatesAutoresizingMaskIntoConstraints {
            customConstraints.forEach { $0.priority = kCustomPriority }
        }
        NSLayoutConstraint.activate(customConstraints)
    }

    // MARK: Horizontal main axis

    func applyHorizontalMainAxis(
        view: UIView, index: Int, count: Int,
        nextX: inout NSLayoutXAxisAnchor,
        insets: UIEdgeInsets, space: CGFloat,
        startSp: CGFloat, endSp: CGFloat)
    {
        var c: NSLayoutConstraint

        // leading
        if index == 0 {
            switch horizontalAlign {
            case .center:
                c = lazyStartGuide().leadingAnchor.constraint(equalTo: nextX)
                customConstraints.append(c)
                nextX = lazyStartGuide().trailingAnchor
                fallthrough
            case .start, .fill:
                c = view.leadingAnchor.constraint(equalTo: nextX, constant: insets.left)
            default:
                c = view.leadingAnchor.constraint(greaterThanOrEqualTo: nextX, constant: insets.left)
            }
            c.identifier = kInsetLeadingId
            customConstraints.append(c)
            nextX = view.trailingAnchor
        } else {
            if flexibleSpacing {
                c = lazyMiddleGuide().leadingAnchor.constraint(equalTo: nextX)
                customConstraints.append(c)
                nextX = lazyMiddleGuide().trailingAnchor
            }
            c = view.leadingAnchor.constraint(equalTo: nextX, constant: space)
            c.identifier = kSpacingId
            customConstraints.append(c)
            nextX = view.trailingAnchor
        }

        // trailing
        if index == count - 1 {
            switch horizontalAlign {
            case .center:
                c = lazyEndGuide().leadingAnchor.constraint(equalTo: nextX)
                customConstraints.append(c)
                nextX = lazyEndGuide().trailingAnchor
                c = lazyStartGuide().widthAnchor.constraint(equalTo: lazyEndGuide().widthAnchor)
                customConstraints.append(c)
                fallthrough
            case .end, .fill:
                c = trailingAnchor.constraint(equalTo: nextX, constant: insets.right)
            default:
                c = trailingAnchor.constraint(greaterThanOrEqualTo: nextX, constant: insets.right)
            }
            c.identifier = kInsetTrailingId
            customConstraints.append(c)
        }

        // cross axis (vertical)
        switch verticalAlign {
        case .start:
            c = view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top + startSp)
            customConstraints.append(c)
            c = view.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -(insets.bottom + endSp))
            customConstraints.append(c)
        case .center:
            c = view.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: insets.top + startSp)
            customConstraints.append(c)
            c = view.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -(insets.bottom + endSp))
            customConstraints.append(c)
            let offsetY = (insets.top - insets.bottom + startSp - endSp) / 2
            c = view.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offsetY)
            customConstraints.append(c)
        case .end:
            c = view.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: insets.top + startSp)
            customConstraints.append(c)
            c = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom + endSp)
            customConstraints.append(c)
        case .fill:
            c = view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top + startSp)
            customConstraints.append(c)
            c = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom + endSp)
            customConstraints.append(c)
        @unknown default:
            break
        }
    }

    // MARK: Vertical main axis

    func applyVerticalMainAxis(
        view: UIView, index: Int, count: Int,
        nextY: inout NSLayoutYAxisAnchor,
        insets: UIEdgeInsets, space: CGFloat,
        startSp: CGFloat, endSp: CGFloat)
    {
        var c: NSLayoutConstraint

        // top
        if index == 0 {
            switch verticalAlign {
            case .center:
                c = lazyStartGuide().topAnchor.constraint(equalTo: nextY)
                customConstraints.append(c)
                nextY = lazyStartGuide().bottomAnchor
                fallthrough
            case .start, .fill:
                c = view.topAnchor.constraint(equalTo: nextY, constant: insets.top)
            default:
                c = view.topAnchor.constraint(greaterThanOrEqualTo: nextY, constant: insets.top)
            }
            c.identifier = kInsetTopId
            customConstraints.append(c)
            nextY = view.bottomAnchor
        } else {
            if flexibleSpacing {
                c = lazyMiddleGuide().topAnchor.constraint(equalTo: nextY)
                customConstraints.append(c)
                nextY = lazyMiddleGuide().bottomAnchor
            }
            c = view.topAnchor.constraint(equalTo: nextY, constant: space)
            c.identifier = kSpacingId
            customConstraints.append(c)
            nextY = view.bottomAnchor
        }

        // bottom
        if index == count - 1 {
            switch verticalAlign {
            case .center:
                c = lazyEndGuide().topAnchor.constraint(equalTo: nextY)
                customConstraints.append(c)
                nextY = lazyEndGuide().bottomAnchor
                c = lazyStartGuide().heightAnchor.constraint(equalTo: lazyEndGuide().heightAnchor)
                customConstraints.append(c)
                fallthrough
            case .end, .fill:
                c = bottomAnchor.constraint(equalTo: nextY, constant: insets.bottom)
            default:
                c = bottomAnchor.constraint(greaterThanOrEqualTo: nextY, constant: insets.bottom)
            }
            c.identifier = kInsetBottomId
            customConstraints.append(c)
        }

        // cross axis (horizontal)
        switch horizontalAlign {
        case .start:
            c = view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left + startSp)
            customConstraints.append(c)
            c = view.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -(insets.right + endSp))
            customConstraints.append(c)
        case .center:
            c = view.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: insets.left + startSp)
            customConstraints.append(c)
            c = trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor, constant: insets.right + endSp)
            customConstraints.append(c)
            let offsetX = (insets.left - insets.right + startSp - endSp) / 2
            c = view.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offsetX)
            customConstraints.append(c)
        case .end:
            c = view.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: insets.left + startSp)
            customConstraints.append(c)
            c = trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: insets.right + endSp)
            customConstraints.append(c)
        case .fill:
            c = view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left + startSp)
            customConstraints.append(c)
            c = trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: insets.right + endSp)
            customConstraints.append(c)
        @unknown default:
            break
        }
    }

    // MARK: Image / Title size

    func updateImageSize() {
        guard let iv = imageView else { return }
        if iv.isHidden {
            if let cons = imgHeighConstraint {
                NSLayoutConstraint.deactivate([cons])
                imgHeighConstraint = nil
            }
            if let cons = imgWidthConstraint {
                NSLayoutConstraint.deactivate([cons])
                imgWidthConstraint = nil
            }
        }else {
            if !CGSizeEqualToSize(imageSize, CGSize(width: -1, height: -1)) {
               let size = imageSize
                if let cons = imgHeighConstraint {
                    cons.constant = size.height
                } else {
                    let c = iv.heightAnchor.constraint(equalToConstant: size.height)
                    c.priority = kCustomPriority
                    c.isActive = true
                    imgHeighConstraint = c
                }
                if let cons = imgWidthConstraint {
                    cons.constant = size.width
                } else {
                    let c = iv.widthAnchor.constraint(equalToConstant: size.width)
                    c.priority = kCustomPriority
                    c.isActive = true
                    imgWidthConstraint = c
                }
            }
            
        }
    }

    func updateTitleSize() {
        guard let lab = titleLabel else { return }
        if lab.isHidden {
            if let cons = labHeighConstraint {
                NSLayoutConstraint.deactivate([cons])
                labHeighConstraint = nil
            }
            if let cons = labWidthConstraint {
                NSLayoutConstraint.deactivate([cons])
                labWidthConstraint = nil
            }
        }else {
            if !CGSizeEqualToSize(titleSize, CGSize(width: -1, height: -1)) {
                let size = titleSize
                if let cons = labHeighConstraint {
                    cons.constant = size.height
                } else {
                    let c = lab.heightAnchor.constraint(equalToConstant: size.height)
                    c.priority = kCustomPriority
                    c.isActive = true
                    labHeighConstraint = c
                }
                if let cons = labWidthConstraint {
                    cons.constant = size.width
                } else {
                    let c = lab.widthAnchor.constraint(equalToConstant: size.width)
                    c.priority = kCustomPriority
                    c.isActive = true
                    labWidthConstraint = c
                }
            }
           
        }
    }

    // MARK: OrderKey

    func generateOrderKey(base: String) -> String {
        var key = base
        key += "\(axis.rawValue)"
        key += "\(verticalAlign.rawValue)"
        key += "\(horizontalAlign.rawValue)"
        key += "\(flexibleSpacing ? 1 : 0)"
        key += NSStringFromCGSize(imageSize)
        let ei = effectiveInsets
        if axis == .horizontal {
            key += "\(ei.top)-\(ei.bottom)"
        } else {
            key += "\(ei.left)-\(ei.right)"
        }
        return key
    }
     func adjustImageViewCompressionAndHugging() {
        guard let iv = imageView else { return }
        let vCompress = iv.contentCompressionResistancePriority(for: .vertical)
        if vCompress != .defaultHigh {
            iv.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        }
        let hCompress = iv.contentCompressionResistancePriority(for: .horizontal)
        if hCompress != .defaultHigh {
            iv.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
        let vHugging = iv.contentHuggingPriority(for: .vertical)
        if vHugging != .defaultHigh {
            iv.setContentHuggingPriority(.defaultHigh, for: .vertical)
        }
        let hHugging = iv.contentHuggingPriority(for: .horizontal)
        if hHugging != .defaultHigh {
            iv.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        }
    }

}
// MARK: - Swift 链式API
public extension Button {
    @discardableResult
    func axis(_ v: ButtonAxis) -> Self {
        self.axis = v
        return self
    }
    @discardableResult
    func contentOrder(_ v: ButtonOrder) -> Self {
        self.contentOrder = v
        return self
    }
    @discardableResult
    func verticalAlign(_ v: ButtonAlign) -> Self {
        self.verticalAlign = v
        return self
    }
    @discardableResult
    func horizontalAlign(_ v: ButtonAlign) -> Self {
        self.horizontalAlign = v
        return self
    }
    @discardableResult
    func spacing(_ v: CGFloat) -> Self {
        self.spacing = v
        return self
    }
    @discardableResult
    func flexibleSpacing(_ v: Bool) -> Self {
        self.flexibleSpacing = v
        return self
    }
    @discardableResult
    func insets(_ v: UIEdgeInsets) -> Self {
        self.insets = v
        return self
    }
    @discardableResult
    func imageSize(_ v: CGSize) -> Self {
        self.imageSize = v
        return self
    }
    @discardableResult
    func titleSize(_ v: CGSize) -> Self {
        self.titleSize = v
        return self
    }
    @discardableResult
    func tapInterval(_ v: CGFloat) -> Self {
        self.tapInterval = v
        return self
    }
    @discardableResult
    func imgTouchOnly(_ v: Bool) -> Self {
        self.imgTouchOnly = v
        return self
    }
    @discardableResult
    func touchAreaEdgeInsets(_ v: UIEdgeInsets) -> Self {
        self.touchAreaEdgeInsets = v
        return self
    }
    
}


// MARK: - ObjC 链式API
public extension Button {

    @objc(setAxis)
    @available(swift, obsoleted: 1, renamed: "axis")
    var axisObjc: (ButtonAxis) -> Button {
        { [weak self] v in self?.axis = v; return self! }
    }
    
    @objc
    var vertical: Button {
        axis = .vertical
        return self
    }
    
    @objc
    var horizontal: Button {
        axis = .horizontal
        return self
    }
   

    @objc(setContentOrder)
    @available(swift, obsoleted: 1, renamed: "contentOrder")
    var contentOrderObjc: (ButtonOrder) -> Button {
        { [weak self] v in self?.contentOrder = v; return self! }
    }

    @objc(setVerticalAlign)
    @available(swift, obsoleted: 1, renamed: "verticalAlign")
    var verticalAlignObjc: (ButtonAlign) -> Button {
        { [weak self] v in self?.verticalAlign = v; return self! }
    }

    @objc(setHorizontalAlign)
    @available(swift, obsoleted: 1, renamed: "horizontalAlign")
    var horizontalAlignObjc: (ButtonAlign) -> Button {
        { [weak self] v in self?.horizontalAlign = v; return self! }
    }

    @objc(setSpacing)
    @available(swift, obsoleted: 1, renamed: "spacing")
    var spacingObjc: (CGFloat) -> Button {
        { [weak self] v in self?.spacing = v; return self! }
    }

    @objc(setFlexibleSpacing)
    @available(swift, obsoleted: 1, renamed: "flexibleSpacing")
    var flexibleSpacingObjc: (Bool) -> Button {
        { [weak self] v in self?.flexibleSpacing = v; return self! }
    }

    @objc(setInsets)
    @available(swift, obsoleted: 1, renamed: "insets")
    var insetsObjc: (UIEdgeInsets) -> Button {
        { [weak self] v in self?.insets = v; return self! }
    }

    @objc(setImageSize)
    @available(swift, obsoleted: 1, renamed: "imageSize")
    var imageSizeObjc: (CGSize) -> Button {
        { [weak self] v in self?.imageSize = v; return self! }
    }

    @objc(setTitleSize)
    @available(swift, obsoleted: 1, renamed: "titleSize")
    var titleSizeObjc: (CGSize) -> Button {
        { [weak self] v in self?.titleSize = v; return self! }
    }

    @objc(setTapInterval)
    @available(swift, obsoleted: 1, renamed: "tapInterval")
    var tapIntervalObjc: (CGFloat) -> Button {
        { [weak self] v in self?.tapInterval = v; return self! }
    }

    @objc(setImgTouchOnly)
    @available(swift, obsoleted: 1, renamed: "imgTouchOnly")
    var imgTouchOnlyObjc: (Bool) -> Button {
        { [weak self] v in self?.imgTouchOnly = v; return self! }
    }

    @objc(setTouchAreaEdgeInsets)
    @available(swift, obsoleted: 1, renamed: "touchAreaEdgeInsets")
    var touchAreaEdgeInsetsObjc: (UIEdgeInsets) -> Button {
        { [weak self] v in self?.touchAreaEdgeInsets = v; return self! }
    }
}


// MARK: - ObjC 样式链式API
public extension Button {
    @objc(gradColors)
    @available(swift, obsoleted: 1, renamed: "gradColors(_:)")
    var gradColorsObjc: (_ colors: [UIColor]?) -> Button {
        { colors in
            self.gradColors(colors)
        }
    }
    
    @objc(gradDirection)
    @available(swift, obsoleted: 1, renamed: "gradDirection(start:end:)")
    var gradDirectionObjc: (_ start: CGPoint, _ end: CGPoint) -> Button {
        { start, end in
            self.gradDirection(start: start, end: end)
        }
    }
    
    @objc(borderColor)
    @available(swift, obsoleted: 1, renamed: "borderColor(_:)")
    var borderColorObjc: (_ color: UIColor?) -> Button {
        { color in
            self.borderColor(color: color)
        }
    }
    
    @objc(borderWidth)
    @available(swift, obsoleted: 1, renamed: "borderWidth(_:)")
    var borderWidthObjc: (_ width: CGFloat) -> Button {
        { width in
            self.borderWidth(w: width)
        }
    }
    
    @objc(border)
    @available(swift, obsoleted: 1, renamed: "border(color:width:)")
    var borderObjc: (_ color: UIColor?, _ width: CGFloat) -> Button {
        { color, width in
            self.border(color: color, w: width)
        }
    }
    @objc(shadowColor)
    @available(swift, obsoleted: 1, renamed: "shadowColor(_:)")
    var shadowColorObjc: (_ color: UIColor?) -> Button {
        { color in
            self.shadowColor(color: color)
        }
    }
    
    @objc(shadowOffset)
    @available(swift, obsoleted: 1, renamed: "shadowOffset(_:_:)")
    var shadowOffsetObjc: (_ width: CGFloat, _ height: CGFloat) -> Button {
        { w, h in
            self.shadowOffset(w: w, h: h)
        }
    }
    
    @objc(shadowRadius)
    @available(swift, obsoleted: 1, renamed: "shadowRadius(_:)")
    var shadowRadiusObjc: (_ radius: CGFloat) -> Button {
        { radius in
            self.shadowRadius(radius: radius)
        }
    }
    
    @objc(shadowOpacity)
    @available(swift, obsoleted: 1, renamed: "shadowOpacity(_:)")
    var shadowOpacityObjc: (_ opacity: Float) -> Button {
        { opacity in
            self.shadowOpacity(opacity: opacity)
        }
    }
    @objc(cornerRadii)
    @available(swift, obsoleted: 1, renamed: "cornerRadii(_:_:_:_:)")
    var cornerRadiiObjc: (_ tl: CGFloat, _ tr: CGFloat, _ bl: CGFloat, _ br: CGFloat) -> Button {
        { tl, tr, bl, br in
            self.cornerRadii(tl, tr, bl, br)
        }
    }
    
    @objc(radius)
    @available(swift, obsoleted: 1, renamed: "radius(_:)")
    var radiusObjc: (_ radius: CGFloat) -> Button {
        { r in
            self.radius(r)
        }
    }
}


