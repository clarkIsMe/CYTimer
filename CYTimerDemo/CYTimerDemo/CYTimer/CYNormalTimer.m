//
//  CYNormalTimer.m
//  CYTimerDemo
//
//  Created by 马春雨 on 2020/6/1.
//  Copyright © 2020 cytimerdemo. All rights reserved.
//

#import "CYNormalTimer.h"
#import "CYWeakProxy.h"

@interface CYNormalTimer()

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSTimeInterval ti;

@property (nonatomic, weak) id aTarget;

@property (nonatomic, assign) SEL aSelector;

@property (nonatomic, weak) VoidBlock block;

@property (nonatomic, strong) id userInfo;

@property (nonatomic, assign) BOOL yesOrNo;

/// 设置NSTimer弱引用代理
@property (nonatomic, strong) CYWeakProxy *weakTarget;

@property (nonatomic, assign) BOOL isSuspended;

@end

@implementation CYNormalTimer

+ (CYNormalTimer *)scheduledNormalTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    CYNormalTimer *normalTimer = [[CYNormalTimer alloc] init];
    normalTimer.ti = ti;
    normalTimer.aTarget = aTarget;
    normalTimer.aSelector = aSelector;
    normalTimer.userInfo = userInfo;
    normalTimer.yesOrNo = yesOrNo;
    [normalTimer createTimer];
    return normalTimer;
}


+ (CYNormalTimer *)scheduledNormalTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(void))block {
    CYNormalTimer *normalTimer = [[CYNormalTimer alloc] init];
    normalTimer.ti = interval;
    normalTimer.block = block;
    normalTimer.yesOrNo = repeats;
    [normalTimer createTimer];
    return normalTimer;
}


#pragma mark - private func

- (void)createTimer {
    self.timer = [NSTimer timerWithTimeInterval:self.ti target:self.weakTarget selector:self.aSelector userInfo:self.userInfo repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}


#pragma mark - block function

- (void)blockFunction {
    if (self.block) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.block();
        });
    }
}


#pragma mark - CYTimerActionDelegate

/// 立刻执行一次
- (void)fire {
    [self.timer fire];
}


/// 暂定定时器
- (void)suspend {
    self.isSuspended = YES;
    [self.timer setFireDate:[NSDate distantFuture]];
}


/// 恢复定时器
- (void)resume {
    if (self.isSuspended) {
        self.isSuspended = NO;
        [self.timer setFireDate:[NSDate date]];
    }
}


/// 使定时器失效
- (void)invalidate {
    [self.timer invalidate];
}


/// 返回定时器当前的状态
- (CYTimerStatus)status {
    if (self.timer.isValid) {
        if (self.isSuspended) {
            return CYTimerStatusSuspend;
        }else {
            return CYTimerStatusRun;
        }
    }else {
        return CYTimerStatusStop;
    }
}


#pragma mark - getter and setter

- (CYWeakProxy *)weakTarget {
    if (!_weakTarget) {
        if (_aTarget) {
            _weakTarget = [CYWeakProxy proxyWithTarget:_aTarget];
        }else {
            __weak typeof(self) weakSelf = self;
            _weakTarget = [CYWeakProxy proxyWithTarget:weakSelf];
        }
    }
    return _weakTarget;
}


- (SEL)aSelector {
    if (!_aSelector) {
        _aSelector = @selector(blockFunction);
    }
    return _aSelector;
}

@end
