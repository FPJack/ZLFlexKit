//
//  View.swift
//  ZLFlexKit
//
//  Created by admin on 2026/6/8.
//

import UIKit
public class ViewStyle {
    let view: ViewStyleable
    init(view: ViewStyleable) {
        self.view = view
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    private var _backgroundShapeLayer: CAShapeLayer?
    lazy private var backgroundShapeLayer: CAShapeLayer = {
        self._backgroundShapeLayer = CAShapeLayer()
        self.markedNeedUpdate = true
        let view = self.view as UIView
        self.observation = view.observe(\.bounds, options: [.new, .old]) {[weak self] view, change in
            guard let self = self else { return }
            if change.newValue != change.oldValue {
                self.markedNeedUpdate = true
                self.view.setNeedsLayout()
            }
        }
        return self._backgroundShapeLayer!
    }()
    
    private var _gradLayer: CAGradientLayer?
    private lazy var gradLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        _gradLayer = layer
        layer.startPoint = CGPoint(x: 0, y: 0) // 左上
        layer.endPoint = CGPoint(x: 1, y: 1)   // 右下
        _ = backgroundShapeLayer
        return layer
    }()
    
    private var _bgColor: UIColor?
    
    public var backgroundColor: UIColor? {
        get {
            return _bgColor ?? self.view.superBackgroundColor()
        }
        set {
            _bgColor = newValue
            if let shapeLayer = _backgroundShapeLayer {
                shapeLayer.fillColor = newValue?.cgColor
            } else {
                self.view.superSetBackgroundColor(newValue)
            }
        }
    }
    private var markedNeedUpdate = false
    
    var cornerRadiiValue:UIEdgeInsets = .init(top: -1, left: -1, bottom: -1, right: -1)
    
    private var observation: NSKeyValueObservation?
    
    public func layoutSubviews() {
        if markedNeedUpdate  {
            markedNeedUpdate = false;
            _updateLayer()
        }
    }
}
extension ViewStyle {
    fileprivate func bezierPath(
        rect: CGRect,
        tl: CGFloat,
        tr: CGFloat,
        bl: CGFloat,
        br: CGFloat
    ) -> UIBezierPath {
        
        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: minX + tl, y: minY))
        path.addLine(to: CGPoint(x: maxX - tr, y: minY))
        
        path.addArc(
            withCenter: CGPoint(x: maxX - tr, y: minY + tr),
            radius: tr,
            startAngle: -.pi / 2,
            endAngle: 0,
            clockwise: true
        )
        
        path.addLine(to: CGPoint(x: maxX, y: maxY - br))
        
        path.addArc(
            withCenter: CGPoint(x: maxX - br, y: maxY - br),
            radius: br,
            startAngle: 0,
            endAngle: .pi / 2,
            clockwise: true
        )
        
        path.addLine(to: CGPoint(x: minX + bl, y: maxY))
        
        path.addArc(
            withCenter: CGPoint(x: minX + bl, y: maxY - bl),
            radius: bl,
            startAngle: .pi / 2,
            endAngle: .pi,
            clockwise: true
        )
        
        path.addLine(to: CGPoint(x: minX, y: minY + tl))
        
        path.addArc(
            withCenter: CGPoint(x: minX + tl, y: minY + tl),
            radius: tl,
            startAngle: .pi,
            endAngle: -.pi / 2,
            clockwise: true
        )
        
        path.close()
        
        return path
    }
    
    private var isRTL: Bool {
        if #available(iOS 10.0, *) {
            return view.effectiveUserInterfaceLayoutDirection == .rightToLeft
        } else {
            return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
        }
    }
    
    private func _updateLayer() {
        
        var tl: CGFloat = 0
        var tr: CGFloat = 0
        var bl: CGFloat = 0
        var br: CGFloat = 0
        
        let isRTL = self.isRTL
        
        let topLeft: CGFloat
        let topRight: CGFloat
        let bottomLeft: CGFloat
        let bottomRight: CGFloat
        
        if isRTL {
            topLeft = cornerRadiiValue.left
            topRight = cornerRadiiValue.top
            bottomLeft = cornerRadiiValue.right
            bottomRight = cornerRadiiValue.bottom
        } else {
            topLeft = cornerRadiiValue.top
            topRight = cornerRadiiValue.left
            bottomLeft = cornerRadiiValue.bottom
            bottomRight = cornerRadiiValue.right
        }
        
        tl = max(topLeft, 0)
        tr = max(topRight, 0)
        bl = max(bottomLeft, 0)
        br = max(bottomRight, 0)
        
        let path = bezierPath(rect: view.bounds, tl: tl, tr: tr, bl: bl, br: br)
        
        // MARK: - background shape layer
        if let shapeLayer = _backgroundShapeLayer {
            
            shapeLayer.frame = view.bounds
            shapeLayer.path = path.cgPath
            
            if let bgColor = _bgColor {
                shapeLayer.fillColor = bgColor.cgColor
                view.superSetBackgroundColor(.clear)
            } else {
                shapeLayer.fillColor = UIColor.white.cgColor
            }
        }
        
        // MARK: - gradient layer
        if let gradLayer = _gradLayer {
            
            gradLayer.frame = view.bounds
            
            let maskLayer = CAShapeLayer()
            maskLayer.frame = gradLayer.bounds
            maskLayer.path = path.cgPath
            gradLayer.mask = maskLayer
            view.layer.insertSublayer(gradLayer, at: 0)
        }
        
        // MARK: - shadow
        if view.layer.shadowColor != nil {
            view.layer.shadowPath = path.cgPath
        }
        
        if let shapeLayer = _backgroundShapeLayer {
            view.layer.insertSublayer(shapeLayer, at: 0)
        }
    }
}

