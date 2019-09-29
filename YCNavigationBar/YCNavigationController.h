//
//  YYNavigationController.h
//  YYNavigationBarDemo
//
//  Created by Codyy.YY on 2019/9/26.
//  Copyright © 2019 Codyy.XYY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCNavigationController : UINavigationController

- (void)updateNavigationBarForViewController:(UIViewController *)vc;

@end

@interface UINavigationController (YCNavigationBar)<UINavigationBarDelegate>

@end

NS_ASSUME_NONNULL_END
