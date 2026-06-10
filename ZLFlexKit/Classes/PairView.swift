import UIKit
//public protocol CreatableView: UIView {
//    init()
//}
//
//open class PairView<F: CreatableView,S: CreatableView>: StackView {
//    public lazy var first: F = {
//        let view = F()
//        addFirst(view)
//        return view
//    }()
//    private func addFirst(_ view: F) {
//        super.insertArrangedSubview(view, at: 0)
//    }
//    public lazy var second: S = {
//            let view = S()
//            addSecond(view)
//            return view
//    }()
//    private func addSecond(_ view: S) {
//        super.addArrangedSubview(view)
//    }
//
//    @discardableResult
//    public func minSpacing(_ spacing: CGFloat) -> Self {
//        setCustomMinSpacing(spacing, after: first)
//        return self
//    }
//    @discardableResult
//    public func maxSpacing(_ spacing: CGFloat) -> Self {
//        setCustomMaxSpacing(spacing, after: first)
//        return self
//    }
//    @discardableResult
//    public func flexSpacing(_ flexible: Bool = true) -> Self {
//        first.flex.isFlexibleSpace = flexible
//        return self
//    }
//    @discardableResult
//    public func firstStart(_ spacing: CGFloat) -> Self {
//        startMarge(spacing, for: first)
//        return self
//    }
//    @discardableResult
//    public func firstEnd(_ spacing: CGFloat) -> Self {
//        endMarge(spacing, for: first)
//        return self
//    }
//    @discardableResult
//    public func secondStart(_ spacing: CGFloat) -> Self {
//        startMarge(spacing, for: second)
//        return self
//    }
//    @discardableResult
//    public func secondEnd(_ spacing: CGFloat) -> Self {
//        endMarge(spacing, for: second)
//        return self
//    }
//
//    @discardableResult
//    public func firstFlex(_ flex: Int) -> Self {
//        setFlex(flex, for: first)
//        return self
//    }
//    @discardableResult
//    public func secondFlex(_ flex: Int) -> Self {
//        setFlex(flex, for: second)
//        return self
//    }
//    @discardableResult
//    public func thenFirst(_ then: @escaping (F) -> Void) -> Self {
//        then(first)
//        return self
//    }
//    @discardableResult
//    public func thenSecond(_ then: @escaping (S) -> Void) -> Self {
//        then(second)
//        return self
//    }
//
//
//
//
//}




@objcMembers
@objc(ZLPairView)
open class PairView: StackView {
    fileprivate lazy var _first: UIView = {
        return createFirstView()
    }()
    private func addFirst(_ view: UIView) {
        super.insertArrangedSubview(view, at: 0)
    }
    fileprivate lazy var _second: UIView = {
        return createSecondView()
    }()
    private func addSecond(_ view: UIView) {
        super.addArrangedSubview(view)
    }
    func createFirstView() -> UIView {
        fatalError("override")
    }
    func createSecondView() -> UIView {
        fatalError("override")
    }
    @discardableResult
    public func minSpacing(_ spacing: CGFloat) -> Self {
        super.setCustomMinSpacing(spacing, after: _first)
        return self
    }
    @discardableResult
    public func maxSpacing(_ spacing: CGFloat) -> Self {
        super.setCustomMaxSpacing(spacing, after: _first)
        return self
    }
    @discardableResult
    public func flexibleSpacing(_ flexible: Bool = true) -> Self {
        _first.flex.isFlexibleSpace = flexible
        return self
    }
    @discardableResult
    public func firstStart(_ spacing: CGFloat) -> Self {
        super.startMarge(spacing, for: _first)
        return self
    }
    @discardableResult
    public func firstEnd(_ spacing: CGFloat) -> Self {
        super.endMarge(spacing, for: _first)
        return self
    }
    @discardableResult
    public func secondStart(_ spacing: CGFloat) -> Self {
        super.startMarge(spacing, for: _second)
        return self
    }
    @discardableResult
    public func secondEnd(_ spacing: CGFloat) -> Self {
        super.endMarge(spacing, for: _second)
        return self
    }
    