public protocol ViewStyleable where Self: UIView {
    var viewStyle: ViewStyle { get }
    func superBackgroundColor() -> UIColor?
    func superSetBackgroundColor(_ color: UIColor?)
    func gradColors(_ colors: [UIColor]?) -> Self
    func gradDirection(start: CGPoint, end: CGPoint) -> Self
    func borderColor(color: UIColor?) -> Self
    func borderWidth(w: Double) -> Self
    func border(color: UIColor?, w: Double) -> Self
    func shadowColor(color: UIColor?) -> Self
    
    func shadowOffset(w: Double,h: Double) -> Self
    
    func shadowRadius(radius: Double) -> Self
    
    func shadowOpacity(opacity: Float) -> Self
    
    func cornerRadii(_ topLeading: CGFloat,
                            _ topTrailing: CGFloat,
                            _ bottomLeading: CGFloat,
                            _ bottomTrailing: CGFloat) -> Self
    func radius(_ radius: CGFloat) -> Self
}
extension ViewStyleable {
    @discardableResult
    public func gradColors(_ colors: [UIColor]?) -> Self {
         self.viewStyle.gradColors(colors).view as! Self
    }
    
    @discardableResult
    public func gradDirection(start: CGPoint, end: CGPoint) -> Self {
         self.viewStyle.gradDirection(start: start, end: end).view as! Self
    }
    
    @discardableResult
    public func borderColor(color: UIColor?) -> Self{
        self.viewStyle.borderColor(color: color).view as! Self
    }
    
    @discardableResult
    public func borderWidth(w: Double) -> Self{
        self.viewStyle.borderWidth(w: w).view as! Self
    }
    
    @discardableResult
    public func border(color: UIColor?, w: Double) -> Self {
        borderColor(color: color).borderWidth(w:w)
    }
    
    @discardableResult
    public func shadowColor(color: UIColor?) -> Self{
        self.viewStyle.shadowColor(color: color).view as! Self
    }
    
    @discardableResult
    public func shadowOffset(w: Double,h: Double) -> Self{
        self.viewStyle.shadowOffset(w: w, h: h).view as! Self
    }
    
    @discardableResult
    public func shadowRadius(radius: Double) -> Self{
        self.viewStyle.shadowRadius(radius: radius).view as! Self
    }
    
    @discardableResult
    public func shadowOpacity(opacity: Float) -> Self{
        self.viewStyle.shadowOpacity(opacity: opacity).view as! Self
    }
    
