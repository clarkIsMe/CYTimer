//
//  BViewController.m
//  CYTimerDemo
//
//  Created by 马春雨 on 2020/6/1.
//  Copyright © 2020 cytimerdemo. All rights reserved.
//

#import "BViewController.h"
#import "CYTimer.h"
#import "CViewController.h"

@interface BViewController ()<CYTimerLifeCycleDelegate>
{
    CYTimer *_timer1;
}

@property (nonatomic, strong) CYTimer *timer;

@property (nonatomic, strong) UIButton *btn1;
@property (nonatomic, strong) UIButton *btn2;
@property (nonatomic, strong) UIButton *btn3;
@property (nonatomic, strong) UIButton *btn4;
@property (nonatomic, strong) UIButton *btn5;

@end

@implementation BViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor greenColor];
    
//    self.timer = [CYTimer scheduledNormalTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
//    self.timer.lifeCycleDelegate = self;
    
//    __block int i = 0;
//    [CYTimer scheduledNormalTimerWithTimeInterval:1 bindTo:self repeats:YES block:^(CYTimer * _Nonnull timer) {
//        NSLog(@"12312312");
//        i++;
//
//        if (i == 10) {
//            [timer invalidate];
//        }
//    }];
    
//    [CYTimer scheduledFPSTimerWithFrameInterval:0 target:self selector:@selector(timerAction)];
    
//    __block int i = 0;
//    [CYTimer scheduledFPSTimerWithFrameInterval:1 bindTo:self block:^(CYTimer * _Nonnull timer) {
//        NSLog(@"%d", i);
//        i++;
//    }];
    
//    [CYTimer scheduledGCDTimerWithTimeInterval:1 bindTo:self block:^(CYTimer * _Nonnull timer) {
//        NSLog(@"1231231231");
//    }];
    
//    [CYTimer scheduledGCDTimerWithTimeInterval:1 target:self selector:@selector(timerAction)];
    
    self.timer = [CYTimer scheduledGCDTimerWithTimeInterval:1 block:^(CYTimer * _Nonnull timer) {
        NSLog(@"1231231");
    }];
    
    [self.view addSubview:self.btn1];
    [self.view addSubview:self.btn2];
    [self.view addSubview:self.btn3];
    [self.view addSubview:self.btn4];
    [self.view addSubview:self.btn5];
}


- (void)timerAction {
    NSLog(@"timer running");
}

#pragma mark - CYTimerLifeCycleDelegate
- (void)applicationWillResignActivedWithTimer:(CYTimer *)timer currentTimeInterval:(NSTimeInterval)timeInterval {
    NSLog(@"applicationWillResignActivedWithTimer-timer:%@,timeInterval:%f", timer, timeInterval);
}
- (void)applicationDidBecomeActiveWithTimer:(CYTimer *)timer currentTimeInterval:(NSTimeInterval)timeInterval {
    NSLog(@"applicationDidBecomeActiveWithTimer-timer:%@,timeInterval:%f,%f", timer, timeInterval, timer.appWillResignActionTimeInterval);
}
- (void)currentControllerWillAppearWithTimer_first:(CYTimer *)timer currentTimeInterval:(NSTimeInterval)timeInterval {
//    NSLog(@"currentControllerWillAppearWithTimer_first-timer:%@,timeInterval:%f", timer, timeInterval);
}
- (void)currentControllerWillAppearWithTimer_not_first:(CYTimer *)timer currentTimeInterval:(NSTimeInterval)timeInterval {
//    NSLog(@"currentControllerWillAppearWithTimer_not_first-timer:%@,timeInterval:%f, %f", timer, timeInterval, timer.ViewControllerDisappearTimeInterval);
}
- (void)currentControllerWillAppearWithTimer_every:(CYTimer *)timer currentTimeInterval:(NSTimeInterval)timeInterval {
    NSLog(@"currentControllerWillAppearWithTimer_every-timer:%@,timeInterval:%f", timer, timeInterval);
    [timer resume];
    NSLog(@"isvalid:%d, status:%lu", timer.isValid, (unsigned long)timer.status);
}
- (void)currentControllerDidAppearWithTimer_first:(CYTimer *)timer currentTimeInterval:(NSTimeInterval)timeInterval {
//    NSLog(@"currentControllerDidAppearWithTimer_first-timer:%@,timeInterval:%f", timer, timeInterval);
}
- (void)currentControllerDidAppearWithTimer_not_first:(CYTimer *)timer currentTimeInterval:(NSTimeInterval)timeInterval {
//    NSLog(@"currentControllerDidAppearWithTimer_not_first-timer:%@,timeInterval:%f", timer, timeInterval);
}
- (void)currentControllerDidAppearWithTimer_every:(CYTimer *)timer currentTimeInterval:(NSTimeInterval)timeInterval {
//    NSLog(@"currentControllerDidAppearWithTimer_every-timer:%@,timeInterval:%f", timer, timeInterval);
}
- (void)currentControllerWillDisappearWithTimer:(CYTimer *)timer currentTimeInterval:(NSTimeInterval)timeInterval {
    NSLog(@"currentControllerWillDisappearWithTimer-timer:%@,timeInterval:%f", timer, timeInterval);
    [timer suspend];
    NSLog(@"isvalid:%d, status:%lu", timer.isValid, (unsigned long)timer.status);
    
}
- (void)currentControllerDidDisappearWithTimer:(CYTimer *)timer currentTimeInterval:(NSTimeInterval)timeInterval {
//    NSLog(@"currentControllerDidDisappearWithTimer-timer:%@,timeInterval:%f", timer, timeInterval);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    NSLog(@"%@ 释放", NSStringFromClass([self class]));
}

