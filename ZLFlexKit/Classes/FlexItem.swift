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
    weak var _view: UIView? {
        didSet {
            guard observation == nil else { return }
            observation = _view?.observe(\.isHidden, options: [.new, .old]) {[weak self] view, change in
                guard let self = self else { return }
                if let newValue = change.newValue,
                    let oldValue = change.oldValue,
                    newValue != oldValue {
                    self.setStackViewNeedsUpdateConstraints()
                }
            }
        }
    }
    
    @objc(view)
    @available(swift, obsoleted: 1, renamed: "view")
    public weak var viewObjc: UIView? {
        _view
    }
    
    public weak var stackView: StackView?
    
    private var startInset: CGFloat {
        guard let stackView = stackView else { return 0 }
        if stackView.axis == .horizontal {
            return stackView.insets.top
        } else {
            return stackView.insets.left
        }
    }
    private var endInset: CGFloat {
        guard let stackView = stackView else { return 0 }
        if stackView.axis == .horizontal {
            return stackView.insets.bottom
        } else {
            return stackView.insets.right
        }
    }
    
    public var startMarge: CGFloat = 0 {
        didSet {
            guard startMarge != oldValue else { return }
            let arr = filterConstraint { constraint in
                let cfg = constraint.item
                return cfg.view == view && cfg.type == .start
            }
            guard let cons = arr?.first else {
                setStackViewNeedsUpdateConstraints()
                return
            }
            
            cons.constant = startMarge + startInset
            
            if alignSelf == .center {
                
                let centerCons = filterConstraint { constraint in
                    
                    let cfg = constraint.item
                    
                    return cfg.view == view && cfg.type == .center
                    
                }?.first
                
                centerCons?.constant = (startMarge + startInset - endMarge - endInset) * 0.5
                
            }
        }
    }
    public var endMarge: CGFloat = 0 {
        didSet {
            guard endMarge != oldValue else { return }
            let arr = filterConstraint { constraint in
                let cfg = constraint.item
                return cfg.view == view && cfg.type == .end
            }
            guard let cons = arr?.first else {
                setStackViewNeedsUpdateConstraints()
                return
            }
            
            cons.constant = -endMarge - endInset
            
            if alignSelf == .center {
                
                let centerCons = filterConstraint { constraint in
                    
                    let cfg = constraint.item
                    
                    return cfg.view == view && cfg.type == .center
                    
                }?.first
                
                centerCons?.constant = (startMarge + startInset - endMarge - endInset) * 0.5
                
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
            view?.layout.height(height)
        }
    }
    public var width: CGFloat = 0 {
        didSet {
            view?.layout.width(width)
        }
    }
    public var minWidth: CGFloat = 0 {
        didSet {
            view?.layout.minWidth(minWidth)
        }
    }
    public var maxWidth: CGFloat = 0 {
        didSet {
            view?.layout.maxWidth(maxWidth)
        }
    }
    public var minHeight: CGFloat = 0 {
        didSet {
            view?.layout.minHeight(minHeight)
        }
    }
    public var maxHeight: CGFloat = 0 {
        didSet {
            view?.layout.maxHeight(maxHeight)
        }
    }
    public var size: CGSize = .zero {
        didSet {
            view?.layout.size(w: size.width, h: size.height)
        }
    }
    
    public override init() {
        super.init()
        minSpacing = -2
        maxSpacing = -2
        startMarge = 0
        endMarge = 0
    }
    
    @discardableResult
    public func startMarge(_ marge: NumberConvertible) -> Self {
        self.startMarge = marge.cgFloat
        return self
    }
    @discardableResult
    public func endMarge(_ marge: NumberConvertible) -> Self {
        self.endMarge = marge.cgFloat
        return self
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
    
    @objc(startMarge)
    @available(swift, obsoleted: 1, renamed: "startSpacing(_:)")
    var startSpacingObjc: (_ marge: CGFloat) -> FlexItem {
        { marge in self.startMarge = marge; return self }
    }
    
    @objc(endMarge)
    @available(swift, obsoleted: 1, renamed: "endSpacing(_:)")
    var endSpacingObjc: (_ marge: CGFloat) -> FlexItem {
        { marge in self.endMarge = marge; return self }
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


public class FlexItemSwift<T: UIView>: FlexItem {
    public init(view: T) {
        super.init()
        self._view = view as UIView
    }
    public var view: T? {
        _view as? T
    }
}


private var flexSwiftKey:      UInt8 = 0
public protocol FLexItemCompatible where Self: UIView {}
extension UIView: FLexItemCompatible {}
extension FLexItemCompatible {
   public var flex: FlexItemSwift<Self> {
        if let cfg = objc_getAssociatedObject(self, &flexSwiftKey) as? FlexItemSwift<Self> {
            return cfg
        }
        let cfg = FlexItemSwift(view: self)
        // 如需显式延长生命周期到自动释放池销毁，可用：
        _ = Unmanaged.passRetained(self).autorelease()
        objc_setAssociatedObject(
            self,
            &flexSwiftKey,
            cfg,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        return cfg
    }
}



private var flexKey:      UInt8 = 0
extension UIView {
    @objc(flex)
    @available(swift, obsoleted: 1, renamed: "flex")
    public var flexObjc: FlexItem {
        if let cfg = objc_getAssociatedObject(self, &flexKey) as? FlexItem {
            return cfg
        }
        let cfg = FlexItem()
        cfg._view = self
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
