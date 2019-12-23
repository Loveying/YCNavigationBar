//
//  UIViewController+YCNavigationBar.m
//  YCNavigationBarDemo
//
//  Created by CodYC.YC on 2019/9/26.
//  Copyright © 2019 CodYC.XYC. All rights reserved.
//

#import "UIViewController+YCNavigationBar.h"
#import <objc/runtime.h>
#import "YCNavigationController.h"

@implementation UIViewController (YCNavigationBar)

#pragma mark - getter && setter

- (BOOL)yc_blackBarStyle{
    return self.yc_barStyle == UIBarStyleBlack;
}

- (void)setYc_blackBarStyle:(BOOL)yc_blackBarStyle{
    self.yc_barStyle = yc_blackBarStyle ? UIBarStyleBlack : UIBarStyleDefault;
}

- (UIBarStyle)yc_barStyle {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return [obj integerValue];
    }
    return [UINavigationBar appearance].barStyle;
}

- (void)setYc_barStyle:(UIBarStyle)yc_barStyle {
    objc_setAssociatedObject(self, @selector(yc_barStyle), @(yc_barStyle), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIColor *)yc_barTintColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYc_barTintColor:(UIColor *)tintColor {
     objc_setAssociatedObject(self, @selector(yc_barTintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)yc_barImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYc_barImage:(UIImage *)image {
    objc_setAssociatedObject(self, @selector(yc_barImage), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)yc_tintColor {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ?: [UINavigationBar appearance].tintColor;
}

- (void)setYc_tintColor:(UIColor *)tintColor {
    objc_setAssociatedObject(self, @selector(yc_tintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)yc_titleTextAttributes {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return obj;
    }
    
    UIBarStyle barStyle = self.yc_barStyle;
    NSDictionary *attributes = [UINavigationBar appearance].titleTextAttributes;
    if (attributes) {
        if (![attributes objectForKey:NSForegroundColorAttributeName]) {
            NSMutableDictionary *mutableAttributes = [attributes mutableCopy];
            if (barStyle == UIBarStyleBlack) {
                [mutableAttributes addEntriesFromDictionary:@{ NSForegroundColorAttributeName: UIColor.whiteColor }];
            } else {
                [mutableAttributes addEntriesFromDictionary:@{ NSForegroundColorAttributeName: UIColor.blackColor }];
            }
            return mutableAttributes;
        }
        return attributes;
    }

    if (barStyle == UIBarStyleBlack) {
        return @{ NSForegroundColorAttributeName: UIColor.whiteColor };
    } else {
        return @{ NSForegroundColorAttributeName: UIColor.blackColor };
    }
}

- (void)setYc_titleTextAttributes:(NSDictionary *)attributes {
    objc_setAssociatedObject(self, @selector(yc_titleTextAttributes), attributes, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIBarButtonItem *)yc_backBarButtonItem {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYc_backBarButtonItem:(UIBarButtonItem *)backBarButtonItem {
    objc_setAssociatedObject(self, @selector(yc_backBarButtonItem), backBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)yc_extendedLayoutDidSet {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setYc_extendedLayoutDidSet:(BOOL)didSet {
    objc_setAssociatedObject(self, @selector(yc_extendedLayoutDidSet), @(didSet), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (float)yc_barAlpha {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (self.yc_barHidden) {
        return 0;
    }
    return obj ? [obj floatValue] : 1.0f;
}

- (void)setYc_barAlpha:(float)alpha {
    objc_setAssociatedObject(self, @selector(yc_barAlpha), @(alpha), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)yc_barHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setYc_barHidden:(BOOL)hidden {
    if (hidden) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
        self.navigationItem.titleView = [UIView new];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.titleView = nil;
    }
    objc_setAssociatedObject(self, @selector(yc_barHidden), @(hidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)yc_barShadowHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return  self.yc_barHidden || obj ? [obj boolValue] : NO;
}

- (void)setYc_barShadowHidden:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(yc_barShadowHidden), @(hidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)yc_backInteractive {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

-(void)setYc_backInteractive:(BOOL)interactive {
    objc_setAssociatedObject(self, @selector(yc_backInteractive), @(interactive), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)yc_swipeBackEnabled {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setYc_swipeBackEnabled:(BOOL)enabled {
    objc_setAssociatedObject(self, @selector(yc_swipeBackEnabled), @(enabled), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)yc_clickBackEnabled {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setYc_clickBackEnabled:(BOOL)enabled {
    objc_setAssociatedObject(self, @selector(yc_clickBackEnabled), @(enabled), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (float)yc_computedBarShadowAlpha {
    return  self.yc_barShadowHidden ? 0 : self.yc_barAlpha;
}

- (UIImage *)yc_computedBarImage {
    UIImage *image = self.yc_barImage;
    if (!image) {
        if (self.yc_barTintColor) {
            return nil;
        }
        return [[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault];
    }
    return image;
}

- (UIColor *)yc_computedBarTintColor {
    if (self.yc_barImage) {
        return nil;
    }
    UIColor *color = self.yc_barTintColor;
    if (!color) {
        if ([[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault]) {
            return nil;
        }
        if ([UINavigationBar appearance].barTintColor) {
            color = [UINavigationBar appearance].barTintColor;
        } else {
            color = [UINavigationBar appearance].barStyle == UIBarStyleDefault ? [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:0.8]: [UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:0.729];
        }
    }
    return color;
}

- (void)yc_setNeedsUpdateNavigationBar {
    if (self.navigationController && [self.navigationController isKindOfClass:[YCNavigationController class]]) {
        YCNavigationController *nav = (YCNavigationController *)self.navigationController;
        [nav updateNavigationBarForViewController:self];
    }
}


@end
