//
//  CYFPSTimer.m
//  CYTimerDemo
//
//  Created by 马春雨 on 2020/6/1.
//  Copyright © 2020 cytimerdemo. All rights reserved.
//

#import "CYFPSTimer.h"
#import "CYWeakProxy.h"
#import <objc/message.h>

@interface CYFPSTimer()

@property (nonatomic, strong) CADisplayLink *timer;

@property (nonatomic, assign) NSUInteger frameInterval;

@property (nonatomic, weak) id aTarget;

@property (nonatomic, assign) SEL aSelector;

@property (nonatomic, weak) VoidBlock block;

@property (nonatomic, assign) BOOL isValid;

/// 设置弱引用代理
@property (nonatomic, strong) CYWeakProxy *weakTarget;

@end

@implementation CYFPSTimer

id _Nullable (* _Nullable fps_msgSend)(id, SEL, _Nullable id) = (id (*)(id, SEL, id))objc_msgSend;

+ (CYFPSTimer *)scheduledFPSTimerWithFrameInterval:(NSUInteger)frameInterval  target:(id)aTarget selector:(SEL)aSelector {
    CYFPSTimer *fpsTimer = [[CYFPSTimer alloc] init];
    fpsTimer.frameInterval = frameInterval;
    fpsTimer.aTarget = aTarget;
    fpsTimer.aSelector = aSelector;
    [fpsTimer createTimer];
    return fpsTimer;
}


+ (CYFPSTimer *)scheduledFPSTimerWithFrameInterval:(NSUInteger)frameInterval bindTo:(id)aTarget block:(void (^)(void))block {
    CYFPSTimer *fpsTimer = [[CYFPSTimer alloc] init];
    fpsTimer.frameInterval = frameInterval;
    fpsTimer.block = block;
    [fpsTimer createTimer];
    return fpsTimer;
}


#pragma mark - private func

- (void)createTimer {
    self.timer = [CADisplayLink displayLinkWithTarget:self.weakTarget selector:self.aSelector];
    if (@available(iOS 10.0, *)) {
        self.timer.preferredFramesPerSecond = self.frameInterval;
    } else {
        self.timer.frameInterval = self.frameInterval>=1?self.frameInterval:1;
    }
    [self.timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.isValid = YES;
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
    fps_msgSend(self.weakTarget, self.aSelector, nil);
}


/// 暂定定时器
- (void)suspend {
    self.timer.paused = YES;
}


/// 恢复定时器
- (void)resume {
    self.timer.paused = NO;
}


/// 使定时器失效
- (void)invalidate {
    self.isValid = NO;
    [self.timer invalidate];
}


/// 返回定时器当前的状态
- (CYTimerStatus)status {
    if (self.isValid) {
        if (self.timer.isPaused) {
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


- (void)setFrameInterval:(NSUInteger)frameInterval {
    NSAssert(frameInterval >= 0, @"frameInterval 要求大于等于0");
    _frameInterval = frameInterval;
}

@end
