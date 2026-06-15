//
//  FlexKitDemoViewController.swift
//  ZLFlexKit_Example
//
//  Demo: 全面展示 ZLFlexKit 弹性布局的所有功能
//

import UIKit
import ZLFlexKit
import SnapKit

// MARK: - 兼容色（替换 iOS 13+ 专属颜色）
class CustomLabel: UILabel {
    
}
private extension UIColor {
    static var compatBackground: UIColor { .white }
    static var compatGray5: UIColor      { UIColor(white: 0.92, alpha: 1) }
}

// MARK: - 入口：Demo 列表

class FlexKitDemoViewController: UITableViewController {

    private let demos: [(title: String, subtitle: String, vc: () -> UIViewController)] = [
        ("① justifyContent - 水平主轴分布",   "start / center / end / spaceBetween / spaceAround / spaceEvenly", { JustifyDemoVC() }),
        ("② justifyContent - fill / fillEqually", "fill 弹性填充 & fillEqually 等宽",  { FillDemoVC() }),
        ("③ alignment - 交叉轴对齐",           "start / center / end / fill",         { AlignmentDemoVC() }),
        ("④ alignSelf - 单个 view 覆盖对齐",   "每个子 view 可独立设置对齐方式",      { AlignSelfDemoVC() }),
        ("⑤ flexValue - 弹性比例权重",         "类似 CSS flex-grow，按比例分配空间",  { FlexValueDemoVC() }),
        ("⑥ isFlexibleSpace - 弹性间距",       "在 fill/fillEqually 模式下插入弹性空白", { FlexSpaceDemoVC() }),
        ("⑦ spacing / minSpacing / maxSpacing", "固定/最小/最大间距，可动态修改",      { SpacingDemoVC() }),
        ("⑧ startMarge / endMarge",             "单个 view 的交叉轴偏移",              { MargeDemoVC() }),
        ("⑨ insets - 内边距",                   "stackView 整体 padding",              { InsetsDemoVC() }),
        ("⑩ 垂直 Axis",                         "axis = .vertical 纵向弹性布局",       { VerticalDemoVC() }),
        ("⑪ 动态增删 view",                     "运行时 add / remove，自动重新布局",   { DynamicDemoVC() }),
        ("⑫ ZLLayout 链式约束",                 "view.layout.top().leading().size()",  { ZLLayoutDemoVC() }),
        ("⑬ DSL 语法 + 链式属性配置",            "addViews { } + .axis().alignment()…", { DSLDemoVC() }),
        ("⑭ ObjC 链式 API",                      "setAxis / setJustify / flex.flex(n)…", { ViewControllerObjc() }),
        ("⑮ wrapScrollView - 水平滚动",           "HStackView.wrapScrollView() 超出屏幕宽度横向滚动", { WrapScrollHorizontalDemoVC() }),
        ("⑯ wrapScrollView - 垂直滚动",           "VStackView.wrapScrollView() 超出屏幕高度纵向滚动", { WrapScrollVerticalDemoVC() }),
        ("⑰ 性能对比 - ZLFlexKit StackView",      "构建/布局/重布耗时 · View数 · 约束数 · 内存增量",  { PerfZLStackViewVC() }),
        ("⑱ 性能对比 - 系统 UIStackView",          "与 ZLStackView 同等 3层嵌套结构横向对比",          { PerfUIStackViewVC() }),
        ("⑲ 性能对比 - SnapKit 手动约束",          "UIView+SnapKit 手动约束，无 StackView 辅助",       { PerfSnapKitVC() }),
        ("⑳ 性能对比 - 纯 Frame 布局",             "零约束，手动计算 frame，最原始的布局方式",          { PerfFrameVC() }),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ZLFlexKit Demo"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .white
        view.backgroundColor = .white
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        demos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let demo = demos[indexPath.row]
        cell.textLabel?.text = demo.title
        cell.textLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        cell.detailTextLabel?.text = demo.subtitle
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .orange
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = demos[indexPath.row].vc()
        vc.title = demos[indexPath.row].title
        navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 60 }
}

// MARK: - 通用辅助

private extension UIView {
    static func colored(_ color: UIColor, text: String = "", size: CGSize = CGSize(width: 50, height: 40)) -> UIView {
        let v = UILabel()
        v.backgroundColor = color
        v.text = text
        v.textAlignment = .center
        v.font = .boldSystemFont(ofSize: 12)
        v.textColor = .white
        v.layer.cornerRadius = 4
        v.clipsToBounds = true
        if size.width > 0 {
            v.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        if size.height > 0 {
            v.heightAnchor.constraint(equalToConstant: size.height).isActive = true

        }
        
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }
}

private func sectionLabel(_ text: String) -> UILabel {
    let l = CustomLabel()
    l.text = text
    l.font = .systemFont(ofSize: 12, weight: .semibold)
    l.textColor = .gray
    l.numberOfLines = 0
    return l
}

private func demoStack(height: CGFloat) -> StackView {
    let sv = StackView()
    sv.backgroundColor = .compatGray5
    sv.layer.cornerRadius = 6
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.heightAnchor.constraint(equalToConstant: height).isActive = true
    return sv
}
private func demoStack() -> StackView {
    let sv = StackView()
    sv.backgroundColor = .compatGray5
    sv.layer.cornerRadius = 6
    sv.translatesAutoresizingMaskIntoConstraints = false
    return sv
}

private let colors: [UIColor] = [
    .systemRed, .systemBlue, .systemGreen, .systemOrange,
    .systemPurple, .systemTeal, .systemPink
]

// MARK: - 安全区辅助 mixin

private protocol SafeTopLayout: AnyObject {
    var view: UIView! { get }
    var topLayoutGuide: UILayoutSupport { get }
}
extension UIViewController: SafeTopLayout {}
private extension SafeTopLayout {
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) { return view.safeAreaLayoutGuide.topAnchor }
        return topLayoutGuide.bottomAnchor
    }
}

// MARK: - 通用容器搭建辅助

private extension UIViewController {
    /// 创建垂直 UIStackView 并固定到安全区
    func makeContainerStack(padding: CGFloat = 16) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeTopAnchor, constant: padding),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
        ])
        
        
        
        return stack
    }
    
    

    /// 创建可滚动的垂直 UIStackView
    func makeScrollableContainerStack(padding: CGFloat = 16) -> UIStackView {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: safeTopAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: padding),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: padding),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -padding),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -padding),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -padding * 2),
        ])
        return stack
    }
}

// MARK: - ① justifyContent

class JustifyDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let stack = makeScrollableContainerStack()
        let cases: [(Justify, String)] = [
            (.start,       ".start  — 靠左对齐，末尾留空"),
            (.center,      ".center — 居中，两侧留空"),
            (.end,         ".end    — 靠右对齐，前面留空"),
            (.spaceBetween,".spaceBetween — 首尾贴边，中间均分"),
            (.spaceAround, ".spaceAround  — 每项两侧相等（首尾是中间一半）"),
            (.spaceEvenly, ".spaceEvenly  — 所有间距完全相等"),
        ]
        for (justify, desc) in cases {
            stack.addArrangedSubview(sectionLabel(desc))
            let sv = demoStack()
            sv.justifyContent = justify
            sv.alignment = .center
            for i in 0..<3 {
                sv.addArrangedSubview(UIView.colored(colors[i], text: "\(i+1)",
                    size: CGSize(width: 44 + CGFloat(i) * 10, height: 36)))
            }
            stack.addArrangedSubview(sv)
        }
    }
}

// MARK: - ② fill / fillEqually

class FillDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeContainerStack()
        
        container.addArrangedSubview(sectionLabel(".fill — 子 view 可通过 flexValue 按比例占据空间"))
        let fill = demoStack()
        fill.insets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        fill.justifyContent = .fill
        fill.alignment = .fill
        let f1 = UIView.colored(colors[0], text: "flex:1", size: .zero)
        let f2 = UIView.colored(colors[1], text: "flex:2", size: .zero)
        let f3 = UIView.colored(colors[2], text: "固定60", size: CGSize(width: 60, height: 40))
        f1.flex.flex = 1
        f2.flex.flex = 2
        for v in [f1, f2, f3] { fill.addArrangedSubview(v) }
        container.addArrangedSubview(fill)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
        }
        
        

        container.addArrangedSubview(sectionLabel(".fillEqually — 所有子 view 宽度完全相等"))
        let eq = demoStack()
        eq.justifyContent = .fillEqually
        eq.alignment = .fill
        for i in 0..<4 { eq.addArrangedSubview(UIView.colored(colors[i], text: "=\(i+1)", size: .zero).flex.height(40).view) }
        container.addArrangedSubview(eq)

        container.addArrangedSubview(sectionLabel("⚠️ fill 模式下，没有 flexValue 且没有自身尺寸约束的 view 宽度会为 0"))
        let warn = demoStack()
        warn.justifyContent = .fill
        warn.alignment = .fill
        let w1 = UIView.colored(colors[4], text: "有宽度", size: CGSize(width: 80, height: 40))
        let w2 = UIView.colored(colors[5], text: "无宽度→0", size: .zero)
        let w3 = UIView.colored(colors[6], text: "flex:1",  size: .zero)
        w3.flex.flex = 1
        for v in [w1, w2, w3] { warn.addArrangedSubview(v) }
        container.addArrangedSubview(warn)
    }
}