    @discardableResult
    public func firstFlex(_ flex: Int) -> Self {
        super.setFlex(flex, for: _first)
        return self
    }
    @discardableResult
    public func secondFlex(_ flex: Int) -> Self {
        super.setFlex(flex, for: _second)
        return self
    }
    @discardableResult
    func _thenFirst<T: UIView>(_ then: @escaping (T) -> Void) -> Self {
        then(_first as! T)
        return self
    }
    @discardableResult
    func _thenSecond<T: UIView>(_ then: @escaping (T) -> Void) -> Self {
        then(_second as! T)
        return self
    }
    
    
    @available(*, unavailable)
    public override func insertSpacing(_ spacing: any NumberConvertible) -> Self {
        super.insertSpacing(spacing)
    }
    @available(*, unavailable)
    public override func insertSpacing(max: any NumberConvertible) -> Self {
        super.insertSpacing(max: max)
    }
    @available(*, unavailable)
    public override func insertSpacing(min: any NumberConvertible) -> Self {
        super.insertSpacing(min: min)
    }
    @available(*, unavailable)
    public override func insertSpacing(flexible: Bool) -> Self {
        super.insertSpacing(flexible: flexible)
    }
    @available(*, unavailable)
    public override func addView(_ flexType: (any FlexType)?) -> Self {
        super.addView(flexType)
    }
    @available(*, unavailable)
    public override func addView(if condition: Bool, _ view: (any FlexType)?) -> Self {
        super.addView(if: condition, view)
    }
    
    @available(*, unavailable)
    public override func addView<T>(make: @escaping (T) -> (any FlexType)?) -> Self where T : StackView {
        super.addView(make: make)
    }
    
    @available(*, unavailable)
    public override func addView<T>(if condition: Bool, make: @escaping (T) -> (any FlexType)?) -> Self where T : StackView {
        super.addView(if: condition, make: make)
    }
    
}

extension PairView {
    @available(*, unavailable)
    public override func addArrangedSubview(_ view: UIView?) {
        super.addArrangedSubview(view)
    }
    @available(*, unavailable)
    public override func addArrangedSubview(_ view: UIView, layout config: ((UIView, FlexItem) -> Void)?) {
        super.addArrangedSubview(view, layout: config)
    }
    @available(*, unavailable)
    public override func insertArrangedSubview(_ view: UIView?, at stackIndex: Int) {
        super.insertArrangedSubview(view, at: stackIndex)
    }
    @available(*, unavailable)
    public override func removeArrangedSubview(_ view: UIView?) {
        super.removeArrangedSubview(view)
    }
    @available(*, unavailable)
    public override func setCustomSpacing(_ spacing: CGFloat, after view: UIView?) {
        super.setCustomSpacing(spacing, after: view)
    }
    @available(*, unavailable)
    public override func setCustomMaxSpacing(_ maxSpacing: CGFloat, after view: UIView?) {
        super.setCustomMaxSpacing(maxSpacing, after: view)
    }
    @available(*, unavailable)
    public override func setCustomMinSpacing(_ minSpacing: CGFloat, after view: UIView?) {
        super.setCustomMinSpacing(minSpacing, after: view)
    }
    @available(*, unavailable)
    public override func setFlex(_ flex: Int, for view: UIView?) {
        super.setFlex(flex, for: view)
    }
    @available(*, unavailable)
    public override func setAlignment(_ alignment: FlexItemCrossAlign, for view: UIView?) {
        super.setAlignment(alignment, for: view)
    }
    @available(*, unavailable)
    public override func startMarge(_ marge: CGFloat, for view: UIView?) {
        super.startMarge(marge, for: view)
    }
    @available(*, unavailable)
    public override func endMarge(_ marge: CGFloat, for view: UIView?) {
        super.endMarge(marge, for: view)
    }
    @available(*, unavailable)
    public override func setFlexibleSpacing(_ flexible: Bool, after view: UIView?) {
        super.setFlexibleSpacing(flexible, after: view)
    }
    
    
    @available(*, unavailable)
    @objc(insertSpacing)
    public override var insertSpacingObjc: (_ spacing: CGFloat) -> StackView {
        {spacing in
            super.insertSpacing(spacing)
            return self
        }
    }
    
