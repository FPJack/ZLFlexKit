//
//  Label.swift
//  ZLFlexKit
//
//  Created by admin on 2026/6/8.
//

import UIKit
@objc(ZLLabel)
open class Label: UILabel {
    @objc
    public var insets: UIEdgeInsets = .zero {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    private var effectiveInsets: UIEdgeInsets {
        let isRTL = effectiveUserInterfaceLayoutDirection == .rightToLeft
        let left = isRTL ? insets.right : insets.left
        let right = isRTL ? insets.left : insets.right
        return UIEdgeInsets(
            
            top: insets.top,
            
            left: left,
            
            bottom: insets.bottom,
            
            right: right
            
        )
    }
    open override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, effectiveInsets))
    }
    
    
    open override var intrinsicContentSize: CGSize {
        
        var size = super.intrinsicContentSize
        
        size.width += insets.left + insets.right
        
        size.height += insets.top + insets.bottom
        
        return size
        
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        let fitSize = super.sizeThatFits(
            
            CGSize(
                
                width: size.width - insets.left - insets.right,
                
                height: size.height - insets.top - insets.bottom
                
            )
            
        )
        
        return CGSize(
            
            width: fitSize.width + insets.left + insets.right,
            
            height: fitSize.height + insets.top + insets.bottom
            
        )
        
    }
}

