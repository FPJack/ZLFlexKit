# ZLFlexKit

`ZLFlexKit` 是一个基于 Auto Layout 的弹性布局库，核心能力是：
- 用 `StackView` + `FlexItem` 提供类似 Flexbox 的布局体验
- 同时支持 Swift 链式、Result Builder DSL、Objective-C 链式 block API
- 支持主轴分布、交叉轴对齐、单项 flex 权重、最小/最大间距、弹性空白
- 内置 `LayoutBox`（`view.box`）快速约束 DSL

> 本 README 内容基于当前仓库 `ZLFlexKit/Classes` 源码整理。

---

## 目录

- [能力概览](#能力概览)
- [安装](#安装)
- [快速开始](#快速开始)
- [核心概念](#核心概念)
- [Swift 详细用法](#swift-详细用法)
- [Objective-C 详细用法](#objective-c-详细用法)
- [LayoutBox 用法（`view.box`）](#layoutbox-用法-viewbox)
- [API 速查](#api-速查)
- [注意事项（逐条）](#注意事项逐条)
- [常见问题](#常见问题)

---

## 能力概览

### 1) 主轴分布（`Justify`）

支持：
- `.fill`
- `.fillEqually`
- `.start`
- `.center`
- `.end`
- `.spaceBetween`
- `.spaceAround`
- `.spaceEvenly`

### 2) 交叉轴对齐（`FlexItemCrossAlign`）

支持：
- `.start`
- `.center`
- `.end`
- `.fill`

并且支持 item 级别 `alignSelf` 覆盖容器对齐策略。

### 3) item 弹性能力（`view.flex`）

支持：
- `flex(Int)` 权重分配剩余空间
- `isFlexibleSpace(true)` 插入弹性空白
- `spacing/minSpacing/maxSpacing` 三种间距控制
- `margin` 外边距
- `width/height/min/max/size/square` 尺寸约束

### 4) 构建方式

- Swift 链式 API
- Result Builder DSL（`StackView { ... }`）
- Objective-C 链式 block API

### 5) 补充能力

- `EdgeInsets` 轻量结构体
- `wrapScrollView()` 一键包裹滚动容器
- `LayoutBox` 约束 DSL（`view.box`）

---

## 安装

### CocoaPods

```ruby
pod 'ZLFlexKit'
```

### Swift Package Manager

在 SPM 中添加仓库后，引入 `ZLFlexKit` 产品。

> 说明：Podspec 与 SPM 的最低系统版本配置可能存在差异，最终以你工程实际集成为准。

---

## 快速开始

```swift
import UIKit
import ZLFlexKit

final class DemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let a = UILabel(); a.text = "A"; a.backgroundColor = .systemRed
        let b = UILabel(); b.text = "B"; b.backgroundColor = .systemBlue
        let c = UILabel(); c.text = "C"; c.backgroundColor = .systemGreen

        let stack = HStackView {
            a
            12
            b
            Spacer()
            c
        }
        .justify(.fill)
        .align(.center)
        .insets(.all(16))

        view.addSubview(stack)
        stack.box
            .top(120)
            .leading(16)
            .trailing(-16)
            .height(56)

        a.flex.flex(1)
        c.flex.flex(1)
    }
}
```

---

## 核心概念

### `StackView`

容器对象，负责统一布局策略：
- `axis`: 主轴方向（水平/垂直）
- `justifyContent`: 主轴分布
- `alignment`: 交叉轴对齐
- `insets`: 容器内边距
- `spacing`: 全局间距

### `FlexItem`（`view.flex`）

子视图对应的布局配置对象，负责单项策略：
- 间距：`spacing/minSpacing/maxSpacing`
- 弹性：`flex/isFlexibleSpace`
- 对齐：`alignSelf`
- 外边距：`margin`
- 尺寸：`width/height/min/max/size`

### `FlexManager`

内部约束生成器，根据容器与 item 状态生成并激活约束。

### `LayoutBox`（`view.box`）

通用约束 DSL，用于非 StackView 场景或辅助布局。

---

## Swift 详细用法

### 1. 创建容器

```swift
let s1 = StackView {}
let s2 = StackView.horizontal()
let s3 = StackView.vertical()
let s4 = HStackView {}
let s5 = VStackView {}
```

### 2. 容器链式配置

```swift
stack
    .axis(.horizontal)
    .justify(.spaceBetween)
    .align(.center)
    .spacing(10)
    .insets(.init(t: 8, s: 12, b: 8, e: 12))
```

### 3. 添加子视图

#### 3.1 普通添加

```swift
stack.addArrangedSubview(label)
stack.insertArrangedSubview(button, at: 0)
stack.removeArrangedSubview(label)
```

#### 3.2 链式添加

```swift
stack
    .addView(label)
    .addView(if: isVIP, badge)
    .addView(make: { (_: StackView) in UIImageView() })
```

#### 3.3 DSL 添加（推荐）

```swift
let stack = StackView {
    UILabel()
    8
    UIButton(type: .system)
    Spacer(min: 6)
    UIView()
}
```

### 4. 主轴分布（justify）

```swift
stack.justify(.fill)
stack.justify(.fillEqually)
stack.justify(.start)
stack.justify(.center)
stack.justify(.end)
stack.justify(.spaceBetween)
stack.justify(.spaceAround)
stack.justify(.spaceEvenly)
```

### 5. 交叉轴对齐（align）

```swift
stack.align(.start)
stack.align(.center)
stack.align(.end)
stack.align(.fill)
```

item 覆盖容器：

```swift
avatar.flex.align(.start)
```

### 6. 间距体系

#### 6.1 全局间距

```swift
stack.spacing(12)
```

#### 6.2 指定某个 view 后面的间距

```swift
stack.setCustomSpacing(20, after: viewA)
stack.setCustomMinSpacing(8, after: viewA)
stack.setCustomMaxSpacing(36, after: viewA)
```

#### 6.3 插入间距（链式）

```swift
stack
    .addView(viewA)
    .insertSpacing(10)
    .addView(viewB)
    .insertSpacing(min: 6)
    .addView(viewC)
    .insertSpacing(max: 30)
```

### 7. flex 与弹性空白

```swift
left.flex.flex(1)
center.flex.flex(2)
right.flex.flex(1)
```

弹性空白：

```swift
spacerHolder.flex.isFlexibleSpace(true)
```

### 8. margin 与 insets

```swift
stack.insets(.all(12))

nameLabel.flex.margin(.init(t: 4, s: 8, b: 4, e: 8))
```

### 9. item 尺寸

```swift
avatar.flex.size(w: 40, h: 40)
titleLabel.flex.minWidth(80)
tagLabel.flex.maxWidth(140)
```

### 10. 动态更新

```swift
itemView.isHidden.toggle()    // 自动触发布局刷新
stack.setFlex(3, for: itemView)
stack.setAlignment(.end, for: itemView)
stack.setMargin(.init(top: 0, leading: 12, bottom: 0, trailing: 0), for: itemView)
```

### 11. 包裹滚动容器

```swift
let scroll = stack.wrapScrollView()
view.addSubview(scroll)
scroll.box.edgesZero()
```

---

## Objective-C 详细用法

`StackView` 暴露了 ObjC 链式 block 属性，示例：

```objc
ZLStackView *stack = [ZLStackView new];
stack
.setAxis(ZLStackViewAxisHorizontal)
.setJustify(ZLJustifyFill)
.setAlign(ZLFlexItemCrossAlignCenter)
.setInsets(8, 12, 8, 12)
.setSpacing(10)
.addView(label)
.insertFlexibleSpacing(YES)
.addView(button);

label.zl_flex
.flex(1)
.minSpacing(8)
.maxSpacing(20)
.height(36);
```

也支持一些便捷属性（如 `justifyFill` / `alignCenter` 等）。

---

## LayoutBox 用法（`view.box`）

`LayoutBox` 可用于所有 `UIView`：

- 位置：`top/leading/bottom/trailing`
- 居中：`center/centerX/centerY/centerOffset`
- 尺寸：`width/height/min/max/size/square`
- 贴边：`edges/allEdges/edgesZero`
- 层级：`addTo/addToFull/addSubview/addSubviewLayout`
- 管理：`clear()/lastConstraint()`

示例：

```swift
let card = UIView()
card.box
    .addTo(view)
    .top(100)
    .leading(16)
    .trailing(-16)
    .height(120)

let icon = UIImageView()
card.box.addSubviewLayout(icon) { box in
    box.leading(12).centerY().size(w: 24, h: 24)
}
```

ObjC 对应属性名为 `zl_layout`。

---

## API 速查

### `StackView`

- 容器属性：`axis` `justifyContent` `alignment` `insets` `spacing`
- Swift 链式：`axis(_:)` `justify(_:)` `align(_:)` `insets(_:)` `spacing(_:)`
- 视图增删：`addArrangedSubview` `insertArrangedSubview` `removeArrangedSubview`
- DSL 相关：`addViews {}` `addView(if:)` `addView(make:)`
- 间距控制：`insertSpacing(_:)` `insertSpacing(min:)` `insertSpacing(max:)` `insertSpacing(flexible:)`
- item 定向设置：`setCustomSpacing` `setCustomMinSpacing` `setCustomMaxSpacing` `setFlex` `setAlignment` `setMargin`
- 滚动容器：`wrapScrollView()`

### `FlexItem`（`view.flex`）

- 间距：`spacing` `minSpacing` `maxSpacing`
- 弹性：`flex` `isFlexibleSpace`
- 对齐：`alignSelf` / `align(_:)`
- 外边距：`margin(_:)`
- 尺寸：`width/height/minWidth/maxWidth/minHeight/maxHeight/size/square`

### DSL

`StackView {}` 内可直接写：
- `UIView`
- `FlexItem`
- `Int/Float/Double`（表示间距）
- `Spacer()` / `Spacer(min:)` / `Spacer(max:)` / `Spacer(value)`
- `Optional<FlexType>`

---

## 注意事项（逐条）

1. **`fill` 与 `fillEqually` 语义完全不同**
   - `fill` 更适合配合 `flex`。
   - `fillEqually` 会强制主轴等分。

2. **`spacing = -1` 在源码里有“回退到 stack.spacing”的语义**
   - item 未显式设置 spacing 时，会使用容器 spacing。

3. **`minSpacing/maxSpacing/spacing` 可能叠加影响**
   - 当三者同时设置时，最终效果受约束关系影响。

4. **`isFlexibleSpace` 不是“任意模式都明显”**
   - 常见有效场景是 `fill/fillEqually`。

5. **调用 `setCustomSpacing(_:after:)` 前，view 必须已经在当前 stack 中**
   - 否则不会生效。

6. **隐藏视图不会出现在 `arrangedViews`**
   - `arrangedViews` 返回的是非隐藏项。

7. **`LayoutBox` 的 `trailing/bottom` 建议按你的团队约定统一正负写法**
   - 常见写法是 `trailing(-16)`、`bottom(-12)`。

8. **`LayoutBox` 使用了 `updateConstraints` swizzle 来激活 pending 约束**
   - 若业务层有类似 swizzle，需评估相互影响。

9. **嵌套 `StackView/UIStackView` 时，内部会处理 `translatesAutoresizingMaskIntoConstraints`**
   - 这是为了降低冲突风险。

10. **`wrapScrollView()` 返回新对象**
    - 你需要把返回的 `ScrollView` 加入父视图。

11. **RTL 下 `ScrollView` 会对自身和 subviews 做 transform 调整**
    - 如果你项目也在做 transform，需要注意叠加效果。

12. **性能建议：批量改动集中触发一次布局**
    - 避免高频小改动反复重建约束。

---

## 常见问题

### Q1：设置了 `flex` 但看起来没按比例分配？

优先检查：
- `justify` 是否为 `.fill`
- item 是否隐藏
- 是否又加了固定宽/高把弹性空间锁死

### Q2：DSL 里为什么数字可以直接写？

因为 `Int/Float/Double` 已实现 `StackViewDSL`，数字被解释为 spacing。

### Q3：怎么把尾部元素顶到最右/最下？

在中间插入 `Spacer()`，或给中间 view 设置 `isFlexibleSpace(true)`。

### Q4：为什么改了 `margin/insets` 没有立刻可见？

通常是布局时机问题，确认 view 已在层级中，必要时调用 `layoutIfNeeded()`。

---

## License

MIT