// MARK: - ③ alignment

class AlignmentDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeContainerStack()
        let cases: [(FlexItemCrossAlign, String)] = [
            (.start,  ".start  — 所有子 view 顶部对齐"),
            (.center, ".center — 所有子 view 垂直居中"),
            (.end,    ".end    — 所有子 view 底部对齐"),
            (.fill,   ".fill   — 所有子 view 拉伸填满高度"),
        ]
        let sizes: [CGSize] = [CGSize(width: 50, height: 30),
                               CGSize(width: 50, height: 50),
                               CGSize(width: 50, height: 20)]
        for (align, desc) in cases {
            container.addArrangedSubview(sectionLabel(desc))
            let sv = demoStack(height: 70)
            sv.justifyContent = .spaceEvenly
            sv.alignment = align
            for i in 0..<3 {
                if align ==  .fill {
                    sv.addArrangedSubview(UIView.colored(colors[i], text: "\(Int(sizes[i].height))", size: .zero))
                }else {
                    sv.addArrangedSubview(UIView.colored(colors[i], text: "\(Int(sizes[i].height))", size: sizes[i]))
                }
            }
            container.addArrangedSubview(sv)
        }
    }
}

// MARK: - ④ alignSelf

class AlignSelfDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeContainerStack()

        container.addArrangedSubview(sectionLabel("stackView.alignment = .center，各自 view 用 alignSelf 覆盖"))
        let sv = demoStack(height: 80)
        sv.justifyContent = .spaceEvenly
        sv.alignment = .center
        let v1 = UIView.colored(colors[0], text: "start",  size: CGSize(width: 60, height: 30))
        let v2 = UIView.colored(colors[1], text: "center", size: CGSize(width: 60, height: 30))
        let v3 = UIView.colored(colors[2], text: "end",    size: CGSize(width: 60, height: 30))
        let v4 = UIView.colored(colors[3], text: "fill",   size: CGSize(width: 60, height: 0))
        v1.flex.alignSelf = .start
        v2.flex.alignSelf = .center
        v3.flex.alignSelf = .end
        v4.flex.alignSelf = .fill
        for v in [v1, v2, v3, v4] { sv.addArrangedSubview(v) }
        container.addArrangedSubview(sv)

        
        
        container.addArrangedSubview(sectionLabel("startMarge / endMarge — 在对齐方向上增加偏移"))
        let sv2 = demoStack(height: 80)
        sv2.justifyContent = .spaceEvenly
        sv2.alignment = .start
        let m1 = UIView.colored(colors[4], text: "start+0",  size: CGSize(width: 60, height: 28))
        let m2 = UIView.colored(colors[5], text: "start+10", size: CGSize(width: 60, height: 28))
        let m3 = UIView.colored(colors[6], text: "end+10",   size: CGSize(width: 60, height: 28))
        m2.flex.margin(.init(top: 10, leading: 0, bottom: 0, trailing: 0))
        m3.flex.alignSelf = .end
        m3.flex.margin(.init(top: 0, leading: 0, bottom: 0, trailing: 10))
        for v in [m1, m2, m3] { sv2.addArrangedSubview(v) }
        container.addArrangedSubview(sv2)
    }
}

// MARK: - ⑤ flexValue

class FlexValueDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeContainerStack()

        container.addArrangedSubview(sectionLabel("flex 1:1:1 — 三等分"))
        let sv1 = demoStack()
        sv1.justifyContent = .fill; sv1.alignment = .fill
        for i in 0..<3 { let v = UIView.colored(colors[i], text: "flex:1", size: .zero); v.flex.flex = 1; sv1.addArrangedSubview(v) }
        container.addArrangedSubview(sv1)

        container.addArrangedSubview(sectionLabel("flex 1:2:3 — 按比例分配"))
        let sv2 = demoStack()
        sv2.justifyContent = .fill; sv2.alignment = .fill
        for (i, f) in [1,2,3].enumerated() { let v = UIView.colored(colors[i], text: "flex:\(f)", size: .zero); v.flex.flex = f; sv2.addArrangedSubview(v) }
        container.addArrangedSubview(sv2)

        container.addArrangedSubview(sectionLabel("固定宽度 + flex 占据剩余空间"))
        let sv3 = demoStack()
        sv3.justifyContent = .fill; sv3.alignment = .fill
        let fixed = UIView.colored(colors[3], text: "固定80", size: CGSize(width: 80, height: 40))
        let fl1   = UIView.colored(colors[4], text: "flex:1", size: .zero)
        let fl2   = UIView.colored(colors[5], text: "flex:2", size: .zero)
        fl1.flex.flex = 1; fl2.flex.flex = 2
        for v in [fixed, fl1, fl2] { sv3.addArrangedSubview(v) }
        container.addArrangedSubview(sv3)

        container.addArrangedSubview(sectionLabel("⚠️ flexValue 仅在 justifyContent = .fill 时生效"))
    }
}

// MARK: - ⑥ isFlexibleSpace

class FlexSpaceDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeContainerStack()

        container.addArrangedSubview(sectionLabel("在 view 后插入弹性空白，将后续 view 推到末尾"))
        let sv1 = demoStack()
        sv1.justifyContent = .fill; sv1.alignment = .center
        let a = UIView.colored(colors[0], text: "A", size: CGSize(width: 44, height: 36))
        let b = UIView.colored(colors[1], text: "B", size: CGSize(width: 44, height: 36))
        let c = UIView.colored(colors[2], text: "C", size: CGSize(width: 44, height: 36))
        a.flex.isFlexibleSpace = true
        for v in [a, b, c] { sv1.addArrangedSubview(v) }
        container.addArrangedSubview(sv1)

        container.addArrangedSubview(sectionLabel("两个弹性空白 → 类似 spaceEvenly"))
        let sv2 = demoStack()
        sv2.justifyContent = .fill; sv2.alignment = .center
        let d = UIView.colored(colors[3], text: "D", size: CGSize(width: 44, height: 36))
        let e = UIView.colored(colors[4], text: "E", size: CGSize(width: 44, height: 36))
        let f = UIView.colored(colors[5], text: "F", size: CGSize(width: 44, height: 36))
        d.flex.isFlexibleSpace = true; e.flex.isFlexibleSpace = true
        for v in [d, e, f] { sv2.addArrangedSubview(v) }
        container.addArrangedSubview(sv2)

        container.addArrangedSubview(sectionLabel("⚠️ isFlexibleSpace 只在 .fill / .fillEqually 模式下有效"))
    }
}

// MARK: - ⑦ spacing / minSpacing / maxSpacing

class SpacingDemoVC: UIViewController {

    private var fixedSpacingView: StackView!
    private var label: UILabel!
    private var currentSpacing: CGFloat = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeContainerStack()

        // 固定 spacing — 使用公开方法 setCustomSpacing 或直接赋值 spacing
        container.addArrangedSubview(sectionLabel("固定 spacing — view.flex.spacing 设置该 view 后面的间距"))
        let sv1 = demoStack()
        sv1.justifyContent = .start;
        sv1.alignment = .center
        let views1 = (0..<4).map { UIView.colored(colors[$0], text: "\($0+1)", size: CGSize(width: 44, height: 36)) }
        views1[0].flex.spacing = 4    // 公开属性
        views1[1].flex.spacing = 16
        views1[2].flex.spacing = 32
        for v in views1 { sv1.addArrangedSubview(v) }
        container.addArrangedSubview(sv1)

        container.addArrangedSubview(sectionLabel("stackView.spacing — 全局默认间距（单个 view 设置后会覆盖）"))
        let sv2 = demoStack()
        sv2.justifyContent = .start; sv2.alignment = .center; sv2.spacing = 20
        let views2 = (0..<4).map { UIView.colored(colors[$0], text: "\($0+1)", size: CGSize(width: 44, height: 36)) }
        views2[2].flex.spacing = 50
        for v in views2 { sv2.addArrangedSubview(v) }
        container.addArrangedSubview(sv2)

        container.addArrangedSubview(sectionLabel("minSpacing / maxSpacing — 间距范围约束"))
        let sv3 = demoStack()
        sv3.justifyContent = .start; sv3.alignment = .center
        let ma = UIView.colored(colors[0], text: "min10", size: CGSize(width: 50, height: 36))
        let mb = UIView.colored(colors[1], text: "max30", size: CGSize(width: 50, height: 36))
        let mc = UIView.colored(colors[2], text: "C",     size: CGSize(width: 50, height: 36))
        ma.flex.minSpacing = 10    // 公开属性
        mb.flex.maxSpacing = 30
        for v in [ma, mb, mc] { sv3.addArrangedSubview(v) }
        container.addArrangedSubview(sv3)

