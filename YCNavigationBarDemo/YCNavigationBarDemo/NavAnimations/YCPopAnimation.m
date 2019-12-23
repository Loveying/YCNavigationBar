//
//  YCPopAnimation.m
//  YCNavigationBarDemo
//
//  Created by Codyy.YY on 2019/9/30.
//  Copyright © 2019 Codyy.XYY. All rights reserved.
//

#import "YCPopAnimation.h"

@implementation YCPopAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    [[transitionContext containerView] insertSubview:toView belowSubview:fromView];
  
    toView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toView.transform = CGAffineTransformIdentity;
        fromView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, transitionContext.containerView.bounds.size.width, 0);
    } completion:^(BOOL finished) {
        toView.transform = CGAffineTransformIdentity;
        fromView.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
