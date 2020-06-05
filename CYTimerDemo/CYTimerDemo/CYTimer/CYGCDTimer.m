//
//  CYGCDTimer.m
//  CYTimerDemo
//
//  Created by 马春雨 on 2020/6/1.
//  Copyright © 2020 cytimerdemo. All rights reserved.
//

#import "CYGCDTimer.h"
#import <objc/message.h>
#import "CYWeakProxy.h"

@interface CYGCDTimer()

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, assign) NSUInteger ti;

@property (nonatomic, weak) id aTarget;

@property (nonatomic, assign) SEL aSelector;

@property (nonatomic, weak) VoidBlock block;

@property (nonatomic, assign, getter=isSuspend) BOOL suspend;

@property (nonatomic, assign, getter=isValid) BOOL valid;

/// 设置弱引用代理
@property (nonatomic, strong) CYWeakProxy *weakTarget;

@end

@implementation CYGCDTimer

id _Nullable (* _Nullable gcd_msgSend)(id, SEL, _Nullable id) = (id (*)(id, SEL, id))objc_msgSend;


+ (CYGCDTimer *)scheduledGCDTimerWithTimeInterval:(NSUInteger)ti target:(id)aTarget selector:(SEL)aSelector {
    CYGCDTimer *gcdTimer = [[CYGCDTimer alloc] init];
    gcdTimer.ti = ti;
    gcdTimer.aTarget = aTarget;
    gcdTimer.aSelector = aSelector;
    [gcdTimer createTimer];
    return gcdTimer;
}


+ (CYGCDTimer *)scheduledGCDTimerWithTimeInterval:(NSUInteger)interval bindTo:(id)aTarget block:(void (^)(void))block {
    CYGCDTimer *gcdTimer = [[CYGCDTimer alloc] init];
    gcdTimer.ti = interval;
    gcdTimer.block = block;
    [gcdTimer createTimer];
    return gcdTimer;
}


#pragma mark - private func

- (void)createTimer {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, dispatch_walltime(nil, 0), self.ti*1000*NSEC_PER_MSEC, 0);
    dispatch_source_set_event_handler(self.timer, ^{
        gcd_msgSend(self.weakTarget, self.aSelector, nil);
    });
    dispatch_resume(self.timer);
    self.valid = YES;
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
    gcd_msgSend(self.weakTarget, self.aSelector, nil);
}


/// 暂定定时器
- (void)suspend {
    self.suspend = YES;
    dispatch_suspend(self.timer);
}


/// 恢复定时器
- (void)resume {
    if (self.isSuspend) {
        self.suspend = NO;
        dispatch_resume(self.timer);
    }
}


/// 使定时器失效
- (void)invalidate {
    self.valid = NO;
    dispatch_source_cancel(self.timer);
}


/// 返回定时器当前的状态
- (CYTimerStatus)status {
    if (self.isValid) {
        if (self.isSuspend) {
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