        container.addArrangedSubview(sectionLabel("动态修改 — setCustomSpacing(_:after:)"))
        fixedSpacingView = demoStack()
        fixedSpacingView.justifyContent = .start; fixedSpacingView.alignment = .center
        let views3 = (0..<3).map { UIView.colored(colors[$0], text: "v\($0+1)", size: CGSize(width: 50, height: 36)) }
        for v in views3 { fixedSpacingView.addArrangedSubview(v) }
        container.addArrangedSubview(fixedSpacingView)

        label = UILabel()
        label.text = "第 1 个 view 后间距: \(Int(currentSpacing))pt"
        label.font = .systemFont(ofSize: 12)
        container.addArrangedSubview(label)

        let slider = UISlider()
        slider.minimumValue = 0; slider.maximumValue = 80; slider.value = Float(currentSpacing)
        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        container.addArrangedSubview(slider)

        fixedSpacingView.setCustomSpacing(currentSpacing, after: views3[0])
    }

    @objc private func sliderChanged(_ s: UISlider) {
        currentSpacing = CGFloat(s.value)
        label.text = "第 1 个 view 后间距: \(Int(currentSpacing))pt"
        if let v = fixedSpacingView.arrangedViews.first {
            fixedSpacingView.setCustomSpacing(currentSpacing, after: v)
        }
    }
}

// MARK: - ⑧ startMarge / endMarge

class MargeDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeContainerStack()

        container.addArrangedSubview(sectionLabel("交叉轴方向的 margin（从 insets 边界开始计算）"))
        let sv = demoStack(height: 90)
        sv.justifyContent = .spaceEvenly;
        sv.alignment = .start
        let v1 = UIView.colored(colors[0], text: "无偏移",   size: CGSize(width: 60, height: 30))
        let v2 = UIView.colored(colors[1], text: "start+15", size: CGSize(width: 60, height: 30))
        let v3 = UIView.colored(colors[2], text: "end+15",   size: CGSize(width: 60, height: 30))
        let v4 = UIView.colored(colors[3], text: "两边+10",  size: CGSize(width: 60, height: 0))
        v2.flex.margin(.init(top: 15, leading: 0, bottom: 0, trailing: 0))
        v3.flex.margin(.init(top: 0, leading: 0, bottom: 15, trailing: 0))
        v3.flex.alignSelf = .end
        v4.flex.align(.fill).margin(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
        for v in [v1, v2, v3, v4] { sv.addArrangedSubview(v) }
        container.addArrangedSubview(sv)

        container.addArrangedSubview(sectionLabel("⚠️ alignSelf = .center 时，offset = (startMarge - endMarge) * 0.5"))
        let sv2 = demoStack(height: 80)
        sv2.justifyContent = .spaceEvenly; sv2.alignment = .center
        let c1 = UIView.colored(colors[4], text: "offset 0", size: CGSize(width: 60, height: 30))
        let c2 = UIView.colored(colors[5], text: "up 16",    size: CGSize(width: 60, height: 30))
        let c3 = UIView.colored(colors[6], text: "down 16",  size: CGSize(width: 60, height: 30))
        c2.flex.margin(.init(top: 0, leading: 0, bottom: 32, trailing: 0))
        c3.flex.margin(.init(top: 32, leading: 0, bottom: 0, trailing: 0))
        for v in [c1, c2, c3] { sv2.addArrangedSubview(v) }
        container.addArrangedSubview(sv2)
    }
}

// MARK: - ⑨ insets

class InsetsDemoVC: UIViewController {

    private var sv: StackView!
    private var insetsLabel: UILabel!
    private var toggled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeContainerStack(padding: 16)
        container.spacing = 12

        container.addArrangedSubview(sectionLabel("insets 给 stackView 整体设置内边距，动态修改时动画流畅"))
        sv = demoStack(height: 80)
        sv.justifyContent = .fillEqually;
        sv.spacing = 50
        sv.alignment = .fill
        sv.insets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        for i in 0..<3 { sv.addArrangedSubview(UIView.colored(colors[i], text: "\(i+1)", size: .zero))
            
        }
        container.addArrangedSubview(sv)

        insetsLabel = UILabel()
        insetsLabel.text = "insets: top=8, left=16, bottom=8, right=16"
        insetsLabel.font = .systemFont(ofSize: 12)
        container.addArrangedSubview(insetsLabel)

        let btn = UIButton(type: .system)
        btn.setTitle("切换 insets", for: .normal)
        btn.addTarget(self, action: #selector(toggleInsets), for: .touchUpInside)
        container.addArrangedSubview(btn)
       
    }

    @objc private func toggleInsets() {
        toggled.toggle()
        UIView.animate(withDuration: 0.3) {
            if self.toggled {
                self.sv.insets = NSDirectionalEdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40)
                self.insetsLabel.text = "insets: top=20, left=40, bottom=20, right=40"
            } else {
                self.sv.insets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
                self.insetsLabel.text = "insets: top=4, left=4, bottom=4, right=4"
            }
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - ⑩ 垂直 Axis

class VerticalDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeScrollableContainerStack()

        container.addArrangedSubview(sectionLabel("vertical + .fill + flexValue — 按比例分配高度"))
        let sv1 = makeVerticalStack(height: 100)
        sv1.justifyContent = .fill; sv1.alignment = .fill
        for (i, f) in [1,2,1].enumerated() {
            let v = UIView.colored(colors[i], text: "flex:\(f)", size: .zero); v.flex.flex = f; sv1.addArrangedSubview(v)
        }
        container.addArrangedSubview(sv1)

        container.addArrangedSubview(sectionLabel("vertical + .spaceEvenly — 均分间距"))
        let sv2 = makeVerticalStack(height: 200)
        sv2.justifyContent = .spaceEvenly; sv2.alignment = .center
        for i in 0..<4 { sv2.addArrangedSubview(UIView.colored(colors[i], text: "v\(i+1)", size: CGSize(width: 120, height: 28))) }
        container.addArrangedSubview(sv2)

        container.addArrangedSubview(sectionLabel("vertical + alignment = .end — 子 view 靠右"))
        let sv3 = makeVerticalStack(height: -1)
        sv3.justifyContent = .start; sv3.alignment = .end; sv3.spacing = 8
        for (i, w) in [60.0,100.0,80.0,130.0].enumerated() {
            sv3.addArrangedSubview(UIView.colored(colors[i], text: "w\(Int(w))", size: CGSize(width: w, height: 26)))
        }
        container.addArrangedSubview(sv3)
    }

    private func makeVerticalStack(height: CGFloat) -> StackView {
        let sv = StackView()
        sv.axis = .vertical
        sv.backgroundColor = .compatGray5
        sv.layer.cornerRadius = 6
        if height > 0 {
            sv.translatesAutoresizingMaskIntoConstraints = false
            sv.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        return sv
    }
}

// MARK: - ⑪ 动态增删

class DynamicDemoVC: UIViewController {

    private var stack: StackView!
    private var colorIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeContainerStack()
        container.spacing = 12

        container.addArrangedSubview(sectionLabel("点击按钮动态增/删子 view，布局自动更新"))
        stack = demoStack(height: 60)
        stack.justifyContent = .start;
        stack.alignment = .center;
        stack.spacing = 8
        container.addArrangedSubview(stack.wrapScrollView())
        
        for _ in 0..<3 { addView() }

