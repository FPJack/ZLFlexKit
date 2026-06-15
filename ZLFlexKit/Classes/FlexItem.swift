//
//  FlexItem.swift
//  ZLFlexKit
//
//  Created by admin on 2026/6/5.
//

import UIKit
import ObjectiveC

@objc(ZLFlexItemCrossAlign)
public enum FlexItemCrossAlign: Int {
    case center
    case start
    case end
    case fill
}


@objc(ZLFlexItem)
public  class FlexItem: NSObject {
    private var observation: NSKeyValueObservation?
    public  weak var view: UIView? {
        didSet {
            guard observation == nil else { return }
            observation = view?.observe(\.isHidden, options: [.new, .old]) {[weak self] view, change in
                guard let self = self else { return }
                if let newValue = change.newValue,
                    let oldValue = change.oldValue,
                    newValue != oldValue {
                    self.setStackViewNeedsUpdateConstraints()
                }
            }
        }
    }
    
    
    
    public weak var stackView: StackView?
    
    
    private var _margin: NSDirectionalEdgeInsets = .zero
    public var margin: NSDirectionalEdgeInsets {
        get {
            _margin
        }
        set {
            guard _margin != newValue else { return }
            if _margin.leading != newValue.leading {
                updateLeadMarge(_margin.leading, newValue.leading)
            }
            if _margin.trailing != newValue.trailing {
                updateTrailMarge(_margin.trailing, newValue.trailing)
            }
            if _margin.top != newValue.top {
                updateTopMarge(_margin.top, newValue.top)
            }
            if _margin.bottom != newValue.bottom {
                updateBottomMarge(_margin.bottom, newValue.bottom)
            }
            _margin = newValue
            updateCenterOffset()
        }
    }
    private func updateLeadMarge(_ preMarge: CGFloat,_ marge: CGFloat) {
        let arr = filterConstraint { constraint in
            return constraint.firstItem === view && constraint.firstAttribute == .leading && (constraint.relation == .equal || constraint.relation == .greaterThanOrEqual)
        }
        if let cons = arr?.first {
            cons.constant = cons.constant - preMarge + marge
        }else {
            setStackViewNeedsUpdateConstraints()
        }
    }
    private func updateTrailMarge(_ preMarge: CGFloat,_ marge: CGFloat) {
        let arr = filterConstraint { constraint in
            let relation = constraint.relation
            let res1 = constraint.secondItem === view && constraint.secondAttribute == .trailing && (relation == .equal || relation == .greaterThanOrEqual)
            if res1 {
                return true
            }
            let res2 = constraint.firstItem === view && constraint.firstAttribute == .trailing && (relation == .equal || relation == .lessThanOrEqual)
            if res2 {
                return true
            }
            return false
        }
        if let constraint = arr?.first {
            let relation = constraint.relation
            if constraint.firstItem === view && constraint.firstAttribute == .trailing && (relation == .equal || relation == .lessThanOrEqual) {
                    constraint.constant = constraint.constant + preMarge - marge
            }else {
                if stackView?.axis == .vertical {
                    constraint.constant = constraint.constant + preMarge - marge
                }else {
                    constraint.constant = constraint.constant - preMarge + marge
                }
            }
        }else {
            setStackViewNeedsUpdateConstraints()
        }
    }
    private func updateTopMarge(_ preMarge: CGFloat,_ marge: CGFloat) {
        let arr = filterConstraint { constraint in
            return constraint.firstItem === view && constraint.firstAttribute == .top && (constraint.relation == .equal || constraint.relation == .greaterThanOrEqual)
        }
        if let cons = arr?.first {
            cons.constant = cons.constant - preMarge + marge
        }else {
            setStackViewNeedsUpdateConstraints()
        }
    }
    private func updateBottomMarge(_ preMarge: CGFloat,_ marge: CGFloat) {
        let arr = filterConstraint { constraint in
            let relation = constraint.relation
            let res1 = constraint.secondItem === view && constraint.secondAttribute == .bottom && (relation == .equal || relation == .greaterThanOrEqual)
            if res1 {
                return true
            }
            let res2 = constraint.firstItem === view && constraint.firstAttribute == .bottom && (relation == .equal || relation == .lessThanOrEqual)
            if res2 {
                return true
            }
            return false
        }
        if let constraint = arr?.first {
            let relation = constraint.relation
            if constraint.firstItem === view && constraint.firstAttribute == .bottom && (relation == .equal || relation == .lessThanOrEqual) {
                constraint.constant = constraint.constant + preMarge - marge
            }else {
                if stackView?.axis == .horizontal {
                    constraint.constant = constraint.constant + preMarge - marge
                }else {
                    constraint.constant = constraint.constant - preMarge + marge
                }
            }
        }else {
            setStackViewNeedsUpdateConstraints()
        }
    }
    private func updateCenterOffset() {
        guard let axis = stackView?.axis,let align = stackView?.alignment else { return }
        let inset = stackView?.insets ?? .zero
        guard align == .center else { return }
        if axis == .horizontal {
            let arr = filterConstraint { cons in
                return cons.firstItem === view && cons.firstAttribute == .centerY && cons.relation == .equal
            }
            if let cons = arr?.first {
                cons.constant = (margin.top + inset.top - margin.bottom - inset.bottom) * 0.5
            }
        }else {
            let arr = filterConstraint { cons in
                return cons.firstItem === view && cons.firstAttribute == .centerX && cons.relation == .equal
            }
            if let cons = arr?.first {
                cons.constant = (margin.leading + inset.leading - margin.trailing - inset.trailing) * 0.5
            }
        }
    }
    
    
    var _spacing: CGFloat = 0
    public var spacing: CGFloat {
        get {_spacing > 0 ? _spacing : stackView?.spacing ?? 0 }
        set {
            let oldValue = spacing
            _spacing = newValue
            if oldValue != newValue {
                setStackViewNeedsUpdateConstraints()
            }
        }
    }
    
