//
//  TestViewController.m
//  XYNavigationBarDemo
//
//  Created by Codyy.YY on 2019/9/25.
//  Copyright © 2019 Codyy.YY. All rights reserved.
//

#import "TestViewController.h"
#import <UIViewController+YCNavigationBar.h>

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"TestVC";
}

- (BOOL)yc_backInteractive {
    [self showAlertWithBlock:^(NSInteger index) {
        if (index == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    return NO;
}

- (void)showAlertWithBlock:(void(^)(NSInteger index))block {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"操作尚未完后，是否返回？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        !block ?: block(0);
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        !block ?: block(1);
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:confirmAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