        let btnStack = UIStackView()
        btnStack.axis = .horizontal; btnStack.spacing = 12; btnStack.distribution = .fillEqually
        let addBtn    = makeBtn("➕ 添加",    #selector(addTapped))
        let removeBtn = makeBtn("➖ 移除末尾", #selector(removeTapped))
        let hideBtn   = makeBtn("👁 隐藏首个", #selector(hideTapped))
        for b in [addBtn, removeBtn, hideBtn] { btnStack.addArrangedSubview(b) }
        container.addArrangedSubview(btnStack)
        container.addArrangedSubview(sectionLabel("⚠️ isHidden=true 的 view 自动排除出布局，显示时自动恢复"))
    }

    private func makeBtn(_ title: String, _ sel: Selector) -> UIButton {
        let b = UIButton(type: .system); b.setTitle(title, for: .normal)
        b.addTarget(self, action: sel, for: .touchUpInside); return b
    }

    private func addView() {
        let v = UIView.colored(colors[colorIndex % colors.count], text: "\(colorIndex+1)", size: CGSize(width: 44, height: 44))
        colorIndex += 1
        UIView.animate(withDuration: 0.25) {
            self.stack.insertArrangedSubview(v, at: 0)
            self.view.layoutIfNeeded()
        }
    }

    @objc private func addTapped() { addView() }
    @objc private func removeTapped() {
        guard let last = stack.arrangedViews.last else { return }
        UIView.animate(withDuration: 0.25) { self.stack.removeArrangedSubview(last); self.view.layoutIfNeeded() }
    }
    @objc private func hideTapped() {
        guard let first = stack.arrangedViews.first else { return }
        UIView.animate(withDuration: 0.25) { first.isHidden = !first.isHidden; self.view.layoutIfNeeded() }
    }
}

// MARK: - ⑫ ZLLayout 链式约束

class ZLLayoutDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground

        // ① 基础：top / leading / size（数字字面量 Int/CGFloat 均可）
        let box1 = UIView()
        box1.backgroundColor = colors[0]; box1.layer.cornerRadius = 6
        view.addSubview(box1)
        box1.box.top(80).leading(16).size(w: 80, h: 80)

        // ② addTo 链式
        let box2 = UIView()
        box2.backgroundColor = colors[1]; box2.layer.cornerRadius = 6
        box2.box.addTo(view).top(80).leading(120).size(w: 80, h: 80)

        // ③ addToFull — 贴满父视图
        let container = UIView()
        container.backgroundColor = .compatGray5; container.layer.cornerRadius = 8
        view.addSubview(container)
        container.box.top(180).leading(16).trailing(16).height(80)
        let inner = UIView()
        inner.backgroundColor = colors[2].withAlphaComponent(0.7)
        inner.box.addToFull(container)

        // ④ centerX / centerY
        let box4 = UIView()
        box4.backgroundColor = colors[3]; box4.layer.cornerRadius = 6
        view.addSubview(box4)
        box4.box.top(280).centerX().size(w: 80, h: 44)

        // ⑤ addSubviewLayout
        view.box.addSubviewLayout(UIView()) { layout in
            layout.view?.backgroundColor = colors[4]
            layout.view?.layer.cornerRadius = 6
            layout.top(340).leading(16).size(w: 120, h: 44)
        }

        // ⑥ tapAction（点击变色）
        let box6 = UIView()
        box6.backgroundColor = colors[5]; box6.layer.cornerRadius = 6
        view.addSubview(box6)
       

        // 说明文字
        let label = UILabel()
        label.numberOfLines = 0; label.font = .systemFont(ofSize: 12); label.textColor = .gray
        label.text = """
        ① box1: top(80).leading(16).size(width:80,height:80)
        ② box2: addTo(view).top(80).leading(120).size(...)
        ③ container: inner.layout.addToFull(container)
        ④ box4: top(280).centerX().size(...)
        ⑤ 绿框: addSubviewLayout { layout in ... }
        ⑥ 紫框: .tapAction { } 点击变色

        ✅ 所有数字参数均支持 Int / Float / Double / CGFloat
        """
        view.addSubview(label)
        label.box.top(400).leading(16).trailing(16)
    }
}

// MARK: - ⑮ wrapScrollView - 水平滚动

/// 演示：HStackView 内容超出屏幕宽度时，用 wrapScrollView() 包一层 ScrollView 实现横向滚动
class WrapScrollHorizontalDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeScrollableContainerStack()

        // ─── 场景 1：大量等宽色块横向排列，超出屏幕宽度后可滚动 ───────────────
        container.addArrangedSubview(sectionLabel(
            "场景 1：HStackView 有 12 个子 view，内容超出屏幕，wrapScrollView() 使其可横向滚动"
        ))

        // 1. 创建水平 StackView 并添加子 view
        let hStack = StackView.horizontal()
        hStack.alignment = .center
        hStack.spacing = 10
        hStack.insets  = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        hStack.backgroundColor = .compatGray5
        hStack.layer.cornerRadius = 8

        for i in 0..<12 {
            hStack.addArrangedSubview(
                UIView.colored(colors[i % colors.count], text: "\(i + 1)",
                               size: CGSize(width: 60, height: 50))
            )
        }

        // 2. 调用 wrapScrollView()，返回一个包含该 hStack 的 ScrollView
        let scrollView1 = hStack.wrapScrollView()
        scrollView1.showsHorizontalScrollIndicator = true
        scrollView1.translatesAutoresizingMaskIntoConstraints = false
        scrollView1.heightAnchor.constraint(equalToConstant: 80).isActive = true
        container.addArrangedSubview(scrollView1)

        // ─── 场景 2：宽度不一的标签横向排列（类似标签流，超宽可滚） ─────────────
        container.addArrangedSubview(sectionLabel(
            "场景 2：不同宽度的「标签」横向排列，内容整体可左右滚动"
        ))

        let tagStack = StackView.horizontal()
        tagStack.alignment = .center
        tagStack.spacing = 8
        tagStack.insets  = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        tagStack.backgroundColor = .compatGray5
        tagStack.layer.cornerRadius = 8

        let tagTexts = ["Swift", "UIKit", "AutoLayout", "FlexKit", "StackView",
                        "wrapScrollView", "iOS 13+", "Objective-C", "DSL", "动态布局"]
        for (i, text) in tagTexts.enumerated() {
            let label = UILabel()
            label.text = "  \(text)  "
            label.font = .systemFont(ofSize: 13, weight: .medium)
            label.textColor = .white
            label.backgroundColor = colors[i % colors.count]
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            label.sizeToFit()
            // 固定高度，宽度由 sizeToFit 决定
            label.translatesAutoresizingMaskIntoConstraints = false
            label.heightAnchor.constraint(equalToConstant: 28).isActive = true
            tagStack.addArrangedSubview(label)
        }

        let scrollView2 = tagStack.wrapScrollView()
        scrollView2.showsHorizontalScrollIndicator = false
        scrollView2.translatesAutoresizingMaskIntoConstraints = false
        scrollView2.heightAnchor.constraint(equalToConstant: 52).isActive = true
        container.addArrangedSubview(scrollView2)

        container.addArrangedSubview(sectionLabel("""
        ✅ 使用要点：
        · axis = .horizontal → wrapScrollView() 自动约束 hStack 高度 = scrollView 高度
        · scrollView 宽度等于父视图宽度（低优先级约束，可超出）
        · 无需手动设置 contentSize，约束自动驱动
        """))
    }
}

// MARK: - ⑯ wrapScrollView - 垂直滚动

/// 演示：VStackView 内容超出屏幕高度时，用 wrapScrollView() 包一层 ScrollView 实现纵向滚动
class WrapScrollVerticalDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground

        // ─── 场景 1：大量行项目纵向排列，超出屏幕高度后可滚动 ────────────────
        // 1. 创建垂直 StackView 并添加子 view
        let vStack = StackView.vertical()
        vStack.alignment = .fill
        vStack.spacing   = 0
        vStack.insets    = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

        // 添加说明 header
        let header = sectionLabel("场景 1：VStackView 有 20 行，内容超出屏幕，wrapScrollView() 使其可纵向滚动")
        header.translatesAutoresizingMaskIntoConstraints = false
        vStack.addArrangedSubview(header)

        for i in 0..<20 {
            let row = makeRowView(index: i)
            vStack.addArrangedSubview(row)
            if i < 19 {
                // 分割线
                let sep = UIView()
                sep.backgroundColor = UIColor(white: 0.88, alpha: 1)
                sep.translatesAutoresizingMaskIntoConstraints = false
                sep.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                vStack.addArrangedSubview(sep)
            }
        }

        // ─── 场景 2：混合内容（图片占位 + 多行文字 + 按钮）可垂直滚动 ──────────
        let divider = sectionLabel("\n场景 2：混合内容行（色块 + 多行文字 + 按钮），整体可垂直滚动")
        divider.translatesAutoresizingMaskIntoConstraints = false
        vStack.addArrangedSubview(divider)

        for i in 0..<5 {
            let card = makeCardView(index: i)
            vStack.addArrangedSubview(card)
        }

        let footer = sectionLabel("""

        ✅ 使用要点：
        · axis = .vertical → wrapScrollView() 自动约束 vStack 宽度 = scrollView 宽度
        · scrollView 高度等于父视图高度（低优先级约束，可超出）
        · 无需手动设置 contentSize，约束自动驱动
        · vStack.insets 可当作 scrollView 的内容 padding 使用
        """)
        footer.translatesAutoresizingMaskIntoConstraints = false
        vStack.addArrangedSubview(footer)

        // 2. 调用 wrapScrollView()，返回包含 vStack 的 ScrollView
        let scrollView = vStack.wrapScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // 3. 将 scrollView 固定到安全区
        let safeTop: NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            safeTop = view.safeAreaLayoutGuide.topAnchor
        } else {
            safeTop = topLayoutGuide.bottomAnchor
        }
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeTop),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // 简单列表行
    private func makeRowView(index: Int) -> UIView {
        let row = StackView.horizontal()
        row.alignment = .center
        row.spacing   = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 52).isActive = true

        let dot = UIView()
        dot.backgroundColor = colors[index % colors.count]
        dot.layer.cornerRadius = 10
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 20).isActive  = true
        dot.heightAnchor.constraint(equalToConstant: 20).isActive = true

        let label = UILabel()
        label.text = "列表项 \(index + 1) — 这是一段描述文字"
        label.font = .systemFont(ofSize: 15)
        label.flex.flex = 1   // 占据剩余宽度

        let badge = UILabel()
        badge.text = "\(index * 3 + 1)"
        badge.font = .systemFont(ofSize: 12, weight: .bold)
        badge.textColor = .white
        badge.backgroundColor = colors[(index + 3) % colors.count]
        badge.layer.cornerRadius = 10
        badge.clipsToBounds = true
        badge.textAlignment = .center
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.widthAnchor.constraint(equalToConstant: 28).isActive  = true
        badge.heightAnchor.constraint(equalToConstant: 20).isActive = true

        row.addArrangedSubview(dot)
        row.addArrangedSubview(label)
        row.addArrangedSubview(badge)
        return row
    }

    // 卡片行（色块 + 多行文字）
    private func makeCardView(index: Int) -> UIView {
        let card = StackView.horizontal()
        card.alignment = .center
        card.spacing   = 12
        card.insets    = NSDirectionalEdgeInsets(top: 10, leading:  0, bottom: 10, trailing:  0)
        card.translatesAutoresizingMaskIntoConstraints = false

        let thumb = UIView()
        thumb.backgroundColor = colors[index % colors.count]
        thumb.layer.cornerRadius = 6
        thumb.translatesAutoresizingMaskIntoConstraints = false
        thumb.widthAnchor.constraint(equalToConstant: 60).isActive  = true
        thumb.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let textStack = StackView.vertical()
        textStack.alignment = .fill
        textStack.spacing   = 4
        textStack.flex.flex = 1

        let title = UILabel()
        title.text = "卡片标题 \(index + 1)"
        title.font = .systemFont(ofSize: 15, weight: .semibold)

        let desc = UILabel()
        desc.text = "这是卡片的详细描述文字，内容可以很长，自动换行撑高卡片高度。wrapScrollView 负责滚动，内部高度自适应。"
        desc.font = .systemFont(ofSize: 13)
        desc.textColor = .gray
        desc.numberOfLines = 0

        textStack.addArrangedSubview(title)
        textStack.addArrangedSubview(desc)

        card.addArrangedSubview(thumb)
        card.addArrangedSubview(textStack)

        // 卡片背景
        let wrapper = UIView()
        wrapper.backgroundColor = UIColor(white: 0.96, alpha: 1)
        wrapper.layer.cornerRadius = 10
        wrapper.translatesAutoresizingMaskIntoConstraints = false

        card.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(card)
        card.box.edgesZero()

        return wrapper
    }
}

