//
//  YYNavigationBar.h
//  YYNavigationBarDemo
//
//  Created by Codyy.YY on 2019/9/26.
//  Copyright © 2019 Codyy.XYY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCNavigationBar : UINavigationBar

@property (nonatomic, strong, readonly) UIImageView *shadowImageView;
@property (nonatomic, strong, readonly) UIVisualEffectView *fakeView;
@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;
@property (nonatomic, strong, readonly) UILabel *backButtonLabel;

@end

NS_ASSUME_NONNULL_END
