//
//  YCNavigationController.m
//  YCNavigationBarDemo
//
//  Created by CodYC.YC on 2019/9/26.
//  Copyright © 2019 CodYC.XYC. All rights reserved.
//

#import "YCNavigationController.h"
#import "YCNavigationBar.h"
#import "UIViewController+YCNavigationBar.h"

#pragma mark - Utils

BOOL isImageEqual(UIImage *image1, UIImage *image2) {
    if (image1 == image2) {
        return YES;
    }
    if (image1 && image2) {
        NSData *data1 = UIImagePNGRepresentation(image1);
        NSData *data2 = UIImagePNGRepresentation(image2);
        BOOL result = [data1 isEqual:data2];
        return result;
    }
    return NO;
}

BOOL shouldShowFake(UIViewController *vc,UIViewController *from, UIViewController *to) {
    if (vc != to ) {
        return NO;
    }
    
    if (from.yc_computedBarImage && to.yc_computedBarImage && isImageEqual(from.yc_computedBarImage, to.yc_computedBarImage)) {
        // have the same image
        if (ABS(from.yc_barAlpha - to.yc_barAlpha) > 0.1) {
            return YES;
        }
        return NO;
    }
    
    if (!from.yc_computedBarImage && !to.yc_computedBarImage && [from.yc_computedBarTintColor.description isEqual:to.yc_computedBarTintColor.description]) {
        // no images, and the colors are the same
        if (ABS(from.yc_barAlpha - to.yc_barAlpha) > 0.1) {
            return YES;
        }
        return NO;
    }
    
    return YES;
}

BOOL colorHasAlphaComponent(UIColor *color) {
    if (!color) {
        return YES;
    }
    CGFloat red = 0;
    CGFloat green= 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return alpha < 1.0;
}