    @objc(insertMinSpacing)
    @available(*, unavailable)
    public override var insertMinSpacingObjc: (_ spacing: CGFloat) -> StackView {
        {
            spacing in
            super.insertSpacing(min: spacing)
            return self
            
        }
    }
    
    @objc(insertMaxSpacing)
    @available(*, unavailable)
    public override var insertMaxSpacingObjc: (_ spacing: CGFloat) -> StackView {
        {
            spacing in
            super.insertSpacing(max: spacing)
            return self
        }
    }
    
    @objc(insertFlexibleSpacing)
    @available(*, unavailable)
    public override var insertFlexibleSpacingObjc: (_ flexible: Bool) -> StackView {
        {
            flexible in
            super.insertSpacing(flexible: flexible)
            return self
        }
    }
    
    @objc(addView)
    @available(*, unavailable)
    public override var addViewObjc: (_ view: UIView?) -> StackView {
        {
            view in
            super.addView(view)
            return self
        }
    }
    
    @objc(addViewIf)
    @available(*, unavailable)
    public override var addViewIfObjc: (_ condition: Bool, _ view: UIView?) -> StackView {
        {
            condition, view in
            super.addView(if: condition, view)
            return self
        }
    }
    
    @objc(addViewMake)
    @available(*, unavailable)
    public override var addViewMakeObjc: (_ make: @escaping (StackView) -> UIView?) -> StackView {
        {
            make in
            super.addView(make: make)
            return self
        }
    }
    
    @objc(addViewIfMake)
    @available(*, unavailable)
    public override var addViewIfMakeObjc: (_ condition: Bool, _ make: @escaping (StackView) -> UIView?) -> StackView {
        {
            condition, make in
            super.addView(if: condition, make: make)
            return self
        }
    }
    
    @objc(assignToPtr)
    @available(*, unavailable)
    public override var assignToPtrObjc: (AutoreleasingUnsafeMutablePointer<StackView>?) -> StackView {
        return { ptr in
            super.assignToPtr(ptr)
            return self
        }
    }
}


@objc(ZLPairImageView)
open class PairImageView: PairView {
    public var first: UIImageView {
        _first as! UIImageView
    }
    public var second: UIImageView {
        _second as! UIImageView
    }
    override func createFirstView() -> UIView {
        UIImageView()
    }
    override func createSecondView() -> UIView {
        UIImageView()
    }
    
    @discardableResult
    public func thenFirst(_ then: @escaping (UIImageView) -> Void) -> Self {
        return _thenFirst(then)
    }
    
    @discardableResult
    public func thenSecond(_ then: @escaping (UIImageView) -> Void) -> Self {
        return _thenSecond(then)
    }
}


@objc(ZLPairButtonView)
open class PairButtonView: PairView {
    public var first: Button {
        _first as! Button
    }
    public var second: Button {
        _second as! Button
    }
    override func createFirstView() -> UIView {
        Button()
    }
    override func createSecondView() -> UIView {
        Button()
    }
    
    @discardableResult
    public func thenFirst(_ then: @escaping (Button) -> Void) -> Self {
        return _thenFirst(then)
    }
    
    @discardableResult
    public func thenSecond(_ then: @escaping (Button) -> Void) -> Self {
        return _thenSecond(then)
    }
}


@objc(ZLPairLabelView)
open class PairLabelView: PairView {
    public var first: Label {
        _first as! Label
    }
    public var second: Label {
        _second as! Label
    }
    override func createFirstView() -> UIView {
        Label()
    }
    override func createSecondView() -> UIView {
        Label()
    }
    
    @discardableResult
    public func thenFirst(_ then: @escaping (Label) -> Void) -> Self {
        return _thenFirst(then)
    }
    
    @discardableResult
    public func thenSecond(_ then: @escaping (Label) -> Void) -> Self {
        return _thenSecond(then)
    }
}

@objc(ZLImgLabelView)
open class ImgLabelView: PairView {
    public var first: UIImageView {
        _first as! UIImageView
    }
    public var second: Label {
        _second as! Label
    }
    override func createFirstView() -> UIView {
        UIImageView()
    }
    override func createSecondView() -> UIView {
        Label()
    }
    
    @discardableResult
    public func thenFirst(_ then: @escaping (UIImageView) -> Void) -> Self {
        return _thenFirst(then)
    }
    
