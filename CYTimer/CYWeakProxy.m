//
//  CYWeakProxy.m
//  CYTimerDemo
//
//  Created by 马春雨 on 2020/6/1.
//  Copyright © 2020 cytimerdemo. All rights reserved.
//

#import "CYWeakProxy.h"
#import <objc/message.h>

@interface CYWeakProxy()

@property (nonatomic, weak) id aTarget;

@end

@implementation CYWeakProxy

#pragma mark - init
- (instancetype)initWithTarget:(id)aTarget {
    _aTarget = aTarget;
    return self;
}

+ (instancetype)proxyWithTarget:(id)aTarget {
    return [[self alloc] initWithTarget:aTarget];
}

#pragma mark - 消息转发
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.aTarget methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL sel = [invocation selector];
    if ([self.aTarget respondsToSelector:sel]) {
        [invocation invokeWithTarget:self.aTarget];
    }
}

@end