/// 立刻执行一次
- (void)fire {
    [self.timer fire];
}

/// 暂定定时器
- (void)suspend {
    [self.timer suspend];
}

/// 恢复定时器
- (void)resume {
    [self.timer resume];
}

/// 使定时器失效
- (void)invalidate {
    [self.timer invalidate];
}


- (void)goCViewController {
    [self presentViewController:[[CViewController alloc] init] animated:YES completion:nil];
}

- (UIButton *)btn1 {
    if (!_btn1) {
        _btn1 = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 80, 40)];
        [_btn1 setTitle:@"fire" forState:UIControlStateNormal];
        _btn1.backgroundColor = [UIColor blueColor];
        [_btn1 addTarget:self action:@selector(fire) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn1;
}
- (UIButton *)btn2 {
    if (!_btn2) {
        _btn2 = [[UIButton alloc] initWithFrame:CGRectMake(50, 50+40+10, 80, 40)];
        [_btn2 setTitle:@"suspend" forState:UIControlStateNormal];
        _btn2.backgroundColor = [UIColor blueColor];
        [_btn2 addTarget:self action:@selector(suspend) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn2;
}
- (UIButton *)btn3 {
    if (!_btn3) {
        _btn3 = [[UIButton alloc] initWithFrame:CGRectMake(50, 50+40+10+40+10, 80, 40)];
        [_btn3 setTitle:@"resume" forState:UIControlStateNormal];
        _btn3.backgroundColor = [UIColor blueColor];
        [_btn3 addTarget:self action:@selector(resume) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn3;
}
- (UIButton *)btn4 {
    if (!_btn4) {
        _btn4 = [[UIButton alloc] initWithFrame:CGRectMake(50, 50+40+10+40+10+40+10, 80, 40)];
        [_btn4 setTitle:@"invalidate" forState:UIControlStateNormal];
        _btn4.backgroundColor = [UIColor blueColor];
        [_btn4 addTarget:self action:@selector(invalidate) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn4;
}
- (UIButton *)btn5 {
    if (!_btn5) {
        _btn5 = [[UIButton alloc] initWithFrame:CGRectMake(50, 50+40+10+40+10+40+10+40+10, 80, 40)];
        [_btn5 setTitle:@"CViewController" forState:UIControlStateNormal];
        _btn5.backgroundColor = [UIColor blueColor];
        [_btn5 addTarget:self action:@selector(goCViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn5;
}

@end
