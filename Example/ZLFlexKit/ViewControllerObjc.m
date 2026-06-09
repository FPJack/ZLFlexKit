//
//  ViewControllerObjc.m
//  ZLFlexKit_Example
//
//  Created by admin on 2026/6/5.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

#import "ViewControllerObjc.h"
@import ZLFlexKit;

@interface ViewControllerObjc ()
@end

@implementation ViewControllerObjc

// MARK: - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"StackView OC 链式 Demo";
    
    
    ZLButtonSwift *button = [ZLButtonSwift buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:button];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.backgroundColor = UIColor.redColor;
    button.insets = UIEdgeInsetsMake(8, 12, 8, 12);
   // button.contentOrder = ButtonOrderTitleFirst;
    button.axis = ButtonAxisHorizontal;
    button.spacing = 20;
//    button.flexibleSpacing = YES;
//    button.horizontalAlign = ZLButtonAlignFill;
    [button setTitle:@"Button" forState:UIControlStateNormal];
    [button setImage:[UIImage systemImageNamed:@"star.fill"] forState:UIControlStateNormal];
    button.axis = ButtonAxisVertical;

    button.layout.centerOffset(0, 0);
//    button.layout.width(50);
//    return;
//    [button titleMargeWithStart:100 end:20];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        button.axis = ButtonAxisVertical;
//        [button setImage:[UIImage systemImageNamed:@"star.fill"] forState:UIControlStateNormal];
//
//    });
    return;
    [button setImage:[UIImage systemImageNamed:@"star.fill"] forState:UIControlStateNormal];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [button setImage:[UIImage imageNamed:@"头像-手机"] forState:UIControlStateNormal];

    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [button setImage:[UIImage systemImageNamed:@"star.fill"] forState:UIControlStateNormal];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [button setImage:nil forState:UIControlStateNormal];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                button.axis = ButtonAxisVertical;
                [button setImage:[UIImage systemImageNamed:@"star.fill"] forState:UIControlStateNormal];

            });
        });
    });
    
    

    return;

    // ── 滚动容器 ──────────────────────────────────────────────────────────
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scroll];

    NSLayoutYAxisAnchor *topAnchor;
    if (@available(iOS 11.0, *)) {
        topAnchor = self.view.safeAreaLayoutGuide.topAnchor;
    } else {
        topAnchor = self.topLayoutGuide.bottomAnchor;
    }
    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:topAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    UIStackView *box = [[UIStackView alloc] init];
    box.axis = UILayoutConstraintAxisVertical;
    box.spacing = 10;
    box.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:box];
    CGFloat pad = 16;
    [NSLayoutConstraint activateConstraints:@[
        [box.topAnchor constraintEqualToAnchor:scroll.topAnchor constant:pad],
        [box.leadingAnchor constraintEqualToAnchor:scroll.leadingAnchor constant:pad],
        [box.trailingAnchor constraintEqualToAnchor:scroll.trailingAnchor constant:-pad],
        [box.bottomAnchor constraintEqualToAnchor:scroll.bottomAnchor constant:-pad],
        [box.widthAnchor constraintEqualToAnchor:scroll.widthAnchor constant:-pad * 2],
    ]];

    // ── ① setJustify / setAlign / setAxis ─────────────────────────────────
    [box addArrangedSubview:[self label:@"① setAxis / setJustify(.spaceEvenly) / setAlign(.center)"]];
    ZLStackView *sv1 = [self makeStack:50];
    sv1
        .setAxis(ZLStackViewAxisHorizontal)
        .setJustify(ZLJustifySpaceEvenly)
        .setAlign(ZLFlexItemCrossAlignCenter)
        .addView([self box:UIColor.systemRedColor   text:@"A" w:44 h:36])
        .addView([self box:UIColor.systemBlueColor  text:@"B" w:54 h:36])
        .addView([self box:UIColor.systemGreenColor text:@"C" w:44 h:36]);
    [box addArrangedSubview:sv1];

    // ── ② setJustify(.fill) + flexValue ───────────────────────────────────
    [box addArrangedSubview:[self label:@"② setJustify(.fill) + view.flex.flexValue — 按比例分配宽度"]];
    ZLStackView *sv2 = [self makeStack:50];
    UIView *f1 = [self box:UIColor.systemOrangeColor  text:@"flex:1" w:0 h:0];
    UIView *f2 = [self box:UIColor.systemPurpleColor  text:@"flex:2" w:0 h:0];
    UIView *f3 = [self box:UIColor.systemTealColor    text:@"flex:3" w:0 h:0];
    f1.flex.flex(1);
    f2.flex.flex(2);
    f3.flex.flex(3);
    sv2
        .setJustify(ZLJustifyFill)
        .setAlign(ZLFlexItemCrossAlignFill)
        .addView(f1)
        .addView(f2)
        .addView(f3);
    
    [box addArrangedSubview:sv2];
    self.view.layout.lastConstraint().constant = 200; // 修改最后一个约束为 200，演示动态更新布局
    
    
    
    // ── ③ setJustify(.fillEqually) ────────────────────────────────────────
    [box addArrangedSubview:[self label:@"③ setJustify(.fillEqually) — 等宽"]];
    ZLStackView *sv3 = [self makeStack:60];
    sv3
        .setJustify(ZLJustifyFillEqually)
        .setAlign(ZLFlexItemCrossAlignFill)
        .addView([self box:UIColor.systemRedColor   text:@"=1" w:0 h:0])
        .addView([self box:UIColor.systemBlueColor  text:@"=2" w:0 h:0])
        .addView([self box:UIColor.systemGreenColor text:@"=3" w:0 h:0])
        .addView([self box:UIColor.systemPinkColor  text:@"=4" w:0 h:0]);
    [box addArrangedSubview:sv3];

    
    // ── ④ setInsets + setSpacing ──────────────────────────────────────────
    [box addArrangedSubview:[self label:@"④ setInsets(8,16,8,16) + setSpacing(12)"]];
    ZLStackView *sv4 = [self makeStack:66];
    sv4
        .setJustify(ZLJustifyStart)
        .setAlign(ZLFlexItemCrossAlignCenter)
        .setInsets(8, 16, 8, 16)
        .setSpacing(12)
        .addView([self box:UIColor.systemRedColor   text:@"A" w:50 h:36])
        .addView([self box:UIColor.systemBlueColor  text:@"B" w:50 h:36])
        .addView([self box:UIColor.systemGreenColor text:@"C" w:50 h:36]);
    [box addArrangedSubview:sv4];
    

    // ── ⑤ insertSpacing / insertMinSpacing / insertMaxSpacing ──────────────
    [box addArrangedSubview:[self label:@"⑤ insertSpacing(20) / insertMinSpacing(8) / insertMaxSpacing(40)"]];
    ZLStackView *sv5 = [self makeStack:56];
    sv5
        .setJustify(ZLJustifyFill)
        .setAlign(ZLFlexItemCrossAlignCenter)
        .addView([self box:UIColor.systemRedColor   text:@"①" w:44 h:36])
        .insertSpacing(20)                          // 精确 20pt
        .addView([self box:UIColor.systemBlueColor  text:@"②" w:44 h:36])
        .insertMinSpacing(8)                        // 最小 8pt
        .addView([self box:UIColor.systemGreenColor text:@"③" w:44 h:36])
        .insertMaxSpacing(40)                       // 最大 40pt
        .addView([self box:UIColor.systemOrangeColor text:@"④" w:44 h:36]);
    [box addArrangedSubview:sv5];
    
    

    // ── ⑥ insertFlexibleSpacing — 弹性空白 ────────────────────────────────
    [box addArrangedSubview:[self label:@"⑥ insertFlexibleSpacing(YES) — 将后续 view 推到末尾"]];
    ZLStackView *sv6 = [self makeStack:56];
    sv6
        .setJustify(ZLJustifyFill)
        .setAlign(ZLFlexItemCrossAlignCenter)
        .addView([self box:UIColor.systemRedColor   text:@"L" w:44 h:36])
        .insertFlexibleSpacing(YES)                 // 弹性空白
        .addView([self box:UIColor.systemBlueColor  text:@"M" w:44 h:36])
        .addView([self box:UIColor.systemGreenColor text:@"R" w:44 h:36]);
    [box addArrangedSubview:sv6];
    
    

    // ── ⑦ addViewIf — 条件渲染 ────────────────────────────────────────────
    [box addArrangedSubview:[self label:@"⑦ addViewIf(condition, view) — 条件为 NO 的 view 不添加"]];
    BOOL showExtra = YES;
    ZLStackView *sv7 = [self makeStack:56];
    sv7
        .setJustify(ZLJustifyStart)
        .setAlign(ZLFlexItemCrossAlignCenter)
        .setSpacing(8)
        .addView([self box:UIColor.systemRedColor   text:@"常驻" w:60 h:36])
        .addViewIf(showExtra,  [self box:UIColor.systemBlueColor  text:@"YES" w:70 h:36])
        .addViewIf(!showExtra, [self box:UIColor.systemGrayColor  text:@"NO"  w:70 h:36]);
    [box addArrangedSubview:sv7];
   
    

    // ── ⑧ addViewMake + addViewIfMake — 闭包创建 ──────────────────────────
    [box addArrangedSubview:[self label:@"⑧ addViewMake / addViewIfMake — 闭包懒创建 view"]];
    ZLStackView *sv8 = [self makeStack:56];
    sv8
        .justifySpaceAround
        .alignCenter
        .addViewMake(^UIView *(ZLStackView *sv) {
            return [self box:UIColor.systemPurpleColor text:@"make①" w:64 h:36];
        })
        .addViewMake(^UIView *(ZLStackView *sv) {
            return [self box:UIColor.systemTealColor   text:@"make②" w:64 h:36];
        })
        .addViewIfMake(YES, ^UIView *(ZLStackView *sv) {
            return [self box:UIColor.systemPinkColor   text:@"if ✅"  w:64 h:36];
        })
        .addViewIfMake(NO, ^UIView *(ZLStackView *sv) {
            return [self box:UIColor.systemGrayColor   text:@"if ❌"  w:64 h:36];
        });
    [box addArrangedSubview:sv8];
    
    // ── ⑨ alignSelf + startMarge / endMarge ──────────────────────────────
    [box addArrangedSubview:[self label:@"⑨ view.flex.alignSelf / startMarge / endMarge"]];
    ZLStackView *sv9 = [self makeStack:90];
    UIView *as1 = [self box:UIColor.systemRedColor    text:@"start"  w:60 h:28];
    UIView *as2 = [self box:UIColor.systemBlueColor   text:@"+top15" w:60 h:28];
    UIView *as3 = [self box:UIColor.systemGreenColor  text:@"end"    w:60 h:28];
    UIView *as4 = [self box:UIColor.systemOrangeColor text:@"fill"   w:60 h:0 ];
    as1.flex.alignSelf(ZLFlexItemCrossAlignStart);
    as2.flex.alignSelf(ZLFlexItemCrossAlignStart);
    as2.flex.startMarge(15);                        // 距顶 15pt
    as3.flex.alignSelf(ZLFlexItemCrossAlignEnd);
    as4.flex.alignSelf(ZLFlexItemCrossAlignFill);
    sv9
        .setJustify(ZLJustifySpaceEvenly)
        .setAlign(ZLFlexItemCrossAlignStart)
        .addView(as1).addView(as2).addView(as3).addView(as4);
    [box addArrangedSubview:sv9];
    
    // ── ⑩ 垂直 axis + flex 综合 ───────────────────────────────────────────
    [box addArrangedSubview:[self label:@"⑩ setAxis(.vertical) + fill + flexValue"]];
    ZLStackView *sv10 = [self makeStack:160];
    UIView *v1 = [self box:UIColor.systemRedColor   text:@"flex:1" w:0 h:0];
    UIView *v2 = [self box:UIColor.systemBlueColor  text:@"flex:2" w:0 h:0];
    UIView *v3 = [self box:UIColor.systemGreenColor text:@"flex:1" w:0 h:0];
    v1.flex.flex(1);
    v2.flex.flex(2);
    v3.flex.flex(1);
    sv10
        .setAxis(ZLStackViewAxisVertical)
        .setJustify(ZLJustifyFill)
        .setAlign(ZLFlexItemCrossAlignFill)
        .setInsets(8, 12, 8, 12)
        .addView(v1).addView(v2).addView(v3);
    [box addArrangedSubview:sv10];
    
    
}