    var _minSpacing: CGFloat = 0
    public var minSpacing: CGFloat {
        get {_minSpacing }
        set {
            let oldValue = minSpacing
            _minSpacing = newValue
            if oldValue != newValue {
                setStackViewNeedsUpdateConstraints()
            }
        }
    }
    
    var _maxSpacing: CGFloat = 0
    public var maxSpacing: CGFloat  {
        get { _maxSpacing }
        set {
            let oldValue = maxSpacing
            _maxSpacing = newValue
            if oldValue != newValue {
                setStackViewNeedsUpdateConstraints()
            }
        }
    }
    
    public var isFlexibleSpace: Bool = false {
        didSet {
            guard isFlexibleSpace != oldValue else { return }
            setStackViewNeedsUpdateConstraints()
        }
    }
    
    public var flex: Int = 0 {
        didSet {
            guard flex != oldValue else { return }
            setStackViewNeedsUpdateConstraints()
        }
    }
    
    private var isSetAlign = false
    
    private var _alignSelf: FlexItemCrossAlign?
    public var alignSelf: FlexItemCrossAlign {
        get {
            _alignSelf ?? (stackView?.alignment ?? .center)
        }
        set {
            isSetAlign = true
            
            let oldValue = alignSelf
            
            _alignSelf = newValue
            
            if oldValue != newValue {
                setStackViewNeedsUpdateConstraints()
            }
        }
    }
    
    public var height: CGFloat = 0 {
        didSet {
            view?.box.height(height)
        }
    }
    public var width: CGFloat = 0 {
        didSet {
            view?.box.width(width)
        }
    }
    public var minWidth: CGFloat = 0 {
        didSet {
            view?.box.minWidth(minWidth)
        }
    }
    public var maxWidth: CGFloat = 0 {
        didSet {
            view?.box.maxWidth(maxWidth)
        }
    }
    public var minHeight: CGFloat = 0 {
        didSet {
            view?.box.minHeight(minHeight)
        }
    }
    public var maxHeight: CGFloat = 0 {
        didSet {
            view?.box.maxHeight(maxHeight)
        }
    }
    public var size: CGSize = .zero {
        didSet {
            view?.box.size(w: size.width, h: size.height)
        }
    }
    
