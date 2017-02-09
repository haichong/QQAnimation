//
//  ViewController.m
//  QQAnimation
//
//  Created by FuHang on 2017/1/17.
//  Copyright © 2017年 付航. All rights reserved.
//

#import "ViewController.h"
#import "QQAnimationView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    QQAnimationView *v = [[QQAnimationView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:v];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