// MARK: - ⑬ DSL 语法 + 链式属性配置

class DSLDemoVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeScrollableContainerStack()

        // ─── ⓪ 构造方法 DSL + 链式别名 ──────────────────────────────────────
        container.addArrangedSubview(sectionLabel("⓪ 构造方法 DSL — StackView { } 初始化时声明子 view，链式别名配置属性"))

        // StackView { } 在 init 内直接用 @StackViewBuilder 接收子 view
        // .justify / .align / .gap 是不与属性重名的链式别名方法：
        //   .justify(.fill)   == justifyContent = .fill
        //   .align(.center)   == alignment = .center
        //   .gap(10)          == spacing = 10
        //   .direction(.vertical) == axis = .vertical
        //   .padding(insets)      == insets = insets
        let sv0 = StackView {
            UIView.colored(colors[0], text: "A", size: CGSize(width: 44, height: 36))
            UIView.colored(colors[1], text: "B", size: CGSize(width: 60, height: 36))
            Spacer()                                    // 弹性空白
            UIView.colored(colors[2], text: "C", size: CGSize(width: 44, height: 36))
            
            
        }
        .justify(.fill)
        .align(.center)
        .spacing(10)
        sv0.backgroundColor = .compatGray5
        sv0.layer.cornerRadius = 6
        sv0.translatesAutoresizingMaskIntoConstraints = false
        sv0.heightAnchor.constraint(equalToConstant: 56).isActive = true
        container.addArrangedSubview(sv0)

        // 垂直方向 + padding
        container.addArrangedSubview(sectionLabel("构造方法 DSL（垂直）— .direction(.vertical).justify(.fill).padding(insets)"))
        let sv0v = StackView {
            UIView.colored(colors[3], text: "flex:1", size: .zero).flex.flex(1)
            UIView.colored(colors[4], text: "flex:2", size: .zero).flex.flex(2)
            UIView.colored(colors[5], text: "flex:1", size: .zero).flex.flex(1)
        }
        .axis(.vertical)
        .justify(.fill)
        .align(.fill)
        .insets(NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        sv0v.backgroundColor = .compatGray5
        sv0v.layer.cornerRadius = 6
        sv0v.translatesAutoresizingMaskIntoConstraints = false
        sv0v.heightAnchor.constraint(equalToConstant: 140).isActive = true
        container.addArrangedSubview(sv0v)
        
        
        
        

        // ─── ① 基本 DSL：addViews { } 内直接列举子 view ───────────────────
        container.addArrangedSubview(sectionLabel("① addViews { } DSL 语法 — 直接列举子 view，无需逐个 addArrangedSubview"))

        // 注意：链式方法与属性同名时 Swift 会优先解析为属性，故直接赋值更安全
        let sv1 = StackView()
        sv1.justifyContent = .spaceEvenly
        sv1.alignment      = .center
        sv1.backgroundColor = .compatGray5
        sv1.layer.cornerRadius = 6
        sv1.translatesAutoresizingMaskIntoConstraints = false
        sv1.heightAnchor.constraint(equalToConstant: 56).isActive = true

        sv1.addViews {
            UIView.colored(colors[0], text: "A")
            UIView.colored(colors[1], text: "B")
            UIView.colored(colors[2], text: "C")
            UIView.colored(colors[3], text: "D")
        }
        container.addArrangedSubview(sv1)

        // ─── ② 数字字面量作为固定间距 ───────────────────────────────────────
        container.addArrangedSubview(sectionLabel("② DSL 中插入数字 = 固定间距（单位 pt），Spacer() = 弹性间距"))

        let sv2 = StackView()
        sv2.justifyContent = .fill
        sv2.alignment      = .center
        sv2.backgroundColor = .compatGray5
        sv2.layer.cornerRadius = 6
        sv2.translatesAutoresizingMaskIntoConstraints = false
        sv2.heightAnchor.constraint(equalToConstant: 56).isActive = true

        sv2.addViews {
            UIView.colored(colors[0], text: "L", size: CGSize(width: 44, height: 36))
            16                                          // 固定 16pt 间距
            UIView.colored(colors[1], text: "M", size: CGSize(width: 44, height: 36))
            Spacer()                                    // 弹性空白，将 R 推到末尾
            UIView.colored(colors[2], text: "R", size: CGSize(width: 44, height: 36))
        }
        container.addArrangedSubview(sv2)

        // ─── ③ Spacer 变体：.min / .max / .value ────────────────────────────
        container.addArrangedSubview(sectionLabel("③ Spacer 变体：.value(固定) / .min(最小) / .max(最大)"))
        

        let sv3 = StackView()
        sv3.justifyContent = .fill
        sv3.alignment      = .center
        sv3.backgroundColor = .compatGray5
        sv3.layer.cornerRadius = 6
        sv3.translatesAutoresizingMaskIntoConstraints = false
        sv3.heightAnchor.constraint(equalToConstant: 56).isActive = true

        sv3.addViews {
            UIView.colored(colors[4], text: "①", size: CGSize(width: 44, height: 36))
            Spacer.value(20)
            // 精确 20pt
            UIView.colored(colors[5], text: "②", size: CGSize(width: 44, height: 36))
            Spacer.min(8)                               // 最小 8pt
            UIView.colored(colors[6], text: "③", size: CGSize(width: 44, height: 36))
            Spacer.max(40)                              // 最大 40pt
            UIView.colored(colors[0], text: "④", size: CGSize(width: 44, height: 36))
        }
        container.addArrangedSubview(sv3)

        // ─── ④ FlexItem 链式配置后直接放进 DSL ──────────────────────────────
        container.addArrangedSubview(sectionLabel("④ view.flex.flexValue(n) 链式配置后直接放进 DSL，按比例填充"))

        let sv4 = StackView()
        sv4.justifyContent = .fill
        sv4.alignment      = .fill
        sv4.spacing        = 4                          // 全局间距
        sv4.backgroundColor = .compatGray5
        sv4.layer.cornerRadius = 6
        sv4.translatesAutoresizingMaskIntoConstraints = false
        sv4.heightAnchor.constraint(equalToConstant: 50).isActive = true

        sv4.addViews {
            UIView.colored(colors[0], text: "flex:1", size: .zero).flex.flex(1)   // FlexItem 链式
            UIView.colored(colors[1], text: "flex:2", size: .zero).flex.flex(2)
            UIView.colored(colors[2], text: "flex:3", size: .zero).flex.flex(3)
        }
        container.addArrangedSubview(sv4)

        // ─── ⑤ 条件渲染：addView(if:) ────────────────────────────────────────
        container.addArrangedSubview(sectionLabel("⑤ addView(if:) 条件渲染 — 条件为 false 的 view 不会被添加"))

        let showExtra = true
        let sv5 = StackView()
        sv5.justifyContent = .start
        sv5.alignment      = .center
        sv5.spacing        = 8
        sv5.backgroundColor = .compatGray5
        sv5.layer.cornerRadius = 6
        sv5.translatesAutoresizingMaskIntoConstraints = false
        sv5.heightAnchor.constraint(equalToConstant: 56).isActive = true

        sv5
            .addView(UIView.colored(colors[3], text: "常驻",   size: CGSize(width: 60, height: 36)))
            .addView(if: showExtra,  UIView.colored(colors[4], text: "条件true",  size: CGSize(width: 80, height: 36)))
            .addView(if: !showExtra, UIView.colored(colors[5], text: "条件false", size: CGSize(width: 80, height: 36)))
        container.addArrangedSubview(sv5)

        // ─── ⑥ addView(make:) 闭包懒创建 ─────────────────────────────────────
        container.addArrangedSubview(sectionLabel("⑥ addView(make:) 闭包懒创建，可引用 stackView 本身"))

        let sv6 = StackView()
        sv6.justifyContent = .spaceAround
        sv6.alignment      = .center
        sv6.insets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        sv6.backgroundColor = .compatGray5
        sv6.layer.cornerRadius = 6
        sv6.translatesAutoresizingMaskIntoConstraints = false
        sv6.heightAnchor.constraint(equalToConstant: 60).isActive = true
        sv6.addView { _ in
            UIView.colored(colors[6], text: "make①", size: CGSize(width: 60, height: 36))
        }.addView { _ in
            UIView.colored(colors[0], text: "make②", size: CGSize(width: 60, height: 36))
        }.addView { _ in
            UIView.colored(colors[1], text: "make③", size: CGSize(width: 60, height: 36))
        }
        
        container.addArrangedSubview(sv6)

        // ─── ⑦ 垂直 StackView + DSL + alignSelf ──────────────────────────────
        container.addArrangedSubview(sectionLabel("⑦ 垂直 axis + DSL + flex.alignSelf 赋值 — 综合示例"))

        let sv7 = StackView()
        sv7.axis           = .vertical
        sv7.justifyContent = .fill
        sv7.alignment      = .start
        sv7.spacing        = 6
        sv7.insets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        sv7.backgroundColor = .compatGray5
        sv7.layer.cornerRadius = 6
        sv7.translatesAutoresizingMaskIntoConstraints = false
        sv7.heightAnchor.constraint(equalToConstant: 180).isActive = true

        sv7.addViews {
            // 高度由 flex 控制，宽度由 alignSelf 控制
            UIView.colored(colors[0], text: "fill", size: .zero)
                .flex.flex(1)          // 链式：权重1；alignSelf 用属性赋值
            UIView.colored(colors[1], text: "center w:120", size: CGSize(width: 120, height: 0))
                .flex.flex(1)          // 权重1，alignSelf 在 addViews 后单独设置
            UIView.colored(colors[2], text: "end w:80", size: CGSize(width: 80, height: 0))
                .flex.flex(1)
        }
        // alignSelf 通过属性赋值（FlexItem 暂无链式 alignSelf 方法）
        if let views = sv7.arrangedViews as [UIView]?,  views.count == 3 {
            views[0].flex.alignSelf = .fill
            views[1].flex.alignSelf = .center
            views[2].flex.alignSelf = .end
        }
        container.addArrangedSubview(sv7)
        
        
       
    

        // ─── 注意事项 ──────────────────────────────────────────────────────────
        container.addArrangedSubview(sectionLabel("""
        ✅ 使用要点：
        · DSL 块内数字字面量 = 固定间距，Spacer() = 弹性间距
        · Spacer 只在 .fill / .fillEqually 模式下有弹性效果
        · flex.flexValue/alignSelf 等返回 FlexItem，可直接放入 DSL
        · addView(if:) / addView(make:) 与 addViews{} 可混用
        · StackView 属性链 .axis().alignment().spacing() 顺序随意
        """))
    }
}

