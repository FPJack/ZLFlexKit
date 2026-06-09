//
//  ZLButton.h
//  ZLTagListView
//
//  Created by fanpeng on 2026/04/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//图片文字水平
#define HButton ZLButton.horizontal
//图片文字垂直
#define VButton ZLButton.vertical
/// 图片与文字的排列方向
typedef NS_ENUM(NSUInteger, ZLButtonAxis) {
    ZLButtonAxisHorizontal = 0,  // 水平排列
    ZLButtonAxisVertical,        // 垂直排列
};

/// 图片与文字的先后顺序
typedef NS_ENUM(NSUInteger, ZLButtonOrder) {
    ZLButtonOrderImageFirst = 0, // 图片在前（左/上）
    ZLButtonOrderTitleFirst,     // 文字在前（左/上）
};

/// 内容在按钮内水平垂直的对齐方式
typedef NS_ENUM(NSUInteger, ZLButtonAlign) {
    ZLButtonAlignCenter = 0, // 居中
    ZLButtonAlignStart,      // 起始对齐
    ZLButtonAlignEnd,        // 末尾对齐
    ZLButtonAlignFill,       // 填充对齐
};

struct GMStartEndInsets {
    CGFloat start;
    CGFloat end;
};
typedef struct CF_BOXABLE GMStartEndInsets GMStartEndInsets;
NS_INLINE GMStartEndInsets GMStartEndInsetsMake(CGFloat start, CGFloat end) {
    GMStartEndInsets insets;
    insets.start = start;
    insets.end = end;
    return insets;
}




/**
 * ZLButton - 继承 UIButton，支持自定义图文布局
 *
 * 功能：
 * - 图片和文字可切换先后顺序（imageFirst / titleFirst）
 * - 支持水平或垂直排列
 * - 支持设置图文间距 (layoutSpacing)
 * - 支持弹性间距 (flexibleSpacing)，图文之间会尽可能撑满
 * - 完整支持 Auto Layout，intrinsicContentSize 自动撑开
 * - 支持 layoutEdgeInsets 设置内边距
 * - 支持固定图片大小 (layoutImageSize)
 * - 完整支持 RTL（阿拉伯语等从右到左语言）：
 *   · 水平布局自动镜像（图文顺序翻转）
 *   · Start/End 对齐自动翻转
 *   · layoutEdgeInsets 的 left/right 自动翻转
 *   · imageOffset/titleOffset 的水平方向自动翻转
 *
 * 注意：使用 UIButton 原生的 setTitle:forState: / setImage:forState: 设置内容，
 *       或使用便捷属性 layoutImage / layoutTitle。
 */
@interface ZLButton : UIButton

@property (nonatomic, assign) ZLButtonAxis axis;

@property (nonatomic, assign) ZLButtonOrder contentOrder;


@property (nonatomic, assign) ZLButtonAlign verticalAlign;

@property (nonatomic, assign) ZLButtonAlign horizontalAlign;

@property (nonatomic,assign)BOOL imgTouchOnly;

@property (nonatomic,assign)CGFloat tapInerval;

///只接受图片点击
///扩大点击范围，正值扩大，负值缩小，纯视觉扩展，不影响布局
@property (nonatomic,assign)UIEdgeInsets touchAreaEdgeInsets;


/// 图文间距，默认 4
@property (nonatomic, assign) CGFloat spacing;

/// 是否启用弹性间距（图文之间弹性撑满），默认 NO
/// 启用后 layoutSpacing 作为最小间距
@property (nonatomic, assign) BOOL flexibleSpacing;

/// 内边距，默认 UIEdgeInsetsZero
@property (nonatomic, assign) UIEdgeInsets insets;

///文字内容size
@property (nonatomic, assign) CGSize titleSize;

/// 图片固定大小，默认 CGSizeZero 表示使用图片自身大小
@property (nonatomic, assign) CGSize imageSize;


///图片start end间距
@property (nonatomic, assign) GMStartEndInsets imageMarge;

@property (nonatomic, assign) GMStartEndInsets titleMarge;


@end

NS_ASSUME_NONNULL_END
