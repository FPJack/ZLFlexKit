//
//  View.swift
//  ZLFlexKit
//
//  Created by admin on 2026/6/8.
//

import UIKit
@objc(ZLView)
open class View: UIView {
    
    private var _backgroundShapeLayer: CAShapeLayer?
    lazy private var backgroundShapeLayer: CAShapeLayer = {
        self._backgroundShapeLayer = CAShapeLayer()
        self.markedNeedUpdate = true
        self.observation = self.observe(\.bounds, options: [.new, .old]) { view, change in
            if change.newValue != change.oldValue {
                self.markedNeedUpdate = true
                self.setNeedsLayout()
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
    
    override public var backgroundColor: UIColor? {
        get {
            return _bgColor ?? super.backgroundColor
        }
        set {
            _bgColor = newValue
            if let shapeLayer = _backgroundShapeLayer {
                shapeLayer.fillColor = newValue?.cgColor
            } else {
                super.backgroundColor = newValue
            }
        }
    }
    
    
    private var markedNeedUpdate = false
    
    var cornerRadiiValue:UIEdgeInsets = .init(top: -1, left: -1, bottom: -1, right: -1)
    
    private var observation: NSKeyValueObservation?
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if markedNeedUpdate  {
            markedNeedUpdate = false;
            _updateLayer()
        }
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
extension View {
    @discardableResult
    public func gradColors(_ colors: [UIColor]?) -> Self {
        if _gradLayer == nil {
            setNeedsLayout()
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
            setNeedsLayout()
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
        layer.shadowOffset = CGSize(width: w, height: h)
        return self
    }
    
    @discardableResult
    public func shadowRadius(radius: Double) -> Self{
        layer.shadowRadius = radius;
        return self
    }
    
    @discardableResult
    public func shadowOpacity(opacity: Float) -> Self{
        layer.shadowOpacity = opacity
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
        setNeedsLayout()
        return self
    }
    
    
    @discardableResult
    public func radius(_ radius: CGFloat) -> Self {
        cornerRadii(radius, radius, radius, radius)
        return self
    }
}

extension View {
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
            return effectiveUserInterfaceLayoutDirection == .rightToLeft
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
        
        let path = bezierPath(rect: bounds, tl: tl, tr: tr, bl: bl, br: br)
        
        // MARK: - background shape layer
        if let shapeLayer = _backgroundShapeLayer {
            
            shapeLayer.frame = bounds
            shapeLayer.path = path.cgPath
            
            if let bgColor = _bgColor {
                shapeLayer.fillColor = bgColor.cgColor
                super.backgroundColor = .clear
            } else {
                shapeLayer.fillColor = UIColor.white.cgColor
            }
        }
        
        // MARK: - gradient layer
        if let gradLayer = _gradLayer {
            
            gradLayer.frame = bounds
            
            let maskLayer = CAShapeLayer()
            maskLayer.frame = gradLayer.bounds
            maskLayer.path = path.cgPath
            gradLayer.mask = maskLayer
            layer.insertSublayer(gradLayer, at: 0)
        }
        
        // MARK: - shadow
        if layer.shadowColor != nil {
            layer.shadowPath = path.cgPath
        }
        
        if let shapeLayer = _backgroundShapeLayer {
            layer.insertSublayer(shapeLayer, at: 0)
        }
    }
}
