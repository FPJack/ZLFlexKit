//
//  ZLButton.m
//  ZLTagListView
//
//  Created by fanpeng on 2026/04/20.
//

#import "ZLButton.h"
#import <objc/runtime.h>
#define kInsetLeadingId @"kInsetLeadingId"
#define kInsetTrailingId @"kInsetTrailingId"
#define kInsetTopId @"kInsetTopId"
#define kInsetBottomId @"kInsetBottomId"
#define kSpacingId @"kSpacingId"
#define kCustomPriority UILayoutPriorityRequired - 1
@interface ZLButton ()
@property (nonatomic,strong)UILayoutGuide *middelGuide;
@property (nonatomic,strong)UILayoutGuide *startGuide;
@property (nonatomic,strong)UILayoutGuide *endGuide;
@property (nonatomic,strong)NSMutableArray *customContraints;
///图片和文字展示顺序的拼接字段
@property (nonatomic,copy)NSString *orderKey;
///是否需要重绘
@property (nonatomic, assign) BOOL needsUpdate;
@end

@implementation ZLButton
- (void)layoutSubviews {
    [super layoutSubviews];
}
- (void)setNeedsUpdateConstraintsIfNeed {
    self.needsUpdate = YES;
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}
- (UIEdgeInsets)_zl_effectiveInsets {
    UIEdgeInsets insets = _insets;
    if ([self _zl_isRTL]) {
        CGFloat tmp = insets.left;
        insets.left = insets.right;
        insets.right = tmp;
    }
    return insets;
}
- (NSMutableArray *)customContraints {
    if (!_customContraints) {
        _customContraints = NSMutableArray.array;
    }
    return _customContraints;
}
- (UILayoutGuide *)middelGuide {
    if (!_middelGuide) {
        _middelGuide = [[UILayoutGuide alloc] init];
            _middelGuide.identifier = @"middle-guide";
        [self addLayoutGuide:_middelGuide];
    }
    return _middelGuide;
}
- (UILayoutGuide *)startGuide {
    if (!_startGuide) {
        _startGuide = [[UILayoutGuide alloc] init];
        _startGuide.identifier = @"start-guide";
        [self addLayoutGuide:_startGuide];
    }
    return _startGuide;
}
- (UILayoutGuide *)endGuide {
    if (!_endGuide) {
        _endGuide = [[UILayoutGuide alloc] init];
        _endGuide.identifier = @"end-guide";
        [self addLayoutGuide:_endGuide];
    }
    return _endGuide;
}
- (void)updateConstraints {
    [super updateConstraints];
    if (self.needsUpdate) {
        [self updateAllConstraints];
        self.needsUpdate = NO;
    }
}

