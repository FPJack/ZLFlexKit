//
//  WrapStackView.swift
//  ZLFlexKit
//
//  自动换行的弹性布局容器（水平主轴，放不下自动换到下一行）
//
//  实现思路（方案 A）：
//  1. 代码中按容器可用宽度对子 view 分行（Auto Layout 无法表达"放不下就换行"）
//  2. 每一行用一个 UILayoutGuide 作为行容器（不产生额外 UIView）
//  3. 行内按 justifyContent / alignment / flex / margin / spacing 生成约束
//  4. layoutSubviews 中宽度变化导致分行结果变化时，才重建约束
//
//  复用：FlexItem（view.flex 的 flex / margin / spacing / alignSelf）、StackViewBuilder DSL
//  不继承 StackView：StackView.updateConstraints 会驱动 FlexManager 生成整套单行约束，与换行约束冲突
//

import UIKit

@objc(ZLWrapStackView)
open class WrapStackView: UIView {

    // MARK: - Public properties

    /// 每一行内的主轴分布，默认 .start
    @objc public var justifyContent: Justify = .start {
        didSet { if oldValue != justifyContent { setNeedsRelayout() } }
    }

    /// 行内交叉轴对齐，默认 .center（单个 view 可用 view.flex.alignSelf 覆盖）
    @objc public var alignment: FlexItemCrossAlign = .center {
        didSet { if oldValue != alignment { setNeedsRelayout() } }
    }

    /// 同一行内 view 之间的默认间距（view.flex.spacing > 0 时以单个 view 为准）
    @objc public var spacing: CGFloat = 0 {
        didSet { if oldValue != spacing { setNeedsRelayout() } }
    }

    /// 行与行之间的间距
    @objc public var lineSpacing: CGFloat = 0 {
        didSet { if oldValue != lineSpacing { setNeedsRelayout() } }
    }

    /// 内边距
    @objc public var insets: NSDirectionalEdgeInsets = .zero {
        didSet { if oldValue != insets { setNeedsRelayout() } }
    }

    /// 布局前就需要确定分行时使用的宽度（例如 cell 自动算高）。
    /// 容器 bounds.width > 0 时以 bounds 为准，否则使用该值；默认 0 表示不使用
    @objc public var preferredMaxLayoutWidth: CGFloat = 0 {
        didSet { if oldValue != preferredMaxLayoutWidth { setNeedsRelayout() } }
    }

    /// 是否自动换行，默认 true。false 时所有 view 排在同一行，放不下时按抗压缩优先级压缩
    @objc public var isWrapEnabled: Bool = true {
        didSet { if oldValue != isWrapEnabled { setNeedsRelayout() } }
    }

    /// 行数变化回调（重建约束后调用）
    public var linesDidChange: ((_ numberOfLines: Int) -> Void)?

    /// 参与布局的 view（不含隐藏的）
    @objc public var arrangedViews: [UIView] { allViews.filter { !$0.isHidden } }

    /// 所有添加的 view（含隐藏的）
    @objc public var allArrangedViews: [UIView] { allViews }

    /// 当前行数
    @objc public var numberOfLines: Int { lastSignature.filter { !$0.isEmpty }.count }

    // MARK: - Private state

    private var allViews: [UIView] = []
    private var hiddenObservations: [ObjectIdentifier: NSKeyValueObservation] = [:]
    private var installedConstraints: [NSLayoutConstraint] = []
    private var installedGuides: [UILayoutGuide] = []
    private var lastSignature: [[ObjectIdentifier]] = []
    private var measuredWidths: [ObjectIdentifier: CGFloat] = [:]
    private var needsRebuild = true

    /// 行高收紧优先级：略高于 UILabel 默认 hugging(250)，低于 compression(750)
    private let lineHugPriority = UILayoutPriority(260)

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// DSL 构造
    public convenience init(justify: Justify? = nil,
                            align: FlexItemCrossAlign? = nil,
                            spacing: CGFloat? = nil,
                            lineSpacing: CGFloat? = nil,
                            insets: EdgeInsets? = nil,
                            @StackViewBuilder builder: () -> [StackViewDSL]) {
        self.init(frame: .zero)
        if let justify = justify { justifyContent = justify }
        if let align = align { alignment = align }
        if let spacing = spacing { self.spacing = spacing }
        if let lineSpacing = lineSpacing { self.lineSpacing = lineSpacing }
        if let insets = insets { self.insets = insets.directionalEdgeInsets }
        addViews(with: builder)
    }