    @discardableResult
    public func thenSecond(_ then: @escaping (Label) -> Void) -> Self {
        return _thenSecond(then)
    }
}


@objc(ZLImgButtonView)
open class ImgButtonView: PairView {
    public var first: UIImageView {
        _first as! UIImageView
    }
    public var second: Button {
        _second as! Button
    }
    override func createFirstView() -> UIView {
        UIImageView()
    }
    override func createSecondView() -> UIView {
        Button()
    }
    
    @discardableResult
    public func thenFirst(_ then: @escaping (UIImageView) -> Void) -> Self {
        return _thenFirst(then)
    }
    
    @discardableResult
    public func thenSecond(_ then: @escaping (Button) -> Void) -> Self {
        return _thenSecond(then)
    }
}


@objc(ZLButtonImgView)
open class ButtonImgView: PairView {
    public var first: Button {
        _first as! Button
    }
    public var second: UIImageView {
        _second as! UIImageView
    }
    override func createFirstView() -> UIView {
        Button()
    }
    override func createSecondView() -> UIView {
        UIImageView()
    }
    
    @discardableResult
    public func thenFirst(_ then: @escaping (Button) -> Void) -> Self {
        return _thenFirst(then)
    }
    
    @discardableResult
    public func thenSecond(_ then: @escaping (UIImageView) -> Void) -> Self {
        return _thenSecond(then)
    }
}


@objc(ZLButtonLabView)
open class ButtonLabView: PairView {
    public var first: Button {
        _first as! Button
    }
    public var second: Label {
        _second as! Label
    }
    override func createFirstView() -> UIView {
        Button()
    }
    override func createSecondView() -> Label {
        Label()
    }
    
    @discardableResult
    public func thenFirst(_ then: @escaping (Button) -> Void) -> Self {
        return _thenFirst(then)
    }
    
    @discardableResult
    public func thenSecond(_ then: @escaping (Label) -> Void) -> Self {
        return _thenSecond(then)
    }
}


@objc(ZLLabelImgView)
open class LabelImgView: PairView {
    public var first: Label {
        _first as! Label
    }
    public var second: UIImageView {
        _second as! UIImageView
    }
    override func createFirstView() -> UIView {
        Label()
    }
    override func createSecondView() -> UIView {
        UIImageView()
    }
    
    @discardableResult
    public func thenFirst(_ then: @escaping (Label) -> Void) -> Self {
        return _thenFirst(then)
    }
    
    @discardableResult
    public func thenSecond(_ then: @escaping (UIImageView) -> Void) -> Self {
        return _thenSecond(then)
    }
}


@objc(ZLLabButtonView)
open class LabButtonView: PairView {
    public var first: Label {
        _first as! Label
    }
    public var second: Button {
        _second as! Button
    }
    override func createFirstView() -> UIView {
        Label()
    }
    override func createSecondView() -> UIView {
        Button()
    }
    
    @discardableResult
    public func thenFirst(_ then: @escaping (Label) -> Void) -> Self {
        return _thenFirst(then)
    }
    
    @discardableResult
    public func thenSecond(_ then: @escaping (Button) -> Void) -> Self {
        return _thenSecond(then)
    }
}


@objc(ZLButtonStackView)
open class ZLButtonStackView: PairView {
    public var first: Button {
        _first as! Button
    }
    public var second: StackView {
        _second as! StackView
    }
    override func createFirstView() -> UIView {
        Button()
    }
    override func createSecondView() -> UIView {
        StackView()
    }
    
    @discardableResult
    public func thenFirst(_ then: @escaping (Button) -> Void) -> Self {
        return _thenFirst(then)
    }
    
    @discardableResult
    public func thenSecond(_ then: @escaping (StackView) -> Void) -> Self {
        return _thenSecond(then)
    }
}


@objc(ZLStackViewButton)
open class StackViewButton: PairView {
    public var first: StackView {
        _first as! StackView
    }
    public var second: Button {
        _second as! Button
    }
    override func createFirstView() -> UIView {
        StackView()
    }
    override func createSecondView() -> UIView {
        Button()
    }
    
