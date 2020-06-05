//
//  CYTimer.m
//  CYTimerDemo
//
//  Created by 马春雨 on 2020/6/1.
//  Copyright © 2020 cytimerdemo. All rights reserved.
//

#import "CYTimer.h"
#import "CYNormalTimer.h"
#import "CYFPSTimer.h"
#import "CYGCDTimer.h"
#import "CYTimerPrivateProtocol.h"
#import "CYTimerPrivateEnum.h"

static NSString *cytimerKey = @"CYTIMER_OBJC_ASSOCIATED";

@interface CYTimer()

/// 这里必须strong引用，别瞎改。 delegate是真正实现定时器的类
@property (nonatomic, strong) id<CYTimerActionDelegate> delegate;

@property (readonly) BOOL isTargetFirstApppear;

@property (nonatomic, copy) VoidBlock subBlock;

@end

@implementation CYTimer


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addObserver];
    }
    return self;
}


+ (CYTimer *)scheduledNormalTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    CYTimer *timer = [[CYTimer alloc] init];
    [self targetReleateTimer:timer target:aTarget];
    CYNormalTimer *subtimer = [CYNormalTimer scheduledNormalTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    timer.delegate = subtimer;
    return timer;
}


+ (CYTimer *)scheduledNormalTimerWithTimeInterval:(NSTimeInterval)interval bindTo:(id)aTarget repeats:(BOOL)repeats block:(void (^)(CYTimer * _Nonnull))block {
    CYTimer *timer = [[CYTimer alloc] init];
    __weak typeof(timer) weakTimer = timer;
    [self targetReleateTimer:timer target:aTarget];
    timer.subBlock = ^{
        block(weakTimer);
    };
    CYNormalTimer *subtimer = [CYNormalTimer scheduledNormalTimerWithTimeInterval:interval repeats:repeats block:timer.subBlock];
    timer.delegate = subtimer;
    return timer;
}


+ (CYTimer *)scheduledFPSTimerWithFrameInterval:(NSUInteger)ti target:(id)aTarget selector:(SEL)aSelector {
    CYTimer *timer = [[CYTimer alloc] init];
    [self targetReleateTimer:timer target:aTarget];
    CYFPSTimer *subtimer = [CYFPSTimer scheduledFPSTimerWithFrameInterval:ti target:aTarget selector:aSelector];
    timer.delegate = subtimer;
    return timer;
}


+ (CYTimer *)scheduledFPSTimerWithFrameInterval:(NSUInteger)interval bindTo:(id)aTarget block:(void (^)(CYTimer * _Nonnull))block {
    CYTimer *timer = [[CYTimer alloc] init];
    __weak typeof(timer) weakTimer = timer;
    [self targetReleateTimer:timer target:aTarget];
    timer.subBlock = ^{
        block(weakTimer);
    };
    CYFPSTimer *subtimer = [CYFPSTimer scheduledFPSTimerWithFrameInterval:interval bindTo:aTarget block:timer.subBlock];
    timer.delegate = subtimer;
    return timer;
}


+ (CYTimer *)scheduledGCDTimerWithTimeInterval:(NSUInteger)ti target:(id)aTarget selector:(SEL)aSelector {
    CYTimer *timer = [[CYTimer alloc] init];
    [self targetReleateTimer:timer target:aTarget];
    CYGCDTimer *subtimer = [CYGCDTimer scheduledGCDTimerWithTimeInterval:ti target:aTarget selector:aSelector];
    timer.delegate = subtimer;
    return timer;
}


+ (CYTimer *)scheduledGCDTimerWithTimeInterval:(NSUInteger)interval bindTo:(id)aTarget block:(void (^)(CYTimer *timer))block {
    CYTimer *timer = [[CYTimer alloc] init];
    __weak typeof(timer) weakTimer = timer;
    [self targetReleateTimer:timer target:aTarget];
    timer.subBlock = ^{
        block(weakTimer);
    };
    CYGCDTimer *subtimer = [CYGCDTimer scheduledGCDTimerWithTimeInterval:interval bindTo:aTarget block:timer.subBlock];
    timer.delegate = subtimer;
    return timer;
}


#pragma mark - timer的生命周期绑定到aTarget