- (void)updateAllConstraints {
   ///刷选不是宽高的约束
    NSArray *filterConstraints = [self.constraints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSLayoutConstraint * _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        BOOL res2 = [self.customContraints containsObject:evaluatedObject];
        if (res2) return NO;

        if ([evaluatedObject.firstItem isEqual:self] || [evaluatedObject.secondItem isEqual:self]) {
            if (evaluatedObject.firstAttribute == NSLayoutAttributeWidth ||
                evaluatedObject.firstAttribute == NSLayoutAttributeHeight) {
                return NO;
            }
        }
        
        BOOL res1 = evaluatedObject.firstItem == self.titleLabel ||
        evaluatedObject.secondItem == self.titleLabel ||
        evaluatedObject.firstItem  == self.imageView ||
        evaluatedObject.secondItem  == self.imageView;
        if (res1) {
            if (evaluatedObject.firstAttribute == NSLayoutAttributeWidth ||
                evaluatedObject.firstAttribute == NSLayoutAttributeHeight ||
                evaluatedObject.secondAttribute == NSLayoutAttributeWidth ||
                evaluatedObject.secondAttribute == NSLayoutAttributeHeight) {
                return NO;
            }
        }
        return YES;
    }]];

    [NSLayoutConstraint deactivateConstraints:filterConstraints];
    
    NSMutableArray<UIView *> *arr = NSMutableArray.array;
    NSLayoutXAxisAnchor *nextXAnchor;
    NSLayoutYAxisAnchor *nextYAnchor;
    NSString *orderKey = @"";

    if (!self.titleLabel.hidden) {
        ///判断size 是否宽高有一个为0
        NSString *title = [self titleForState:self.state];
        if (title.length > 0) {
            self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [arr addObject:self.titleLabel];
            orderKey = [orderKey stringByAppendingString:@"0"];
        }
    }
    if (!self.imageView.hidden) {
        UIImage *image = [self imageForState:self.state];
        CGSize size = image.size;
        if (size.width > 0 && size.height > 0) {
            self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.imageView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
            [self.imageView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
            [self.imageView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
            [self.imageView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            [arr addObject:self.imageView];
            orderKey = [orderKey stringByAppendingString:@"1"];
        }
    }
    
    if (arr.count == 2) {
        if ([arr.firstObject isEqual:self.titleLabel] && self.contentOrder != ZLButtonOrderTitleFirst) {
            [arr exchangeObjectAtIndex:0 withObjectAtIndex:1];
        }else if ([arr.firstObject isEqual:self.imageView] && self.contentOrder != ZLButtonOrderImageFirst) {
            [arr exchangeObjectAtIndex:0 withObjectAtIndex:1];
        }
    }
    
    orderKey = [self generateOrderKeyWithStr:orderKey];
    if ([self.orderKey isEqualToString:orderKey]) {
        return;
    }
    self.orderKey = orderKey;
    [self updateImageSize];
    [self updateTitleSize];
    
    [NSLayoutConstraint deactivateConstraints:self.customContraints];
    [self.customContraints removeAllObjects];
    nextXAnchor = self.leadingAnchor;
    nextYAnchor = self.topAnchor;

    NSLayoutConstraint *cons;
    NSInteger count = arr.count;
    UIEdgeInsets insets = [self _zl_effectiveInsets];
    CGFloat space = self.spacing;
    if (count == 1) {
        if (!self.translatesAutoresizingMaskIntoConstraints) {
            cons = [self.widthAnchor constraintGreaterThanOrEqualToConstant: MAX(0, insets.left + insets.right)];
            cons.priority = kCustomPriority;
            [self.customContraints addObject:cons];
            cons = [self.heightAnchor constraintGreaterThanOrEqualToConstant:MAX(insets.top + insets.bottom, 0)];
            cons.priority = kCustomPriority;
            [self.customContraints addObject:cons];
        }
    }
   
 
    for (int i = 0 ; i < count; i ++) {
        UIView *view = arr[i];
        CGFloat startSpacing = [view isEqual:self.titleLabel] ? self.titleMarge.start : self.imageMarge.start;
        CGFloat endSpacing = [view isEqual:self.titleLabel] ? self.titleMarge.end : self.imageMarge.end;
        if (self.axis == ZLButtonAxisHorizontal) {
            if (i == 0) {
                switch (self.horizontalAlign) {
                    case ZLButtonAlignCenter:
                        cons = [self.startGuide.leadingAnchor constraintEqualToAnchor:nextXAnchor constant:0];
                        nextXAnchor = self.startGuide.trailingAnchor;
                        [self.customContraints addObject:cons];
                    case ZLButtonAlignStart:
                    case ZLButtonAlignFill:
                    cons = [view.leadingAnchor constraintEqualToAnchor:nextXAnchor constant:insets.left];
                        break;
                   
                    default:
                        cons = [view.leadingAnchor constraintGreaterThanOrEqualToAnchor:nextXAnchor constant:insets.left];
                        break;
                }
                cons.identifier = kInsetLeadingId;
                [self.customContraints addObject:cons];
                nextXAnchor = view.trailingAnchor;
            }else {
                if (self.flexibleSpacing) {
                    cons = [self.middelGuide.leadingAnchor constraintEqualToAnchor:nextXAnchor];
                    [self.customContraints addObject:cons];
                    nextXAnchor = self.middelGuide.trailingAnchor;
                }
                cons = [view.leadingAnchor constraintEqualToAnchor:nextXAnchor constant:space];
                cons.identifier = kSpacingId;
                [self.customContraints addObject:cons];
                nextXAnchor = view.trailingAnchor;

            }
            
            if (i  == count - 1) {
                switch (self.horizontalAlign) {
                    case ZLButtonAlignCenter:
                        cons = [self.endGuide.leadingAnchor constraintEqualToAnchor:nextXAnchor];
                        nextXAnchor = self.endGuide.trailingAnchor;
                        [self.customContraints addObject:cons];
                        cons = [self.startGuide.widthAnchor constraintEqualToAnchor:self.endGuide.widthAnchor];
                        [self.customContraints addObject:cons];
                    case ZLButtonAlignEnd:
                    case ZLButtonAlignFill:
                        cons = [self.trailingAnchor constraintEqualToAnchor:nextXAnchor constant:insets.right];
                        break;
                    default:
                        cons = [self.trailingAnchor constraintGreaterThanOrEqualToAnchor:nextXAnchor constant:insets.right];
                        break;
                }
                cons.identifier = kInsetTrailingId;
                [self.customContraints addObject:cons];
            }
            
            
            
            switch (self.verticalAlign) {
                case ZLButtonAlignStart:
                    cons = [view.topAnchor constraintEqualToAnchor:self.topAnchor constant:insets.top + startSpacing];
                    [self.customContraints addObject:cons];
                    
                    cons = [view.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor constant:-insets.bottom - endSpacing];
                    [self.customContraints addObject:cons];
                    break;
                 case ZLButtonAlignCenter:
                    
                    cons = [view.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:insets.top + startSpacing];
                    [self.customContraints addObject:cons];
                    
                    cons = [view.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor constant: - insets.bottom - endSpacing];
                    [self.customContraints addObject:cons];
                    
                    CGFloat offsetY = (insets.top - insets.bottom + startSpacing - endSpacing) / 2;
                    cons = [view.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:offsetY];
                    [self.customContraints addObject:cons];
                    
                    break;
                 case ZLButtonAlignEnd:
                    
                    cons = [view.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:insets.top + startSpacing];
                    [self.customContraints addObject:cons];
                    
                    cons = [self.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:insets.bottom + endSpacing];
                    [self.customContraints addObject:cons];
                        break;
                case ZLButtonAlignFill:
                   cons = [view.topAnchor constraintEqualToAnchor:self.topAnchor constant:insets.top + startSpacing];
                   [self.customContraints addObject:cons];
                   
                   cons = [self.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:insets.bottom + endSpacing];
                   [self.customContraints addObject:cons];
                       break;
                default:
                    break;
            }
        }else {
            if (i == 0) {
                switch (self.verticalAlign) {
                    case ZLButtonAlignCenter:
                        cons = [self.startGuide.topAnchor constraintEqualToAnchor:nextYAnchor];
                        nextYAnchor = self.startGuide.bottomAnchor;
                        [self.customContraints addObject:cons];
                    case ZLButtonAlignStart:
                    case ZLButtonAlignFill:
                        cons = [view.topAnchor constraintEqualToAnchor:nextYAnchor constant:insets.top];
                        break;
                    default:
                        cons = [view.topAnchor constraintGreaterThanOrEqualToAnchor:nextYAnchor constant:insets.top];
                        break;
                }
                cons.identifier = kInsetTopId;
                [self.customContraints addObject:cons];
                nextYAnchor = view.bottomAnchor;
            }else {
                if (self.flexibleSpacing) {
                    cons = [self.middelGuide.topAnchor constraintEqualToAnchor:nextYAnchor];
                    [self.customContraints addObject:cons];
                    nextYAnchor = self.middelGuide.bottomAnchor;
                }
                
                cons = [view.topAnchor constraintEqualToAnchor:nextYAnchor constant:space];
                cons.identifier = kSpacingId;
                [self.customContraints addObject:cons];
                nextYAnchor = view.bottomAnchor;
                
            }
            if (i  == count - 1) {
                switch (self.verticalAlign) {
                    case ZLButtonAlignCenter:
                        cons = [self.endGuide.topAnchor constraintEqualToAnchor:nextYAnchor];
                        nextYAnchor = self.endGuide.bottomAnchor;
                        [self.customContraints addObject:cons];
                        cons = [self.startGuide.heightAnchor constraintEqualToAnchor:self.endGuide.heightAnchor];
                        [self.customContraints addObject:cons];
                    case ZLButtonAlignEnd:
                    case ZLButtonAlignFill:
                        cons = [self.bottomAnchor constraintEqualToAnchor:nextYAnchor constant:insets.bottom];
                        break;
                    default:
                        cons = [self.bottomAnchor constraintGreaterThanOrEqualToAnchor:nextYAnchor constant:insets.bottom];
                        break;
                }
                cons.identifier = kInsetBottomId;
                [self.customContraints addObject:cons];
            }
            
            switch (self.horizontalAlign) {
                case ZLButtonAlignStart:
                    cons = [view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:insets.left + startSpacing];
                    [self.customContraints addObject:cons];
                    
                    cons = [view.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-insets.right - endSpacing];
                    [self.customContraints addObject:cons];
                    
                    break;
                case ZLButtonAlignCenter:
                    cons = [view.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:insets.left + startSpacing];
                    [self.customContraints addObject:cons];
                    cons = [self.trailingAnchor constraintGreaterThanOrEqualToAnchor:view.trailingAnchor constant:insets.right + endSpacing];
                    [self.customContraints addObject:cons];
                    
                    CGFloat offsetX = (insets.left - insets.right + startSpacing - endSpacing) / 2;

                    cons = [view.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:offsetX];
                    [self.customContraints addObject:cons];
                    break;

                case ZLButtonAlignEnd:
                    cons = [view.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:insets.left + startSpacing];
                    [self.customContraints addObject:cons];
                    cons = [self.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:insets.right + endSpacing];
                    [self.customContraints addObject:cons];
                        break;
                case ZLButtonAlignFill:
                    cons = [view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:insets.left + startSpacing];
                   [self.customContraints addObject:cons];
                   
                    cons = [self.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:insets.right + endSpacing];
                   [self.customContraints addObject:cons];
                       break;
                    
                default:
                    break;
            }
            
        }
    }

    // TAMR=YES（frame 布局）时，降低所有自定义约束的优先级，避免和 autoresizing 约束冲突
    if ([super translatesAutoresizingMaskIntoConstraints]) {
        for (NSLayoutConstraint *c in self.customContraints) {
            c.priority = kCustomPriority; // 750，低于 autoresizing 的 1000
        }
    }
    [NSLayoutConstraint activateConstraints:self.customContraints];

}
- (CGSize)intrinsicContentSize {
    //返回自适应
    return CGSizeMake(self.insets.left + self.insets.right, self.insets.top + self.insets.bottom);
}
///重新生成orderKey
- (NSString *)generateOrderKeyWithStr:(NSString *)str {
    NSString *orderKey = str ?: @"";
    orderKey = [orderKey stringByAppendingFormat:@"%ld", self.axis];
    orderKey = [orderKey stringByAppendingFormat:@"%ld", self.verticalAlign];
    orderKey = [orderKey stringByAppendingFormat:@"%ld", self.horizontalAlign];
    orderKey = [orderKey stringByAppendingFormat:@"%d", self.flexibleSpacing];
    orderKey = [orderKey stringByAppendingFormat:@"%@", NSStringFromCGSize(self.imageSize)];
    UIEdgeInsets insets = [self _zl_effectiveInsets];
    if (self.axis == ZLButtonAxisHorizontal) {
        orderKey = [orderKey stringByAppendingFormat:@"%f-%f", insets.top,insets.bottom];
    }else {
        orderKey = [orderKey stringByAppendingFormat:@"%f-%f", insets.left,insets.right];
    }
    return orderKey;
}
///根据id获取约束对象
- (NSLayoutConstraint *)constraintWithIdentifier:(NSString *)identifier {
    return [self.customContraints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSLayoutConstraint*  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject.identifier isEqualToString:identifier];
    }]].firstObject;
}
#pragma mark - RTL Support

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self _zl_setupDefaults];
    return self;
}