    // MARK: - Arranged views

    @objc open func addArrangedSubview(_ view: UIView?) {
        guard let view = view, !allViews.contains(view) else { return }
        allViews.append(view)
        attach(view)
    }

    @objc open func insertArrangedSubview(_ view: UIView?, at index: Int) {
        guard let view = view, !allViews.contains(view) else { return }
        allViews.insert(view, at: max(0, min(index, allViews.count)))
        attach(view)
    }

    @objc open func removeArrangedSubview(_ view: UIView?) {
        guard let view = view, let index = allViews.firstIndex(of: view) else { return }
        allViews.remove(at: index)
        hiddenObservations[ObjectIdentifier(view)] = nil
        view.removeFromSuperview()
        setNeedsRelayout()
    }

    @objc open func removeAllArrangedSubviews() {
        allViews.forEach { $0.removeFromSuperview() }
        allViews.removeAll()
        hiddenObservations.removeAll()
        setNeedsRelayout()
    }

    /// 修改了子 view 的 flex 配置（flex / margin / spacing / alignSelf）或尺寸后调用，强制重新分行与布局。
    /// 注意：FlexItem 的修改只会自动通知 StackView，WrapStackView 需要手动调用本方法
    @objc open func setNeedsRelayout() {
        needsRebuild = true
        setNeedsUpdateConstraints()
        setNeedsLayout()
        superview?.setNeedsLayout()
    }

    private func attach(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        hiddenObservations[ObjectIdentifier(view)] = view.observe(\.isHidden, options: [.old, .new]) { [weak self] _, change in
            guard change.oldValue != change.newValue else { return }
            self?.setNeedsRelayout()
        }
        setNeedsRelayout()
    }

    // MARK: - Layout entry

    open override func updateConstraints() {
        rebuildIfNeeded(containerWidth: bounds.width)
        super.updateConstraints()
    }

    open override func layoutSubviews() {
        // 宽度变化 → 分行结果变化 → 重建约束，并让父视图重新布局以更新自身高度
        if rebuildIfNeeded(containerWidth: bounds.width) {
            superview?.setNeedsLayout()
        }
        super.layoutSubviews()
    }

