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
//  复用：FlexItem（view.flex 的 flex / margin / spacing / alignSelf / 尺寸）、StackViewBuilder DSL
//  FlexItem 属性变化通过 FlexContainer 协议通知本容器，自动重新布局
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
    /// 自身有固定宽度约束（width == 常量）的 view，fill 模式下不参与 flex 拉伸
    private var fixedWidthViews: Set<ObjectIdentifier> = []
    /// 强制重建约束（增删 view、容器属性、FlexItem 属性、isHidden 变化）
    private var needsRebuild = true
    /// 需要重新分行检查（分行结果不变则不重建）：子 view 尺寸变化、嵌套 Wrap 内容变化
    private var needsLineCheck = true
    /// 上一次分行使用的宽度，宽度不变且无脏标记时跳过 computeLines
    private var lastLineWidth: CGFloat = -1
    /// 上一次布局完成后各子 view 的宽度快照，用于低成本感知内容变化（改文字/字体等）
    private var childWidthSnapshot: [ObjectIdentifier: CGFloat] = [:]
    /// 本次 rebuildIfNeeded 是否真正执行了 computeLines
    private var didComputeLines = false

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
        guard let view = view, allViews.contains(view) else { return }
        view.removeFromSuperview()          // 清理逻辑统一在 willRemoveSubview 中
    }

    @objc open func removeAllArrangedSubviews() {
        allViews.forEach { $0.removeFromSuperview() }
    }

    /// 子 view 离开本容器（removeArrangedSubview / removeFromSuperview / 被加到别的父视图）时统一清理
    open override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        guard let index = allViews.firstIndex(of: subview) else { return }
        allViews.remove(at: index)
        hiddenObservations[ObjectIdentifier(subview)] = nil
        detach(subview)
        setNeedsRelayout()
    }

    /// 标记需要重新分行与布局（下一次布局时统一重建一次，多次调用不会重复重建）。
    /// 子 view 的 view.flex 属性、isHidden、增删 view、容器属性变化都会自动调用，一般无需手动调用；
    /// 只有修改了无法感知的状态（例如直接改子 view 自己的约束 constant）时才需要手动调用
    @objc open func setNeedsRelayout() {
        needsRebuild = true
        setNeedsUpdateConstraints()
        setNeedsLayout()
//        superview?.setNeedsLayout()
    }

    private func attach(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.flex.container = self
        addSubview(view)
        hiddenObservations[ObjectIdentifier(view)] = view.observe(\.isHidden, options: [.old, .new]) { [weak self] _, change in
            guard change.oldValue != change.newValue else { return }
            self?.setNeedsRelayout()
        }
        setNeedsRelayout()
    }

    private func detach(_ view: UIView) {
        if view.flex.container === self { view.flex.container = nil }
    }

    // MARK: - Layout entry

    open override func updateConstraints() {
        rebuildIfNeeded(containerWidth: bounds.width)
        super.updateConstraints()
    }

    open override func layoutSubviews() {
        // ① 有脏标记或宽度变化时才分行（快路径：什么都没变时不调用 computeLines）
        var rebuilt = rebuildIfNeeded(containerWidth: bounds.width)
        let checkedBefore = didComputeLines
        super.layoutSubviews()

        // ② 本轮没分过行，但子 view 实际宽度变了（改文字/字体/嵌套内容变化）→ 补一次分行检查
        if !checkedBefore, childWidthsChanged() {
            needsLineCheck = true
            if rebuildIfNeeded(containerWidth: bounds.width) {
                rebuilt = true
                super.layoutSubviews()
            }
        }
        recordChildWidths()

        // 分行变化会改变自身高度：让父视图重新布局；嵌套在外层 Wrap 中时通知外层重新分行检查
        if rebuilt {
//            superview?.setNeedsLayout()
            (superview as? WrapStackView)?.setNeedsLineCheck()
        }
    }

    open override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                               withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                               verticalFittingPriority: UILayoutPriority) -> CGSize {
        // 指定了宽度的算高（如 cell 自动算高）：先按目标宽度分行。
        // cell 复用时只改了文字不会有任何脏标记，所以这里始终做一次分行检查
        if targetSize.width > 0, targetSize.width < UIView.layoutFittingExpandedSize.width {
            needsLineCheck = true
            rebuildIfNeeded(containerWidth: targetSize.width)
        }
        return super.systemLayoutSizeFitting(targetSize,
                                             withHorizontalFittingPriority: horizontalFittingPriority,
                                             verticalFittingPriority: verticalFittingPriority)
    }

    /// 只标记"需要分行检查"：分行结果不变时不重建约束
    fileprivate func setNeedsLineCheck() {
        needsLineCheck = true
        setNeedsLayout()
    }

    // MARK: - Child size tracking

    private func childWidthsChanged() -> Bool {
        let views = arrangedViews
        guard views.count == childWidthSnapshot.count else { return true }
        for v in views {
            guard let old = childWidthSnapshot[ObjectIdentifier(v)],
                  abs(old - v.bounds.width) < 0.5 else { return true }
        }
        return false
    }

    private func recordChildWidths() {
        childWidthSnapshot.removeAll(keepingCapacity: true)
        for v in arrangedViews { childWidthSnapshot[ObjectIdentifier(v)] = v.bounds.width }
    }

    // MARK: - Rebuild

    /// - Returns: 是否重建了约束
    @discardableResult
    private func rebuildIfNeeded(containerWidth: CGFloat) -> Bool {
        didComputeLines = false
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

        // 快路径：没有任何脏标记且宽度没变，分行结果不可能变化，直接跳过
        guard needsRebuild || needsLineCheck || abs(width - lastLineWidth) >= 0.5 else { return false }
        lastLineWidth = width
        needsLineCheck = false
        didComputeLines = true

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
        fixedWidthViews.removeAll(keepingCapacity: true)
        var lines: [[UIView]] = []
        var current: [UIView] = []
        var used: CGFloat = 0

        for view in arrangedViews {
            let m = view.flex.margin
            let base = measureWidth(of: view)
            let w = base + m.leading + m.trailing

            // 独占一行：结束当前行，自己单独成一行，后面的 view 从新行开始
            if view.flex.exclusiveLine {
                if !current.isEmpty { lines.append(current) }
                lines.append([view])
                current = []
                used = 0
                continue
            }

            if let prev = current.last {
                let gap = minGap(after: prev)
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
            fixedWidthViews.insert(ObjectIdentifier(view))
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

    /// view 后面的间距类型
    private enum Gap {
        /// 固定间距（spacing / 数字 / Spacer(值)）
        case fixed(CGFloat)
        /// 弹性间距（minSpacing / maxSpacing）：min ≤ 间距 ≤ max，平时取 preferred，空间不足时压缩、需要撑满时拉伸
        case elastic(min: CGFloat, max: CGFloat?, preferred: CGFloat)
        /// 纯弹性空白（Spacer() / isFlexibleSpace）：占满剩余空间，同一行多个时等宽
        case flexible(min: CGFloat)
    }

    private func gap(after view: UIView) -> Gap {
        let f = view.flex
        let minV = max(0, f._minSpacing)
        let maxV: CGFloat? = f._maxSpacing > 0 ? max(f._maxSpacing, minV) : nil
        if f.isFlexibleSpace { return .flexible(min: minV) }
        if f._minSpacing > 0 || f._maxSpacing > 0 {
            let preferred = min(max(spacing(after: view), minV), maxV ?? .greatestFiniteMagnitude)
            return .elastic(min: minV, max: maxV, preferred: preferred)
        }
        return .fixed(spacing(after: view))
    }

    /// 分行测量使用的最小间距（弹性间距按下限计算，放得下时再由约束拉伸）
    private func minGap(after view: UIView) -> CGFloat {
        switch gap(after: view) {
        case .fixed(let v):            return v
        case .elastic(let m, _, _):    return m
        case .flexible(let m):         return m
        }
    }

    /// 单独设置了 alignSelf 用它，否则跟随容器 alignment
    private func crossAlign(of view: UIView) -> FlexItemCrossAlign {
        view.flex.explicitAlignSelf ?? alignment
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

        // 与 CSS flex-grow 一致：本行有 flex > 0（且无固定宽度）的 view 时，剩余空间全部按权重分给它们，
        // 此时 justifyContent 的分布方式不再起作用（等价于 fill）；fillEqually 忽略 flex，保持行内等宽
        let flexViews = justifyContent == .fillEqually ? [] :
            views.filter { $0.flex.flex > 0 && !fixedWidthViews.contains(ObjectIdentifier($0)) }

        // 本行各 view 之间的间距类型（最后一个 view 后面的间距不在本行内，不参与）
        let gaps: [Gap] = (0..<max(0, count - 1)).map { gap(after: views[$0]) }
        let hasFlexibleGap = gaps.contains { if case .flexible = $0 { return true }; return false }
        let hasElasticGap  = gaps.contains { if case .elastic = $0 { return true }; return false }
        /// 可无上限拉伸的弹性间距（只有 minSpacing）：fill 模式下由它撑满整行
        let hasStretchableGap = gaps.contains { if case .elastic(_, nil, _) = $0 { return true }; return false }
        let spaceModes: [Justify] = [.spaceBetween, .spaceAround, .spaceEvenly]

        var justify: Justify = justifyContent
        if !flexViews.isEmpty {
            justify = .fill                                   // flex view 吃掉剩余空间
        } else if hasFlexibleGap, justify != .fillEqually {
            justify = .fill                                   // Spacer() 吃掉剩余空间
        } else if hasElasticGap, spaceModes.contains(justify) {
            // space 模式下有弹性间距：between 两端贴边由弹性间距撑满；around / evenly 居中
            justify = justify == .spaceBetween ? .fill : .center
        }

        let isSpaceMode = spaceModes.contains(justify) && count > 1
        var firstGap: UILayoutGuide?

        // 弹性间距的"首选值"优先级：低于 UILabel hugging(250) → 需要撑满时间距先拉伸、内容不被拉伸；
        // 行内有 flex view 时要高于 flex view 的 hugging(249) → 剩余空间优先给 flex view
        let preferPriority = UILayoutPriority(flexViews.isEmpty ? 240 : 260)
        // 多个弹性间距：相对首选值的拉伸 / 压缩量相等（优先级略高于首选值，保证均匀变化；触到上下限的不再跟随）
        let evenStretchPriority = UILayoutPriority(preferPriority.rawValue + 5)
        var elasticGaps: [(guide: UILayoutGuide, preferred: CGFloat)] = []
        var flexibleGaps: [UILayoutGuide] = []

        /// 连接 prev 与 view 的间距 guide
        func gapGuide(_ prev: UIView, _ pm: NSDirectionalEdgeInsets,
                      _ view: UIView, _ m: NSDirectionalEdgeInsets) -> UILayoutGuide {
            let g = hGuide()
            cons.append(g.leadingAnchor.constraint(equalTo: prev.trailingAnchor, constant: pm.trailing))
            cons.append(g.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: -m.leading))
            return g
        }

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
            let gapValue = spacing(after: prev)
            if isSpaceMode {
                let sg = gapGuide(prev, pm, view, m)
                cons.append(sg.widthAnchor.constraint(greaterThanOrEqualToConstant: gapValue))
                if let fg = firstGap {
                    cons.append(sg.widthAnchor.constraint(equalTo: fg.widthAnchor))
                } else {
                    firstGap = sg
                }
                continue
            }

            switch gaps[i - 1] {
            case .fixed(let v):
                cons.append(view.leadingAnchor.constraint(equalTo: prev.trailingAnchor,
                                                          constant: pm.trailing + v + m.leading))
            case let .elastic(minV, maxV, preferred):
                let sg = gapGuide(prev, pm, view, m)
                cons.append(sg.widthAnchor.constraint(greaterThanOrEqualToConstant: minV))
                if let maxV = maxV {
                    cons.append(sg.widthAnchor.constraint(lessThanOrEqualToConstant: maxV))
                }
                elasticGaps.append((sg, preferred))
                let prefer = sg.widthAnchor.constraint(equalToConstant: preferred)
                prefer.priority = preferPriority
                cons.append(prefer)
            case .flexible(let minV):
                let sg = gapGuide(prev, pm, view, m)
                cons.append(sg.widthAnchor.constraint(greaterThanOrEqualToConstant: minV))
                flexibleGaps.append(sg)
            }
        }

        // Spacer()：同一行多个时等宽
        if let f0 = flexibleGaps.first {
            flexibleGaps.dropFirst().forEach { cons.append($0.widthAnchor.constraint(equalTo: f0.widthAnchor)) }
            // 有 flex view / fillEqually 时剩余空间归 view，Spacer 收缩到最小
            if !flexViews.isEmpty || justify == .fillEqually {
                let collapse = f0.widthAnchor.constraint(equalToConstant: 0)
                collapse.priority = UILayoutPriority(500)
                cons.append(collapse)
            }
        }
        // 弹性间距：width_i - preferred_i == width_0 - preferred_0
        if let s0 = elasticGaps.first {
            for s in elasticGaps.dropFirst() {
                let c = s.guide.widthAnchor.constraint(equalTo: s0.guide.widthAnchor, constant: s.preferred - s0.preferred)
                c.priority = evenStretchPriority
                cons.append(c)
            }
        }

        let zeroLead  = lead.widthAnchor.constraint(equalToConstant: 0)
        let zeroTrail = trail.widthAnchor.constraint(equalToConstant: 0)
        let centered  = lead.widthAnchor.constraint(equalTo: trail.widthAnchor)

        switch justify {
        case .start:
            cons.append(zeroLead)
        case .end:
            cons.append(zeroTrail)
        case .center:
            cons.append(centered)
        case .fill:
            cons.append(zeroLead)
            // 有可无限伸展的东西（flex view / Spacer / 只有下限的弹性间距）时撑满整行；
            // 只有 maxSpacing 这类有上限的间距时不强制撑满，避免拉伸 view 本身；
            // 有固定宽度的 view 即使设置了 flex 也不拉伸（固定宽度优先），避免与撑满整行冲突
            if !flexViews.isEmpty || hasFlexibleGap || hasStretchableGap {
                cons.append(zeroTrail)
            }
            if !flexViews.isEmpty {
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

    /// DSL 追加子 view。支持 UIView / FlexItem / 可选 / if / for-in；以下写法作用于前一个 view 后面的间距：
    /// - 数字 / Spacer(值)：固定间距
    /// - 3.minSpacing / Spacer(min:)：最小间距（可拉伸，空间不足时压缩到最小值）
    /// - 3.maxSpacing / Spacer(max:)：最大间距（可压缩到 0，最多拉伸到最大值）
    /// - Spacer()：纯弹性空白，占满本行剩余空间，同一行多个时等宽
    /// 写在第一个 view 之前的间距没有作用对象，会被忽略
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
            } else if let spacer = component as? Spacer {
                switch spacer {
                case .normal:          allViews.last?.flex.isFlexibleSpace = true
                case .min(let v):      allViews.last?.flex.minSpacing = CGFloat(v)
                case .max(let v):      allViews.last?.flex.maxSpacing = CGFloat(v)
                case .value(let v):    allViews.last?.flex.spacing = CGFloat(v)
                }
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

// MARK: - 独占一行

extension WrapStackView {
    /// 设置某个子 view 是否独占一行（等价于 view.flex.exclusiveLine = exclusive，自动重新布局）
    @objc(setExclusiveLine:forView:)
    open func setExclusiveLine(_ exclusive: Bool, for view: UIView?) {
        guard let view = view, allViews.contains(view) else { return }
        view.flex.exclusiveLine = exclusive
    }

    /// 是否独占一行
    @objc(isExclusiveLineForView:)
    open func isExclusiveLine(for view: UIView) -> Bool {
        view.flex.exclusiveLine
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

// MARK: - FlexContainer

extension WrapStackView: FlexContainer {
    /// 子 view 的 FlexItem 属性变化 → 标记重新布局（同一 runloop 内多次修改只重建一次）
    public func flexItemDidChange(_ item: FlexItem) {
        setNeedsRelayout()
    }

    public var flexDefaultAlignment: FlexItemCrossAlign { alignment }

    public var flexDefaultSpacing: CGFloat { max(0, spacing) }
}
