//
//  UIViewController+YCNavigationBar.h
//  YCNavigationBarDemo
//
//  Created by CodYC.YC on 2019/9/26.
//  Copyright © 2019 CodYC.XYC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (YCNavigationBar)

@property (nonatomic, assign) IBInspectable BOOL yc_blackBarStyle;
@property (nonatomic, assign) UIBarStyle yc_barStyle;
@property (nonatomic, strong) IBInspectable UIColor *yc_barTintColor;
@property (nonatomic, strong) IBInspectable UIImage *yc_barImage;
@property (nonatomic, strong) IBInspectable UIColor *yc_tintColor;
@property (nonatomic, strong) NSDictionary *yc_titleTextAttributes;

@property (nonatomic, assign) IBInspectable float yc_barAlpha;
@property (nonatomic, assign) IBInspectable BOOL yc_barHidden;
@property (nonatomic, assign) IBInspectable BOOL yc_barShadowHidden;
@property (nonatomic, assign) IBInspectable BOOL yc_backInteractive;
@property (nonatomic, assign) IBInspectable BOOL yc_swipeBackEnabled;
@property (nonatomic, assign) IBInspectable BOOL yc_clickBackEnabled;

// computed
@property (nonatomic, assign, readonly) float yc_computedBarShadowAlpha;
@property (nonatomic, strong, readonly) UIColor *yc_computedBarTintColor;
@property (nonatomic, strong, readonly) UIImage *yc_computedBarImage;

- (void)yc_setNeedsUpdateNavigationBar;

@end

NS_ASSUME_NONNULL_END