    open override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                               withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                               verticalFittingPriority: UILayoutPriority) -> CGSize {
        // 指定了宽度的算高（如 cell 自动算高）：先按目标宽度分行
        if targetSize.width > 0, targetSize.width < UIView.layoutFittingExpandedSize.width {
            rebuildIfNeeded(containerWidth: targetSize.width)
        }
        return super.systemLayoutSizeFitting(targetSize,
                                             withHorizontalFittingPriority: horizontalFittingPriority,
                                             verticalFittingPriority: verticalFittingPriority)
    }

    // MARK: - Rebuild

    /// - Returns: 是否重建了约束
    @discardableResult
    private func rebuildIfNeeded(containerWidth: CGFloat) -> Bool {
        let width = containerWidth > 0 ? containerWidth : preferredMaxLayoutWidth
        guard width > 0 else {
            // 宽度未知：不分行，只放一个低优先级高度占位，等拿到宽度再布局
            if needsRebuild, installedConstraints.isEmpty {
                let c = heightAnchor.constraint(equalToConstant: insets.top + insets.bottom)
                c.priority = .defaultLow
                c.isActive = true
                installedConstraints = [c]
            }
            return false
        }

        let available = isWrapEnabled
            ? max(0, width - insets.leading - insets.trailing)
            : .greatestFiniteMagnitude
        let lines = computeLines(maxWidth: available)
        let signature = lines.map { $0.map(ObjectIdentifier.init) }
        guard needsRebuild || signature != lastSignature else { return false }

        let linesChanged = signature.count != lastSignature.count
        needsRebuild = false
        lastSignature = signature
        removeInstalled()
        build(lines: lines)
        if linesChanged { linesDidChange?(signature.count) }
        return true
    }

    private func removeInstalled() {
        NSLayoutConstraint.deactivate(installedConstraints)
        installedConstraints.removeAll()
        installedGuides.forEach { removeLayoutGuide($0) }
        installedGuides.removeAll()
    }

    private func makeGuide() -> UILayoutGuide {
        let g = UILayoutGuide()
        addLayoutGuide(g)
        installedGuides.append(g)
        return g
    }

    // MARK: - Line breaking

    private func computeLines(maxWidth: CGFloat) -> [[UIView]] {
        measuredWidths.removeAll(keepingCapacity: true)
        var lines: [[UIView]] = []
        var current: [UIView] = []
        var used: CGFloat = 0

        for view in arrangedViews {
            let m = view.flex.margin
            let base = measureWidth(of: view)
            measuredWidths[ObjectIdentifier(view)] = base
            let w = base + m.leading + m.trailing

            if let prev = current.last {
                let gap = spacing(after: prev)
                if used + gap + w > maxWidth + 0.5 {
                    lines.append(current)
                    current = [view]
                    used = w
                } else {
                    current.append(view)
                    used += gap + w
                }
            } else {
                current = [view]
                used = w
            }
        }
        if !current.isEmpty { lines.append(current) }
        return lines
    }

    /// 测量子 view 在主轴上的基准宽度（只看自身约束 / 内容尺寸，不受换行约束影响）
    private func measureWidth(of view: UIView) -> CGFloat {
        // 让 view.box / view.flex.width 暂存的约束先生效
        view.updateConstraintsIfNeeded()

        var fixed: CGFloat?
        var minW: CGFloat = 0
        var maxW = CGFloat.greatestFiniteMagnitude
        for c in view.constraints where c.isActive
            && !WrapStackView.isContentSizeConstraint(c)
            && c.firstItem === view && c.secondItem == nil
            && c.firstAttribute == .width
            && c.priority.rawValue >= UILayoutPriority.defaultHigh.rawValue {
            switch c.relation {
            case .equal:              fixed = c.constant
            case .greaterThanOrEqual: minW = max(minW, c.constant)
            case .lessThanOrEqual:    maxW = min(maxW, c.constant)
            @unknown default:         break
            }
        }

        let width: CGFloat
        if let fixed = fixed {
            width = fixed
        } else if let nested = view as? WrapStackView {
            // 嵌套的 WrapStackView 本身可以换行：按最小内容宽度（最宽的单个子 view）参与分行
            width = nested.minContentWidth
        } else if view.intrinsicContentSize.width > 0 {
            width = view.intrinsicContentSize.width
        } else {
            width = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width
        }
        return min(max(width, minW), maxW)
    }

    /// 系统根据 intrinsicContentSize 生成的约束（NSContentSizeLayoutConstraint）不是用户设置的固定宽度。
    /// 例如 StackView.intrinsicContentSize 返回 .zero 时会生成 width == 0 的内容尺寸约束，必须跳过
    private static func isContentSizeConstraint(_ c: NSLayoutConstraint) -> Bool {
        NSStringFromClass(type(of: c)).contains("ContentSize")
    }

    /// 最小内容宽度：内边距 + 最宽的单个子 view（含 margin）。作为子 view 嵌套时用于分行测量
    @objc public var minContentWidth: CGFloat {
        let widest = arrangedViews.map { v -> CGFloat in
            let m = v.flex.margin
            return measureWidth(of: v) + m.leading + m.trailing
        }.max() ?? 0
        return insets.leading + insets.trailing + widest
    }

    private func spacing(after view: UIView) -> CGFloat {
        let s = view.flex._spacing
        return s > 0 ? s : max(0, spacing)
    }

    /// FlexItem 未设置 alignSelf 时返回 nil（跟随容器 alignment）
    private func crossAlign(of view: UIView) -> FlexItemCrossAlign {
        let explicit = Mirror(reflecting: view.flex).children
            .first { $0.label == "_alignSelf" }?.value as? FlexItemCrossAlign
        return explicit ?? alignment
    }

    // MARK: - Build constraints

    private func build(lines: [[UIView]]) {
        var cons: [NSLayoutConstraint] = []

        guard !lines.isEmpty else {
            let c = heightAnchor.constraint(equalToConstant: insets.top + insets.bottom)
            c.priority = .defaultLow
            cons.append(c)
            NSLayoutConstraint.activate(cons)
            installedConstraints = cons
            return
        }

        var prevLine: UILayoutGuide?
        for (index, line) in lines.enumerated() {
            let g = makeGuide()
            cons.append(g.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.leading))
            cons.append(g.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.trailing))
            if let prev = prevLine {
                cons.append(g.topAnchor.constraint(equalTo: prev.bottomAnchor, constant: lineSpacing))
            } else {
                cons.append(g.topAnchor.constraint(equalTo: topAnchor, constant: insets.top))
            }
            if index == lines.count - 1 {
                cons.append(g.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom))
            }
            // 行高收紧到本行最高的 view
            let hug = g.heightAnchor.constraint(equalToConstant: 0)
            hug.priority = lineHugPriority
            cons.append(hug)

            layoutLine(line, in: g, cons: &cons)
            prevLine = g
        }

        NSLayoutConstraint.activate(cons)
        installedConstraints = cons
    }

    private func layoutLine(_ views: [UIView], in line: UILayoutGuide, cons: inout [NSLayoutConstraint]) {
        guard let first = views.first, let last = views.last else { return }
        let count = views.count

        /// 只占水平方向的辅助 guide，垂直方向固定避免歧义
        func hGuide() -> UILayoutGuide {
            let g = makeGuide()
            cons.append(g.topAnchor.constraint(equalTo: line.topAnchor))
            cons.append(g.heightAnchor.constraint(equalToConstant: 0))
            cons.append(g.widthAnchor.constraint(greaterThanOrEqualToConstant: 0))
            return g
        }

        let lead = hGuide()
        let trail = hGuide()
        cons.append(lead.leadingAnchor.constraint(equalTo: line.leadingAnchor))
        cons.append(lead.trailingAnchor.constraint(equalTo: first.leadingAnchor, constant: -first.flex.margin.leading))
        cons.append(trail.leadingAnchor.constraint(equalTo: last.trailingAnchor, constant: last.flex.margin.trailing))
        cons.append(trail.trailingAnchor.constraint(equalTo: line.trailingAnchor))

        let isSpaceMode = [.spaceBetween, .spaceAround, .spaceEvenly].contains(justifyContent) && count > 1
        var firstGap: UILayoutGuide?

        for (i, view) in views.enumerated() {
            let m = view.flex.margin

            // 单个 view 最宽不超过一行（固定宽度更大时让步，允许溢出）
            let cap = view.widthAnchor.constraint(lessThanOrEqualTo: line.widthAnchor, constant: -(m.leading + m.trailing))
            cap.priority = UILayoutPriority(999)
            cons.append(cap)

            addCrossAxis(view, margin: m, in: line, cons: &cons)

            guard i > 0 else { continue }
            let prev = views[i - 1]
            let pm = prev.flex.margin
            let gap = spacing(after: prev)
            if isSpaceMode {
                let sg = hGuide()
                cons.append(sg.leadingAnchor.constraint(equalTo: prev.trailingAnchor, constant: pm.trailing))
                cons.append(sg.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: -m.leading))
                cons.append(sg.widthAnchor.constraint(greaterThanOrEqualToConstant: gap))
                if let fg = firstGap {
                    cons.append(sg.widthAnchor.constraint(equalTo: fg.widthAnchor))
                } else {
                    firstGap = sg
                }
            } else {
                cons.append(view.leadingAnchor.constraint(equalTo: prev.trailingAnchor,
                                                          constant: pm.trailing + gap + m.leading))
            }
        }

        let zeroLead  = lead.widthAnchor.constraint(equalToConstant: 0)
        let zeroTrail = trail.widthAnchor.constraint(equalToConstant: 0)
        let centered  = lead.widthAnchor.constraint(equalTo: trail.widthAnchor)

        switch justifyContent {
        case .start:
            cons.append(zeroLead)
        case .end:
            cons.append(zeroTrail)
        case .center:
            cons.append(centered)
        case .fill:
            cons.append(zeroLead)
            let flexViews = views.filter { $0.flex.flex > 0 }
            if !flexViews.isEmpty {
                cons.append(zeroTrail)
                addFlexGrow(flexViews, cons: &cons)
            }
        case .fillEqually:
            cons.append(zeroLead)
            cons.append(zeroTrail)
            views.dropFirst().forEach { cons.append($0.widthAnchor.constraint(equalTo: first.widthAnchor)) }
        case .spaceBetween:
            cons.append(zeroLead)
            if count > 1 { cons.append(zeroTrail) }
        case .spaceAround:
            cons.append(centered)
            if let fg = firstGap {
                cons.append(lead.widthAnchor.constraint(equalTo: fg.widthAnchor, multiplier: 0.5))
            }
        case .spaceEvenly:
            cons.append(centered)
            if let fg = firstGap {
                cons.append(lead.widthAnchor.constraint(equalTo: fg.widthAnchor))
            }
        }
    }

    /// flex 权重：flex view 宽度按 flex 比例分配剩余空间（与 StackView 的 applyFlexWeights 一致）
    /// - 不把测量宽度写进约束常量：内容变长/变短都由约束系统响应，frame 变化后自动触发重新分行
    /// - flex view 的 hugging / 抗压缩略低于默认值：剩余空间只给 flex view，空间不足时优先压缩 flex view
    private func addFlexGrow(_ views: [UIView], cons: inout [NSLayoutConstraint]) {
        guard let v0 = views.first else { return }
        let f0 = CGFloat(v0.flex.flex)
        let hugging     = UILayoutPriority(UILayoutPriority.defaultLow.rawValue - 1)
        let compression = UILayoutPriority(UILayoutPriority.defaultHigh.rawValue - 1)
        for v in views {
            v.setContentHuggingPriority(hugging, for: .horizontal)
            v.setContentCompressionResistancePriority(compression, for: .horizontal)
            guard v !== v0 else { continue }
            cons.append(v.widthAnchor.constraint(equalTo: v0.widthAnchor, multiplier: CGFloat(v.flex.flex) / f0))
        }
    }

    private func addCrossAxis(_ view: UIView, margin m: NSDirectionalEdgeInsets,
                              in line: UILayoutGuide, cons: inout [NSLayoutConstraint]) {
        let top = view.topAnchor
        let bottom = view.bottomAnchor
        switch crossAlign(of: view) {
        case .start:
            cons.append(top.constraint(equalTo: line.topAnchor, constant: m.top))
            cons.append(bottom.constraint(lessThanOrEqualTo: line.bottomAnchor, constant: -m.bottom))
        case .end:
            cons.append(top.constraint(greaterThanOrEqualTo: line.topAnchor, constant: m.top))
            cons.append(bottom.constraint(equalTo: line.bottomAnchor, constant: -m.bottom))
        case .fill:
            cons.append(top.constraint(equalTo: line.topAnchor, constant: m.top))
            cons.append(bottom.constraint(equalTo: line.bottomAnchor, constant: -m.bottom))
        case .center:
            cons.append(top.constraint(greaterThanOrEqualTo: line.topAnchor, constant: m.top))
            cons.append(bottom.constraint(lessThanOrEqualTo: line.bottomAnchor, constant: -m.bottom))
            cons.append(view.centerYAnchor.constraint(equalTo: line.centerYAnchor, constant: (m.top - m.bottom) / 2))
        }
    }
}

