//
//  CYTimer.h
//  CYTimerDemo
//
//  Created by 马春雨 on 2020/6/1.
//  Copyright © 2020 cytimerdemo. All rights reserved.
//
/*
 做个这个组件的初衷：
 1、提供干净的定时器调用方式，不用考虑循环引用、内存泄漏等等问题，不用时刻想着销毁定时器，让我们更加专注在业务上。
 2、提供不同原理实现的定时器来更好的适应业务场景。
 3、提供适当的AOP。
 */

/*
 需要知道的地方：
 1、如果你声明了CYTimer类型的成员变量，然后直接调用CYTimer的类方法去执行任务，没有用 = 给成员变量赋值，
 那么这个赋值过程会自动发生；如果CYTimer类型的成员变量个数超过一个，这个自动赋值的过程就不会发生了。
 2、如果你采用CYTimer的Block方式调用，那么你仍然要注意Block内部弱引用self，这个组件是解决定时器的问题，
 不是block。
 3、除了block内部你自己写的代码里注意循环引用，其它地方你将不再需要关心self是否需要弱引用，怎么样都可以
 4、dealloc里不要求调用 invalidate 方法，当然你要调用也可以。
 5、在使用normal定时器，你不用关心runloop是否会释放NSTimer，这个释放过程是自动发生的。
 6、normal和FPS的定时器都是在当前线程的runloop中，模式是 NSRunLoopCommonModes，如果你需要自己灵活设置模式，请告诉我。
 7、block回调已经自动切回了主线程，你没必要在自己的block代码再切一次。
 */

/*
 使用建议：
 1、非动画类推荐使用用GCD的方法。
 2、动画类的推荐使用FPS的方法。
 3、如果你偏爱用NSTimer，那你也可以选择normal的方法，而且让你使用中不再有坑。但是它不准呀大兄弟，为啥你非得用。
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CYTimerPublicProtocol.h"
#import "CYTimerPublicEnum.h"

NS_ASSUME_NONNULL_BEGIN


@interface CYTimer : NSObject

/// 不在运行中且不可恢复运行的状态为失效，返回NO； 否则返回YES
@property (readonly, getter=isValid) BOOL valid;

/// 定时器当前的状态
@property (readonly) CYTimerStatus status;

@property (readonly) NSTimeInterval appWillResignActionTimeInterval;
@property (readonly) NSTimeInterval ViewControllerDisappearTimeInterval;

/// CYTimer通过协议对外提供时间切片
@property (nonatomic, weak) id<CYTimerLifeCycleDelegate> lifeCycleDelegate;

#pragma mark - 创建定时器的方法

/*

/// NSTimer的Target-Action实现方式，自动检测runloop并添加，内部解决了循环引用问题，内部自动调用了invalidate，避免内存泄漏
/// @param ti 调用间隔，单位 s
/// @param aTarget 目标对象
/// @param aSelector 回调方法
/// @param userInfo 传参
/// @param yesOrNo 是否重复执行

+ (CYTimer *)scheduledNormalTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo API_AVAILABLE(ios(8.0));


/// NSTimer的Block实现方式，自动检测runloop并添加，内部解决了循环引用问题，内部自动调用了invalidate，避免内存泄漏
/// @param interval 调用间隔，单位 s
/// @param aTarget CYTimer的生命周期与aTarget绑定，aTarget不建议使用weak 引用，虽然weak引用不会导致任何问题。
/// @param repeats 是否重复执行
/// @param block 回调

+ (CYTimer *)scheduledNormalTimerWithTimeInterval:(NSTimeInterval)interval bindTo:(id)aTarget repeats:(BOOL)repeats block:(void (^)(CYTimer *timer))block API_AVAILABLE(ios(8.0));


/// CADisplayLink的Target-Action实现方式，自动检测runloop并添加，内部解决了循环引用问题，内部自动调用了invalidate，避免内存泄漏
/// @param ti 调用间隔，单位 s
/// @param aTarget 目标对象
/// @param aSelector 回调方法

+ (CYTimer *)scheduledFPSTimerWithFrameInterval:(NSUInteger)ti target:(id)aTarget selector:(SEL)aSelector API_AVAILABLE(ios(8.0));


/// CADisplayLink的Block实现方式，自动检测runloop并添加，内部解决了循环引用问题，内部自动调用了invalidate，避免内存泄漏
/// @param interval  iOS 10以后该参数代表每秒执行的次数，0 为代表每一帧都调用；iOS 10以前每 frameInterval  帧的调用一次，1 为每一帧都调用，不可以小于1
/// @param aTarget CYTimer的生命周期与aTarget绑定，aTarget不建议使用weak 引用，虽然weak引用不会导致任何问题。
/// @param block 回调

+ (CYTimer *)scheduledFPSTimerWithFrameInterval:(NSUInteger)interval bindTo:(id)aTarget block:(void (^)(CYTimer *timer))block API_AVAILABLE(ios(8.0));


/// GCD定时器的Target-Action实现方式，自动检测runloop并添加，内部解决了循环引用问题，内部自动调用了invalidate，避免内存泄漏
/// @param ti  iOS 10以后该参数代表每秒执行的次数，0 为代表每一帧都调用；iOS 10以前每 frameInterval  帧的调用一次，1 为每一帧都调用，不可以小于1
/// @param aTarget 目标对象
/// @param aSelector 回调方法

+ (CYTimer *)scheduledGCDTimerWithTimeInterval:(NSUInteger)ti target:(id)aTarget selector:(SEL)aSelector API_AVAILABLE(ios(8.0));


/// GCD定时器的Block实现方式，自动检测runloop并添加，内部解决了循环引用问题，内部自动调用了invalidate，避免内存泄漏
/// @param interval 调用间隔，单位 s
/// @param aTarget CYTimer的生命周期与aTarget绑定，aTarget不建议使用weak 引用，虽然weak引用不会导致任何问题。
/// @param block 回调

+ (CYTimer *)scheduledGCDTimerWithTimeInterval:(NSUInteger)interval bindTo:(id)aTarget block:(void (^)(CYTimer *timer))block API_AVAILABLE(ios(8.0));

*/

/// 暂时仅开发这个方法
/// @param interval 调用间隔，单位 s
/// @param block 回调
+ (CYTimer *)scheduledGCDTimerWithTimeInterval:(NSUInteger)interval block:(void (^)(CYTimer *timer))block API_AVAILABLE(ios(8.0));


#pragma mark - CYTimer对外提供的接口

/// 立刻执行一次
- (void)fire;

/// 暂定定时器
- (void)suspend;

/// 恢复定时器
- (void)resume;

/// 使定时器失效
- (void)invalidate;


@end


#pragma mark - target成员变量列表模型

@interface TargetIvarModel: NSObject

/// 成员变量类型
@property (nonatomic, copy) Class ivarType;

/// 成员变量名称
@property (nonatomic, copy) NSString *ivarName;

/// 成员变量值
@property (nonatomic, assign) Ivar i_v;

@end


NS_ASSUME_NONNULL_END