- (void)_zl_setupDefaults {
    _axis = ZLButtonAxisHorizontal;
    _contentOrder = ZLButtonOrderImageFirst;
    _spacing = 4;
    _flexibleSpacing = NO;
    _insets = UIEdgeInsetsZero;
    _imageSize = CGSizeMake(-1, -1);
    _titleSize = CGSizeMake(-1, -1);
    _horizontalAlign = ZLButtonAlignCenter;
    _verticalAlign = ZLButtonAlignCenter;
    [self setNeedsUpdateConstraintsIfNeed];
}
- (void)setVerticalAlign:(ZLButtonAlign)verticalAlign {
    if (_verticalAlign != verticalAlign) {
        _verticalAlign = verticalAlign;
        [self setNeedsUpdateConstraintsIfNeed];
    }
}
- (void)setHorizontalAlign:(ZLButtonAlign)horizontalAlign {
    if (_horizontalAlign != horizontalAlign) {
        _horizontalAlign = horizontalAlign;
        [self setNeedsUpdateConstraintsIfNeed];
    }
}



#pragma mark - Layout Property Setters

- (void)setAxis:(ZLButtonAxis)layoutAxis {
    if (_axis != layoutAxis) {
        _axis = layoutAxis;
        [self setNeedsUpdateConstraintsIfNeed];
    }
}
- (void)setContentOrder:(ZLButtonOrder)contentOrder {
    if (_contentOrder != contentOrder) {
        _contentOrder = contentOrder;
        [self setNeedsUpdateConstraintsIfNeed];
    }
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if (self.tapInerval > 0) {
        self.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.tapInerval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.userInteractionEnabled = YES;
        });
    }
    [super sendAction:action to:target forEvent:event];
}