// MARK: - DSL

extension WrapStackView {

    /// DSL 追加子 view。支持 UIView / FlexItem / 可选 / if / for-in；
    /// 数字 = 设置前一个 view 后面的间距；Spacer 只支持 Spacer(值)，其余忽略
    @discardableResult
    public func addViews(@StackViewBuilder builder: () -> [StackViewDSL]) -> Self {
        addViews(with: builder)
        return self
    }

    func addViews(with builder: () -> [StackViewDSL]) {
        for component in builder() {
            if let view = component.getDslView() {
                addArrangedSubview(view)
            } else if let item = component as? FlexItem {
                addArrangedSubview(item.view)
            } else if let v = component as? Int {
                allViews.last?.flex.spacing = CGFloat(v)
            } else if let v = component as? Double {
                allViews.last?.flex.spacing = CGFloat(v)
            } else if let v = component as? Float {
                allViews.last?.flex.spacing = CGFloat(v)
            } else if let spacer = component as? Spacer, case .value(let v) = spacer {
                allViews.last?.flex.spacing = CGFloat(v)
            }
        }
        setNeedsRelayout()
    }

    /// 链式添加单个 view / FlexItem
    @discardableResult
    public func addView(_ item: FlexType?) -> Self {
        addArrangedSubview(item?.baseView)
        return self
    }
}

// MARK: - 链式配置（方法名避开同名属性）

extension WrapStackView {
    @discardableResult public func justify(_ v: Justify) -> Self { justifyContent = v; return self }
    @discardableResult public func align(_ v: FlexItemCrossAlign) -> Self { alignment = v; return self }
    @discardableResult public func gap(_ v: NumberConvertible) -> Self { spacing = v.cgFloat; return self }
    @discardableResult public func lineGap(_ v: NumberConvertible) -> Self { lineSpacing = v.cgFloat; return self }
    @discardableResult public func insets(_ v: EdgeInsets) -> Self { insets = v.directionalEdgeInsets; return self }
    @discardableResult public func wrap(_ v: Bool) -> Self { isWrapEnabled = v; return self }
    @discardableResult public func maxLayoutWidth(_ v: NumberConvertible) -> Self { preferredMaxLayoutWidth = v.cgFloat; return self }
}
