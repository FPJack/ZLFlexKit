//
//  ZLLayout.swift
//  ZLFlexKit
//
//  Created by admin on 2026/4/24.
//

import UIKit
import ObjectiveC

// MARK: - Utility Functions

// MARK: - Layout

public protocol NumberConvertible {
    var doubleValue: Double { get }
}

public extension NumberConvertible {
    var cgFloat: CGFloat { CGFloat(doubleValue) }
}

extension Int:     NumberConvertible { public var doubleValue: Double { Double(self) } }
extension Int8:    NumberConvertible { public var doubleValue: Double { Double(self) } }
extension Int16:   NumberConvertible { public var doubleValue: Double { Double(self) } }
extension Int32:   NumberConvertible { public var doubleValue: Double { Double(self) } }
extension Int64:   NumberConvertible { public var doubleValue: Double { Double(self) } }
extension UInt:    NumberConvertible { public var doubleValue: Double { Double(self) } }
extension Float:   NumberConvertible { public var doubleValue: Double { Double(self) } }
extension Double:  NumberConvertible { public var doubleValue: Double { self } }
extension CGFloat: NumberConvertible { public var doubleValue: Double { Double(self) } }


@objc(ZLLayout)
public class Layout: NSObject {

    public weak var view: UIView?

    private var _constraints: NSMutableArray?
    private weak var _lastConstraint: NSLayoutConstraint?

    override public init() {
        super.init()
        _ = UIView._zlSwizzleOnce
    }

    private var constraintsArray: NSMutableArray {
        if _constraints == nil {
            let arr = NSMutableArray()
            _constraints = arr
            view?.zl_setConstraints(arr)
        }
        return _constraints!
    }

    private func addConstraint(_ constraint: NSLayoutConstraint?) {
        guard let constraint = constraint else { return }
        _lastConstraint = constraint
        constraintsArray.add(constraint)
        if let view = view {            view.setNeedsUpdateConstraints()
        }
    }

    // MARK: - Public API

    /// 获取最后一次添加的约束
    public func lastConstraint() -> NSLayoutConstraint? {
        return _lastConstraint
    }

    /// 清除所有布局约束
    @discardableResult
    public func clear() -> Self {
        _lastConstraint = nil
        if let constraints = _constraints {
            NSLayoutConstraint.deactivate(constraints as! [NSLayoutConstraint])
            constraints.removeAllObjects()
        }
        return self
    }

   

    @discardableResult
    public func centerX(_ x: NumberConvertible = 0) -> Self {
        return centerXTo(view?.superview?.centerXAnchor, offset: x)
    }