BOOL imageHasAlphaChannel(UIImage *image) {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

void adjustLayout(UIViewController *vc) {
    BOOL isTranslucent = vc.yc_barHidden || vc.yc_barAlpha < 1.0;
    if (!isTranslucent) {
        UIImage *image = vc.yc_computedBarImage;
        if (image) {
            isTranslucent = imageHasAlphaChannel(image);
        } else {
            UIColor *color = vc.yc_computedBarTintColor;
            isTranslucent = colorHasAlphaComponent(color);
        }
    }
    
    if (isTranslucent || vc.extendedLayoutIncludesOpaqueBars) {
        vc.edgesForExtendedLayout |= UIRectEdgeTop;
    } else {
        vc.edgesForExtendedLayout &= ~UIRectEdgeTop;
    }
    
    if (vc.yc_barHidden) {
        if (@available(iOS 11.0, *)) {
            UIEdgeInsets insets = vc.additionalSafeAreaInsets;
            float height = vc.navigationController.navigationBar.bounds.size.height;
            vc.additionalSafeAreaInsets = UIEdgeInsetsMake(-height + insets.top, insets.left, insets.bottom, insets.right);
        }
    }
}


UIColor* blendColor(UIColor *from, UIColor *to, float percent) {
    CGFloat fromRed = 0;
    CGFloat fromGreen = 0;
    CGFloat fromBlue = 0;
    CGFloat fromAlpha = 0;
    [from getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    CGFloat toRed = 0;
    CGFloat toGreen = 0;
    CGFloat toBlue = 0;
    CGFloat toAlpha = 0;
    [to getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    CGFloat newRed =  fromRed + (toRed - fromRed) * fminf(1, percent * 4) ;
    CGFloat newGreen = fromGreen + (toGreen - fromGreen) * fminf(1, percent * 4);
    CGFloat newBlue = fromBlue + (toBlue - fromBlue) * fminf(1, percent * 4);
    CGFloat newAlpha = fromAlpha + (toAlpha - fromAlpha) * fminf(1, percent * 4);
    return [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:newAlpha];
}

@interface YCNavigationControllerDelegate : UIScreenEdgePanGestureRecognizer <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<UINavigationControllerDelegate> proxiedDelegate;
@property (nonatomic, weak, readonly) YCNavigationController *nav;

- (instancetype)initWithNavigationController:(YCNavigationController *)navigationController;

@end


@interface YCNavigationController ()

@property (nonatomic, readonly) YCNavigationBar *navigationBar;
@property (nonatomic, strong) UIVisualEffectView *fromFakeBar;
@property (nonatomic, strong) UIVisualEffectView *toFakeBar;
@property (nonatomic, strong) UIImageView *fromFakeShadow;
@property (nonatomic, strong) UIImageView *toFakeShadow;
@property (nonatomic, strong) UIImageView *fromFakeImageView;
@property (nonatomic, strong) UIImageView *toFakeImageView;
@property (nonatomic, weak) UIViewController *poppingViewController;
@property (nonatomic, assign) BOOL transitional;
@property (nonatomic, strong) YCNavigationControllerDelegate *navigationDelegate;

- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc;
- (void)updateNavigationBarColorOrImageForViewController:(UIViewController *)vc;
- (void)updateNavigationBarShadowImageIAlphaForViewController:(UIViewController *)vc;
- (void)updateNavigationBarAnimatedForViewController:(UIViewController *)vc;

- (void)showFakeBarFrom:(UIViewController *)from to:(UIViewController * _Nonnull)to;

- (void)clearFake;

- (void)resetSubviewsInNavBar:(UINavigationBar *)navBar;

- (UIGestureRecognizer *)superInteractivePopGestureRecognizer;

@end

@implementation YCNavigationControllerDelegate

- (instancetype)initWithNavigationController:(YCNavigationController *)nav {
    if (self = [super init]) {
        _nav = nav;
        self.edges = UIRectEdgeLeft;
        self.delegate = self;
        [self addTarget:self action:@selector(handleNavigationTransition:)];
        [nav.view addGestureRecognizer:self];
        [nav superInteractivePopGestureRecognizer].enabled = NO;
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.nav.viewControllers.count > 1) {
        return self.nav.topViewController.yc_backInteractive && self.nav.topViewController.yc_swipeBackEnabled;
    }
    return NO;
}

- (void)handleNavigationTransition:(UIScreenEdgePanGestureRecognizer *)pan {
    YCNavigationController *nav = self.nav;
    if (![self.proxiedDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        id<YCNavigationTransitionProtocol> target = (id<YCNavigationTransitionProtocol>)[nav superInteractivePopGestureRecognizer].delegate;
        if ([target respondsToSelector:@selector(handleNavigationTransition:)]) {
            [target handleNavigationTransition:pan];
        }
    }
    
    if (@available(iOS 11.0, *)) {
        // empty
    } else {
        id<UIViewControllerTransitionCoordinator> coordinator = nav.transitionCoordinator;
        if (coordinator) {
            UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
            if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
                nav.navigationBar.tintColor = blendColor(from.yc_tintColor, to.yc_tintColor, coordinator.percentComplete);
            }
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.proxiedDelegate && [self.proxiedDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.proxiedDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
    
    YCNavigationController *nav = self.nav;
    nav.transitional = YES;
    
    if (!viewController.yc_extendedLayoutDidSet) {
        adjustLayout(viewController);
        viewController.yc_extendedLayoutDidSet = YES;
    }
    
    id<UIViewControllerTransitionCoordinator> coordinator = nav.transitionCoordinator;
    if (coordinator) {
        if (@available(iOS 11.0, *)) {
            UIViewController *fromVC = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController *toVC = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
            
            if (fromVC == nav.poppingViewController && toVC.navigationController == nav) {
                UIBarButtonItem *oldButtonItem = toVC.navigationItem.backBarButtonItem;
                UIBarButtonItem *newButtonItem = [[UIBarButtonItem alloc] init];
                if (oldButtonItem) {
                    newButtonItem.title = oldButtonItem.title;
                } else {
                    newButtonItem.title = nav.navigationBar.backButtonLabel.text;
                }
                newButtonItem.tintColor = fromVC.yc_tintColor;
                toVC.navigationItem.backBarButtonItem = newButtonItem;
            }
            
            UIViewController *top = nav.topViewController;
            if (top.navigationItem.backBarButtonItem && !nav.poppingViewController) {
                top.yc_backBarButtonItem = top.navigationItem.backBarButtonItem;
            }
            
            if (toVC == top && fromVC.navigationController == nav) {
                UIBarButtonItem *backItem = fromVC.navigationItem.backBarButtonItem;
                if (backItem) {
                    backItem.tintColor = toVC.yc_tintColor;
                }
            }
        }
        [self showViewController:viewController withCoordinator:coordinator];
        
    } else {
        if (!animated && nav.childViewControllers.count > 1) {
            UIViewController *lastButOne = nav.childViewControllers[nav.childViewControllers.count - 2];
            if (shouldShowFake(viewController, lastButOne, viewController)) {
                [nav showFakeBarFrom:lastButOne to:viewController];
                return;
            }
        }
        [nav updateNavigationBarForViewController:viewController];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.proxiedDelegate && [self.proxiedDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.proxiedDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
    
    YCNavigationController *nav = self.nav;
    nav.transitional = NO;
    if (!animated) {
       [nav updateNavigationBarForViewController:viewController];
       [nav clearFake];
    }
    
    if (@available(iOS 11.0, *)) {
        if (viewController.yc_backBarButtonItem) {
            viewController.navigationItem.backBarButtonItem = viewController.yc_backBarButtonItem;
        }
    }
    
    nav.poppingViewController = nil;
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    if (self.proxiedDelegate && [self.proxiedDelegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]) {
        return [self.proxiedDelegate navigationControllerSupportedInterfaceOrientations:navigationController];
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController  {
    if (self.proxiedDelegate && [self.proxiedDelegate respondsToSelector:@selector(navigationControllerPreferredInterfaceOrientationForPresentation:)]) {
        return [self.proxiedDelegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
    }
    return UIInterfaceOrientationPortrait;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController  {
    if (self.proxiedDelegate && [self.proxiedDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        return [self.proxiedDelegate navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
    return nil;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC  {
    if (self.proxiedDelegate && [self.proxiedDelegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        return [self.proxiedDelegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
    }
    return nil;
}

- (void)showViewController:(UIViewController * _Nonnull)viewController withCoordinator: (id<UIViewControllerTransitionCoordinator>)coordinator {
    UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (@available(iOS 12.0, *)) {
        [self resetButtonLabelInNavBar:self.nav.navigationBar];
    }
    
    [self.nav updateNavigationBarAnimatedForViewController:viewController];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        BOOL shouldFake = shouldShowFake(viewController, from, to);
        if (shouldFake) {
            [self.nav updateNavigationBarAnimatedForViewController:viewController];
            [self.nav showFakeBarFrom:from to:to];
        } else {
            [self.nav updateNavigationBarForViewController:viewController];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        self.nav.transitional = NO;
        if (context.isCancelled) {
            [self.nav updateNavigationBarForViewController:from];
        } else {
            // `to` != `viewController` when present
            [self.nav updateNavigationBarForViewController:viewController];
        }
        if (to == viewController) {
            [self.nav clearFake];
        }
    }];
}

- (void)resetButtonLabelInNavBar:(UINavigationBar *)navBar {
    if (@available(iOS 12.0, *)) {
        for (UIView *view in navBar.subviews) {
            NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
            if ([viewName isEqualToString:@"UINavigationBarContentView"]) {
                [self resetButtonLabelInView:view];
                break;
            }
        }
    }
}

- (void)resetButtonLabelInView:(UIView *)view {
    NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    if ([viewName isEqualToString:@"UIButtonLabel"]) {
        view.alpha = 1.0;
    } else if (view.subviews.count > 0) {
        for (UIView *sub in view.subviews) {
            [self resetButtonLabelInView:sub];
        }
    }
}

@end

@implementation YCNavigationController

@dynamic navigationBar;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[YCNavigationBar class] toolbarClass:nil]) {
        self.viewControllers = @[ rootViewController ];
    }
    return self;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    NSAssert([navigationBarClass isSubclassOfClass:[YCNavigationBar class]], @"navigationBarClass Must be a subclass of YCNavigationBar");
    return [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
}

- (instancetype)init {
    return [super initWithNavigationBarClass:[YCNavigationBar class] toolbarClass:nil];
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    if ([delegate isKindOfClass:[YCNavigationControllerDelegate class]] || !self.navigationDelegate) {
        [super setDelegate:delegate];
    } else {
        self.navigationDelegate.proxiedDelegate = delegate;
    }
}

- (UIGestureRecognizer *)interactivePopGestureRecognizer {
    return self.navigationDelegate;
}

- (UIGestureRecognizer *)superInteractivePopGestureRecognizer {
    return [super interactivePopGestureRecognizer];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setTranslucent:YES];
    [self.navigationBar setShadowImage:[UINavigationBar appearance].shadowImage];
    
    self.navigationDelegate = [[YCNavigationControllerDelegate alloc] initWithNavigationController:self];
    self.navigationDelegate.proxiedDelegate = self.delegate;
    self.delegate = self.navigationDelegate;
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (!coordinator) {
       [self updateNavigationBarForViewController:self.topViewController];
    }
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (self.viewControllers.count > 1 && self.topViewController.navigationItem == item ) {
        if (!(self.topViewController.yc_backInteractive && self.topViewController.yc_clickBackEnabled)) {
            [self resetSubviewsInNavBar:self.navigationBar];
            return NO;
        }
    }
    return [super navigationBar:navigationBar shouldPopItem:item];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    self.poppingViewController = self.topViewController;
    UIViewController *vc = [super popViewControllerAnimated:animated];
    // vc != self.topViewController
    [self fixClickBackIssue];
    return vc;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.poppingViewController = self.topViewController;
    NSArray *array = [super popToViewController:viewController animated:animated];
    [self fixClickBackIssue];
    return array;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    self.poppingViewController = self.topViewController;
    NSArray *array = [super popToRootViewControllerAnimated:animated];
    [self fixClickBackIssue];
    return array;
}

- (void)fixClickBackIssue {
    if (@available(iOS 13.0, *)) {
        return;
    }
    if (@available(iOS 11.0, *)){
        // fix：ios 11，12，当前后两个页面的 barStyle 不一样时，点击返回按钮返回，前一个页面的标题颜色响应迟缓或不响应
        id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
        if (!(coordinator && coordinator.interactive)) {
            self.navigationBar.barStyle = self.topViewController.yc_barStyle;
            self.navigationBar.titleTextAttributes = self.topViewController.yc_titleTextAttributes;
        }
    }
}

- (void)resetSubviewsInNavBar:(UINavigationBar *)navBar {
    if (@available(iOS 11, *)) {
        // empty
    } else {
        [navBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            if (subview.alpha < 1.0) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.0;
                }];
            }
        }];
    }
}

- (void)printSubViews:(UIView *)view prefix:(NSString *)prefix {
    NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    NSLog(@"%@%@", prefix, viewName);
    if (view.subviews.count > 0) {
        for (UIView *sub in view.subviews) {
            [self printSubViews:sub prefix:[NSString stringWithFormat:@"--%@", prefix]];
        }
    }
}

- (void)updateNavigationBarForViewController:(UIViewController *)vc {
    [self updateNavigationBarAlphaForViewController:vc];
    [self updateNavigationBarColorOrImageForViewController:vc];
    [self updateNavigationBarShadowImageIAlphaForViewController:vc];
    [self updateNavigationBarAnimatedForViewController:vc];
}

- (void)updateNavigationBarAnimatedForViewController:(UIViewController *)vc {
    self.navigationBar.tintColor = vc.yc_tintColor;
    self.navigationBar.barStyle = vc.yc_barStyle;
    self.navigationBar.titleTextAttributes = vc.yc_titleTextAttributes;
    
    if (@available(iOS 11.0, *)) {
        if (!self.poppingViewController) {
            __block NSInteger index = -1;
            if (!self.transitional) {
                [self.childViewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj == vc) {
                        index = idx - 1;
                        *stop = YES;
                    }
                }];
            }
            
            if (index > -1) {
                UIViewController *backItemVC = self.childViewControllers[index];
                UIBarButtonItem *backItem = backItemVC.navigationItem.backBarButtonItem;
                if (backItem) {
                    backItem = [[UIBarButtonItem alloc] init];
                    UIBarButtonItem *storedBackItem = backItemVC.yc_backBarButtonItem;
                    if (storedBackItem) {
                        backItem.title = storedBackItem.title;
                    } else {
                        backItem.title = self.navigationBar.backButtonLabel.text;
                    }
                    backItem.tintColor = vc.yc_tintColor;
                    backItemVC.navigationItem.backBarButtonItem = backItem;
                }
            }
        }
    }
}

- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc {
    if (vc.yc_computedBarImage) {
        self.navigationBar.fakeView.alpha = 0;
        self.navigationBar.backgroundImageView.alpha = vc.yc_barAlpha;
    } else {
        self.navigationBar.fakeView.alpha = vc.yc_barAlpha;
        self.navigationBar.backgroundImageView.alpha = 0;
    }
    self.navigationBar.shadowImageView.alpha = vc.yc_computedBarShadowAlpha;
}

- (void)updateNavigationBarColorOrImageForViewController:(UIViewController *)vc {
    self.navigationBar.barTintColor = vc.yc_computedBarTintColor;
    self.navigationBar.backgroundImageView.image = vc.yc_computedBarImage;
}

- (void)updateNavigationBarShadowImageIAlphaForViewController:(UIViewController *)vc {
    self.navigationBar.shadowImageView.alpha = vc.yc_computedBarShadowAlpha;
}

- (void)showFakeBarFrom:(UIViewController *)from to:(UIViewController * _Nonnull)to {
   
    [UIView setAnimationsEnabled:NO];
    self.navigationBar.fakeView.alpha = 0;
    self.navigationBar.shadowImageView.alpha = 0;
    self.navigationBar.backgroundImageView.alpha = 0;
    [self showFakeBarFrom:from];
    [self showFakeBarTo:to];
    [UIView setAnimationsEnabled:YES];
}

- (void)showFakeBarFrom:(UIViewController *)from {
    self.fromFakeImageView.image = from.yc_computedBarImage;
    self.fromFakeImageView.alpha = from.yc_barAlpha;
    self.fromFakeImageView.frame = [self fakeBarFrameForViewController:from];
    [from.view addSubview:self.fromFakeImageView];
    
    self.fromFakeBar.subviews.lastObject.backgroundColor = from.yc_computedBarTintColor;
    self.fromFakeBar.alpha = from.yc_barAlpha == 0 || from.yc_computedBarImage ? 0.01:from.yc_barAlpha;
    if (from.yc_barAlpha == 0 || from.yc_computedBarImage) {
        self.fromFakeBar.subviews.lastObject.alpha = 0.01;
    }
    self.fromFakeBar.frame = [self fakeBarFrameForViewController:from];
    [from.view addSubview:self.fromFakeBar];
    
    self.fromFakeShadow.alpha = from.yc_computedBarShadowAlpha;
    self.fromFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.fromFakeBar.frame];
    [from.view addSubview:self.fromFakeShadow];
}

- (void)showFakeBarTo:(UIViewController * _Nonnull)to {
    self.toFakeImageView.image = to.yc_computedBarImage;
    self.toFakeImageView.alpha = to.yc_barAlpha;
    self.toFakeImageView.frame = [self fakeBarFrameForViewController:to];
    [to.view addSubview:self.toFakeImageView];
    
    self.toFakeBar.subviews.lastObject.backgroundColor = to.yc_computedBarTintColor;
    self.toFakeBar.alpha = to.yc_computedBarImage ? 0 : to.yc_barAlpha;
    self.toFakeBar.frame = [self fakeBarFrameForViewController:to];
    [to.view addSubview:self.toFakeBar];
    
    self.toFakeShadow.alpha = to.yc_computedBarShadowAlpha;
    self.toFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.toFakeBar.frame];
    [to.view addSubview:self.toFakeShadow];
}

- (UIVisualEffectView *)fromFakeBar {
    if (!_fromFakeBar) {
        _fromFakeBar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _fromFakeBar;
}

- (UIVisualEffectView *)toFakeBar {
    if (!_toFakeBar) {
        _toFakeBar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _toFakeBar;
}

- (UIImageView *)fromFakeImageView {
    if (!_fromFakeImageView) {
        _fromFakeImageView = [[UIImageView alloc] init];
    }
    return _fromFakeImageView;
}

- (UIImageView *)toFakeImageView {
    if (!_toFakeImageView) {
        _toFakeImageView = [[UIImageView alloc] init];
    }
    return _toFakeImageView;
}

- (UIImageView *)fromFakeShadow {
    if (!_fromFakeShadow) {
        _fromFakeShadow = [[UIImageView alloc] initWithImage:self.navigationBar.shadowImageView.image];
        _fromFakeShadow.backgroundColor = self.navigationBar.shadowImageView.backgroundColor;
    }
    return _fromFakeShadow;
}

- (UIImageView *)toFakeShadow {
    if (!_toFakeShadow) {
        _toFakeShadow = [[UIImageView alloc] initWithImage:self.navigationBar.shadowImageView.image];
        _toFakeShadow.backgroundColor = self.navigationBar.shadowImageView.backgroundColor;
    }
    return _toFakeShadow;
}

- (void)clearFake {
    [_fromFakeBar removeFromSuperview];
    [_toFakeBar removeFromSuperview];
    [_fromFakeShadow removeFromSuperview];
    [_toFakeShadow removeFromSuperview];
    [_fromFakeImageView removeFromSuperview];
    [_toFakeImageView removeFromSuperview];
    _fromFakeBar = nil;
    _toFakeBar = nil;
    _fromFakeShadow = nil;
    _toFakeShadow = nil;
    _fromFakeImageView = nil;
    _toFakeImageView = nil;
}

- (CGRect)fakeBarFrameForViewController:(UIViewController *)vc {
    UIView *back = self.navigationBar.subviews[0];
    CGRect frame = [self.navigationBar convertRect:back.frame toView:vc.view];
    frame.origin.x = 0;
    if ((vc.edgesForExtendedLayout & UIRectEdgeTop) == 0) {
        frame.origin.y = -frame.size.height;
    }
    if ([vc.view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollview = (UIScrollView *)vc.view;
        scrollview.clipsToBounds = NO;
        if (scrollview.contentOffset.y == 0) {
            frame.origin.y = -frame.size.height;
        }
    }
    return frame;
}

- (CGRect)fakeShadowFrameWithBarFrame:(CGRect)frame {
    return CGRectMake(frame.origin.x, frame.size.height + frame.origin.y - 0.5, frame.size.width, 0.5);
}

@end