+ (void)targetReleateTimer: (CYTimer*)timer target: (id)aTarget {
    NSArray *allIvar = getAllIvar([aTarget class], [UIViewController class]);
    __block NSInteger numOfContained = 0;
    __block TargetIvarModel *onlyOne = nil;
    [allIvar enumerateObjectsUsingBlock:^(TargetIvarModel *model, NSUInteger i, BOOL *stop) {
        if (model.ivarType == [self class]) {
            onlyOne = model;
            numOfContained++;
        }
    }];
    ///如果有且只有一个CYTimer类型的成员变量，且没有赋值，那么直接赋值绑定
    if (numOfContained == 1) {
        if (!object_getIvar(aTarget, onlyOne.i_v)) {
            object_setIvar(aTarget, onlyOne.i_v, timer);
        }
    }
    ///如果没有CYTimer类型的成员变量 或者 有两个及以上的CYTimer类型的成员变量将不会做赋值操作，那么strong方式关联绑定
    if (numOfContained != 1) {
        objc_setAssociatedObject(aTarget, [cytimerKey cStringUsingEncoding:NSUTF8StringEncoding], timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#pragma mark - 获取aTarget的成员变量列表，为timer绑定提供判断条件，！！！为系统类通过关联对象添加CYTimer的情况暂未考虑！！！

/**
 获取指定类的变量
 
 @param cls 被获取变量的类
 @return 变量类型集合 [NSString *]
 */

NSArray * getClassIvar(Class cls) {
    if (!cls) return @[];
    NSMutableArray * all_p = [NSMutableArray array];
    unsigned int a;
    Ivar * iv = class_copyIvarList(cls, &a);
    for (unsigned int i = 0; i < a; i++) {
        Ivar i_v = iv[i];
        TargetIvarModel *model = [[TargetIvarModel alloc] init];
        NSString *typeStr = [NSString stringWithUTF8String:ivar_getTypeEncoding(i_v)];
        model.ivarType = NSClassFromString([typeStr substringWithRange:NSMakeRange(2, typeStr.length-3)]);
        model.ivarName = [NSString stringWithUTF8String:ivar_getName(i_v)];
        model.i_v = i_v;
        if (model) {
            [all_p addObject:model];
        }
    }
    free(iv);
    return [all_p copy];
}


/**
 获取指定类（以及其父类）的所有变量
 
 @param cls 被获取变量的类
 @param until_class 当查找到此类时会停止查找，当设置为 nil 时，默认采用 [NSObject class]
 @return 变量类型集合 [NSString *]
 */

NSArray * getAllIvar(Class cls, Class until_class) {
    Class stop_class = until_class ?: [NSObject class];
    if (cls == stop_class) return @[];
    NSMutableArray * all_p = [NSMutableArray array];
    [all_p addObjectsFromArray:getClassIvar(cls)];
    if (class_getSuperclass(cls) == stop_class) {
        return [all_p copy];
    } else {
        [all_p addObjectsFromArray:getAllIvar([cls superclass], stop_class)];
    }
    return [all_p copy];
}

#pragma mark - 监听application和target生命周期

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReciveResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReciveBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReciveViewController:) name:CYTimerViewControlerLifeCyleNotification object:nil];
    _isTargetFirstApppear = YES;
}