    public override init() {
        super.init()
        minSpacing = -2
        maxSpacing = -2
    }
    
   
    @discardableResult
    public func spacing(_ spacing: NumberConvertible) -> Self {
        self.spacing = spacing.cgFloat
        return self
    }
    @discardableResult
    public func alignSelf(_ align: FlexItemCrossAlign) -> Self {
        self.alignSelf = align
        return self
    }
    @discardableResult
    public func margin(_ margin: NSDirectionalEdgeInsets) -> Self {
        self.margin = margin
        return self
    }
    @discardableResult
    public func margin(_ margin: NumberConvertible) -> Self {
           self.margin = .init(top: margin.cgFloat, leading: margin.cgFloat, bottom: margin.cgFloat, trailing: margin.cgFloat)
        return self
    }
    @discardableResult
    public func margin(top: NumberConvertible? = nil,leading: NumberConvertible? = nil,  bottom: NumberConvertible? = nil,trailing: NumberConvertible? = nil) -> Self {
        var margin = _margin
        if let top = top {
            margin.top = top.cgFloat
        }
        if let leading = leading {
            margin.leading = leading.cgFloat
        }
        if let bottom = bottom {
            margin.bottom = bottom.cgFloat
        }
        if let trailing = trailing {
            margin.trailing = trailing.cgFloat
        }
        self.margin = margin
        return self
    }
    ///水平marge
    public func marginX(_ margin: NumberConvertible) -> Self {
        return self.margin(leading: margin, trailing: margin)
    }
    public func marginY(_ margin: NumberConvertible) -> Self {
        return self.margin(top: margin,bottom: margin)
    }
    
    @discardableResult
    public func minSpacing(_ spacing: NumberConvertible) -> Self {
        self.minSpacing = spacing.cgFloat
        return self
    }
    @discardableResult
    public func maxSpacing(_ spacing: NumberConvertible) -> Self {
        self.maxSpacing = spacing.cgFloat
        return self
    }
    @discardableResult
    public func isFlexibleSpace(_ isFlex: Bool) -> Self {
        self.isFlexibleSpace = isFlex
        return self
    }
    @discardableResult
    public func flex(_ value: Int) -> Self {
        self.flex = value
        return self
    }
    @discardableResult
    public func height(_ height: NumberConvertible) -> Self {
        self.height = height.cgFloat
        return self
    }
    @discardableResult
    public func width(_ width: NumberConvertible) -> Self {
        self.width = width.cgFloat
        return self
    }
    @discardableResult
    public func minWidth(_ width: NumberConvertible) -> Self {
        self.minWidth = width.cgFloat
        return self
    }
    
    @discardableResult
    public func maxWidth(_ width: NumberConvertible) -> Self {
        self.maxWidth = width.cgFloat
        return self
    }
    
    @discardableResult
    public func minHeight(_ height: NumberConvertible) -> Self {
        self.minHeight = height.cgFloat
        return self
    }
    
    @discardableResult
    public func maxHeight(_ height: NumberConvertible) -> Self {
        self.maxHeight = height.cgFloat
        return self
    }
    
    @discardableResult
    public func size(w: NumberConvertible,h: NumberConvertible) -> Self {
        self.size = CGSize(width: w.cgFloat, height: h.cgFloat)
        return self
    }
    
    
    @discardableResult
    public func view<T>(as view: T.Type) -> T? where T: UIView {
        return self.view as? T
    }
}

extension FlexItem {
    public func setStackViewNeedsUpdateConstraints() {
        guard let view = self.view,
              let stackView = self.stackView,
              view.superview == stackView else { return }
        stackView.markedUpdateConstraints()
    }
    public func setSpacingWithoutUpdate(_ spacing: CGFloat) {
        _spacing = spacing
    }
    
    public func filterConstraint(
        _ block: (NSLayoutConstraint) -> Bool
    ) -> [NSLayoutConstraint]? {
        guard let manager = stackView?.layoutManager else {
            return nil
        }
        guard !manager.constraints.isEmpty else { return nil }
        return manager.constraints.filter { constraint in
            block(constraint)
        }
    }
}



