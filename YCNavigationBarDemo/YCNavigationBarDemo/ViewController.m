//
//  ViewController.m
//  XYNavigationBarDemo
//
//  Created by Codyy.YY on 2019/9/25.
//  Copyright © 2019 Codyy.YY. All rights reserved.
//

#import "ViewController.h"
#import <UIViewController+YCNavigationBar.h>
#import "TestViewController.h"
#import "TestGradientDemoViewController.h"

@interface ViewController ()

@property (nonatomic,strong) NSArray *colors;
@property (weak, nonatomic) IBOutlet UILabel *percentLab;
@property (weak, nonatomic) IBOutlet UISwitch *shadowHidden;
@property (weak, nonatomic) IBOutlet UISwitch *barHidden;
@property (weak, nonatomic) IBOutlet UISwitch *blackStyle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *colorSegment;
@property (nonatomic,assign) CGFloat barAlpha;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我是标题";
    self.barAlpha = 1.0;
    self.colors = @[UIColor.whiteColor,UIColor.greenColor,UIColor.blueColor,UIColor.yellowColor,UIColor.redColor];
    
}


- (IBAction)sliderValueChanged:(UISlider *)sender {
    self.barAlpha = sender.value;
    self.percentLab.text = [NSString stringWithFormat:@"%f",sender.value];
}


- (IBAction)pushNextVc:(UIButton *)sender {
    
    UIColor *color = self.colors[self.colorSegment.selectedSegmentIndex];
    TestViewController *vc = [[TestViewController alloc] init];
    vc.yc_barShadowHidden = self.shadowHidden.isOn;
    vc.yc_barHidden = self.barHidden.isOn;
    vc.yc_barStyle = self.blackStyle.isOn ? UIBarStyleBlack : UIBarStyleDefault;
    vc.yc_barTintColor = color;
    vc.yc_barAlpha = self.barAlpha;
    if (CGColorEqualToColor(color.CGColor, UIColor.whiteColor.CGColor)) {
        vc.yc_tintColor = [UIColor blackColor];
        vc.yc_titleTextAttributes = @{NSForegroundColorAttributeName:UIColor.blackColor};
    }else {
        vc.yc_tintColor = [UIColor whiteColor];
        vc.yc_titleTextAttributes = @{NSForegroundColorAttributeName:UIColor.whiteColor};
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)pushDynamicVC:(UIButton *)sender {
    TestGradientDemoViewController *vc = [[TestGradientDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