// MARK: - ⑰⑱⑲⑳ 布局性能对比 ── 共享基础设施

// ── 内存（resident_size KB）──
private func _benchMemKB() -> Int64 {
    var info = mach_task_basic_info()
    var cnt  = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / 4)
    let ok: kern_return_t = withUnsafeMutablePointer(to: &info) { p in
        p.withMemoryRebound(to: integer_t.self, capacity: Int(cnt)) {
            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &cnt)
        }
    }
    return ok == KERN_SUCCESS ? Int64(info.resident_size / 1024) : 0
}

// ── 计时（ms）──
private func _benchMs(_ block: () -> Void) -> Double {
    let s = CACurrentMediaTime(); block()
    return (CACurrentMediaTime() - s) * 1_000.0
}

// ── 递归统计 ──
private func _benchVC(_ v: UIView) -> Int { 1 + v.subviews.reduce(0) { $0 + _benchVC($1) } }
private func _benchCC(_ v: UIView) -> Int { v.constraints.count + v.subviews.reduce(0) { $0 + _benchCC($1) } }
private func _benchDp(_ v: UIView) -> Int { v.subviews.isEmpty ? 0 : 1 + (v.subviews.map { _benchDp($0) }.max() ?? 0) }

// ── 结果结构 ──
private struct BenchResult {
    let name: String
    var desc      = ""
    var buildMs   = 0.0     // 创建 view 树 + 约束/frame 设置
    var layout1Ms = 0.0     // 首次 layoutIfNeeded
    var layoutNMs = 0.0     // 重布 kBenchN 次的单次均值
    var views     = 0
    var constraints = 0
    var memKB: Int64 = 0
    var depth     = 0
    var totalMs: Double { buildMs + layout1Ms }
}

// ── 性能面板 UI ──
private final class BenchPanel: UIView {

    private let rows = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.82, alpha: 1)
        layer.cornerRadius = 10; layer.masksToBounds = true
        layer.borderWidth = 0.5; layer.borderColor = UIColor(white: 0.74, alpha: 1).cgColor
        rows.axis = .vertical; rows.spacing = 1
        rows.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rows)
        NSLayoutConstraint.activate([
            rows.topAnchor.constraint(equalTo: topAnchor),
            rows.leadingAnchor.constraint(equalTo: leadingAnchor),
            rows.trailingAnchor.constraint(equalTo: trailingAnchor),
            rows.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func load(_ r: BenchResult) {
        rows.arrangedSubviews.forEach { $0.removeFromSuperview() }
        addHead("📊  " + r.name)
        if !r.desc.isEmpty { addNote(r.desc) }
        addRow("构建耗时",               ms(r.buildMs),    false)
        addRow("首次 layoutIfNeeded",    ms(r.layout1Ms),  true)
        addRow("重新布局均值 (×\(kBenchN)次)", ms(r.layoutNMs), false)
        addRow("总耗时  (构建 + 首次)",  ms(r.totalMs),    true)
        addRow("View 层级总数",          "\(r.views) 个",  false)
        addRow("约束总数 (含子视图)",    "\(r.constraints) 个", true)
        addRow("内存增量",               "\(r.memKB >= 0 ? "+" : "")\(r.memKB) KB", false)
        addRow("最大嵌套深度",           "\(r.depth) 层",  true)
        addNote("⚠️ 以上数值因设备/系统负载不同会有波动，重复进入页面可观察差异")
    }

    private func ms(_ v: Double) -> String { String(format: "%.3f ms", v) }

    private func addHead(_ t: String) {
        let bg = UIView()
        bg.backgroundColor = UIColor(red: 0.22, green: 0.48, blue: 0.9, alpha: 0.14)
        let l = UILabel(); l.text = t; l.font = .boldSystemFont(ofSize: 13)
        l.textColor = UIColor(red: 0.08, green: 0.34, blue: 0.82, alpha: 1)
        _pin(l, bg, 7, 12); rows.addArrangedSubview(bg)
    }
    private func addNote(_ t: String) {
        let bg = UIView(); bg.backgroundColor = UIColor(white: 0.96, alpha: 1)
        let l = UILabel(); l.text = t; l.font = .systemFont(ofSize: 10)
        l.textColor = .gray; l.numberOfLines = 0
        _pin(l, bg, 4, 12); rows.addArrangedSubview(bg)
    }
    private func addRow(_ k: String, _ v: String, _ alt: Bool) {
        let bg = UIView(); bg.backgroundColor = alt ? .white : UIColor(white: 0.976, alpha: 1)
        let kl = UILabel(); kl.text = k; kl.font = .systemFont(ofSize: 11.5)
        kl.textColor = UIColor(white: 0.3, alpha: 1)
        let vl = UILabel(); vl.text = v; vl.textAlignment = .right
        vl.font = .monospacedDigitSystemFont(ofSize: 11.5, weight: .medium)
        vl.textColor = UIColor(white: 0.1, alpha: 1)
        let sv = UIStackView(arrangedSubviews: [kl, vl]); sv.axis = .horizontal
        _pin(sv, bg, 5, 12); rows.addArrangedSubview(bg)
    }
    private func _pin(_ child: UIView, _ parent: UIView, _ vp: CGFloat, _ hp: CGFloat) {
        child.translatesAutoresizingMaskIntoConstraints = false; parent.addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor,      constant:  vp),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: hp),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -hp),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor,  constant: -vp),
        ])
    }
}