    @discardableResult
    public func centerXTo(_ anchor: NSLayoutXAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.centerXAnchor.constraint(equalTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    @discardableResult
    public func centerXGreaterThanOrTo(_ anchor: NSLayoutXAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.centerXAnchor.constraint(greaterThanOrEqualTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    @discardableResult
    public func centerXLessThanOrTo(_ anchor: NSLayoutXAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.centerXAnchor.constraint(lessThanOrEqualTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    // MARK: - CenterY

    @discardableResult
    public func centerY(_ y: NumberConvertible = 0) -> Self {
        return centerYTo(view?.superview?.centerYAnchor, offset: y)
    }

    @discardableResult
    public func centerYTo(_ anchor: NSLayoutYAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.centerYAnchor.constraint(equalTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    @discardableResult
    public func centerYGreaterThanOrTo(_ anchor: NSLayoutYAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.centerYAnchor.constraint(greaterThanOrEqualTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    @discardableResult
    public func centerYLessThanOrTo(_ anchor: NSLayoutYAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.centerYAnchor.constraint(lessThanOrEqualTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    // MARK: - Center

    @discardableResult
    public func center() -> Self {
        return centerX(0).centerY(0)
    }

    @discardableResult
    public func centerOffset(x: NumberConvertible, y: NumberConvertible) -> Self {
        return centerX(x).centerY(y)
    }

    // MARK: - Top

    @discardableResult
    public func top(_ top: NumberConvertible) -> Self {
        return topTo(view?.superview?.topAnchor, offset: top)
    }

    @discardableResult
    public func topTo(_ anchor: NSLayoutYAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.topAnchor.constraint(equalTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    @discardableResult
    public func topGreaterThanOrTo(_ anchor: NSLayoutYAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.topAnchor.constraint(greaterThanOrEqualTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    @discardableResult
    public func topLessThanOrTo(_ anchor: NSLayoutYAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.topAnchor.constraint(lessThanOrEqualTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    // MARK: - Leading

    @discardableResult
    public func leading(_ leading: NumberConvertible) -> Self {
        return leadingTo(view?.superview?.leadingAnchor, offset: leading)
    }

    @discardableResult
    public func leadingTo(_ anchor: NSLayoutXAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.leadingAnchor.constraint(equalTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    @discardableResult
    public func leadingGreaterThanOrTo(_ anchor: NSLayoutXAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.leadingAnchor.constraint(greaterThanOrEqualTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    @discardableResult
    public func leadingLessThanOrTo(_ anchor: NSLayoutXAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.leadingAnchor.constraint(lessThanOrEqualTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    // MARK: - Bottom

    @discardableResult
    public func bottom(_ bottom: NumberConvertible) -> Self {
        return bottomTo(view?.superview?.bottomAnchor, offset: bottom)
    }

    @discardableResult
    public func bottomTo(_ anchor: NSLayoutYAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.bottomAnchor.constraint(equalTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    @discardableResult
    public func bottomGreaterThanOrTo(_ anchor: NSLayoutYAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.bottomAnchor.constraint(greaterThanOrEqualTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    @discardableResult
    public func bottomLessThanOrTo(_ anchor: NSLayoutYAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.bottomAnchor.constraint(lessThanOrEqualTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    // MARK: - Trailing

    @discardableResult
    public func trailing(_ trailing: NumberConvertible) -> Self {
        return trailingTo(view?.superview?.trailingAnchor, offset: trailing)
    }

    @discardableResult
    public func trailingTo(_ anchor: NSLayoutXAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.trailingAnchor.constraint(equalTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    @discardableResult
    public func trailingGreaterThanOrTo(_ anchor: NSLayoutXAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.trailingAnchor.constraint(greaterThanOrEqualTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    @discardableResult
    public func trailingLessThanOrTo(_ anchor: NSLayoutXAxisAnchor?, offset: NumberConvertible = 0) -> Self {
        if let anchor = anchor {
            addConstraint(view?.trailingAnchor.constraint(lessThanOrEqualTo: anchor, constant: offset.cgFloat))
        }
        return self
    }

    // MARK: - Height

    /// 设置高度
    @discardableResult
    public func height(_ height: NumberConvertible) -> Self {
        addConstraint(view?.heightAnchor.constraint(equalToConstant: height.cgFloat))
        return self
    }

    /// 设置高度相等
    @discardableResult
    public func heightTo(_ dimension: NSLayoutDimension) -> Self {
        addConstraint(view?.heightAnchor.constraint(equalTo: dimension))
        return self
    }

    @discardableResult
    public func minHeight(_ height: NumberConvertible) -> Self {
        addConstraint(view?.heightAnchor.constraint(greaterThanOrEqualToConstant: height.cgFloat))
        return self
    }

    @discardableResult
    public func maxHeight(_ height: NumberConvertible) -> Self {
        addConstraint(view?.heightAnchor.constraint(lessThanOrEqualToConstant: height.cgFloat))
        return self
    }

    // MARK: - Width

    /// 设置宽度
    @discardableResult
    public func width(_ width: NumberConvertible) -> Self {
        addConstraint(view?.widthAnchor.constraint(equalToConstant: width.cgFloat))
        return self
    }

    /// 设置宽度相等
    @discardableResult
    public func widthTo(_ dimension: NSLayoutDimension) -> Self {
        addConstraint(view?.widthAnchor.constraint(equalTo: dimension))
        return self
    }

    @discardableResult
    public func minWidth(_ width: NumberConvertible) -> Self {
        addConstraint(view?.widthAnchor.constraint(greaterThanOrEqualToConstant: width.cgFloat))
        return self
    }

    @discardableResult
    public func maxWidth(_ width: NumberConvertible) -> Self {
        addConstraint(view?.widthAnchor.constraint(lessThanOrEqualToConstant: width.cgFloat))
        return self
    }

    // MARK: - Size

    /// 同时设置宽高
    @discardableResult
    public func size(w: NumberConvertible, h: NumberConvertible) -> Self {
        return self.width(w).height(h)
    }

    /// 设置宽高相等
    @discardableResult
    public func square(_ wh: NumberConvertible) -> Self {
        return size(w: wh, h: wh)
    }

    // MARK: - Edges

    /// 贴紧父视图四边（参数布局）
    @discardableResult
    public func edges(top: NumberConvertible, leading: NumberConvertible, bottom: NumberConvertible, trailing: NumberConvertible) -> Self {
        guard let superview = view?.superview else { return self }
        addConstraint(view?.topAnchor.constraint(equalTo: superview.topAnchor, constant: top.cgFloat))
        addConstraint(view?.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leading.cgFloat))
        addConstraint(view?.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -bottom.cgFloat))
        addConstraint(view?.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -trailing.cgFloat))
        return self
    }

    /// 贴紧父视图四边，参数相同。allEdges(10) 等价于 edges(top:10, leading:10, bottom:10, trailing:10)
    @discardableResult
    public func allEdges(_ inset: NumberConvertible) -> Self {
        return edges(top: inset, leading: inset, bottom: inset, trailing: inset)
    }

    /// 贴紧父视图四边布局（全为 0）
    @discardableResult
    public func edgesZero() -> Self {
        return edges(top: 0, leading: 0, bottom: 0, trailing: 0)
    }

    // MARK: - Hierarchy

    /// 添加到父视图，参数是父视图
    @discardableResult
    public func addTo(_ superview: UIView) -> Self {
        if let view = view {
            superview.addSubview(view)
        }
        return self
    }

    /// 添加到父视图并贴紧四边，参数是父视图
    @discardableResult
    public func addToFull(_ superview: UIView) -> Self {
        if let view = view {
            superview.addSubview(view)
            edgesZero()
        }
        return self
    }

    @discardableResult
    public func addSubview(_ subview: UIView) -> Self {
        view?.addSubview(subview)
        return self
    }

    @discardableResult
    public func addSubviewLayout(_ subview: UIView, layout: (Layout) -> Void) -> Self {
        view?.addSubview(subview)
        layout(subview.layout)
        return self
    }
}

// MARK: - UIView Extension

private var zlLayoutKey:      UInt8 = 0
private var zlConstraintsKey: UInt8 = 0
private var zlTapActionKey:   UInt8 = 0

public extension UIView {

    /// 关联的 Layout 对象
   @objc var layout: Layout {
        if let obj = objc_getAssociatedObject(self, &zlLayoutKey) as? Layout {
            return obj
        }
        let layoutObj = Layout()
        layoutObj.view = self
       _ = Unmanaged.passRetained(self).autorelease()
        objc_setAssociatedObject(self, &zlLayoutKey, layoutObj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return layoutObj
    }

    // MARK: Internal constraint storage

    fileprivate var zl_pendingConstraints: NSMutableArray? {
        return objc_getAssociatedObject(self, &zlConstraintsKey) as? NSMutableArray
    }

    fileprivate func zl_setConstraints(_ constraints: NSMutableArray) {
        objc_setAssociatedObject(self, &zlConstraintsKey, constraints, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // MARK: - updateConstraints swizzling

    /// 在 +load 等价时机调用一次即可完成 swizzle
    static let _zlSwizzleOnce: Void = {
        let cls = UIView.self
        guard
            let original = class_getInstanceMethod(cls, #selector(updateConstraints)),
            let swizzled = class_getInstanceMethod(cls, #selector(zl_updateConstraints))
        else { return }
        method_exchangeImplementations(original, swizzled)
    }()

    @objc private func zl_updateConstraints() {
        if let constraints = zl_pendingConstraints, constraints.count > 0 {
            let inactive = constraints.filtered(using: NSPredicate(format: "active == NO"))
            if !inactive.isEmpty {
                if translatesAutoresizingMaskIntoConstraints {
                    translatesAutoresizingMaskIntoConstraints = false
                }
                NSLayoutConstraint.activate(inactive as! [NSLayoutConstraint])
            }
        }
        zl_updateConstraints()
    }
}






public extension Layout {

    // MARK: - CenterX
    @objc(centerX)
    @available(swift, obsoleted: 1, renamed: "centerX(_:)")
    var centerXObjc: (_ x: CGFloat) -> Layout {
        { x in self.centerX(x) }
    }

    @objc(centerXTo)
    @available(swift, obsoleted: 1, renamed: "centerXTo(_:offset:)")
    var centerXToObjc: (_ anchor: NSLayoutXAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.centerXTo(anchor, offset: offset) }
    }

    @objc(centerXGreaterThanOrTo)
    @available(swift, obsoleted: 1, renamed: "centerXGreaterThanOrTo(_:offset:)")
    var centerXGreaterThanOrToObjc: (_ anchor: NSLayoutXAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.centerXGreaterThanOrTo(anchor, offset: offset) }
    }

    @objc(centerXLessThanOrTo)
    @available(swift, obsoleted: 1, renamed: "centerXLessThanOrTo(_:offset:)")
    var centerXLessThanOrToObjc: (_ anchor: NSLayoutXAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.centerXLessThanOrTo(anchor, offset: offset) }
    }

    // MARK: - CenterY
    @objc(centerY)
    @available(swift, obsoleted: 1, renamed: "centerY(_:)")
    var centerYObjc: (_ y: CGFloat) -> Layout {
        { y in self.centerY(y) }
    }

    @objc(centerYTo)
    @available(swift, obsoleted: 1, renamed: "centerYTo(_:offset:)")
    var centerYToObjc: (_ anchor: NSLayoutYAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.centerYTo(anchor, offset: offset) }
    }

    @objc(centerYGreaterThanOrTo)
    @available(swift, obsoleted: 1, renamed: "centerYGreaterThanOrTo(_:offset:)")
    var centerYGreaterThanOrToObjc: (_ anchor: NSLayoutYAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.centerYGreaterThanOrTo(anchor, offset: offset) }
    }

    @objc(centerYLessThanOrTo)
    @available(swift, obsoleted: 1, renamed: "centerYLessThanOrTo(_:offset:)")
    var centerYLessThanOrToObjc: (_ anchor: NSLayoutYAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.centerYLessThanOrTo(anchor, offset: offset) }
    }

    // MARK: - Center
    @objc(centerOffset)
    @available(swift, obsoleted: 1, renamed: "centerOffset(x:y:)")
    var centerOffsetObjc: (_ x: CGFloat, _ y: CGFloat) -> Layout {
        { x, y in self.centerOffset(x: x, y: y) }
    }

    // MARK: - Top
    @objc(top)
    @available(swift, obsoleted: 1, renamed: "top(_:)")
    var topObjc: (_ top: CGFloat) -> Layout {
        { top in self.top(top) }
    }

    @objc(topTo)
    @available(swift, obsoleted: 1, renamed: "topTo(_:offset:)")
    var topToObjc: (_ anchor: NSLayoutYAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.topTo(anchor, offset: offset) }
    }

    @objc(topGreaterThanOrTo)
    @available(swift, obsoleted: 1, renamed: "topGreaterThanOrTo(_:offset:)")
    var topGreaterThanOrToObjc: (_ anchor: NSLayoutYAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.topGreaterThanOrTo(anchor, offset: offset) }
    }

    @objc(topLessThanOrTo)
    @available(swift, obsoleted: 1, renamed: "topLessThanOrTo(_:offset:)")
    var topLessThanOrToObjc: (_ anchor: NSLayoutYAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.topLessThanOrTo(anchor, offset: offset) }
    }

    // MARK: - Leading
    @objc(leading)
    @available(swift, obsoleted: 1, renamed: "leading(_:)")
    var leadingObjc: (_ leading: CGFloat) -> Layout {
        { leading in self.leading(leading) }
    }

    @objc(leadingTo)
    @available(swift, obsoleted: 1, renamed: "leadingTo(_:offset:)")
    var leadingToObjc: (_ anchor: NSLayoutXAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.leadingTo(anchor, offset: offset) }
    }

    @objc(leadingGreaterThanOrTo)
    @available(swift, obsoleted: 1, renamed: "leadingGreaterThanOrTo(_:offset:)")
    var leadingGreaterThanOrToObjc: (_ anchor: NSLayoutXAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.leadingGreaterThanOrTo(anchor, offset: offset) }
    }

    @objc(leadingLessThanOrTo)
    @available(swift, obsoleted: 1, renamed: "leadingLessThanOrTo(_:offset:)")
    var leadingLessThanOrToObjc: (_ anchor: NSLayoutXAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.leadingLessThanOrTo(anchor, offset: offset) }
    }

    // MARK: - Bottom
    @objc(bottom)
    @available(swift, obsoleted: 1, renamed: "bottom(_:)")
    var bottomObjc: (_ bottom: CGFloat) -> Layout {
        { bottom in self.bottom(bottom) }
    }

    @objc(bottomTo)
    @available(swift, obsoleted: 1, renamed: "bottomTo(_:offset:)")
    var bottomToObjc: (_ anchor: NSLayoutYAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.bottomTo(anchor, offset: offset) }
    }

    @objc(bottomGreaterThanOrTo)
    @available(swift, obsoleted: 1, renamed: "bottomGreaterThanOrTo(_:offset:)")
    var bottomGreaterThanOrToObjc: (_ anchor: NSLayoutYAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.bottomGreaterThanOrTo(anchor, offset: offset) }
    }

    @objc(bottomLessThanOrTo)
    @available(swift, obsoleted: 1, renamed: "bottomLessThanOrTo(_:offset:)")
    var bottomLessThanOrToObjc: (_ anchor: NSLayoutYAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.bottomLessThanOrTo(anchor, offset: offset) }
    }

    // MARK: - Trailing
    @objc(trailing)
    @available(swift, obsoleted: 1, renamed: "trailing(_:)")
    var trailingObjc: (_ trailing: CGFloat) -> Layout {
        { trailing in self.trailing(trailing) }
    }

    @objc(trailingTo)
    @available(swift, obsoleted: 1, renamed: "trailingTo(_:offset:)")
    var trailingToObjc: (_ anchor: NSLayoutXAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.trailingTo(anchor, offset: offset) }
    }

    @objc(trailingGreaterThanOrTo)
    @available(swift, obsoleted: 1, renamed: "trailingGreaterThanOrTo(_:offset:)")
    var trailingGreaterThanOrToObjc: (_ anchor: NSLayoutXAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.trailingGreaterThanOrTo(anchor, offset: offset) }
    }

    @objc(trailingLessThanOrTo)
    @available(swift, obsoleted: 1, renamed: "trailingLessThanOrTo(_:offset:)")
    var trailingLessThanOrToObjc: (_ anchor: NSLayoutXAxisAnchor?, _ offset: CGFloat) -> Layout {
        { anchor, offset in self.trailingLessThanOrTo(anchor, offset: offset) }
    }

    // MARK: - Height
    @objc(height)
    @available(swift, obsoleted: 1, renamed: "height(_:)")
    var heightObjc: (_ height: CGFloat) -> Layout {
        { height in self.height(height) }
    }

    @objc(minHeight)
    @available(swift, obsoleted: 1, renamed: "minHeight(_:)")
    var minHeightObjc: (_ height: CGFloat) -> Layout {
        { height in self.minHeight(height) }
    }

    @objc(maxHeight)
    @available(swift, obsoleted: 1, renamed: "maxHeight(_:)")
    var maxHeightObjc: (_ height: CGFloat) -> Layout {
        { height in self.maxHeight(height) }
    }

    // MARK: - Width
    @objc(width)
    @available(swift, obsoleted: 1, renamed: "width(_:)")
    var widthObjc: (_ width: CGFloat) -> Layout {
        { width in self.width(width) }
    }

    @objc(minWidth)
    @available(swift, obsoleted: 1, renamed: "minWidth(_:)")
    var minWidthObjc: (_ width: CGFloat) -> Layout {
        { width in self.minWidth(width) }
    }

    @objc(maxWidth)
    @available(swift, obsoleted: 1, renamed: "maxWidth(_:)")
    var maxWidthObjc: (_ width: CGFloat) -> Layout {
        { width in self.maxWidth(width) }
    }

    // MARK: - Size
    @objc(size)
    @available(swift, obsoleted: 1, renamed: "size(width:height:)")
    var sizeObjc: (_ width: CGFloat, _ height: CGFloat) -> Layout {
        { width, height in self.size(w: width, h: height) }
    }

    @objc(square)
    @available(swift, obsoleted: 1, renamed: "square(_:)")
    var squareObjc: (_ wh: CGFloat) -> Layout {
        { wh in self.square(wh) }
    }

    // MARK: - Edges
    @objc(edges)
    @available(swift, obsoleted: 1, renamed: "edges(top:leading:bottom:trailing:)")
    var edgesObjc: (_ top: CGFloat, _ leading: CGFloat, _ bottom: CGFloat, _ trailing: CGFloat) -> Layout {
        { top, leading, bottom, trailing in self.edges(top: top, leading: leading, bottom: bottom, trailing: trailing) }
    }

    @objc(allEdges)
    @available(swift, obsoleted: 1, renamed: "allEdges(_:)")
    var allEdgesObjc: (_ inset: CGFloat) -> Layout {
        { inset in self.allEdges(inset) }
    }

    // MARK: - No-param / non-number methods

    @objc(center)
    @available(swift, obsoleted: 1, renamed: "center()")
    var centerObjc: () -> Layout {
        { self.center() }
    }

    @objc(edgesZero)
    @available(swift, obsoleted: 1, renamed: "edgesZero()")
    var edgesZeroObjc: () -> Layout {
        { self.edgesZero() }
    }

    @objc(clear)
    @available(swift, obsoleted: 1, renamed: "clear()")
    var clearObjc: () -> Layout {
        { self.clear() }
    }

    @objc(lastConstraint)
    @available(swift, obsoleted: 1, renamed: "lastConstraint()")
    var lastConstraintObjc: () -> NSLayoutConstraint? {
        { self.lastConstraint() }
    }

    @objc(heightTo)
    @available(swift, obsoleted: 1, renamed: "heightTo(_:)")
    var heightToObjc: (_ dimension: NSLayoutDimension) -> Layout {
        { dimension in self.heightTo(dimension) }
    }

    @objc(widthTo)
    @available(swift, obsoleted: 1, renamed: "widthTo(_:)")
    var widthToObjc: (_ dimension: NSLayoutDimension) -> Layout {
        { dimension in self.widthTo(dimension) }
    }

   

    @objc(addTo)
    @available(swift, obsoleted: 1, renamed: "addTo(_:)")
    var addToObjc: (_ superview: UIView) -> Layout {
        { superview in self.addTo(superview) }
    }

    @objc(addToFull)
    @available(swift, obsoleted: 1, renamed: "addToFull(_:)")
    var addToFullObjc: (_ superview: UIView) -> Layout {
        { superview in self.addToFull(superview) }
    }

    @objc(addSubview)
    @available(swift, obsoleted: 1, renamed: "addSubview(_:)")
    var addSubviewObjc: (_ subview: UIView) -> Layout {
        { subview in self.addSubview(subview) }
    }

    @objc(addSubviewLayout)
    @available(swift, obsoleted: 1, renamed: "addSubviewLayout(_:layout:)")
    var addSubviewLayoutObjc: (_ subview: UIView, _ layout: (Layout) -> Void) -> Layout {
        { subview, layout in self.addSubviewLayout(subview, layout: layout) }
    }
}