- (void)setSpacing:(CGFloat)spacing {
    if (_spacing != spacing) {
        _spacing = spacing;
        NSLayoutConstraint *cons = [self constraintWithIdentifier:kSpacingId];
        if (cons) {
            cons.constant = spacing;
        }
    }
}
- (void)setFlexibleSpacing:(BOOL)flexibleSpacing {
    if (_flexibleSpacing != flexibleSpacing) {
        _flexibleSpacing = flexibleSpacing;
        [self setNeedsUpdateConstraintsIfNeed];
    }
}


- (void)setInsets:(UIEdgeInsets)insets {
    if (UIEdgeInsetsEqualToEdgeInsets(insets, _insets)) return;
    _insets = insets;
    NSLayoutConstraint *leadingCons = [self constraintWithIdentifier:kInsetLeadingId];
    if (leadingCons) leadingCons.constant = insets.left;
    NSLayoutConstraint *trailingCons = [self constraintWithIdentifier:kInsetTrailingId];
    if (trailingCons) trailingCons.constant = insets.right;
    NSLayoutConstraint *topCons = [self constraintWithIdentifier:kInsetTopId];
    if (topCons) topCons.constant = insets.top;
    NSLayoutConstraint *bottomCons = [self constraintWithIdentifier:kInsetBottomId];
    if (bottomCons) bottomCons.constant = insets.bottom;
}