public extension FlexItem {
    
    @objc(margin)
    @available(swift, obsoleted: 1, renamed: "margin(_:)")
    var marginObjc: (_ margin: NSDirectionalEdgeInsets) -> FlexItem {
        { margin in self.margin = margin; return self }
    }
    
    @objc(spacing)
    @available(swift, obsoleted: 1, renamed: "spacing(_:)")
    var spacingObjc: (_ spacing: CGFloat) -> FlexItem {
        { spacing in self.spacing = spacing; return self }
    }
    
    @objc(minSpacing)
    @available(swift, obsoleted: 1, renamed: "minSpacing(_:)")
    var minSpacingObjc: (_ spacing: CGFloat) -> FlexItem {
        { spacing in self.minSpacing = spacing; return self }
    }
    
    @objc(maxSpacing)
    @available(swift, obsoleted: 1, renamed: "maxSpacing(_:)")
    var maxSpacingObjc: (_ spacing: CGFloat) -> FlexItem {
        { spacing in self.maxSpacing = spacing; return self }
    }
    
    @objc(isFlexibleSpace)
    @available(swift, obsoleted: 1, renamed: "isFlexSpace(_:)")
    var isFlexSpaceObjc: (_ isFlex: Bool) -> FlexItem {
        { isFlex in self.isFlexibleSpace = isFlex; return self }
    }
    
    @objc(flex)
    @available(swift, obsoleted: 1, renamed: "flexValue(_:)")
    var flexValueObjc: (_ value: Int) -> FlexItem {
        { value in self.flex = value; return self }
    }
    
    @objc(alignSelf)
    @available(swift, obsoleted: 1, renamed: "alignSelf")
    var alignSelfObjc: (_ align: FlexItemCrossAlign) -> FlexItem {
        { align in self.alignSelf = align; return self }
    }
    
    @objc(height)
    @available(swift, obsoleted: 1, renamed: "height(_:)")
    var heightObjc: (_ height: CGFloat) -> FlexItem {
        { height in self.height = height; return self }
    }
    
    @objc(width)
    @available(swift, obsoleted: 1, renamed: "width(_:)")
    var widthObjc: (_ width: CGFloat) -> FlexItem {
        { width in self.width = width; return self }
    }
    
    @objc(minWidth)
    @available(swift, obsoleted: 1, renamed: "minWidth(_:)")
    var minWidthObjc: (_ width: CGFloat) -> FlexItem {
        { width in self.minWidth = width; return self }
    }
    
    @objc(maxWidth)
    @available(swift, obsoleted: 1, renamed: "maxWidth(_:)")
    var maxWidthObjc: (_ width: CGFloat) -> FlexItem {
        { width in self.maxWidth = width; return self }
    }
    
    @objc(minHeight)
    @available(swift, obsoleted: 1, renamed: "minHeight(_:)")
    var minHeightObjc: (_ height: CGFloat) -> FlexItem {
        { height in self.minHeight = height; return self }
    }
    
    @objc(maxHeight)
    @available(swift, obsoleted: 1, renamed: "maxHeight(_:)")
    var maxHeightObjc: (_ height: CGFloat) -> FlexItem {
        { height in self.maxHeight = height; return self }
    }
    
    @objc(size)
    @available(swift, obsoleted: 1, renamed: "size(w:h:)")
    var sizeObjc: (_ w: CGFloat, _ h: CGFloat) -> FlexItem {
        { w, h in self.size = CGSize(width: w, height: h); return self }
    }
}









private var flexKey:      UInt8 = 0
extension UIView {
    @objc
    public var flex: FlexItem {
        if let cfg = objc_getAssociatedObject(self, &flexKey) as? FlexItem {
            return cfg
        }
        let cfg = FlexItem()
        cfg.view = self
        // 如需显式延长生命周期到自动释放池销毁，可用：
        _ = Unmanaged.passRetained(self).autorelease()
        objc_setAssociatedObject(
            self,
            &flexKey,
            cfg,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        return cfg
    }
}