- (void)onReciveResignActive {
    if (![self.lifeCycleDelegate conformsToProtocol:@protocol(CYTimerLifeCycleDelegate)]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    /// app从活动状态进入非活动状态
    if ([self.lifeCycleDelegate respondsToSelector:@selector(applicationWillResignActivedWithTimer:currentTimeInterval:)]) {
        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
        _appWillResignActionTimeInterval = currentTimeInterval;
        [self.lifeCycleDelegate applicationWillResignActivedWithTimer:weakSelf currentTimeInterval:currentTimeInterval];
    }
}


- (void)onReciveBecomeActive {
    if (![self.lifeCycleDelegate conformsToProtocol:@protocol(CYTimerLifeCycleDelegate)]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    /// app进入前台并处于活动状态
    if ([self.lifeCycleDelegate respondsToSelector:@selector(applicationDidBecomeActiveWithTimer:currentTimeInterval:)]) {
        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
        [self.lifeCycleDelegate applicationDidBecomeActiveWithTimer:weakSelf currentTimeInterval:currentTimeInterval];
    }
}


- (void)onReciveViewController:(NSNotification *)noti {
    NSArray *objects = [noti object];
    if (![objects isKindOfClass:[NSArray class]] ||![objects.lastObject isMemberOfClass:[self.lifeCycleDelegate class]]) {
        return;
    }
    if (![self.lifeCycleDelegate conformsToProtocol:@protocol(CYTimerLifeCycleDelegate)]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    CYTimerAOP aop = [objects.firstObject integerValue];
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    /// target will appear
    if (aop == CYTimerAOPViewControllerWillAppear) {
        if (self.isTargetFirstApppear) {
            if ([self.lifeCycleDelegate respondsToSelector:@selector(currentControllerWillAppearWithTimer_first:currentTimeInterval:)]) {
                [self.lifeCycleDelegate currentControllerWillAppearWithTimer_first:weakSelf currentTimeInterval:currentTimeInterval];
            }
        }else {
            if ([self.lifeCycleDelegate respondsToSelector:@selector(currentControllerWillAppearWithTimer_not_first:currentTimeInterval:)]) {
                [self.lifeCycleDelegate currentControllerWillAppearWithTimer_not_first:weakSelf currentTimeInterval:currentTimeInterval];
            }
        }
        if ([self.lifeCycleDelegate respondsToSelector:@selector(currentControllerWillAppearWithTimer_every:currentTimeInterval:)]) {
            [self.lifeCycleDelegate currentControllerWillAppearWithTimer_every:weakSelf currentTimeInterval:currentTimeInterval];
        }
    }
    
    /// target did appear
    if (aop == CYTimerAOPViewControllerDidAppear) {
        if (self.isTargetFirstApppear) {
            _isTargetFirstApppear = NO;
            if ([self.lifeCycleDelegate respondsToSelector:@selector(currentControllerDidAppearWithTimer_first:currentTimeInterval:)]) {
                [self.lifeCycleDelegate currentControllerDidAppearWithTimer_first:weakSelf currentTimeInterval:currentTimeInterval];
            }
        }else {
            if ([self.lifeCycleDelegate respondsToSelector:@selector(currentControllerDidAppearWithTimer_not_first:currentTimeInterval:)]) {
                [self.lifeCycleDelegate currentControllerDidAppearWithTimer_not_first:weakSelf currentTimeInterval:currentTimeInterval];
            }
        }
        if ([self.lifeCycleDelegate respondsToSelector:@selector(currentControllerDidAppearWithTimer_every:currentTimeInterval:)]) {
            [self.lifeCycleDelegate currentControllerDidAppearWithTimer_every:weakSelf currentTimeInterval:currentTimeInterval];
        }
    }
    
    /// target will disappear
    if (aop == CYTimerAOPViewControllerWillDisappear && [self.lifeCycleDelegate respondsToSelector:@selector(currentControllerWillDisappearWithTimer:currentTimeInterval:)]) {
        [self.lifeCycleDelegate currentControllerWillDisappearWithTimer:weakSelf currentTimeInterval:currentTimeInterval];
    }
    
    /// target did disappear
    if (aop == CYTimerAOPViewControllerDidDisappear && [self.lifeCycleDelegate respondsToSelector:@selector(currentControllerDidDisappearWithTimer:currentTimeInterval:)]) {
        _ViewControllerDisappearTimeInterval = currentTimeInterval;
        [self.lifeCycleDelegate currentControllerDidDisappearWithTimer:weakSelf currentTimeInterval:currentTimeInterval];
    }
    
}

#pragma mark - dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.delegate invalidate];
}

#pragma mark - CYTimer对外提供的方式实现

/// 立刻执行一次
- (void)fire {
    [self conformsCYTimerActionDelegate];
    [self.delegate fire];
}


/// 暂定定时器
- (void)suspend {
    [self conformsCYTimerActionDelegate];
    [self.delegate suspend];
}


/// 恢复定时器
- (void)resume {
    [self conformsCYTimerActionDelegate];
    [self.delegate resume];
}


/// 使定时器失效
- (void)invalidate {
    [self conformsCYTimerActionDelegate];
    [self.delegate invalidate];
}


#pragma mark - setter and getter

- (BOOL)isValid {
    [self conformsCYTimerActionDelegate];
    if ([self.delegate status] == CYTimerStatusStop) {
        return NO;
    }else {
        return YES;
    }
}


- (CYTimerStatus)status {
    [self conformsCYTimerActionDelegate];
    return [self.delegate status];
}


#pragma mark - 开发期检查是否遵守CYTimerActionDelegate协议，并实现协议方法

- (void)conformsCYTimerActionDelegate {
    NSAssert([self.delegate conformsToProtocol:@protocol(CYTimerActionDelegate)], @"未遵守协议：CYTimerActionDelegate");
    NSAssert([self.delegate respondsToSelector:@selector(fire)], @"协议方法必须实现");
    NSAssert([self.delegate respondsToSelector:@selector(suspend)], @"协议方法必须实现");
    NSAssert([self.delegate respondsToSelector:@selector(resume)], @"协议方法必须实现");
    NSAssert([self.delegate respondsToSelector:@selector(invalidate)], @"协议方法必须实现");
    NSAssert([self.delegate respondsToSelector:@selector(status)], @"协议方法必须实现");
}


@end

#pragma mark - TargetIvarModel implementation

@implementation TargetIvarModel

@end