    @discardableResult
    public func thenFirst(_ then: @escaping (StackView) -> Void) -> Self {
        return _thenFirst(then)
    }
    
    @discardableResult
    public func thenSecond(_ then: @escaping (Button) -> Void) -> Self {
        return _thenSecond(then)
    }
}



@objc(ZLPairStackView)
open class PairStackView: PairView {
    public var first: StackView {
        _first as! StackView
    }
    public var second: StackView {
        _second as! StackView
    }
    override func createFirstView() -> UIView {
        StackView()
    }
    override func createSecondView() -> UIView {
        StackView()
    }
    
    @discardableResult
    public func thenFirst(_ then: @escaping (StackView) -> Void) -> Self {
        return _thenFirst(then)
    }
    
    @discardableResult
    public func thenSecond(_ then: @escaping (StackView) -> Void) -> Self {
        return _thenSecond(then)
    }
}

public protocol CreatableView: UIView {
    init()
}
extension UIView: CreatableView {
    
}


private var storageKey: UInt8 = 0
public extension UIView {
    private var zl_storage: NSMutableDictionary {
        if let dict = objc_getAssociatedObject(self, &storageKey) as? NSMutableDictionary {
            return dict
        }
        let dict = NSMutableDictionary()
        objc_setAssociatedObject(
            self,
            &storageKey,
            dict,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        return dict
    }
    
    
    private func getView<T: CreatableView>(_ type: T.Type,_ key: String) -> T {
        if let v = zl_storage[key] as? T {return v}
        let v = T()
        zl_storage[key] = v
        addSubview(v)
        return v
    }
    ///第一组
    @objc
    var zl_btn: Button {
        getView(Button.self, #function)
    }
    
    @objc
    var zl_lab: Label {
        getView(Label.self, #function)
    }
    
    @objc
    var zl_imgView: UIImageView {
        getView(UIImageView.self, #function)
    }
    
    @objc
    var zl_stackView: StackView {
        getView(StackView.self, #function)
    }
    
    
    ///第二组
    @objc
    var zl_altBtn: Button {
        getView(Button.self, #function)
        
    }
    @objc
    var zl_altLab: Label {
        getView(Label.self, #function)
        
    }
    @objc
    var zl_altImgView: UIImageView {
        getView(UIImageView.self, #function)
        
    }
    @objc
    var zl_altStackView: StackView {
        getView(StackView.self, #function)
        
    }
    
    
    ///第三组
    @objc
    var zl_extraBtn: Button {
        getView(Button.self, #function)
        
    }
    @objc
    var zl_extraLab: Label {
        getView(Label.self, #function)
        
    }
    @objc
    var zl_extraImgView: UIImageView {
        getView(UIImageView.self, #function)
        
    }
    @objc
    var zl_extraStackView: StackView {
        getView(StackView.self, #function)
        
    }
    
    
    
    ///成对view
    @objc
    var zl_pairLab: PairLabelView {
        getView(PairLabelView.self, #function)
        
    }
    @objc
    var zl_pairImg: PairImageView {
        getView(PairImageView.self, #function)
        
    }
    @objc
    var zl_pairBtn: PairButtonView {
        getView(PairButtonView.self, #function)
        
    }
    @objc
    var zl_pairStackView: PairStackView {
        getView(PairStackView.self, #function)
        
    }
    @objc
    var zl_imgViewLab: ImgLabelView {
        getView(ImgLabelView.self, #function)
        
    }
    @objc
    var zl_imgViewBtn: ImgButtonView {
        getView(ImgButtonView.self, #function)
        
    }
    @objc
    var zl_btnImgView: ButtonImgView {
        getView(ButtonImgView.self, #function)
        
    }
    @objc
    var zl_btnLabel: ButtonLabView {
        getView(ButtonLabView.self, #function)
        
    }
    @objc
    var zl_labelBtn: LabButtonView {
        getView(LabButtonView.self, #function)
        
    }
    @objc
    var zl_labImgView: LabelImgView {
        getView(LabelImgView.self, #function)
        
    }
    
    var zl_wrapView: WrapperView {
             let key = #function
             if let view = zl_storage[key] as? WrapperView {return view}
             let view = WrapperView.wrap(with: self)
             zl_storage[key] = view
             return view
    }
}