- (void)setTitleSize:(CGSize)titleSize {
    if (CGSizeEqualToSize(titleSize, self.titleLabel.intrinsicContentSize)) return;
    if (CGSizeEqualToSize(titleSize, _titleSize)) return;
    _titleSize = titleSize;
    [self setNeedsUpdateConstraintsIfNeed];
}
- (void)updateTitleSize {
    if (CGSizeEqualToSize(self.titleSize, CGSizeMake(-1, -1))) return;
    if (CGSizeEqualToSize(self.titleSize, self.titleLabel.intrinsicContentSize)) return;
    [NSLayoutConstraint deactivateConstraints:self.titleLabel.constraints];
    NSMutableArray *arr = NSMutableArray.array;
    NSLayoutConstraint *cons = [self.titleLabel.widthAnchor constraintEqualToConstant:self.titleSize.width];
    cons.priority = kCustomPriority;
    [arr addObject:cons];
    cons = [self.titleLabel.heightAnchor constraintEqualToConstant:self.titleSize.height];
    cons.priority = kCustomPriority;
    [NSLayoutConstraint activateConstraints:arr];
}


- (void)setImageSize:(CGSize)imageSize {
    if (CGSizeEqualToSize(imageSize, _imageSize)) return;
    _imageSize = imageSize;
    [self setNeedsUpdateConstraintsIfNeed];
}