// 基准测试常量
private let kBenchRows = 100      // section 数
private let kBenchCols = 5      // 每 section cell 列数
private let kBenchN    = 0     // 重布迭代次数

// 各 VC 通用脚手架：在 view 上搭建 panel(top) + scrollView(bottom)
private func _benchScaffold(vc: UIViewController) -> (BenchPanel, UIScrollView) {
    let panel  = BenchPanel()
    let scroll = UIScrollView()
    panel.translatesAutoresizingMaskIntoConstraints  = false
    scroll.translatesAutoresizingMaskIntoConstraints = false
    vc.view.addSubview(panel); vc.view.addSubview(scroll)
    let safeTop: NSLayoutYAxisAnchor
    if #available(iOS 11, *) { safeTop = vc.view.safeAreaLayoutGuide.topAnchor }
    else { safeTop = vc.topLayoutGuide.bottomAnchor }
    NSLayoutConstraint.activate([
        panel.topAnchor.constraint(equalTo: safeTop, constant: 8),
        panel.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor,  constant: 12),
        panel.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -12),
        scroll.topAnchor.constraint(equalTo: panel.bottomAnchor, constant: 8),
        scroll.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
        scroll.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
        scroll.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
    ])
    return (panel, scroll)
}

// 构造通用 cell 子视图
private func _bIcon(_ idx: Int) -> UIView {
    let v = UILabel();
    v.font = .systemFont(ofSize: 8, weight: .medium)
    v.text = String(format: "%02d", idx + 1)
    v.backgroundColor = colors[idx % colors.count]
    return v
}
private func _bTitle(_ i: Int, _ j: Int) -> UILabel {
    let l = UILabel(); l.text = "Item\(i+1)-\(j+1)"
    l.font = .systemFont(ofSize: 10, weight: .medium)
    l.textAlignment = .center; return l
}
private func _bSub() -> UILabel {
    let l = UILabel(); l.text = "subtitle"
    l.font = .systemFont(ofSize: 9); l.textColor = .lightGray
    l.textAlignment = .center; return l
}
private func _bHeader(_ i: Int) -> UILabel {
    let l = UILabel(); l.text = "Section \(i + 1)"
    l.font = .systemFont(ofSize: 12, weight: .semibold)
    l.textColor = UIColor(white: 0.45, alpha: 1); return l
}

// MARK: - ⑰ ZLFlexKit StackView 性能测试

class PerfZLStackViewVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let (panel, scroll) = _benchScaffold(vc: self)

        var r = BenchResult(name: "⑰ ZLFlexKit StackView")
        r.desc = "3层 ZLStackView 嵌套：OuterVStack → RowHStack → CellVStack → icon+title+sub，\(kBenchRows)×\(kBenchCols) 格"

        let m0 = _benchMemKB()
        var outerSV: StackView!

        // ── 构建耗时 ──
        r.buildMs = _benchMs {
            // Level 1: 垂直 outer StackView
            outerSV = StackView.vertical()
            outerSV.alignment = .fill; outerSV.justifyContent = .start
            outerSV.spacing = 10
            outerSV.insets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 20, trailing: 12)
            outerSV.translatesAutoresizingMaskIntoConstraints = false
            scroll.addSubview(outerSV)
            NSLayoutConstraint.activate([
                outerSV.topAnchor.constraint(equalTo: scroll.topAnchor),
                outerSV.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
                outerSV.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
                outerSV.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
                outerSV.widthAnchor.constraint(equalTo: scroll.widthAnchor),
            ])
            for i in 0..<kBenchRows {
                outerSV.addArrangedSubview(_bHeader(i))
                // Level 2: 水平 row StackView
                let rowSV = StackView.horizontal()
                rowSV.alignment = .fill
                rowSV.justifyContent = .fillEqually
                rowSV.spacing = 8
                for j in 0..<kBenchCols {
                    // Level 3: 垂直 cell StackView
                    let cellSV = StackView.vertical()
                    cellSV.alignment = .center
                    cellSV.justifyContent = .fill
                    cellSV.alignment = .center
                    cellSV.spacing = 4
                    cellSV.insets = NSDirectionalEdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
                    cellSV.backgroundColor = UIColor(white: 0.97, alpha: 1)
                    cellSV.layer.cornerRadius = 8; cellSV.flex.flex = 1
                    let icon = _bIcon(i * kBenchCols + j)
//                    icon.layout.size(w: 10, h: 10)
                    cellSV.addArrangedSubview(icon)
                    cellSV.addArrangedSubview(_bTitle(i, j))
                    cellSV.addArrangedSubview(_bSub())
                    rowSV.addArrangedSubview(cellSV)
                    rowSV.box.height(50)
                }
                outerSV.addArrangedSubview(rowSV)
            }
        }

        // ── 首次布局耗时 ──
        r.layout1Ms = _benchMs { self.view.setNeedsLayout(); self.view.layoutIfNeeded() }

        // ── 重新布局耗时（均值）：反复隐藏/显示第 1 个 row ──
        let toggleTarget = outerSV.arrangedViews.dropFirst().first
        r.layoutNMs = _benchMs {
            for _ in 0..<kBenchN {
                toggleTarget?.isHidden = true;  self.view.setNeedsLayout(); self.view.layoutIfNeeded()
                toggleTarget?.isHidden = false; self.view.setNeedsLayout(); self.view.layoutIfNeeded()
            }
        } / Double(kBenchN * 2)

        r.memKB = _benchMemKB() - m0
        r.views = _benchVC(outerSV); r.constraints = _benchCC(outerSV); r.depth = _benchDp(outerSV)
        panel.load(r)
    }
}

// MARK: - ⑱ 系统 UIStackView 性能测试

class PerfUIStackViewVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let (panel, scroll) = _benchScaffold(vc: self)

        var r = BenchResult(name: "⑱ 系统 UIStackView")
        r.desc = "3层 UIStackView 嵌套：OuterUIVSV → RowUIHSV → CellUIVSV → icon+title+sub，与 ⑰ 完全对等结构"

        let m0 = _benchMemKB()
        var outerSV: UIStackView!

        r.buildMs = _benchMs {
            // Level 1
            outerSV = UIStackView()
            outerSV.axis = .vertical; outerSV.alignment = .fill
            outerSV.distribution = .fill; outerSV.spacing = 10
            outerSV.isLayoutMarginsRelativeArrangement = true
            outerSV.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 20, right: 12)
            outerSV.translatesAutoresizingMaskIntoConstraints = false
            scroll.addSubview(outerSV)
            NSLayoutConstraint.activate([
                outerSV.topAnchor.constraint(equalTo: scroll.topAnchor),
                outerSV.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
                outerSV.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
                outerSV.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
                outerSV.widthAnchor.constraint(equalTo: scroll.widthAnchor),
            ])
            for i in 0..<kBenchRows {
                outerSV.addArrangedSubview(_bHeader(i))
                // Level 2
                let rowSV = UIStackView()
                rowSV.axis = .horizontal; rowSV.alignment = .fill
                rowSV.distribution = .fillEqually; rowSV.spacing = 8
                for j in 0..<kBenchCols {
                    // Level 3
                    let cellSV = UIStackView()
                    cellSV.axis = .vertical; cellSV.alignment = .center
                    cellSV.distribution = .fill; cellSV.spacing = 4
                    cellSV.isLayoutMarginsRelativeArrangement = true
                    cellSV.layoutMargins = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
                    cellSV.backgroundColor = UIColor(white: 0.97, alpha: 1)
                    cellSV.layer.cornerRadius = 8
                    let icon = _bIcon(i * kBenchCols + j)
//                    icon.layout.size(w: 10, h: 10)
                    cellSV.addArrangedSubview(icon)
                    cellSV.addArrangedSubview(_bTitle(i, j))
                    cellSV.addArrangedSubview(_bSub())
                    rowSV.addArrangedSubview(cellSV)
                }
                rowSV.box.height(50)
                outerSV.addArrangedSubview(rowSV)
            }
        }
        
        

        r.layout1Ms = _benchMs { self.view.setNeedsLayout(); self.view.layoutIfNeeded() }

        let toggleTarget = outerSV.arrangedSubviews.dropFirst().first
        r.layoutNMs = _benchMs {
            for _ in 0..<kBenchN {
                toggleTarget?.isHidden = true;  self.view.setNeedsLayout(); self.view.layoutIfNeeded()
                toggleTarget?.isHidden = false; self.view.setNeedsLayout(); self.view.layoutIfNeeded()
            }
        } / Double(kBenchN * 2)

        r.memKB = _benchMemKB() - m0
        r.views = _benchVC(outerSV); r.constraints = _benchCC(outerSV); r.depth = _benchDp(outerSV)
        panel.load(r)
    }
}

// MARK: - ⑲ SnapKit 手动约束性能测试

class PerfSnapKitVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let (panel, scroll) = _benchScaffold(vc: self)

        var r = BenchResult(name: "⑲ SnapKit 手动约束")
        r.desc = "纯 UIView 层级 + SnapKit DSL 约束：outer UIView → row UIView → cell UIView → icon+title+sub，无 StackView 辅助，\(kBenchRows)×\(kBenchCols) 格"

        let m0 = _benchMemKB()
        var container: UIView!
        var firstRowView: UIView?

        r.buildMs = _benchMs {
            // Level 1: 手动 UIView 容器
            container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            scroll.addSubview(container)

            var prevView: UIView? = nil   // 用于垂直链式定位

            for i in 0..<kBenchRows {
                // Level 1 child: section header
                let header = _bHeader(i)
                container.addSubview(header)
                header.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(12)
                    if let prev = prevView {
                        make.top.equalTo(prev.snp.bottom).offset(10)
                    } else {
                        make.top.equalToSuperview().inset(12)
                    }
                }
                prevView = header

                // Level 2: row 容器
                let rowView = UIView()
                container.addSubview(rowView)
                rowView.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(12)
                    make.top.equalTo(header.snp.bottom).offset(6)
                }
                if i == 0 { firstRowView = rowView }

                var prevCell: UIView? = nil
                for j in 0..<kBenchCols {
                    // Level 3: cell 容器
                    let cellView = UIView()
                    cellView.backgroundColor = UIColor(white: 0.97, alpha: 1)
                    cellView.layer.cornerRadius = 8
                    rowView.addSubview(cellView)

                    let icon   = _bIcon(i * kBenchCols + j)
                    let titleL = _bTitle(i, j)
                    let subL   = _bSub()
                    [icon, titleL, subL].forEach { cellView.addSubview($0) }

                    // ── icon: 固定尺寸居中 ──
                    icon.snp.makeConstraints { make in
                        make.top.equalToSuperview().inset(8)
                        make.centerX.equalToSuperview()
                        make.leading.greaterThanOrEqualTo(4)
                        make.trailing.lessThanOrEqualTo(-4)
                    }
                    titleL.snp.makeConstraints { make in
                        make.top.equalTo(icon.snp.bottom).offset(4)
                        make.centerX.equalToSuperview()
                        make.leading.greaterThanOrEqualTo(4)
                        make.trailing.lessThanOrEqualTo(-4)
                    }
                    subL.snp.makeConstraints { make in
                        make.top.equalTo(titleL.snp.bottom).offset(2)
                        make.centerX.equalToSuperview()
                        make.leading.greaterThanOrEqualTo(4)
                        make.trailing.lessThanOrEqualTo(-4)
                        make.bottom.equalToSuperview().inset(8)
                    }

                    // ── cell 横向排列 ──
                    cellView.snp.makeConstraints { make in
                        make.top.bottom.equalToSuperview()
                        if let prev = prevCell {
                            make.leading.equalTo(prev.snp.trailing).offset(8)
                            make.width.equalTo(prev)   // 等宽
                        } else {
                            make.leading.equalToSuperview()
                        }
                        if j == kBenchCols - 1 { make.trailing.equalToSuperview() }
                    }
                    prevCell = cellView
                }
                prevView = rowView
            }

            // ── container 四边全部 pin 到 scroll（含 bottom → 告知 scrollView contentSize）──
            container.snp.makeConstraints { make in
                make.top.leading.trailing.bottom.equalToSuperview()
                make.width.equalTo(scroll)
            }
            // ── 最后一个 rowView 的 bottom 关闭高度链 ──
            if let last = prevView {
                last.snp.makeConstraints { make in
                    make.bottom.equalToSuperview().inset(20)  // last.bottom + 20 = container.bottom
                }
            }
        }

        r.layout1Ms = _benchMs { self.view.setNeedsLayout(); self.view.layoutIfNeeded() }

        r.layoutNMs = _benchMs {
            for _ in 0..<kBenchN {
                firstRowView?.isHidden = true;  self.view.setNeedsLayout(); self.view.layoutIfNeeded()
                firstRowView?.isHidden = false; self.view.setNeedsLayout(); self.view.layoutIfNeeded()
            }
        } / Double(kBenchN * 2)

        r.memKB = _benchMemKB() - m0
        r.views = _benchVC(container); r.constraints = _benchCC(container); r.depth = _benchDp(container)
        panel.load(r)
    }
}

// MARK: - ⑳ 纯 Frame 手动布局性能测试

/// 零约束，全部手动计算 frame，模拟最传统的 iOS 布局方式
class PerfFrameVC: UIViewController {

    private var contentView: UIView!
    private var contentHeightCon: NSLayoutConstraint!
    private var containerWidth: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let (panel, scroll) = _benchScaffold(vc: self)

        var r = BenchResult(name: "⑳ 纯 Frame 手动布局")
        r.desc = "零约束（icon/label 的 size/position 全手动），UIView 层级：outer UIView → cell UIView → icon+title+sub，\(kBenchRows)×\(kBenchCols) 格，重布调用 applyFrames()"

        containerWidth = UIScreen.main.bounds.width
        let m0 = _benchMemKB()

        r.buildMs = _benchMs {
            // ── 建立 contentView（用 AutoLayout 固定在 scrollView 中，高度靠 heightConstraint 驱动）──
            contentView = UIView()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            scroll.addSubview(contentView)
            contentHeightCon = contentView.heightAnchor.constraint(equalToConstant: 100)
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: scroll.topAnchor),
                contentView.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
                contentView.widthAnchor.constraint(equalTo: scroll.widthAnchor),
                contentHeightCon,
            ])

            // ── 创建所有子视图（尚未设置 frame）──
            // 顺序：header0, cell(0,0), cell(0,1), cell(0,2), cell(0,3), header1, cell(1,0), ...
            for i in 0..<kBenchRows {
                contentView.addSubview(_bHeader(i))         // header
                for j in 0..<kBenchCols {
                    let cell = UIView()
                    cell.backgroundColor = UIColor(white: 0.97, alpha: 1)
                    cell.layer.cornerRadius = 8
                    cell.addSubview(_bIcon(i * kBenchCols + j))
                    cell.addSubview(_bTitle(i, j))
                    cell.addSubview(_bSub())
                    contentView.addSubview(cell)
                }
            }

            // ── 首次 frame 计算 ──
            applyFrames(width: containerWidth)
        }

        // Frame 布局无单独 layout pass，layoutIfNeeded 极快
        r.layout1Ms = _benchMs { self.view.setNeedsLayout(); self.view.layoutIfNeeded() }

        // ── 重新布局：纯 frame 重算 kBenchN 次 ──
        r.layoutNMs = _benchMs {
            for _ in 0..<kBenchN { applyFrames(width: containerWidth) }
        } / Double(kBenchN)

        r.memKB = _benchMemKB() - m0
        r.views = _benchVC(contentView); r.constraints = _benchCC(contentView); r.depth = _benchDp(contentView)
        panel.load(r)
    }

    /// 根据给定宽度重新计算并设置所有子视图 frame（纯手动，无约束）
    private func applyFrames(width: CGFloat) {
        let hPad: CGFloat = 12, colGap: CGFloat = 8, rowGap: CGFloat = 10
        let availW  = width - hPad * 2
        let colW    = (availW - colGap * CGFloat(kBenchCols - 1)) / CGFloat(kBenchCols)
        let iconS: CGFloat = 10, titleH: CGFloat = 15, subH: CGFloat = 13
        let cellH   = 8 + iconS + 4 + titleH + 2 + subH + 8   // top-pad + icon + gap + title + gap + sub + bot-pad
        let headerH: CGFloat = 18

        var y: CGFloat = 12
        let stride = 1 + kBenchCols   // 每组 subviews 数：1 header + kBenchCols cells

        for i in 0..<kBenchRows {
            let base = i * stride
            guard base < contentView.subviews.count else { break }

            // header
            contentView.subviews[base].frame = CGRect(x: hPad, y: y, width: availW, height: headerH)
            y += headerH + 6

            // cells
            for j in 0..<kBenchCols {
                let idx = base + 1 + j
                guard idx < contentView.subviews.count else { break }
                let cell = contentView.subviews[idx]
                let x    = hPad + CGFloat(j) * (colW + colGap)
                cell.frame = CGRect(x: x, y: y, width: colW, height: cellH)

                // icon（Level 3 leaf）
                let iconX = (colW - iconS) / 2
                if cell.subviews.count >= 3 {
                    cell.subviews[0].frame = CGRect(x: iconX, y: 8, width: iconS, height: iconS)
                    cell.subviews[1].frame = CGRect(x: 4, y: 8 + iconS + 4, width: colW - 8, height: titleH)
                    cell.subviews[2].frame = CGRect(x: 4, y: 8 + iconS + 4 + titleH + 2, width: colW - 8, height: subH)
                }
            }
            y += cellH + rowGap
        }

        let totalH = y + 20
        contentHeightCon?.constant = totalH
    }
}

