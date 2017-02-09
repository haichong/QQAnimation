//
//  QQAnimationView.m
//  QQAnimation
//
//  Created by FuHang on 2017/1/17.
//  Copyright © 2017年 付航. All rights reserved.
//

#import "QQAnimationView.h"

@implementation QQAnimationView

- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}
- (void)drawRect:(CGRect)rect {
    
   
    // 屏幕的宽度
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    // 圆半径
    float r = 2 * width / sqrt(3);
    // 画曲线
    UIColor *color = [UIColor redColor];
    [color set];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0) radius:r startAngle:M_PI / 2 endAngle:M_PI / 6 clockwise:NO];
    path.lineWidth = 1.0;
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    [path stroke];
    // 放图片
    for (int i = 0; i < 4; i++) {
    
        // 一共四个按钮 从左到右index分别为0，1，2，3
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = [self getButtonFrame:i];
        button.tag = i + 1;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",i + 1]] forState:UIControlStateNormal];
        // 设置按钮为圆
        button.layer.cornerRadius = 25;
        button.layer.borderColor = [UIColor greenColor].CGColor;
        button.layer.masksToBounds = YES;
        button.layer.borderWidth = 2.0f;
        [self addSubview:button];
    }
    // 放头像 默认第一个
    self.head = [[UIImageView alloc] initWithFrame:[self getButtonFrame:0]];
    self.head.image = [UIImage imageNamed:@"myHead"];
    self.head.layer.borderColor = [UIColor greenColor].CGColor;
    self.head.layer.masksToBounds = YES;
    self.head.layer.cornerRadius = 25;
    self.head.layer.borderWidth = 2.0f;
    [self addSubview:self.head];

}
// 根据Index确定按钮的坐标
- (CGRect)getButtonFrame: (int) index {
    
    float radians = M_PI * (7.5 + 15 * index) / 180;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    float r = 2 * width / sqrt(3);
    CGRect frame = CGRectMake(sin(radians) * r, cos(radians) * r, 50, 50);
    frame.origin.x = frame.origin.x - 25;
    frame.origin.y = frame.origin.y - 25;
    return frame;
}
// 根据Head坐标确定当前图片所在的按钮index
- (int)getPreviousIndexByFrame:(CGRect)frame {
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    float r = 2 * width / sqrt(3);
    float x = frame.origin.x + 25;
    float radians = asin(x / r);
    
    return round(radians / M_PI * 180 - 7.5) / 15;
}
// 按钮点击事件
- (void)buttonClick:(UIButton *)button {
    
    // 原来图片所在按钮的index
    int preIndex = [self getPreviousIndexByFrame:self.head.frame];
    int buttonIndex = (int)button.tag - 1;
    // 点击图片所在按钮 不做任何操作
    if (preIndex == buttonIndex) {
        return;
    }
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    float r = 2 * width / sqrt(3);
    //加入动画效果
    CALayer *transitionLayer = [[CALayer alloc] init];
    //显式事务默认开启动画效果,kCFBooleanTrue关闭 保证begin和commit 之间的属性修改同时进行
    transitionLayer.contents = self.head.layer.contents;
    transitionLayer.borderColor = [UIColor greenColor].CGColor;
    transitionLayer.masksToBounds = YES;
    transitionLayer.cornerRadius = 25;
    transitionLayer.borderWidth = 2.0f;
    transitionLayer.frame = self.head.frame;
    transitionLayer.backgroundColor=[UIColor blueColor].CGColor;
    [self.layer addSublayer:transitionLayer];
    
    self.head.hidden = YES;
    
    UIBezierPath *movePath;
    //路径曲线 贝塞尔曲线
    if (buttonIndex > preIndex) {
        // 向上滑 逆时针
        movePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0) radius:r startAngle:[self getAnticlockwiseByIndex:preIndex] endAngle:[self getAnticlockwiseByIndex:buttonIndex] clockwise:NO];
        [movePath moveToPoint:transitionLayer.position];
    }else {
        // 向下滑 顺时针
        movePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0) radius:r startAngle:[self getClockwiseAngleByIndex:preIndex] endAngle:[self getClockwiseAngleByIndex:buttonIndex] clockwise:YES];
        [movePath moveToPoint:transitionLayer.position];
    }
    //关键帧动画效果
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    // 动画轨迹
    positionAnimation.path = movePath.CGPath;
    // 动画完成之后是否删除动画效果
    positionAnimation.removedOnCompletion = NO;
    // 设置开始的时间
    positionAnimation.beginTime = CACurrentMediaTime();
    CGFloat time =  0.7;
    if (labs(buttonIndex - preIndex) > 1) {
        time = 0.4 * labs(buttonIndex - preIndex);

    }
    //动画总时间
    positionAnimation.duration = time;
    // 动画的方式 淡入淡出
    positionAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    // 执行完之后保存最新的状态
    positionAnimation.fillMode = kCAFillModeForwards;
    // 动画完成之后，是否回到原来的地方
    positionAnimation.autoreverses= NO;
    
    [transitionLayer addAnimation:positionAnimation forKey:@"opacity"];
    [CATransaction setCompletionBlock:^{
        [NSThread sleepForTimeInterval:time];
        self.head.hidden = NO;
        self.head.frame = button.frame;
        [transitionLayer removeFromSuperlayer];
    }];
}
// 根据Index获得顺时针的弧度
- (float)getAnticlockwiseByIndex: (NSInteger)index {
    
    return M_PI * (0.5  - (7.5 + 15 * index) / 180);
}
// 根据Index获得逆时针的弧度
- (float)getClockwiseAngleByIndex: (NSInteger)index {
    
    index = 3 - index;
    return M_PI * (30 + 7.5 + 15 * index) / 180;
}

@end