- (void)updateImageSize {
    
    if (CGSizeEqualToSize(self.imageSize, CGSizeMake(-1, -1))) {
        return;
    }
    if (CGSizeEqualToSize(self.imageView.frame.size, self.imageSize)) {
        return;
    }
   
    ///删除imageView的宽高约束
   NSArray *deleteCons = [self.imageView.constraints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSLayoutConstraint *cons = (NSLayoutConstraint *)evaluatedObject;
        if (cons.firstItem == self.imageView ||
            cons.secondItem == self.imageView) {
            if (cons.firstAttribute == NSLayoutAttributeWidth || cons.firstAttribute == NSLayoutAttributeHeight ||
                cons.secondAttribute == NSLayoutAttributeWidth || cons.secondAttribute == NSLayoutAttributeHeight) {
                return YES;
            }
        }
        return NO;
    }]];
    [NSLayoutConstraint deactivateConstraints:deleteCons];
    if (self.imageView.translatesAutoresizingMaskIntoConstraints) {
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    ///降优先级防止和button的宽高约束冲突
    NSLayoutConstraint *cons1 = [self.imageView.widthAnchor constraintEqualToConstant:self.imageSize.width];
    cons1.priority = kCustomPriority;
    NSLayoutConstraint *cons2 = [self.imageView.heightAnchor constraintEqualToConstant:self.imageSize.height];
    cons2.priority = kCustomPriority;
    [NSLayoutConstraint activateConstraints:@[cons1,cons2]];
}
- (void)setTitleMarge:(GMStartEndInsets)titleMarge {
    if (titleMarge.start != self.titleMarge.start || titleMarge.end != self.titleMarge.end) {
        _titleMarge = titleMarge;
        [self setNeedsUpdateConstraintsIfNeed];
    }
}

- (void)setImageMarge:(GMStartEndInsets)imageMarge {
    if (imageMarge.start != self.imageMarge.start || imageMarge.end != self.imageMarge.end) {
        _imageMarge = imageMarge;
        [self setNeedsUpdateConstraintsIfNeed];
    }
}

- (BOOL)_zl_isRTL {
    
    if (@available(iOS 10.0, *)) {
        return self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
    }
    return [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.userInteractionEnabled ||
        !self.enabled ||
        self.hidden ||
        self.alpha < 0.01) {
        return [super pointInside:point withEvent:event];
    }
    UIEdgeInsets edget = self.touchAreaEdgeInsets;
    if ([self _zl_isRTL]) {
        CGFloat tmp = edget.left;
        edget.left = edget.right;
        edget.right = tmp;
    }
    CGRect expandedRect;
    if (self.imgTouchOnly) {
       expandedRect = UIEdgeInsetsInsetRect(self.imageView.bounds, UIEdgeInsetsMake(-edget.top, -edget.left, -edget.bottom, -edget.right));
        // 将点转换到 imageView 的坐标系
        CGPoint pointInImageView = [self convertPoint:point toView:self.imageView];
        return CGRectContainsPoint(expandedRect, pointInImageView);
    }
    expandedRect = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(-edget.top, -edget.left, -edget.bottom, -edget.right));
    return CGRectContainsPoint(expandedRect, point);
}

@end
