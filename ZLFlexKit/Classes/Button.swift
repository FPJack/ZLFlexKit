//
//  Button.swift
//  ZLFlexKit
//
//  Created by admin on 2026/6/9.
//

import UIKit
@objc
open class Button: UIButton, ViewStyleable {
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



public extension Button {
    @objc(gradColors)
    @available(swift, obsoleted: 1, renamed: "gradColors(_:)")
    var gradColorsObjc: (_ colors: [UIColor]?) -> Button {
        { colors in
            self.gradColors(colors)
        }
    }
    
    @objc(gradDirection)
    @available(swift, obsoleted: 1, renamed: "gradDirection(start:end:)")
    var gradDirectionObjc: (_ start: CGPoint, _ end: CGPoint) -> Button {
        { start, end in
            self.gradDirection(start: start, end: end)
        }
    }
    
    @objc(borderColor)
    @available(swift, obsoleted: 1, renamed: "borderColor(_:)")
    var borderColorObjc: (_ color: UIColor?) -> Button {
        { color in
            self.borderColor(color: color)
        }
    }
    
    @objc(borderWidth)
    @available(swift, obsoleted: 1, renamed: "borderWidth(_:)")
    var borderWidthObjc: (_ width: CGFloat) -> Button {
        { width in
            self.borderWidth(w: width)
        }
    }
    
    @objc(border)
    @available(swift, obsoleted: 1, renamed: "border(color:width:)")
    var borderObjc: (_ color: UIColor?, _ width: CGFloat) -> Button {
        { color, width in
            self.border(color: color, w: width)
        }
    }
    @objc(shadowColor)
    @available(swift, obsoleted: 1, renamed: "shadowColor(_:)")
    var shadowColorObjc: (_ color: UIColor?) -> Button {
        { color in
            self.shadowColor(color: color)
        }
    }
    
    @objc(shadowOffset)
    @available(swift, obsoleted: 1, renamed: "shadowOffset(_:_:)")
    var shadowOffsetObjc: (_ width: CGFloat, _ height: CGFloat) -> Button {
        { w, h in
            self.shadowOffset(w: w, h: h)
        }
    }
    
    @objc(shadowRadius)
    @available(swift, obsoleted: 1, renamed: "shadowRadius(_:)")
    var shadowRadiusObjc: (_ radius: CGFloat) -> Button {
        { radius in
            self.shadowRadius(radius: radius)
        }
    }
    
    @objc(shadowOpacity)
    @available(swift, obsoleted: 1, renamed: "shadowOpacity(_:)")
    var shadowOpacityObjc: (_ opacity: Float) -> Button {
        { opacity in
            self.shadowOpacity(opacity: opacity)
        }
    }
    @objc(cornerRadii)
    @available(swift, obsoleted: 1, renamed: "cornerRadii(_:_:_:_:)")
    var cornerRadiiObjc: (_ tl: CGFloat, _ tr: CGFloat, _ bl: CGFloat, _ br: CGFloat) -> Button {
        { tl, tr, bl, br in
            self.cornerRadii(tl, tr, bl, br)
        }
    }
    
    @objc(radius)
    @available(swift, obsoleted: 1, renamed: "radius(_:)")
    var radiusObjc: (_ radius: CGFloat) -> Button {
        { r in
            self.radius(r)
        }
    }
}