// MARK: - 辅助

/// 创建固定高度的 StackView 容器
- (ZLStackView *)makeStack:(CGFloat)height {
    ZLStackView *sv = [[ZLStackView alloc] init];
    sv.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
    sv.layer.cornerRadius = 6;
    sv.translatesAutoresizingMaskIntoConstraints = NO;
    if (height > 0) {
        [[sv.heightAnchor constraintEqualToConstant:height] setActive:YES];
    }
    
    return sv;
}

/// 创建带文字的彩色方块
- (UIView *)box:(UIColor *)color text:(NSString *)text w:(CGFloat)w h:(CGFloat)h {
    UILabel *v = [[UILabel alloc] init];
    v.backgroundColor = color;
    v.text = text;
    v.textAlignment = NSTextAlignmentCenter;
    v.font = [UIFont boldSystemFontOfSize:11];
    v.textColor = UIColor.whiteColor;
    v.layer.cornerRadius = 4;
    v.clipsToBounds = YES;
    v.translatesAutoresizingMaskIntoConstraints = NO;
    if (w > 0) [[v.widthAnchor  constraintEqualToConstant:w] setActive:YES];
    if (h > 0) [[v.heightAnchor constraintEqualToConstant:h] setActive:YES];
    return v;
}

/// 创建说明文字
- (UILabel *)label:(NSString *)text {
    UILabel *l = [[UILabel alloc] init];
    l.text = text;
    l.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    l.textColor = UIColor.grayColor;
    l.numberOfLines = 0;
    return l;
}

@end

// ⚠️ 不能在 ObjC 里继承 Swift 类（ZLStackView），
// 因为 Swift 导出到 ObjC 头文件时统一带有 objc_subclassing_restricted。
// 需要继承请在 Swift 文件中定义，然后在 ObjC 中使用：
//
//   open class STackView: StackView { ... }   ← Swift
//   STackView *sv = [[STackView alloc] init]; ← ObjC 使用