    @discardableResult
    public func cornerRadii(_ topLeading: CGFloat,
                            _ topTrailing: CGFloat,
                            _ bottomLeading: CGFloat,
                            _ bottomTrailing: CGFloat) -> Self {
        self.viewStyle.cornerRadii(topLeading, topTrailing, bottomLeading, bottomTrailing).view as! Self
    }
    
    
    @discardableResult
    public func radius(_ radius: CGFloat) -> Self {
        cornerRadii(radius, radius, radius, radius)
    }
}
 extension ViewStyle {
    @discardableResult
    public func gradColors(_ colors: [UIColor]?) -> Self {
        if _gradLayer == nil {
            markedNeedUpdate = true
            view.setNeedsLayout()
        }
        let cgColors = colors?.map {
            $0.cgColor
        }
        gradLayer.colors = cgColors
        return self
    }
    
    @discardableResult
    public func gradDirection(start: CGPoint, end: CGPoint) -> Self {
        if _gradLayer == nil {
            view.setNeedsLayout()
        }
        gradLayer.startPoint = start
        gradLayer.endPoint = end
        return self
    }
    
    @discardableResult
    public func borderColor(color: UIColor?) -> Self{
        backgroundShapeLayer.strokeColor = color?.cgColor
        return self
    }
    
    @discardableResult
    public func borderWidth(w: Double) -> Self{
        backgroundShapeLayer.lineWidth = CGFloat(w)
        return self
    }
    
    @discardableResult
    public func border(color: UIColor?, w: Double) -> Self {
        borderColor(color: color).borderWidth(w:w)
    }
    
    @discardableResult
    public func shadowColor(color: UIColor?) -> Self{
        let layer = view.layer
        layer.shadowColor = color?.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.masksToBounds = false
        _ = backgroundShapeLayer
        return self
    }
    
    @discardableResult
    public func shadowOffset(w: Double,h: Double) -> Self{
        view.layer.shadowOffset = CGSize(width: w, height: h)
        return self
    }
    
    @discardableResult
    public func shadowRadius(radius: Double) -> Self{
        view.layer.shadowRadius = radius;
        return self
    }
    
    @discardableResult
    public func shadowOpacity(opacity: Float) -> Self{
        view.layer.shadowOpacity = opacity
        return self
    }
    
    @discardableResult
    public func cornerRadii(_ topLeading: CGFloat,
                            _ topTrailing: CGFloat,
                            _ bottomLeading: CGFloat,
                            _ bottomTrailing: CGFloat) -> Self {
        let newValue = UIEdgeInsets(top: topLeading,
                                    left: topTrailing,
                                    bottom: bottomLeading,
                                    right: bottomTrailing)
        if newValue == cornerRadiiValue {
            return self
        }
        cornerRadiiValue = newValue
        _ = backgroundShapeLayer
        markedNeedUpdate = true
        view.setNeedsLayout()
        return self
    }
    
    
    @discardableResult
    public func radius(_ radius: CGFloat) -> Self {
        cornerRadii(radius, radius, radius, radius)
        return self
    }
}





@objc(ZLView)
open class View: UIView,ViewStyleable {
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
    override public func layoutSubviews() {
        super.layoutSubviews()
        viewStyle.layoutSubviews()
    }
}



public extension View {
    @objc(gradColors)
    @available(swift, obsoleted: 1, renamed: "gradColors(_:)")
    var gradColorsObjc: (_ colors: [UIColor]?) -> View {
        { colors in
            self.gradColors(colors)
        }
    }
    
    @objc(gradDirection)
    @available(swift, obsoleted: 1, renamed: "gradDirection(start:end:)")
    var gradDirectionObjc: (_ start: CGPoint, _ end: CGPoint) -> View {
        { start, end in
            self.gradDirection(start: start, end: end)
        }
    }
    
    @objc(borderColor)
    @available(swift, obsoleted: 1, renamed: "borderColor(_:)")
    var borderColorObjc: (_ color: UIColor?) -> View {
        { color in
            self.borderColor(color: color)
        }
    }
    
    @objc(borderWidth)
    @available(swift, obsoleted: 1, renamed: "borderWidth(_:)")
    var borderWidthObjc: (_ width: CGFloat) -> View {
        { width in
            self.borderWidth(w: width)
        }
    }
    
    @objc(border)
    @available(swift, obsoleted: 1, renamed: "border(color:width:)")
    var borderObjc: (_ color: UIColor?, _ width: CGFloat) -> View {
        { color, width in
            self.border(color: color, w: width)
        }
    }
    @objc(shadowColor)
    @available(swift, obsoleted: 1, renamed: "shadowColor(_:)")
    var shadowColorObjc: (_ color: UIColor?) -> View {
        { color in
            self.shadowColor(color: color)
        }
    }
    
    @objc(shadowOffset)
    @available(swift, obsoleted: 1, renamed: "shadowOffset(_:_:)")
    var shadowOffsetObjc: (_ width: CGFloat, _ height: CGFloat) -> View {
        { w, h in
            self.shadowOffset(w: w, h: h)
        }
    }
    
    @objc(shadowRadius)
    @available(swift, obsoleted: 1, renamed: "shadowRadius(_:)")
    var shadowRadiusObjc: (_ radius: CGFloat) -> View {
        { radius in
            self.shadowRadius(radius: radius)
        }
    }
    
    @objc(shadowOpacity)
    @available(swift, obsoleted: 1, renamed: "shadowOpacity(_:)")
    var shadowOpacityObjc: (_ opacity: Float) -> View {
        { opacity in
            self.shadowOpacity(opacity: opacity)
        }
    }
    @objc(cornerRadii)
    @available(swift, obsoleted: 1, renamed: "cornerRadii(_:_:_:_:)")
    var cornerRadiiObjc: (_ tl: CGFloat, _ tr: CGFloat, _ bl: CGFloat, _ br: CGFloat) -> View {
        { tl, tr, bl, br in
            self.cornerRadii(tl, tr, bl, br)
        }
    }
    
    @objc(radius)
    @available(swift, obsoleted: 1, renamed: "radius(_:)")
    var radiusObjc: (_ radius: CGFloat) -> View {
        { r in
            self.radius(r)
        }
    }
}

