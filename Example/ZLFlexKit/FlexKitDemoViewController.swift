//
//  FlexKitDemoViewController.swift
//  ZLFlexKit_Example
//
//  Demo: 全面展示 ZLFlexKit 弹性布局的所有功能
//

import UIKit
import ZLFlexKit
import SnapKit
import RxSwift
// MARK: - 兼容色（替换 iOS 13+ 专属颜色）
class CustomLabel: UILabel {}

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
        ("㉑ ZStackView - 层叠布局",                "DSL 添加子视图：ZStackView { } / addViews { }", { ZStackDemoVC() }),
        ("㉒ WStackView - 自动换行",             "标签流式布局：justify / align / flex / lineSpacing / 动态增删", { WrapDemoVC() }),
        ("TableViewController",             "cell自动计算高度",          { TableViewController() }),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView().box.width(3).height(10).width(33).height(3);
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
    func makeContainerStack(padding: CGFloat = 16) -> StackView {
       let view = VStackView()
            .spacing(8)
            .insets(.top(120))
            .justify(.start)
            .align(.fill)
        
            view.box.addTo(self.view).allEdges(16)
        return view
    }
    
    

    /// 创建可滚动的垂直 UIStackView
    func makeScrollableContainerStack(padding: CGFloat = 16) -> StackView {
        let v = VStackView().align(.fill).spacing(8)
        v.wrapScrollView().box.addTo(self.view).allEdges(16)
        return v
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
           let sv = HStackView(
                justify: justify,
                align: .center
            ) {
                for i in 0..<3 {
                    UIView.colored(colors[i], text: "\(i+1)",
                        size: CGSize(width: 50, height: 36))
                }
            }
            sv.backgroundColor = .compatGray5
            
            
            
            stack.addViews {
                sectionLabel(desc)
                sv
            }
        }
    }
}

// MARK: - ② fill / fillEqually

class FillDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeContainerStack()

        
        do {
            let fillStackView = HStackView(align: .fill,insets: .all(8)) {
                
                UIView.colored(colors[0], text: "flex:1", size: .zero)
                    .flex.flex(1)
                
                UIView.colored(colors[1], text: "flex:2", size: .zero).flex.flex(2)
                
                UIView.colored(colors[2], text: "固定60", size: CGSize(width: 60, height: 40))
                
            }
            fillStackView.backgroundColor = .compatGray5
            
            container.addViews {
                sectionLabel(".fill — 子 view 可通过 flexValue 按比例占据空间")
                fillStackView
            }
        }
        
        
        do {
            let stackView = HStackView(justify: .fillEqually,
                                       align: .fill,
                                       spacing: 10,
                                       insets: .all(8)
    
            ) {
                UIView.colored(colors[1], text: "1", size: .init(width: 0, height: 40))
                UIView.colored(colors[2], text: "2", size: .init(width: 0, height: 40))
                UIView.colored(colors[3], text: "3", size: .init(width: 0, height: 40))
            }
            stackView.backgroundColor = .compatGray5
            
            container.addViews {
                sectionLabel(".fillEqually — 所有子 view 宽度完全相等")
                stackView
            }
        }
        
        
        
        do {
            let stackView = HStackView(justify: .fill,
                                       align: .fill,
                                       spacing: 10,
                                       insets: .all(8)
    
            ) {
                UIView.colored(colors[4], text: "有宽度", size: CGSize(width: 80, height: 40))
                UIView.colored(colors[5], text: "无宽度→0", size: .zero)
                UIView.colored(colors[6], text: "flex:1",  size: .zero).flex.flex(1)
            }
            stackView.backgroundColor = .compatGray5
            
            container.addViews {
                sectionLabel("⚠️ fill 模式下，没有 flexValue 且没有自身尺寸约束的 view 宽度会为 0")
                stackView
            }
        }
        
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
           let stackView = HStackView {
                for i in 0..<3 {
                    if align ==  .fill {
                        UIView.colored(colors[i], text: "\(Int(sizes[i].height))", size: .zero)
                    }else {
                        UIView.colored(colors[i], text: "\(Int(sizes[i].height))", size: sizes[i])
                    }
                }
            }
            stackView.backgroundColor = .compatGray5
            stackView
                .justify(.spaceEvenly)
                .align(align)
                .box.height(70)
        
            container.addViews {
                sectionLabel(desc)
                stackView
            }
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
        sv.justify(.spaceEvenly).align(.center)
        
        let v1 = UIView.colored(colors[0], text: "start",  size: CGSize(width: 60, height: 30))
            .flex.align(.start)
        
        let v2 = UIView.colored(colors[1], text: "center", size: CGSize(width: 60, height: 30))
            .flex.align(.center)
        
        let v3 = UIView.colored(colors[2], text: "end",    size: CGSize(width: 60, height: 30))
            .flex.align(.end)
        
        let v4 = UIView.colored(colors[3], text: "fill",   size: CGSize(width: 60, height: 0))
            .flex.align(.fill)
      
        sv.addViews {
            v1; v2; v3; v4
        }
        container.addArrangedSubview(sv)

        
        
        container.addArrangedSubview(sectionLabel("startMarge / endMarge — 在对齐方向上增加偏移"))
        let sv2 = demoStack(height: 80)
        sv2.justifyContent = .spaceEvenly
        sv2.alignment = .start
        let m1 = UIView.colored(colors[4], text: "start+0",  size: CGSize(width: 60, height: 28))
        let m2 = UIView.colored(colors[5], text: "start+10", size: CGSize(width: 60, height: 28))
        let m3 = UIView.colored(colors[6], text: "end+10",   size: CGSize(width: 60, height: 28))
        m2.flex.margin(.top(10))
        m3.flex.alignSelf = .end
        m3.flex.margin(.bottom(10))
        sv2.addViews {
            m1; m2; m3
        }
        
        container.addArrangedSubview(sv2)
    }
}

// MARK: - ⑤ flexValue

class FlexValueDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeContainerStack()
        
        do {
            let sv1 = HStackView(justify: .fill,align: .fill) {
                
                UIView.colored(colors[0], text: "flex:1", size: .init(width: 0, height: 40)).flex.flex(1)
                
                UIView.colored(colors[1], text: "flex:1", size: .zero).flex.flex(1)

                UIView.colored(colors[2], text: "flex:1", size: .zero).flex.flex(1)
            }
            sv1.backgroundColor = .compatGray5
            
            container.addViews {
                sectionLabel("flex 1:1:1 — 三等分")
                sv1
            }
        }
        
        
        do {
            let sv1 = HStackView(justify: .fill,align: .fill) {
                
                UIView.colored(colors[0], text: "flex:1", size: .init(width: 0, height: 40)).flex.flex(1)
                
                UIView.colored(colors[1], text: "flex:2", size: .zero).flex.flex(2)

                UIView.colored(colors[2], text: "flex:3", size: .zero).flex.flex(3)
            }
            sv1.backgroundColor = .compatGray5

            container.addViews {
                sectionLabel("flex 1:2:3 — 按比例分配")
                sv1
            }
            
        }
        
        do {
            let sv1 = HStackView(justify: .fill,align: .fill) {
                
                UIView.colored(colors[3], text: "固定80", size: CGSize(width: 80, height: 40))
                
                UIView.colored(colors[1], text: "flex:1", size: .zero).flex.flex(1)

                UIView.colored(colors[2], text: "flex:2", size: .zero).flex.flex(2)
            }
            sv1.backgroundColor = .compatGray5

            container.addViews {
                sectionLabel("固定宽度 + flex 占据剩余空间")
                sv1
            }
            
        }

    }
}

// MARK: - ⑥ isFlexibleSpace

class FlexSpaceDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeContainerStack()

      
        
        
        do {
            let sv1 = HStackView(justify: .fill,align: .fill) {
                
                UIView.colored(colors[0], text: "A", size: CGSize(width: 44, height: 36))
                
                Spacer() //弹性空白
                
                UIView.colored(colors[1], text: "B", size: CGSize(width: 44, height: 36))

                UIView.colored(colors[2], text: "C", size: CGSize(width: 44, height: 36))
            }
            sv1.backgroundColor = .compatGray5

            container.addViews {
                sectionLabel("在 view 后插入弹性空白，将后续 view 推到末尾")
                sv1
            }
        }
        
        
        do {
            let sv1 = HStackView(justify: .fill,align: .fill) {
                
                UIView.colored(colors[0], text: "A", size: CGSize(width: 44, height: 36))
                
                Spacer() //弹性空白
                
                UIView.colored(colors[1], text: "B", size: CGSize(width: 44, height: 36))
                
                Spacer() //弹性空白

                UIView.colored(colors[2], text: "C", size: CGSize(width: 44, height: 36))
            }
            sv1.backgroundColor = .compatGray5

            container.addViews {
                sectionLabel("在 view 后插入弹性空白，将后续 view 推到末尾")
                sv1
            }
        }
        
       
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

       
        
        do {
          let sv1 = HStackView(justify: .start,align: .center) {
              
              UIView.colored(colors[0], text: "1", size: CGSize(width: 44, height: 36))
              
              5
              
              UIView.colored(colors[1], text: "2", size: CGSize(width: 44, height: 36))
              
              10

              UIView.colored(colors[2], text: "3", size: CGSize(width: 44, height: 36))

              15
              
              UIView.colored(colors[3], text: "4", size: CGSize(width: 44, height: 36))
              
          }
            
          sv1.backgroundColor = .compatGray5
          container.addViews {
                sectionLabel("固定 spacing — view.flex.spacing 设置该 view 后面的间距")
                sv1
            }
        }
        
        
        do {
          let sv1 = HStackView(justify: .start,align: .center,spacing: 20) {
              
              UIView.colored(colors[0], text: "1", size: CGSize(width: 44, height: 36))
              
              
              
              UIView.colored(colors[1], text: "2", size: CGSize(width: 44, height: 36))
              
              30

              UIView.colored(colors[2], text: "3", size: CGSize(width: 44, height: 36))
              40
                            
              UIView.colored(colors[3], text: "4", size: CGSize(width: 44, height: 36))
              
          }
            
          sv1.backgroundColor = .compatGray5
          container.addViews {
                sectionLabel("stackView.spacing — 全局默认间距（单个 view 设置后会覆盖）")
                sv1
            }
        }
        
        
        do {
          let sv1 = HStackView(justify: .start,align: .center) {
              
              UIView.colored(colors[0], text: "min30", size: CGSize(width: 44, height: 36))
              
              Spacer(min: 30)
              
              UIView.colored(colors[1], text: "2", size: CGSize(width: 44, height: 36))
              
              10

              UIView.colored(colors[2], text: "3", size: CGSize(width: 44, height: 36))
             
              
          }
            
          sv1.backgroundColor = .compatGray5
          container.addViews {
                sectionLabel("minSpacing  — 间距范围约束")
                sv1
            }
        }
        
        do {
          let sv1 = HStackView(justify: .fill,align: .center) {
              
              UIView.colored(colors[0], text: "max50", size: CGSize(width: 44, height: 36))
              
              Spacer(max: 50)
              
              UIView.colored(colors[1], text: "2", size: CGSize(width: 44, height: 36))
              
              10


              UIView.colored(colors[2], text: "3", size: CGSize(width: 0, height: 36))
             
              
          }
            
          sv1.backgroundColor = .compatGray5
          container.addViews {
                sectionLabel("maxSpacing — 间距范围约束")
                sv1
            }
        }
        
        

       

       

        do {
            fixedSpacingView =  HStackView(justify: .start) {
                UIView.colored(colors[0], text: "1", size: CGSize(width: 50, height: 36))
                
                UIView.colored(colors[1], text: "2", size: CGSize(width: 50, height: 36))
                
                UIView.colored(colors[2], text: "3", size: CGSize(width: 50, height: 36))


            }
            
            
            fixedSpacingView.backgroundColor = .compatGray5
            container.addViews {
                sectionLabel("动态修改 — setCustomSpacing(_:after:)")
                fixedSpacingView
            }

            label = UILabel()
            label.text = "第 1 个 view 后间距: \(Int(currentSpacing))pt"
            label.font = .systemFont(ofSize: 12)
            container.addArrangedSubview(label)

            let slider = UISlider()
            slider.minimumValue = 0;
            slider.maximumValue = 80;
            slider.value = Float(currentSpacing)
            slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
            container.addArrangedSubview(slider)

            fixedSpacingView.setCustomSpacing(currentSpacing, after: fixedSpacingView.arrangedViews.first!)
        }
    }

    @objc private func sliderChanged(_ s: UISlider) {
        currentSpacing = CGFloat(s.value)
        label.text = "第 1 个 view 后间距: \(Int(currentSpacing))pt"
        if let v = fixedSpacingView.arrangedViews.first {
//            fixedSpacingView.setCustomSpacing(currentSpacing, after: v)
            v.flex.spacing(currentSpacing)
        }
    }
}

// MARK: - ⑧ startMarge / endMarge

class MargeDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let container = makeContainerStack()

        do {
            let stackView =  HStackView(justify: .spaceEvenly,align: .start) {
                
                UIView.colored(colors[0], text: "无偏移",   size: CGSize(width: 60, height: 30))
                
                UIView.colored(colors[1], text: "start+15", size: CGSize(width: 60, height: 30))
                    .flex.margin(.top(15))
                
                UIView.colored(colors[2], text: "end+15",   size: CGSize(width: 60, height: 30))
                    .flex.align(.end).margin(.bottom(15))
                
                UIView.colored(colors[3], text: "两边+10",  size: CGSize(width: 60, height: 0))
                    .flex.align(.fill).margin(.vertical(10))
            }
            stackView.box.height(90)
            stackView.backgroundColor = .compatGray5
            container.addViews {
                sectionLabel("交叉轴方向的 margin（从 insets 边界开始计算）")
                stackView
            }
        }

        
        
        do {
            let stackView =  HStackView(justify: .spaceEvenly,align: .center) {
                
                UIView.colored(colors[0], text: "offset 0",   size: CGSize(width: 60, height: 30))
                
                UIView.colored(colors[1], text: "up 10", size: CGSize(width: 60, height: 30))
                    .flex.margin(.bottom(10))
                
                UIView.colored(colors[2], text: "down 10",   size: CGSize(width: 60, height: 30))
                    .flex.margin(.top(10))
                
            }
            stackView.box.height(90)
            stackView.backgroundColor = .compatGray5
            container.addViews {
                sectionLabel("⚠️ alignSelf = .center 时，offset = (startMarge - endMarge)")
                stackView
            }
        }
        
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
        
        do {
           let view =  HStackView(justify: .fillEqually,
                                 align: .fill,
                                 spacing: 50,
                                  insets: .init(t: 8, s: 16, b: 8, e: 16)) {
               UIView.colored(colors[0], text: "1", size: .init(width: 0, height: 40))
               UIView.colored(colors[1], text: "2", size: .init(width: 0, height: 40))
               UIView.colored(colors[2], text: "3", size: .init(width: 0, height: 40))
            }
            view.backgroundColor = .compatGray5
            self.sv = view
            container.addViews {
                sectionLabel("insets 给 stackView 整体设置内边距，动态修改时动画流畅")
                view
            }
        }
        

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

       
        
        do {
           let view = VStackView(align: .fill,spacing: 10) {
                UIView.colored(colors[1], text: "flex:1", size: .zero).flex.flex(1)
                UIView.colored(colors[2], text: "flex:2", size: .zero).flex.flex(2)
                UIView.colored(colors[3], text: "flex:1", size: .zero).flex.flex(1)
               
               
            }
            view.backgroundColor = .compatGray5
            view.box.height(100)
            container.addViews {
                sectionLabel("vertical + .fill + flexValue — 按比例分配高度")
                view
            }
        }
        
        
        do {
            let view = VStackView(justify: .spaceEvenly,
                                  align: .center) {
                UIView.colored(colors[1], text: "1", size: .init(width: 120, height: 28))
                UIView.colored(colors[2], text: "2", size: .init(width: 120, height: 28))
                UIView.colored(colors[3], text: "3", size: .init(width: 120, height: 28))
                UIView.colored(colors[4], text: "4", size: .init(width: 120, height: 28))
                
            }
            view.backgroundColor = .compatGray5
            view.box.height(200)
            container.addViews {
                sectionLabel("vertical + .spaceEvenly — 均分间距")
                view
            }
        }
        

       
        do {
            let view = VStackView(justify: .fill,
                                  align: .end,
                                  spacing: 20) {
                UIView.colored(colors[1], text: "1", size: .init(width: 60, height: 28))
                UIView.colored(colors[2], text: "2", size: .init(width: 100, height: 28))
                UIView.colored(colors[3], text: "3", size: .init(width: 80, height: 28))
                UIView.colored(colors[4], text: "4", size: .init(width: 130, height: 28))

            }
            view.backgroundColor = .compatGray5
            container.addViews {
                sectionLabel("vertical + alignment = .end — 子 view 靠右")
                view
            }
        }
    
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
        stack.justifyContent = .fill;
        stack.alignment = .center;
        stack.spacing = 8
        container.addArrangedSubview(stack.wrapScrollView())
        
       
        
        for _ in 0..<3 { addView() }

        
        do {
            
           let view = HStackView(justify: .spaceEvenly,spacing: 20) {
               makeBtn("➕ 添加",    #selector(addTapped))
               makeBtn("➖ 移除末尾", #selector(removeTapped))
               makeBtn("👁 隐藏首个", #selector(hideTapped))
           }
            
           container.addArrangedSubview(view)
        }
        
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

    @objc private func addTapped() {
        addView()
    }
    @objc private func removeTapped() {
        guard let last = stack.arrangedViews.last else { return }
        UIView.animate(withDuration: 0.25) { self.stack.removeArrangedSubview(last); self.view.layoutIfNeeded() }
    }
    @objc private func hideTapped() {
        guard let first = stack.arrangedViews.first else { return }
        UIView.animate(withDuration: 0.25) { first.isHidden = !first.isHidden; self.view.layoutIfNeeded() }
    }
}

// MARK: - ⑫ LayoutBox 链式约束 —— 全功能详解

/// LayoutBox（`view.box`）是 ZLFlexKit 内置的通用约束 DSL，本 Demo 完整覆盖：
///  ① top/leading/bottom/trailing 基础位置（含正负号约定）
///  ② xxxTo(anchor:offset:) 相对任意 anchor 定位
///  ③ >=（GreaterThanOrTo）/ <=（LessThanOrTo）关系变体
///  ④ center / centerX / centerY / centerOffset 居中系列
///  ⑤ width / height / min* / max* / size / square 尺寸约束
///  ⑥ widthTo / heightTo 相对其他 dimension
///  ⑦ edges / allEdges / edgesZero 贴边（bottom/trailing 自动取反）
///  ⑧ addTo / addToFull / addSubview / addSubviewLayout 层级管理
///  ⑨ NumberConvertible —— Int / Float / Double / CGFloat 通吃
///  ⑩ update() 更新已有约束的 constant / priority
///  ⑪ remake() 清空历史约束后整体重建
///  ⑫ id: / .id(_:) 打标签 + latestConstraint 读最近一条
///  ⑬ constraints(withID:) 查询 + removeConstraints(withID:) 精细删除（替代旧 .remove()）
///  ⑭ clear() 全清所有约束
///  ⑮ 综合实战：卡片布局
class ZLLayoutDemoVC: UIViewController {

    // 用于第 ⑩/⑪/⑫/⑬ 节动态演示的 view 与容器
    private let updateBox   = UIView()
    private let remakeBox   = UIView()
    private let queryBox    = UIView()   // ⑫ 打标签 + 查询
    private let removeIDBox = UIView()   // ⑬ removeConstraints(withID:)
    private var isRemakeAlt = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground

        // 外层滚动容器（VStackView + wrapScrollView）
        let container = makeScrollableContainerStack()

        // ─────────── ① 基础位置：相对 superview ───────────
        container.addViews {
            sectionLabel("""
            ① 基础位置：不带 To 的方法默认相对 superview
               · top/leading 传正数=向内偏移
               · bottom/trailing 使用原生 constant 语义，正数=向外扩，常传负数内缩
            """)
            makeCanvas(height: 120) { canvas in
                let a = UIView.tinyBox(colors[0], text: "top+leading")
                canvas.addSubview(a)
                a.box.top(12).leading(12).size(w: 110, h: 36)

                let b = UIView.tinyBox(colors[1], text: "trailing(-12)")
                canvas.addSubview(b)
                b.box.top(12).trailing(-12).size(w: 130, h: 36)

                let c = UIView.tinyBox(colors[2], text: "bottom(-12)")
                canvas.addSubview(c)
                c.box.bottom(-12).leading(12).size(w: 110, h: 36)
            }
        }

        // ─────────── ② 相对任意 anchor：xxxTo ───────────
        container.addViews {
            sectionLabel("""
            ② xxxTo(anchor, offset:) —— 相对任意 anchor 定位
               · A.leadingTo(B.trailingAnchor, offset: 8) 让 A 跟在 B 后面
               · topTo/bottomTo 同理
            """)
            makeCanvas(height: 100) { canvas in
                let a = UIView.tinyBox(colors[3], text: "A")
                let b = UIView.tinyBox(colors[4], text: "B")
                let c = UIView.tinyBox(colors[5], text: "C")
                canvas.addSubview(a); canvas.addSubview(b); canvas.addSubview(c)

                a.box.centerY().leading(12).size(w: 60, h: 36)
                b.box.centerY().leadingTo(a.trailingAnchor, offset: 8).size(w: 60, h: 36)
                c.box.centerY().leadingTo(b.trailingAnchor, offset: 8).size(w: 60, h: 36)
            }
        }

        // ─────────── ③ >= / <= 变体 ───────────
        container.addViews {
            sectionLabel("""
            ③ 关系变体：每个位置方法都有 3 个版本
               · xxx / xxxTo         →  ==
               · xxxGreaterThanOrTo  →  >= 至少
               · xxxLessThanOrTo     →  <= 至多
            下方蓝色标签：宽度默认 40，但设置 minWidth(80)，最终显示 80
            """)
            makeCanvas(height: 80) { canvas in
                let label = UILabel()
                label.backgroundColor = colors[1]
                label.textColor = .white
                label.textAlignment = .center
                label.text = "min≥80"
                label.font = .systemFont(ofSize: 12)
                label.layer.cornerRadius = 4
                label.clipsToBounds = true
                canvas.addSubview(label)
                label.box
                    .center()
                    .height(36)
                    .width(40)      // 期望值 40
//                    .minWidth(80)   // 但保证 >= 80，最终生效 80
            }
        }

        // ─────────── ④ 居中系列 ───────────
        container.addViews {
            sectionLabel("""
            ④ 居中：center() / centerX() / centerY() / centerOffset(x:y:)
            """)
            makeCanvas(height: 140) { canvas in
                let cx = UIView.tinyBox(colors[0], text: "centerX")
                canvas.addSubview(cx)
                cx.box.top(8).centerX().size(w: 100, h: 32)

                let both = UIView.tinyBox(colors[2], text: "center()")
                canvas.addSubview(both)
                both.box.center().size(w: 100, h: 32)

                let off = UIView.tinyBox(colors[4], text: "offset(60,20)")
                canvas.addSubview(off)
                off.box.centerOffset(x: 60, y: 20).size(w: 120, h: 32)
            }
        }

        // ─────────── ⑤ 尺寸约束 ───────────
        container.addViews {
            sectionLabel("""
            ⑤ 尺寸：width/height/minWidth/maxWidth/minHeight/maxHeight/size(w:h:)/square(_:)
            """)
            makeCanvas(height: 110) { canvas in
                let sq = UIView.tinyBox(colors[3], text: "square(64)")
                canvas.addSubview(sq)
                sq.box.top(12).leading(12).square(64)

                let sz = UIView.tinyBox(colors[5], text: "size(120x40)")
                canvas.addSubview(sz)
                sz.box.top(12).leadingTo(sq.trailingAnchor, offset: 12).size(w: 120, h: 40)

                let mm = UIView.tinyBox(colors[6], text: "min80/max140")
                canvas.addSubview(mm)
                mm.box
                    .bottom(-12).leading(12).height(28)
                    .minWidth(80).maxWidth(140)
            }
        }

        // ─────────── ⑥ widthTo / heightTo ───────────
        container.addViews {
            sectionLabel("""
            ⑥ widthTo/heightTo：让宽/高等于另一个 view 的 dimension
               · rightBox.widthTo(leftBox.widthAnchor)
            """)
            makeCanvas(height: 90) { canvas in
                let left = UIView.tinyBox(colors[0], text: "leader")
                let right = UIView.tinyBox(colors[1], text: "= leader.width")
                canvas.addSubview(left); canvas.addSubview(right)

                left.box.centerY().leading(12).size(w: 120, h: 40)
                right.box
                    .centerY()
                    .leadingTo(left.trailingAnchor, offset: 12)
                    .widthTo(left.widthAnchor)
                    .height(40)
            }
        }

        // ─────────── ⑦ edges / allEdges / edgesZero ───────────
        container.addViews {
            sectionLabel("""
            ⑦ 贴边（edges 系列）：
               · edges(top:leading:bottom:trailing:) —— bottom/trailing 自动取反，传正数即内缩
               · allEdges(16) —— 四边同 16 内缩
               · edgesZero() —— 完全贴满
            """)
            makeCanvas(height: 120) { canvas in
                let box1 = UIView(); box1.backgroundColor = colors[0].withAlphaComponent(0.35)
                let inner1 = UIView.tinyBox(colors[0], text: "allEdges(8)")
                canvas.addSubview(box1); box1.addSubview(inner1)
                box1.box.top(8).leading(12).size(w: 150, h: 90)
                inner1.box.allEdges(8)

                let box2 = UIView(); box2.backgroundColor = colors[2].withAlphaComponent(0.35)
                let inner2 = UIView.tinyBox(colors[2], text: "edges(4,8,4,8)")
                canvas.addSubview(box2); box2.addSubview(inner2)
                box2.box.top(8).trailing(-12).size(w: 160, h: 90)
                inner2.box.edges(top: 4, leading: 8, bottom: 4, trailing: 8)
            }
        }

        // ─────────── ⑧ 层级管理 API ───────────
        container.addViews {
            sectionLabel("""
            ⑧ 层级管理：
               · addTo(parent)         把 self 加到 parent
               · addToFull(parent)     加到 parent 并 edgesZero()
               · addSubview(child)     把 child 加进来
               · addSubviewLayout(child) { box in … }  加进来并立刻布局 child
            """)
            makeCanvas(height: 120) { canvas in
                // addToFull 演示：黄色底铺满
                let bg = UIView()
                bg.backgroundColor = colors[3].withAlphaComponent(0.25)
                bg.layer.cornerRadius = 6
                canvas.addSubview(bg)
                bg.box.top(8).leading(12).size(w: 160, h: 100)

                let fill = UIView()
                fill.backgroundColor = colors[3]
                fill.layer.cornerRadius = 6
                fill.box.addToFull(bg)  // 一句话铺满 bg，box 会内部执行 edgesZero()

                // addSubviewLayout 演示：canvas.box.addSubviewLayout 一步添加+布局
                canvas.box.addSubviewLayout(UIView.tinyBox(colors[5], text: "subviewLayout")) { box in
                    box.top(8).trailing(-12).size(w: 140, h: 40)
                }
                canvas.box.addSubviewLayout(UIView.tinyBox(colors[6], text: "addSubview then box")) { box in
                    box.bottom(-8).trailing(-12).size(w: 140, h: 40)
                }
            }
        }

        // ─────────── ⑨ NumberConvertible ───────────
        container.addViews {
            sectionLabel("""
            ⑨ 数值类型自由：Int / Int64 / UInt / Float / Double / CGFloat 均可直传
            """)
            makeCanvas(height: 80) { canvas in
                let a = UIView.tinyBox(colors[0], text: "Int(12)")
                let b = UIView.tinyBox(colors[1], text: "Double(12.5)")
                let c = UIView.tinyBox(colors[2], text: "CGFloat(13)")
                canvas.addSubview(a); canvas.addSubview(b); canvas.addSubview(c)
                a.box.centerY().leading(Int(12)).size(w: 90, h: 36)
                b.box.centerY().leadingTo(a.trailingAnchor, offset: Double(12.5)).size(w: 110, h: 36)
                c.box.centerY().leadingTo(b.trailingAnchor, offset: CGFloat(13)).size(w: 110, h: 36)
            }
        }

        // ─────────── ⑩ update() 更新 constant ───────────
        container.addViews {
            sectionLabel("""
            ⑩ update()：修改已有约束的 constant / priority
               点击按钮切换 leading（16 ↔ 120）与 width（80 ↔ 200）
               · 相同 (firstItem, secondItem, attr, relation) 的约束会被匹配并更新 constant
            """)
            makeCanvas(height: 80) { canvas in
                canvas.addSubview(updateBox)
                updateBox.backgroundColor = colors[4]
                updateBox.layer.cornerRadius = 4
                updateBox.box.top(16).leading(16).height(40).width(80)
            }
            makeButton("点我 update() 切换 leading & width") { [weak self] in
                self?.demoUpdate()
            }
        }

        // ─────────── ⑪ remake() 整体重建 ───────────
        container.addViews {
            sectionLabel("""
            ⑪ remake()：先删除该 view 全部历史约束，再激活本次链式的所有约束
               适合“布局方式完全变了”的场景（比如横竖屏切换）
            """)
            makeCanvas(height: 120) { canvas in
                canvas.addSubview(remakeBox)
                remakeBox.backgroundColor = colors[5]
                remakeBox.layer.cornerRadius = 4
                remakeBox.box.top(12).leading(12).size(w: 100, h: 40)
            }
            makeButton("点我 remake() 切换整套布局") { [weak self] in
                self?.demoRemake()
            }
        }

        // ─────────── ⑫ 打标签（id:）+ latestConstraint ───────────
        container.addViews {
            sectionLabel("""
            ⑫ 打标签：所有约束方法都新增了 id: 可选参数，两种等价写法：
               · 内联传入：view.box.top(20, id: "top-1")
               · 链式覆盖：view.box.top(20).id("top-1")   // 给 latestConstraint 打
            打完标签后可用 latestConstraint 拿最近生成的那条 NSLayoutConstraint。
            下方 view 的 4 条约束都打了 tag，点击按钮弹窗查看 latestConstraint 的 identifier。
            """)
            makeCanvas(height: 100) { canvas in
                canvas.addSubview(queryBox)
                queryBox.backgroundColor = colors[3]
                queryBox.layer.cornerRadius = 4
                let label = UILabel()
                label.text = "tagged"
                label.textColor = .white
                label.textAlignment = .center
                label.font = .systemFont(ofSize: 11, weight: .semibold)
                queryBox.addSubview(label)
                label.box.edgesZero()

                queryBox.box
                    .top(16, id: "Q-top")           // 方式一：id: 参数
                    .leading(16).id("Q-leading")    // 方式二：.id(_:) 链式
                    .width(140, id: "Q-w")
                    .height(60, id: "Q-h")
            }
            makeButton("点我：查询 constraints(withID: \"Q-w\") + latestConstraint") { [weak self] in
                self?.demoQueryID()
            }
        }

        // ─────────── ⑬ removeConstraints(withID:) 按 ID 精细删除 ───────────
        container.addViews {
            sectionLabel("""
            ⑬ removeConstraints(withID:)：按 identifier 精确删除约束（替代旧 .remove()）
               初始有 4 条约束（top/leading/width/height），全部打了 R-* tag
               点击按钮删掉 R-w / R-h 两条 → view 尺寸塌陷，只剩 top+leading
            """)
            makeCanvas(height: 120) { canvas in
                canvas.addSubview(removeIDBox)
                removeIDBox.backgroundColor = colors[6]
                removeIDBox.layer.cornerRadius = 4
                let l = UILabel()
                l.text = "tag & remove"
                l.font = .systemFont(ofSize: 11, weight: .semibold)
                l.textColor = .white
                l.textAlignment = .center
                removeIDBox.addSubview(l)
                l.box.edgesZero()

                removeIDBox.box
                    .top(12, id: "R-top")
                    .leading(12, id: "R-leading")
                    .width(140, id: "R-w")
                    .height(60, id: "R-h")
            }
            makeButton("点我：removeConstraints(withID:) 删掉 R-w & R-h") { [weak self] in
                self?.demoRemoveByID()
            }
        }

        // ─────────── ⑭ clear() 全清 ───────────
        container.addViews {
            sectionLabel("""
            ⑭ clear()：同步清空该 view 上的所有 LayoutBox 约束
               注意：clear() 不需要 flush()，会立即生效
            """)
            let hint = UIView.tinyBox(colors[0], text: "点我 clear()")
            makeCanvas(height: 80) { canvas in
                canvas.addSubview(hint)
                hint.box.center().size(w: 120, h: 36)
                let tap = UITapGestureRecognizer(target: self, action: #selector(demoClear(_:)))
                hint.isUserInteractionEnabled = true
                hint.addGestureRecognizer(tap)
                hint.tag = 9999
            }
        }

        // ─────────── ⑮ 综合实战：卡片布局 ───────────
        container.addViews {
            sectionLabel("""
            ⑮ 综合实战：一张卡片（图标 + 标题 + 副标题 + 右侧按钮），全部用 LayoutBox 拼装
            """)
            makeCard()
        }

        // 尾部说明
        container.addArrangedSubview(sectionLabel("""
        📌 温馨提示：
        · bottom/trailing 直接使用时不自动取反，请传负值；仅 edges(...) 会自动取反。
        · update() 只更新 constant/priority；如果 attr 不同，会作为新约束追加。
        · v(最新) 已移除 .remove()，精细删除请用 id: / .id(_:) + removeConstraints(withID:)。
        · clear() 与 removeConstraints(withID:) 是同步的；update / remake 内部自动 flush()。
        · view.box 是同一实例（associated object 缓存），多次访问累积约束记录。
        · 所有数值参数支持 NumberConvertible —— 直接写 Int/Double/CGFloat 均可。
        """))
    }

    // MARK: - 动作

    private var updateToggled = false
    private func demoUpdate() {
        updateToggled.toggle()
        updateBox.box
            .leading(updateToggled ? 120 : 16)
            .width(updateToggled ? 200 : 80)
            .update()   // 匹配已有约束，只更新 constant
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    private func demoRemake() {
        isRemakeAlt.toggle()
        if isRemakeAlt {
            // 完全换一套：改成右下、竖长条
            remakeBox.box
                .bottom(-12).trailing(-12).size(w: 40, h: 80)
                .remake()
        } else {
            // 复位：左上、横条
            remakeBox.box
                .top(12).leading(12).size(w: 100, h: 40)
                .remake()
        }
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    /// ⑫ 查询 identifier
    private func demoQueryID() {
        let matched = queryBox.box.constraints(withID: "Q-w") ?? []
        let latestID = queryBox.box.latestConstraint?.identifier ?? "nil"
        let latestConst = queryBox.box.latestConstraint?.constant ?? 0

        let msg = """
        constraints(withID: "Q-w")：
          命中 \(matched.count) 条
          第一条 constant = \(matched.first?.constant ?? 0)

        latestConstraint：
          identifier = \(latestID)
          constant   = \(latestConst)

        （latestConstraint 就是链式的最后一条约束，
         这里是 .height(60, id: "Q-h") 生成的那条）
        """
        let a = UIAlertController(title: "identifier 查询", message: msg, preferredStyle: .alert)
        a.addAction(.init(title: "OK", style: .cancel))
        present(a, animated: true)
    }

    /// ⑬ 按 identifier 精细删除
    private var didRemoveByID = false
    private func demoRemoveByID() {
        guard !didRemoveByID else { return }
        didRemoveByID = true
        // 精确删除宽高两条约束
        removeIDBox.box.removeConstraints(withID: "R-w")
        removeIDBox.box.removeConstraints(withID: "R-h")
        // 位置约束（R-top / R-leading）仍然生效，view 会因失去尺寸约束而塌陷
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    @objc private func demoClear(_ sender: UITapGestureRecognizer) {
        guard let v = sender.view else { return }
        v.box.clear()  // 清空后 view 将失去所有约束，回到无 frame 状态
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    // MARK: - 卡片示例

    private func makeCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 10
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.compatGray5.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 84).isActive = true

        // 头像
        let icon = UIView()
        icon.backgroundColor = colors[4]
        icon.layer.cornerRadius = 24
        card.box.addSubviewLayout(icon) { box in
            box.leading(12).centerY().square(48)
        }

        // 标题
        let title = UILabel()
        title.text = "ZLFlexKit"
        title.font = .boldSystemFont(ofSize: 15)
        card.box.addSubviewLayout(title) { box in
            box.leadingTo(icon.trailingAnchor, offset: 12).top(16)
        }

        // 副标题
        let subtitle = UILabel()
        subtitle.text = "LayoutBox · 链式约束 · id/查询/删除/update/remake/clear"
        subtitle.font = .systemFont(ofSize: 12)
        subtitle.textColor = .gray
        card.box.addSubviewLayout(subtitle) { box in
            box.leadingTo(icon.trailingAnchor, offset: 12)
                .topTo(title.bottomAnchor, offset: 4)
                .trailing(-80)
        }

        // 右侧按钮
        let btn = UIButton(type: .system)
        btn.setTitle("Go", for: .normal)
        btn.backgroundColor = colors[1]
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 14
        btn.titleLabel?.font = .boldSystemFont(ofSize: 13)
        card.box.addSubviewLayout(btn) { box in
            box.trailing(-12).centerY().size(w: 56, h: 28)
        }

        return card
    }

    // MARK: - 辅助

    /// 生成一块灰底“画布”：内部代码可任意用 box 摆放子 view
    private func makeCanvas(height: CGFloat, config: (UIView) -> Void) -> UIView {
        let canvas = UIView()
        canvas.backgroundColor = .compatGray5
        canvas.layer.cornerRadius = 6
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.heightAnchor.constraint(equalToConstant: height).isActive = true
        config(canvas)
        return canvas
    }

    private func makeButton(_ title: String, action: @escaping () -> Void) -> UIButton {
        let btn = ClosureButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = .compatGray5
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.layer.cornerRadius = 6
        btn.titleLabel?.font = .systemFont(ofSize: 13)
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        btn.action = action
        btn.addTarget(btn, action: #selector(ClosureButton.trigger), for: .touchUpInside)
        return btn
    }
}

// MARK: - Demo 辅助类型

/// 带 closure 的 UIButton（避免每个 demo 都再造一个 target）
private final class ClosureButton: UIButton {
    var action: (() -> Void)?
    @objc func trigger() { action?() }
}

private extension UIView {
    /// 生成带文字的小色块（不预设尺寸约束，方便 LayoutBox 完全掌控大小）
    static func tinyBox(_ color: UIColor, text: String) -> UILabel {
        let l = UILabel()
        l.backgroundColor = color
        l.textColor = .white
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.text = text
        l.layer.cornerRadius = 4
        l.clipsToBounds = true
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.6
        return l
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
            
            Spacer()
            
            // 弹性空白，将 R 推到末尾
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


// MARK: - ㉑ ZStackView DSL 添加子视图

/// ZStackView 只负责用 DSL 添加子视图（后添加的在上层），
/// 子视图的位置/尺寸可以直接在 DSL 里用 view.box 链式书写。
class ZStackDemoVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let stack = makeScrollableContainerStack()

        // ① DSL 中直接写 box 约束
        stack.addView(sectionLabel("① DSL 中直接写 view.box 约束：按书写顺序添加，后面的在上层"))
        let bg = UIView()
        bg.backgroundColor = .compatGray5
        bg.layer.cornerRadius = 8
        let red = UIView.colored(.systemRed, text: "1", size: .zero)
        let blue = UIView.colored(.systemBlue, text: "2", size: .zero)
        let green = UIView.colored(.systemGreen, text: "3", size: .zero)
        let z1 = ZStackView {
            bg.box.edgesZero()
            red.box.top(16).leading(16).size(w: 80, h: 60)
            blue.box.top(32).leading(48).size(w: 80, h: 60)
            green.box.top(48).leading(80).size(w: 80, h: 60)
        }
        z1.box.height(120)
        stack.addView(z1)

        // ② 条件 / 循环 / 可选
        stack.addView(sectionLabel("② DSL 支持 if / if-else / for-in / 可选 view（nil 自动忽略）\n未被添加的分支不会生成任何约束"))
        let showBadge = true
        let isVip = false
        let optionalView: UIView? = nil
        let cards = (0..<4).map { UIView.colored(colors[$0], text: "\($0)", size: .zero) }

        let z2 = ZStackView {
            for (i, card) in cards.enumerated() {
                card.box.top(10 + i * 10).leading(10 + i * 20).size(w: 70, h: 50)
            }
            if showBadge {
                UIView.colored(.black, text: "if", size: .zero)
                    .box.top(8).trailing(-8).size(w: 30, h: 20)
            }
            if isVip {
                UIView.colored(.systemYellow, text: "VIP", size: .zero)
                    .box.bottom(-8).trailing(-8).size(w: 44, h: 20)
            } else {
                UIView.colored(.gray, text: "else", size: .zero)
                    .box.bottom(-8).trailing(-8).size(w: 44, h: 20)
            }
            optionalView
        }
        z2.backgroundColor = .compatGray5
        z2.layer.cornerRadius = 8
        z2.box.height(120)
        stack.addView(z2)

        // ③ 混写：view / box / addViews 追加
        stack.addView(sectionLabel("③ view 与 box 可混写；addViews { } 追加子视图，支持链式"))
        let plain = UIView.colored(.systemTeal, text: "固定尺寸", size: CGSize(width: 70, height: 30))
        let z3 = ZStackView {
            UIView.colored(.systemIndigo, text: "center", size: .zero)
                .box.center().size(w: 160, h: 50)
            plain                       // 普通 view，后面再自己约束也可以
        }
        .addViews {
            UIView.colored(.systemPink, text: "addViews 追加", size: .zero)
                .box.top(6).trailing(-6).size(w: 100, h: 24)
        }
        plain.box.bottom(-6).leading(6)
        z3.backgroundColor = .compatGray5
        z3.layer.cornerRadius = 8
        z3.box.height(80)
        stack.addView(z3)

        // ④ 内边距 insets：构造时设置 + 动态修改
        stack.addView(sectionLabel("④ insets 内边距：ZStackView(insets:) { } 构造时设置（可选）\n子视图的 top/leading/edges/center 等相对 insetsGuide 布局，拖动滑块动态修改"))
        let insetBg = UIView()
        insetBg.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.25)
        insetBg.layer.borderColor = UIColor.systemBlue.cgColor
        insetBg.layer.borderWidth = 1
        let z4 = ZStackView(insets: .init(t: 10, s: 10, b: 10, e: 10)) {
            insetBg.box.edgesZero()                     // 贴 insetsGuide，直观显示内容区
            UIView.colored(.systemRed, text: "TL", size: .zero)
                .box.top(0).leading(0).size(w: 36, h: 24)
            UIView.colored(.systemGreen, text: "BR", size: .zero)
                .box.bottom(0).trailing(0).size(w: 36, h: 24)
            UIView.colored(.systemIndigo, text: "center", size: .zero)
                .box.center().size(w: 70, h: 30)
        }
        z4.backgroundColor = .compatGray5
        z4.layer.cornerRadius = 8
        z4.box.height(140)
        stack.addView(z4)

        let insetLabel = UILabel()
        insetLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        insetLabel.text = "insets = 10"
        stack.addView(insetLabel)

        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 40
        slider.value = 10
        slider.addAction(UIAction { [weak z4, weak insetLabel] action in
            guard let s = action.sender as? UISlider, let z4 = z4 else { return }
            let v = CGFloat(Int(s.value))
            insetLabel?.text = "insets = \(Int(v))"
            z4.insets = .init(t: v, s: v, b: v, e: v)   // 修改即生效
            UIView.animate(withDuration: 0.15) { z4.layoutIfNeeded() }
        }, for: .valueChanged)
        stack.addView(slider)

        let seg = UISegmentedControl(items: ["四边相同", "仅上下", "仅左右", "不对称"])
        seg.selectedSegmentIndex = 0
        seg.addAction(UIAction { [weak z4, weak slider, weak insetLabel] action in
            guard let z4 = z4, let seg = action.sender as? UISegmentedControl else { return }
            let v = CGFloat(Int(slider?.value ?? 10))
            switch seg.selectedSegmentIndex {
            case 1:  z4.insets = .init(t: v, s: 0, b: v, e: 0)
            case 2:  z4.insets = .init(t: 0, s: v, b: 0, e: v)
            case 3:  z4.insets = .init(t: 4, s: 30, b: 20, e: 8)
            default: z4.insets = .init(t: v, s: v, b: v, e: v)
            }
            let i = z4.insets
            insetLabel?.text = "insets = (t:\(Int(i.t)) l:\(Int(i.s)) b:\(Int(i.b)) r:\(Int(i.e)))"
            UIView.animate(withDuration: 0.25) { z4.layoutIfNeeded() }
        }, for: .valueChanged)
        stack.addView(seg)

        // ⑤ 注意事项
        stack.addView(sectionLabel("""
        ⑤ 注意事项
        1. ZStackView 只负责添加子视图，不做布局；约束可以直接在 DSL 里用 view.box 写。
        2. 层级 = 书写顺序，后写的在上层。
        3. top / leading / bottom / trailing / centerX / centerY / center / edges 等相对父视图的约束，
           在 DSL 中会先暂存，等加入 ZStackView 后才生成。
        4. xxxTo(anchor) 引用其他 view 的 anchor 时，两个 view 必须最终处于同一视图树中。
        5. DSL 中只能写 UIView / view.box / 可选 UIView，不支持数字 / Spacer。
        6. insets 作用于 insetsGuide：相对父视图的 top/leading/bottom/trailing/center/edges 会自动内缩；
           xxxTo(anchor) 传入的是什么锚点就约束到什么，不受 insets 影响。
        7. 修改 insets 只更新约束 constant，想要动画请在 animate 中调用 layoutIfNeeded()。
        """))
    }
}

// MARK: - ㉒ WStackView 自动换行

/// WStackView 完整 demo：覆盖全部属性 / 方法 / DSL / 多行垂直布局 / 嵌套 / cell 自动算高
class WrapDemoVC: UIViewController {

    private let words = ["Swift", "iOS", "Auto Layout", "Flex", "ZLFlexKit", "UIKit",
                         "DSL", "弹性布局", "自动换行", "LayoutGuide", "SnapKit", "RxSwift", "CocoaPods"]

    // MARK: 辅助

    /// 有内容尺寸的标签（没有固定宽高约束，可被 fill / fillEqually / flex 拉伸）
    private func tag(_ text: String, _ color: UIColor = .systemBlue, font: CGFloat = 13) -> UILabel {
        let l = PaddingTagLabel()
        l.text = text
        l.font = .systemFont(ofSize: font, weight: .medium)
        l.textColor = .white
        l.backgroundColor = color
        l.textAlignment = .center
        l.layer.cornerRadius = 6
        l.clipsToBounds = true
        return l
    }

    /// 灰底圆角容器，方便看清 WStackView 的边界
    @discardableResult
    private func wrapBox(_ w: WStackView) -> WStackView {
        w.backgroundColor = .compatGray5
        w.layer.cornerRadius = 8
        return w
    }

    private func note(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 12)
        l.textColor = .systemRed
        l.numberOfLines = 0
        return l
    }

    /// 标题 + 滑块 + 当前值
    private func slider(_ title: String, min: Float, max: Float, value: Float,
                        onChange: @escaping (CGFloat) -> Void) -> UIView {
        let name = UILabel()
        name.text = title
        name.font = .systemFont(ofSize: 12)
        name.box.width(92)
        let valueLabel = UILabel()
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        valueLabel.text = "\(Int(value))"
        valueLabel.box.width(28)
        let s = UISlider()
        s.minimumValue = min
        s.maximumValue = max
        s.value = value
        s.addAction(UIAction { [weak valueLabel] a in
            guard let s = a.sender as? UISlider else { return }
            let v = CGFloat(Int(s.value))
            valueLabel?.text = "\(Int(v))"
            onChange(v)
        }, for: .valueChanged)
        return HStackView {
            name
            s.flex.flex(1)
            valueLabel
        }.spacing(6)
    }

    private func segment(_ items: [String], selected: Int = 0,
                         onChange: @escaping (Int) -> Void) -> UISegmentedControl {
        let seg = UISegmentedControl(items: items)
        seg.selectedSegmentIndex = selected
        seg.apportionsSegmentWidthsByContent = true
        seg.addAction(UIAction { a in
            guard let s = a.sender as? UISegmentedControl else { return }
            onChange(s.selectedSegmentIndex)
        }, for: .valueChanged)
        return seg
    }

    private func animateLayout() {
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    // MARK: viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatBackground
        let stack = makeScrollableContainerStack()
        
        
        do {
            
            let view =  WStackView (justify: .start,
                                       align: .center,
                                       spacing: 10,
                                       lineSpacing: 10){
                UISwitch()
                Spacer()
                UISwitch()
                Spacer()
                UISwitch()
                UISwitch().flex.exclusiveLine()
            }
            
            stack.addArrangedSubview(view)
        }

        section1_DSL(stack)
        section2_Playground(stack)
        section3_MultiLineVertical(stack)
        section3b_LineJustify(stack)
        section4_FillFlex(stack)
        section5_MarginSpacing(stack)
        section5d_ElasticSpacing(stack)
        section5b_DynamicFlexItem(stack)
        section5c_ExclusiveLine(stack)
        section6_Dynamic(stack)
        section7_ContentChange(stack)
        section8_NestedWrapInWrap(stack)
        section9_NestedCards(stack)
        section10_NestedStackView(stack)
        section11_CellAutoHeight(stack)
        section12_Notes(stack)
        
//        let view =  WStackView (align: .start,spacing: 10,lineSpacing: 10,){
//            UISwitch()
//            UIView().flex.flex(1)
//            UISwitch()
//            UIView().flex.flex(1)
//            UISwitch()
//            UISwitch().flex.exclusiveLine()
//            UISwitch()
//            UISwitch().flex.align(.start)
//            UISwitch().flex.exclusiveLine()
//        }
//        stack.addArrangedSubview(view)
//
    }

    // MARK: ① DSL + 链式

    private func section1_DSL(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ① DSL 构造 + 链式配置
        · 构造：WStackView(justify:align:spacing:lineSpacing:lineJustify:insets:) { }
        · 链式：.justify() .align() .gap() .lineGap() .lineJustify() .insets() .wrap() .maxLayoutWidth()
        · DSL 内支持 UIView / FlexItem / for-in / if / 可选 view / 数字间距 / Spacer(值) / N.minSpacing / N.maxSpacing / Spacer()
        """))
        let showHot = true
        let optionalView: UIView? = nil
        let w = wrapBox(WStackView {
            for (i, word) in words.prefix(6).enumerated() {
                tag(word, colors[i % colors.count])
            }
            if showHot { tag("🔥 if 条件", .systemRed) }
            optionalView                                  // nil 自动忽略
            tag("FlexItem", .systemIndigo).flex.margin(.init(t: 0, s: 0, b: 0, e: 0))
            tag("⬇︎ exclusiveLine() 独占一行", .systemPurple).flex.exclusiveLine()
            24                                            // 前一个 view 后面间距 24
            tag("前面间距 24", .systemGray)
            Spacer(4)                                     // Spacer(值) 等价数字
            tag("前面间距 4", .systemGray)
        }
        .justify(.start)
        .align(.center)
        .gap(8)
        .lineGap(8)
        .insets(.all(10)))
        stack.addView(w)
    }

    // MARK: ② 属性面板

    private func section2_Playground(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ② 属性面板：所有容器属性实时调节
        justifyContent / alignment / spacing / lineSpacing / insets / isWrapEnabled / numberOfLines
        （选中 fill 时 "Swift" 和 "UIKit" 设置 flex = 1，观察 fill 效果；
          其余模式下 flex = 0 —— 有 flex 的行会被撑满，justify 对该行不再生效）
        """))

        let fonts: [CGFloat] = [13, 18, 11, 22, 14, 12, 16, 11, 20, 13]
        let items = (0..<10).map { i -> UILabel in
            tag(words[i], colors[i % colors.count], font: fonts[i])
        }

        let w = wrapBox(WStackView(spacing: 8, lineSpacing: 8, insets: .all(10)) {
            for v in items { v }
        })

        let info = note("")
        let refreshInfo = { [weak w, weak info] in
            guard let w = w else { return }
            info?.text = "numberOfLines = \(w.numberOfLines)   arrangedViews = \(w.arrangedViews.count)"
        }
        w.linesDidChange = { _ in refreshInfo() }

        let justifies: [(String, Justify)] = [("start", .start), ("center", .center), ("end", .end),
                                              ("between", .spaceBetween), ("around", .spaceAround),
                                              ("evenly", .spaceEvenly), ("fill", .fill), ("fillEq", .fillEqually)]
        let aligns: [(String, FlexItemCrossAlign)] = [("start", .start), ("center", .center),
                                                      ("end", .end), ("fill", .fill)]

        stack.addView(segment(justifies.map { $0.0 }) { [weak self] i in
            w.justifyContent = justifies[i].1
            let flexValue = justifies[i].1 == .fill ? 1 : 0
            items[0].flex.flex = flexValue
            items[5].flex.flex = flexValue
            self?.animateLayout()
        })
        stack.addView(segment(aligns.map { "align " + $0.0 }, selected: 1) { [weak self] i in
            w.alignment = aligns[i].1
            self?.animateLayout()
        })
        stack.addView(slider("spacing", min: 0, max: 30, value: 8) { [weak self] v in
            w.spacing = v; self?.animateLayout()
        })
        stack.addView(slider("lineSpacing", min: 0, max: 30, value: 8) { [weak self] v in
            w.lineSpacing = v; self?.animateLayout()
        })
        stack.addView(slider("insets", min: 0, max: 40, value: 10) { [weak self] v in
            w.insets = .init(top: v, leading: v, bottom: v, trailing: v); self?.animateLayout()
        })

        let sw = UISwitch()
        sw.isOn = true
        sw.addAction(UIAction { [weak self] a in
            guard let s = a.sender as? UISwitch else { return }
            w.isWrapEnabled = s.isOn
            self?.animateLayout()
        }, for: .valueChanged)
        let swLabel = UILabel()
        swLabel.text = "isWrapEnabled（关闭 = 强制单行，放不下压缩）"
        swLabel.font = .systemFont(ofSize: 12)
        stack.addView(HStackView { swLabel; Spacer(); sw })

        stack.addView(info)
        stack.addView(w)
        DispatchQueue.main.async { refreshInfo() }
    }

    // MARK: ③ 多行垂直方向布局

    private func section3_MultiLineVertical(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ③ 多行垂直方向布局
        · 行从上往下排列：第一行贴 insets.top，行与行之间隔 lineSpacing，最后一行贴 insets.bottom
        · 每行行高 = 本行最高的 view（含 margin.top / bottom）
        · alignment 决定矮的 view 在本行里靠上 / 居中 / 靠下 / 拉满
        · 橙色 alignSelf = .end 单独覆盖；紫色 margin.top = 16 在行内往下偏移
        · 容器高度 = 所有行高 + 行间距 + 上下 insets，自动撑开，下方内容跟着移动
        """))

        let heights: [CGFloat] = [30, 60, 24, 44, 36, 70, 28, 50, 40]
        let widths: [CGFloat] = [60, 50, 90, 70, 80, 56, 100, 64, 72]
        let blocks = (0..<heights.count).map { i in
            UIView.colored(colors[i % colors.count], text: "h\(Int(heights[i]))",
                           size: CGSize(width: widths[i], height: heights[i]))
        }
        blocks[2].backgroundColor = .systemOrange
        blocks[2].flex.alignSelf = .end
        blocks[4].backgroundColor = .systemPurple
        blocks[4].flex.margin = .init(top: 16, leading: 0, bottom: 0, trailing: 0)

        let w = wrapBox(WStackView(align: .start, spacing: 8, lineSpacing: 12, insets: .all(10)) {
            for b in blocks { b }
        })

        let aligns: [(String, FlexItemCrossAlign)] = [("start", .start), ("center", .center), ("end", .end)]
        stack.addView(segment(aligns.map { "行内 align " + $0.0 }) { [weak self] i in
            w.alignment = aligns[i].1
            self?.animateLayout()
        })
        stack.addView(slider("lineSpacing", min: 0, max: 40, value: 12) { [weak self] v in
            w.lineSpacing = v; self?.animateLayout()
        })

        let lineInfo = note("")
        w.linesDidChange = { [weak lineInfo] n in lineInfo?.text = "当前 \(n) 行，容器高度随行数变化" }
        stack.addView(lineInfo)

        var tallCount = 0
        let add = UIButton(type: .system)
        add.setTitle("➕ 追加一个高 80 的块（行数 / 行高 / 容器高度一起变）", for: .normal)
        add.titleLabel?.font = .systemFont(ofSize: 13)
        add.addAction(UIAction { [weak self] _ in
            tallCount += 1
            w.addArrangedSubview(UIView.colored(.systemTeal, text: "h80-\(tallCount)",
                                                size: CGSize(width: 70, height: 80)))
            self?.animateLayout()
        }, for: .touchUpInside)
        stack.addView(add)
        stack.addView(w)

        let below = UILabel()
        below.text = "⬆️ 我在 WStackView 下方，它变高时我会自动下移"
        below.font = .systemFont(ofSize: 12)
        below.textColor = .gray
        stack.addView(below)
    }

    // MARK: ③-2 lineJustifyContent：多行之间的垂直分布

    private func section3b_LineJustify(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ③-2 lineJustifyContent：多行在垂直方向的分布（类似 CSS align-content）
        · justifyContent 管"行内"水平分布，lineJustifyContent 管"行与行"垂直分布
        · 只有容器高度 > 内容高度（高度由外部约束确定）时才看得出区别
        · start / center / end：整体靠上 / 居中 / 靠下
        · between / around / evenly：多余高度分到行间（lineSpacing 是最小行间距）
        · fill：多余高度平均加到每一行，行内 view 按 alignment 在拉伸后的行内对齐
        · fillEqually：所有行等高
        · 构造：WStackView(lineJustify: .center) { }　链式：.lineJustify(.center)
        """))

        let heights: [CGFloat] = [28, 40, 24, 36, 30, 44, 26, 34]
        let widths: [CGFloat] = [70, 90, 60, 100, 80, 64, 96, 72]
        let blocks = (0..<heights.count).map { i in
            UIView.colored(colors[i % colors.count], text: "h\(Int(heights[i]))",
                           size: CGSize(width: widths[i], height: heights[i]))
        }

        let w = wrapBox(WStackView(align: .center, spacing: 8, lineSpacing: 8, insets: .all(10)) {
            for b in blocks { b }
        }
        .lineJustify(.start))

        let modes: [(String, Justify)] = [("start", .start), ("center", .center), ("end", .end),
                                          ("between", .spaceBetween), ("around", .spaceAround),
                                          ("evenly", .spaceEvenly), ("fill", .fill), ("fillEq", .fillEqually)]
        let aligns: [(String, FlexItemCrossAlign)] = [("start", .start), ("center", .center), ("end", .end),("fill", .fill)]

        let info = note("")
        let refreshInfo = { [weak w, weak info] in
            guard let w = w else { return }
            info?.text = "lineJustifyContent = \(modes.first { $0.1 == w.lineJustifyContent }?.0 ?? "-")，"
                + "\(w.numberOfLines) 行，容器高 \(Int(w.bounds.height))"
        }

        stack.addView(segment(modes.map { $0.0 }) { [weak self] i in
            w.lineJustifyContent = modes[i].1
            self?.animateLayout()
            refreshInfo()
        })
        stack.addView(segment(aligns.map { "行内 align " + $0.0 }, selected: 1) { [weak self] i in
            w.alignment = aligns[i].1
            self?.animateLayout()
        })

        // 容器固定高度（由外部约束确定），高度 > 内容时 lineJustifyContent 才有效果
        let heightConstraint = w.heightAnchor.constraint(equalToConstant: 300)
        stack.addView(slider("容器高度", min: 120, max: 420, value: 300) { [weak self] v in
            heightConstraint.constant = v
            self?.animateLayout()
            refreshInfo()
        })
        stack.addView(slider("lineSpacing", min: 0, max: 30, value: 8) { [weak self] v in
            w.lineSpacing = v
            self?.animateLayout()
            refreshInfo()
        })

        let sw = UISwitch()
        sw.isOn = true
        sw.addAction(UIAction { [weak self] a in
            guard let s = a.sender as? UISwitch else { return }
            heightConstraint.isActive = s.isOn
            self?.animateLayout()
            refreshInfo()
        }, for: .valueChanged)
        let swLabel = UILabel()
        swLabel.text = "固定容器高度（关闭 = 内容撑开，各模式效果相同）"
        swLabel.font = .systemFont(ofSize: 12)
        swLabel.numberOfLines = 0
        stack.addView(HStackView { swLabel.flex.flex(1); 8; sw })

        stack.addView(info)
        stack.addView(w)
        heightConstraint.isActive = true
        DispatchQueue.main.async { refreshInfo() }
    }

    // MARK: ④ fill / flex / fillEqually

    private func section4_FillFlex(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ④ fill + flex / fillEqually：都是"按行"生效
        · fill：本行 flex > 0 的 view 按比例瓜分剩余空间，本行没有 flex 时按 start 排列
        · fillEqually：本行所有 view 等宽填满（不要给子 view 固定宽度，否则约束冲突）
        """))
        stack.addView(WStackView {
            tag("固定", .systemGray)
            tag("flex 1").flex.flex(1)
            tag("flex 2", .systemGreen).flex.flex(2)
            tag("这一项比较长，放不下会换到下一行", .systemOrange)
            tag("flex 1", .systemPink).flex.flex(1)
        }
        .justify(.fill).gap(8).lineGap(8).insets(.all(10))
        .then { wrapBox($0) })

        stack.addView(WStackView {
            for (i, word) in words.prefix(7).enumerated() { tag(word, colors[i % colors.count]) }
        }
        .justify(.fillEqually).gap(6).lineGap(6).insets(.all(10))
        .then { wrapBox($0) })
    }

    // MARK: ⑤ margin / 单项 spacing

    private func section5_MarginSpacing(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ⑤ 复用 FlexItem 的 margin / spacing
        · view.flex.margin：四个方向外边距（leading/trailing 参与分行宽度计算）
        · view.flex.spacing：该 view 后面的间距，优先于容器 spacing（换行后不生效于行首）
        · 布局完成后再修改 view.flex 属性会自动重新布局，无需手动刷新
        """))
        let a = tag("margin 左右 12", .systemPurple)
        a.flex.margin = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
        let b = tag("spacing 30 →", .systemGreen)
        b.flex.spacing = 30
        let w = wrapBox(WStackView(spacing: 6, lineSpacing: 6, insets: .all(10)) {
            tag("A"); a; tag("B"); b; tag("C"); tag("D"); tag("E")
        })
        stack.addView(segment(["margin 12", "margin 0", "margin 30"]) { [weak self] i in
            let v: CGFloat = [12, 0, 30][i]
            a.flex.margin = .init(top: 0, leading: v, bottom: 0, trailing: v)
            // 只改 view.flex，WStackView 通过 FlexContainer 自动收到通知并重新布局
            self?.animateLayout()
        })
        stack.addView(w)
    }

    // MARK: ⑤-4 弹性间距：minSpacing / maxSpacing / Spacer()

    private func section5d_ElasticSpacing(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ⑤-4 弹性间距：DSL 里的 3.minSpacing / 3.maxSpacing / Spacer()，以及对应的 view.flex 属性
        · 数字 / Spacer(值)：固定间距
        · N.minSpacing（flex.minSpacing）：间距 ≥ N；平时取 clamp(spacing, N)，fill 时拉伸撑满，空间不足时压缩到 N
        · N.maxSpacing（flex.maxSpacing）：0 ≤ 间距 ≤ N；空间不足时先压缩间距，再压缩内容
        · Spacer()（flex.isFlexibleSpace）：纯弹性空白，占满本行剩余空间；同一行多个时等宽
        · 多个弹性间距相对首选值的伸缩量相同；分行时按最小间距计算
        """))

        // a. Spacer()：一行多个等宽，把内容推向两端 / 中间
        stack.addView(note("a. Spacer() × 2：左 / 中 / 右，两个 Spacer 等宽"))
        stack.addView(wrapBox(WStackView(insets: .all(10)) {
            tag("左", .systemBlue)
            Spacer()
            tag("中间", .systemGreen)
            Spacer()
            tag("右", .systemOrange)
        }))

        // b. minSpacing + fill：间距拉伸撑满，内容不被拉伸
        stack.addView(note("b. justify = fill + 10.minSpacing / 30.minSpacing：两个间距在最小值基础上拉伸相同的量"))
        stack.addView(wrapBox(WStackView(justify: .start, insets: .all(10)) {
            tag("A", .systemPurple)
            10.minSpacing
            tag("B", .systemPurple)
            30.minSpacing
            tag("C", .systemPurple)
        }))

        // c. maxSpacing：空间不足时先压缩间距
        stack.addView(note("c. spacing = 40 + 40.maxSpacing：拖动宽度，放不下时间距先被压缩（最小到 0），仍放不下才换行"))
        let compress = wrapBox(WStackView(spacing: 40, insets: .all(10)) {
            tag("Swift UI", .systemTeal)
            40.maxSpacing
            tag("Auto Layout", .systemTeal)
            40.maxSpacing
            tag("Wrap", .systemTeal)
        })
        let holder = UIView()
        holder.addSubview(compress)
        compress.translatesAutoresizingMaskIntoConstraints = false
        let widthCons = compress.widthAnchor.constraint(equalToConstant: 320)
        NSLayoutConstraint.activate([
            compress.topAnchor.constraint(equalTo: holder.topAnchor),
            compress.bottomAnchor.constraint(equalTo: holder.bottomAnchor),
            compress.leadingAnchor.constraint(equalTo: holder.leadingAnchor),
            widthCons,
            compress.trailingAnchor.constraint(lessThanOrEqualTo: holder.trailingAnchor),
        ])
        stack.addView(slider("容器宽度", min: 180, max: 340, value: 320) { [weak self] v in
            widthCons.constant = v
            self?.animateLayout()
        })
        stack.addView(holder)

        // d. Spacer() 与 flex 共存：剩余空间归 flex view，Spacer 收缩为 0
        stack.addView(note("d. Spacer() + flex(1)：剩余空间优先给 flex view，Spacer 收缩为最小值"))
        stack.addView(wrapBox(WStackView(insets: .all(10)) {
            tag("Spacer 前", .systemGray)
            Spacer()
            tag("flex 1", .systemGreen).flex.flex(1)
            tag("尾", .systemGray)
        }))

        // e. 通过 view.flex 动态切换间距类型
        stack.addView(note("e. 用 view.flex 动态切换 \"A\" 后面的间距类型（自动重新布局）"))
        let a = tag("A", .systemPink)
        let w = wrapBox(WStackView(spacing: 8, insets: .all(10)) {
            a
            tag("B", .systemPink)
            tag("C", .systemPink)
        })
        let info = note("")
        let kinds = ["固定 8", "min 24", "max 4", "Spacer()", "Spacer(min:40)"]
        let apply: (Int) -> Void = { [weak self, weak info] i in
            // 先重置，再设置当前类型
            a.flex.isFlexibleSpace = false
            a.flex.minSpacing = 0
            a.flex.maxSpacing = 0
            switch i {
            case 1: a.flex.minSpacing = 24
            case 2: a.flex.maxSpacing = 4
            case 3: a.flex.isFlexibleSpace = true
            case 4: a.flex.isFlexibleSpace = true; a.flex.minSpacing = 40
            default: break
            }
            info?.text = "A 后面：\(kinds[i])   flex.minSpacing=\(Int(a.flex.minSpacing))  flex.maxSpacing=\(Int(a.flex.maxSpacing))  isFlexibleSpace=\(a.flex.isFlexibleSpace)"
            self?.animateLayout()
        }
        stack.addView(segment(kinds) { apply($0) })
        stack.addView(w)
        stack.addView(info)
        apply(0)
    }

    // MARK: ⑤-2 布局完成后动态修改 view.flex

    private func section5b_DynamicFlexItem(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ⑤-2 布局完成后动态修改 view.flex（全部自动重新布局，不调用任何刷新方法）
        先点选一个标签（红框为当前选中），再修改它的 flex / margin / spacing / alignSelf / exclusiveLine / width / height
        · 容器 justify = fill：flex > 0 的 view 按比例瓜分本行剩余空间
        · width 变大放不下会自动换行，变小又会合并回上一行
        · 一次改多个属性（"批量"按钮）只会重建一次约束
        """))

        let names = ["Swift", "UIKit", "Flex", "Wrap", "DSL", "Guide"]
        let items = names.enumerated().map { tag($1, colors[$0 % colors.count]) }
        let w = wrapBox(WStackView(justify: .fill, align: .start, spacing: 8, lineSpacing: 8, insets: .all(10)) {
            for v in items { v }
        })

        var selected: UIView = items[0]
        let state = note("")
        let refresh = { [weak w, weak state] in
            guard let w = w else { return }
            let f = selected.flex
            let m = f.margin
            let a: [FlexItemCrossAlign: String] = [.start: "start", .center: "center", .end: "end", .fill: "fill"]
            state?.text = """
            选中「\((selected as? UILabel)?.text ?? "")」 flex=\(f.flex)  spacing=\(Int(f.spacing))  \
            margin(t\(Int(m.top)) l\(Int(m.leading)) b\(Int(m.bottom)) r\(Int(m.trailing)))  \
            alignSelf=\(a[f.alignSelf] ?? "")\(f.explicitAlignSelf == nil ? "(跟随容器)" : "")  \
            独占一行=\(f.exclusiveLine ? "是" : "否")  实际宽=\(Int(selected.frame.width))  lines=\(w.numberOfLines)
            """
        }
        let select = { (v: UIView) in
            items.forEach { $0.layer.borderWidth = 0 }
            v.layer.borderWidth = 2
            v.layer.borderColor = UIColor.systemRed.cgColor
            selected = v
            refresh()
        }
        for v in items {
            v.isUserInteractionEnabled = true
            v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dynamicTagTapped(_:))))
        }
        dynamicSelect = select
        w.linesDidChange = { _ in refresh() }

        let apply = { [weak self] (change: (FlexItem) -> Void) in
            change(selected.flex)                       // 只改 view.flex
            self?.animateLayout()
            DispatchQueue.main.async { refresh() }
        }

        stack.addView(segment(["flex 0", "flex 1", "flex 2", "flex 3"], selected: -1) { i in
            apply { $0.flex = i }
        }.then { $0.isMomentary = true })
        stack.addView(segment(["margin 0", "左右 12", "上 16", "四周 6"], selected: -1) { i in
            let m: [NSDirectionalEdgeInsets] = [
                .zero, .init(top: 0, leading: 12, bottom: 0, trailing: 12),
                .init(top: 16, leading: 0, bottom: 0, trailing: 0), .init(top: 6, leading: 6, bottom: 6, trailing: 6)]
            apply { $0.margin = m[i] }
        }.then { $0.isMomentary = true })
        stack.addView(segment(["后间距 0", "后间距 20", "后间距 40"], selected: -1) { i in
            apply { $0.spacing = [0, 20, 40][i] }
        }.then { $0.isMomentary = true })
        stack.addView(segment(["align start", "center", "end", "fill"], selected: -1) { i in
            apply { $0.alignSelf = [.start, .center, .end, .fill][i] }
        }.then { $0.isMomentary = true })
        stack.addView(segment(["独占一行 开", "独占一行 关"], selected: -1) { i in
            apply { $0.exclusiveLine = (i == 0) }      // flex 属性控制，自动重新分行
        }.then { $0.isMomentary = true })
        stack.addView(segment(["宽 auto", "宽 60", "宽 160", "宽 260", "高 44"], selected: -1) { i in
            apply { f in
                switch i {
                case 0: f.view?.box.clear()      // 清掉 width/height 约束，回到内容宽度
                case 4: f.height(44)
                default: f.width([60, 160, 260][i - 1]) // updateSize：更新已有宽度约束，避免重复添加
                }
            }
        }.then { $0.isMomentary = true })
        stack.addView(segment(["批量：flex2+margin+end", "全部重置"], selected: -1) { [weak self] i in
            if i == 0 {
                // 同一 runloop 内多次修改，只会在下一次布局时重建一次
                selected.flex.flex = 2
                selected.flex.margin = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
                selected.flex.alignSelf = .end
                selected.flex.spacing = 16
            } else {
                for v in items {
                    v.flex.flex = 0
                    v.flex.margin = .zero
                    v.flex.spacing = 0
                    v.flex.alignSelf = .start
                    v.flex.exclusiveLine = false
                    v.box.clear()
                }
            }
            self?.animateLayout()
            DispatchQueue.main.async { refresh() }
        }.then { $0.isMomentary = true })

        stack.addView(state)
        stack.addView(w)
        DispatchQueue.main.async { select(items[0]) }
    }

    private var dynamicSelect: ((UIView) -> Void)?

    // MARK: ⑤-3 单独一行 exclusiveLine

    private func section5c_ExclusiveLine(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ⑤-3 让某个 view 单独占一行（exclusiveLine）
        · 两种写法：view.flex.exclusiveLine = true / .flex.exclusiveLine()，或 wrap.setExclusiveLine(true, for: view)
        · 独占的 view 前后都会换行；行内仍按 justifyContent 排列（fill + flex 时会撑满整行）
        · 点击任意标签切换它是否独占一行（这里用的是 setExclusiveLine 方法），自动重新分行
        """))

        // 典型场景：标题独占一行 + 标签流 + 分割线独占一行 + 底部按钮撑满
        let title = tag("📌 标题：DSL 中 .flex.exclusiveLine() 独占一行", .systemIndigo)
        let divider = UIView()
        divider.backgroundColor = .lightGray
        divider.flex.height(1).flex(1).exclusiveLine()        // 分割线：独占一行 + flex 撑满
        let button = tag("撑满整行的按钮（独占 + flex）", .systemGreen)

        let tags = ["Swift", "UIKit", "Flex", "Wrap", "DSL", "Guide", "Layout", "Stack"].enumerated().map {
            tag($1, colors[$0 % colors.count])
        }
        let w = wrapBox(WStackView(justify: .fill, align: .center, spacing: 8, lineSpacing: 8, insets: .all(10)) {
            title.flex.exclusiveLine()                        // DSL 中直接声明独占一行
            for t in tags { t }
            divider
            button.flex.flex(1).exclusiveLine()
        })

        let info = note("")
        let refresh = { [weak w, weak info] in
            guard let w = w else { return }
            let names = w.arrangedViews.compactMap { v -> String? in
                guard w.isExclusiveLine(for: v) else { return nil }
                return (v as? UILabel)?.text.map { String($0.prefix(6)) } ?? "分割线"
            }
            info?.text = "当前 \(w.numberOfLines) 行；独占一行的 view：\(names.joined(separator: "、"))"
        }
        w.linesDidChange = { _ in refresh() }

        exclusiveToggle = { [weak self, weak w] v in
            guard let w = w else { return }
            w.setExclusiveLine(!w.isExclusiveLine(for: v), for: v)   // 方法形式
            v.layer.borderWidth = w.isExclusiveLine(for: v) ? 2 : 0
            v.layer.borderColor = UIColor.systemRed.cgColor
            self?.animateLayout()
            DispatchQueue.main.async { refresh() }
        }
        for v in [title] + tags + [button] {
            v.isUserInteractionEnabled = true
            v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(exclusiveTagTapped(_:))))
        }

        stack.addView(segment(["第 3 个独占", "全部取消独占", "恢复初始"], selected: -1) { [weak self] i in
            switch i {
            case 0:
                w.setExclusiveLine(true, for: tags[2])
                tags[2].layer.borderWidth = 2
                tags[2].layer.borderColor = UIColor.systemRed.cgColor
            case 1:
                w.arrangedViews.forEach { w.setExclusiveLine(false, for: $0); $0.layer.borderWidth = 0 }
            default:
                w.arrangedViews.forEach { w.setExclusiveLine(false, for: $0); $0.layer.borderWidth = 0 }
                [title, divider, button].forEach { $0.flex.exclusiveLine = true }   // flex 属性形式
            }
            self?.animateLayout()
            DispatchQueue.main.async { refresh() }
        }.then { $0.isMomentary = true })
        stack.addView(info)
        stack.addView(w)
        DispatchQueue.main.async { refresh() }
    }

    private var exclusiveToggle: ((UIView) -> Void)?

    @objc private func exclusiveTagTapped(_ g: UITapGestureRecognizer) {
        if let v = g.view { exclusiveToggle?(v) }
    }

    @objc private func dynamicTagTapped(_ g: UITapGestureRecognizer) {
        if let v = g.view { dynamicSelect?(v) }
    }

    // MARK: ⑥ 动态增删

    private func section6_Dynamic(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ⑥ 动态操作：addArrangedSubview / insertArrangedSubview(at:) / removeArrangedSubview /
        removeAllArrangedSubviews / isHidden（自动刷新）；arrangedViews 不含隐藏，allArrangedViews 含隐藏
        """))
        let w = wrapBox(WStackView(spacing: 6, lineSpacing: 6, insets: .all(10)) {
            for w in words.prefix(4) { tag(w) }
        })
        let info = note("")
        let refresh = { [weak w, weak info] in
            guard let w = w else { return }
            info?.text = "arrangedViews = \(w.arrangedViews.count)   allArrangedViews = \(w.allArrangedViews.count)   lines = \(w.numberOfLines)"
        }
        w.linesDidChange = { _ in refresh() }
        var n = 4
        stack.addView(segment(["➕ 末尾", "⬅️ 插到开头", "➖ 删末尾", "👁 隐藏/显示首个", "🗑 清空"], selected: -1) { [weak self] i in
            guard let self = self else { return }
            switch i {
            case 0:
                w.addArrangedSubview(self.tag(self.words[n % self.words.count], colors[n % colors.count])); n += 1
            case 1:
                w.insertArrangedSubview(self.tag("插入\(n)", .systemRed), at: 0); n += 1
            case 2:
                w.removeArrangedSubview(w.allArrangedViews.last)
            case 3:
                w.allArrangedViews.first?.isHidden.toggle()
            default:
                w.removeAllArrangedSubviews()
            }
            self.animateLayout()
            DispatchQueue.main.async { refresh() }
        }.then { $0.isMomentary = true })
        stack.addView(info)
        stack.addView(w)
        DispatchQueue.main.async { refresh() }
    }

    // MARK: ⑦ 修改内容按需换行

    private func section7_ContentChange(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ⑦ 修改内容自动按需换行：只改 text，不调任何刷新方法
        放得下就不换行，放不下才换行；变短后自动合并回上一行
        """))
        let editTag = tag("编辑我", .systemRed)
        let w = wrapBox(WStackView(spacing: 8, lineSpacing: 8, insets: .all(10)) {
            tag("用户名", .systemBlue)
            editTag
            tag("VIP", .systemOrange)
            tag("刚刚", .systemGray)
        })
        let lines = note("行数：1（放得下 → 不换行）")
        w.linesDidChange = { [weak lines] n in
            lines?.text = "行数：\(n)  \(n > 1 ? "（放不下 → 已换行）" : "（放得下 → 不换行）")"
        }
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.text = "编辑我"
        field.clearButtonMode = .whileEditing
        field.addAction(UIAction { [weak self] a in
            guard let tf = a.sender as? UITextField else { return }
            editTag.text = (tf.text ?? "").isEmpty ? " " : tf.text
            self?.animateLayout()
        }, for: .editingChanged)
        stack.addView(field)
        stack.addView(segment(["加长", "缩短", "超长(独占一行)"], selected: -1) { [weak self, weak field] i in
            let text = editTag.text ?? ""
            switch i {
            case 0:  editTag.text = text + "很长"
            case 1:  editTag.text = text.count > 2 ? String(text.dropLast(2)) : "短"
            default: editTag.text = String(repeating: "超长内容", count: 8)
            }
            field?.text = editTag.text
            self?.animateLayout()
        }.then { $0.isMomentary = true })
        stack.addView(lines)
        stack.addView(w)

        // fill + flex 下改内容
        let title = tag("短标题", .systemIndigo)
        let w2 = wrapBox(WStackView {
            title
            tag("flex 1 占满剩余", .systemGreen).flex.flex(1)
        }.justify(.fill).gap(8).lineGap(8).insets(.all(10)))
        stack.addView(note("fill + flex 下改内容：剩余空间重新分给 flex view，太长时换行，变短后恢复"))
        stack.addView(segment(["短标题", "中等长度标题", "很长很长很长很长很长的标题"]) { [weak self] i in
            title.text = ["短标题", "中等长度标题", "很长很长很长很长很长的标题"][i]
            self?.animateLayout()
        })
        stack.addView(w2)
    }

    // MARK: ⑧ 嵌套：WStackView 里放 WStackView

    private func section8_NestedWrapInWrap(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ⑧ 嵌套 A：WStackView 里嵌套 WStackView（表单行）
        · 外层 fill：左侧标题固定，内层 Wrap 设置 flex = 1 占满剩余宽度
        · 内层自己换行，外层的行高跟着内层高度变化
        · 嵌套的 WStackView 按"最宽的单个子 view"参与外层分行（minContentWidth）
        """))
        let inner = WStackView {
            for (i, w) in ["Swift", "ObjC", "UIKit"].enumerated() { tag(w, colors[i]) }
        }.gap(6).lineGap(6)

        let titleLabel = UILabel()
        titleLabel.text = "技能："
        titleLabel.font = .boldSystemFont(ofSize: 14)

        let outer = wrapBox(WStackView {
            titleLabel
            inner.flex.flex(1)
        }.justify(.fill).align(.start).gap(8).insets(.all(10)))

        var n = 0
        let more = ["SwiftUI", "Combine", "RxSwift", "Auto Layout", "Core Animation", "Metal", "Instruments"]
        stack.addView(segment(["➕ 内层加标签", "➖ 内层删标签"], selected: -1) { [weak self] i in
            if i == 0 {
                inner.addArrangedSubview(self?.tag(more[n % more.count], colors[n % colors.count])); n += 1
            } else {
                inner.removeArrangedSubview(inner.allArrangedViews.last)
            }
            self?.animateLayout()
        }.then { $0.isMomentary = true })
        stack.addView(outer)
    }

    // MARK: ⑨ 嵌套：卡片网格

    private func section9_NestedCards(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ⑨ 嵌套 B：卡片网格（外层 Wrap → VStackView 卡片 → 内层 Wrap 标签）
        · 卡片固定宽 150，外层按卡片宽度换行，形成网格
        · 卡片内标签数量不同 → 卡片高度不同 → 外层 align(.start) 让同一行卡片顶部对齐
        """))
        let data: [(String, [String])] = [
            ("iOS", ["Swift", "UIKit", "SwiftUI"]),
            ("布局", ["Auto Layout", "Flex", "Wrap", "Stack", "Guide"]),
            ("响应式", ["RxSwift"]),
            ("工具", ["CocoaPods", "SPM", "Xcode", "Instruments"]),
        ]
        let cards = data.enumerated().map { (i, item) -> UIView in
            let title = UILabel()
            title.text = item.0
            title.font = .boldSystemFont(ofSize: 14)
            let tags = WStackView {
                for t in item.1 { tag(t, colors[i % colors.count], font: 11) }
            }.gap(4).lineGap(4)
            let card = VStackView(justify: .start, align: .fill, spacing: 6, insets: .all(8)) {
                title
                tags
            }
            card.backgroundColor = .white
            card.layer.cornerRadius = 8
            card.layer.borderColor = UIColor.lightGray.cgColor
            card.layer.borderWidth = 0.5
            card.box.width(150)
            return card
        }
        let outer = wrapBox(WStackView {
            for c in cards { c }
        }.justify(.spaceEvenly).align(.start).gap(8).lineGap(8).insets(.all(8)))
        stack.addView(outer)
    }

    // MARK: ⑩ 和 StackView 互相嵌套

    private func section10_NestedStackView(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ⑩ 嵌套 C：WStackView ⇄ StackView 互相嵌套
        · Wrap 里放 HStackView（头像 + 名字）作为一个整体参与换行
        · Wrap 放进 VStackView 中，上下内容随 Wrap 高度自适应（本页面本身就是 VStackView）
        """))
        func user(_ name: String, _ color: UIColor) -> UIView {
            let avatar = UIView.colored(color, text: String(name.prefix(1)), size: CGSize(width: 28, height: 28))
            avatar.layer.cornerRadius = 14
            let label = UILabel()
            label.text = name
            label.font = .systemFont(ofSize: 13)
            let h = HStackView { avatar; label }.spacing(6).align(.center).insets(.init(t: 4, s: 4, b: 4, e: 10))
            h.backgroundColor = .white
            h.layer.cornerRadius = 18
            return h
        }
        let wrap = WStackView {
            for (i, n) in ["张三", "李四", "王小五", "赵六六", "钱七", "孙八八八", "周九"].enumerated() {
                user(n, colors[i % colors.count])
            }
        }.gap(8).lineGap(8)

        let header = UILabel()
        header.text = "VStackView 头部"
        header.font = .boldSystemFont(ofSize: 14)
        let footer = UILabel()
        footer.text = "VStackView 底部（跟随 Wrap 高度）"
        footer.font = .systemFont(ofSize: 12)
        footer.textColor = .gray
        let card = VStackView(justify: .start, align: .fill, spacing: 8, insets: .all(10)) {
            header
            wrap
            footer
        }
        card.backgroundColor = .compatGray5
        card.layer.cornerRadius = 8
        stack.addView(card)
    }

    // MARK: ⑪ cell 自动算高 + preferredMaxLayoutWidth

    private func section11_CellAutoHeight(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ⑪ UITableViewCell 自动算高 + preferredMaxLayoutWidth
        cell 首次算高时 WStackView 还没有宽度，用 preferredMaxLayoutWidth（.maxLayoutWidth(w)）辅助分行
        """))
        let btn = UIButton(type: .system)
        btn.setTitle("打开 cell 自动算高示例 ›", for: .normal)
        btn.addAction(UIAction { [weak self] _ in
            self?.navigationController?.pushViewController(WrapCellDemoVC(), animated: true)
        }, for: .touchUpInside)
        stack.addView(btn)
    }

    // MARK: ⑫ 注意事项

    private func section12_Notes(_ stack: StackView) {
        stack.addView(sectionLabel("""
        ⑫ 注意事项
        1. 只支持水平主轴换行，行从上往下排列；宽度由外部决定，高度由内容撑开，不要给固定高度。
        2. 子 view 需要有宽度：UILabel 等有内容尺寸即可；纯 UIView 要设 width 约束或 flex.width。
        3. justifyContent / alignment 按行生效；某行有 flex>0 的 view 时（与 CSS flex-grow 一致），无论 justify 是什么，剩余空间都按权重分给它们，该行的 justify 不再生效；fillEqually 忽略 flex，行内等宽。
        4. fill(有 flex) / fillEqually 会改变子 view 宽度，子 view 不要再有固定宽度约束，否则冲突。
        5. 单个 view 比一行还宽时独占一行，宽度被压到行宽（多行 UILabel 记得 numberOfLines = 0）。
        6. 布局完成后修改 view.flex（flex / margin / spacing / alignSelf / width / height 等）、增删 view、
           isHidden、容器属性、子 view 内容变化都会自动重新布局；同一 runloop 多次修改只重建一次。
           只有直接改子 view 自己的约束 constant 等无法感知的情况才需要手动 setNeedsRelayout()。
           修改已有宽高时用 flex.width(x).updateSize()，否则会追加一条新的宽度约束导致冲突。
        7. 嵌套 WStackView 时，内层按最宽的单个子 view 参与外层分行；需要占满剩余宽度时给内层 flex。
        8. cell 自动算高时设置 preferredMaxLayoutWidth，避免首次没有宽度。
        9. DSL 中数字 / Spacer(值) / N.minSpacing / N.maxSpacing / Spacer() 都作用于前一个 view 后面的间距（写在第一个 view 之前会被忽略）；
           Spacer() 占满本行剩余空间且多个等宽，行内有 flex view 时 Spacer 收缩为最小值；
           space 模式下若行内有 min/max 间距：spaceBetween 按 fill 处理，spaceAround / spaceEvenly 按居中处理。
        10. isWrapEnabled = false 时强制单行，放不下的 view 会按抗压缩优先级被压缩。
        11. exclusiveLine 只在 WStackView 中生效（StackView 忽略）；独占的 view 前后都换行，
            行内仍按 justifyContent 排列，想撑满整行可配合 justify(.fill) + flex(1)。
            isWrapEnabled = false 时 exclusiveLine 依然生效（强制单行只影响普通 view）。
        """))
    }
}

// MARK: - ⑪ cell 自动算高

private class WrapTagCell: UITableViewCell {
    let titleLabel = UILabel()
    let wrap = WStackView().gap(6).lineGap(6)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        titleLabel.font = .boldSystemFont(ofSize: 15)
        let v = VStackView(justify: .start, align: .fill, spacing: 8, insets: .init(t: 12, s: 16, b: 12, e: 16)) {
            titleLabel
            wrap
        }
        v.box.addTo(contentView).edgesZero().flush()   // box 约束是延迟生效的，cell 算高前要 flush
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, tags: [String], maxWidth: CGFloat) {
        titleLabel.text = title
        wrap.preferredMaxLayoutWidth = maxWidth           // 首次算高时还没有 bounds，用它分行
        wrap.removeAllArrangedSubviews()
        for (i, t) in tags.enumerated() {
            let l = PaddingTagLabel()
            l.text = t
            l.font = .systemFont(ofSize: 12)
            l.textColor = .white
            l.backgroundColor = colors[i % colors.count]
            l.layer.cornerRadius = 6
            l.clipsToBounds = true
            wrap.addArrangedSubview(l)
        }
    }
}

class WrapCellDemoVC: UITableViewController {
    private let all = ["Swift", "iOS", "Auto Layout", "Flex", "ZLFlexKit", "UIKit", "DSL", "弹性布局",
                       "自动换行", "LayoutGuide", "SnapKit", "RxSwift", "CocoaPods", "SwiftUI", "Combine"]
    private lazy var rows: [(String, [String])] = (0..<30).map { i in
        ("第 \(i) 行：\(i % 5 * 3 + 1) 个标签", Array(all.prefix(i % 5 * 3 + 1)))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "cell 自动算高"
        tableView.register(WrapTagCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self else { return }
            self.tableView.reloadData()
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WrapTagCell
        let row = rows[indexPath.row]
        cell.configure(title: row.0, tags: row.1, maxWidth: tableView.bounds.width - 32)
        return cell
    }
}

// MARK: - 辅助

/// 带内边距的标签
private class PaddingTagLabel: UILabel {
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + 16, height: s.height + 8)
    }
}

private protocol WrapDemoThen {}
extension UIView: WrapDemoThen {}
private extension WrapDemoThen {
    @discardableResult
    func then(_ block: (Self) -> Void) -> Self { block(self); return self }
}
