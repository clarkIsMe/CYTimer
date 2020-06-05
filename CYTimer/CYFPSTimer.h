//
//  CYFPSTimer.h
//  CYTimerDemo
//
//  Created by 马春雨 on 2020/6/1.
//  Copyright © 2020 cytimerdemo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYTimerPrivateProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYFPSTimer : NSObject<CYTimerActionDelegate>

/// CADisplayLink的Target-Action实现方式，自动检测runloop并添加，内部解决了循环引用问题，内部自动调用了invalidate，避免内存泄漏
/// @param frameInterval  iOS 10以后该参数代表每秒执行的次数，0 为代表每一帧都调用；iOS 10以前每 frameInterval  帧的调用一次，1 为每一帧都调用，不可以小于1
/// @param aTarget 目标对象
/// @param aSelector 回调方法

+ (CYFPSTimer *)scheduledFPSTimerWithFrameInterval:(NSUInteger)frameInterval  target:(id)aTarget selector:(SEL)aSelector API_AVAILABLE(ios(8.0));


/// CADisplayLink的Block实现方式，自动检测runloop并添加，内部解决了循环引用问题，内部自动调用了invalidate，避免内存泄漏
/// @param frameInterval   iOS 10以后该参数代表每秒执行的次数，0 为代表每一帧都调用；iOS 10以前每 frameInterval  帧的调用一次，1 为每一帧都调用，不可以小于1
/// @param aTarget CYTimer的生命周期与aTarget绑定，aTarget不建议使用weak 引用，虽然weak引用不会导致任何问题。
/// @param block 回调

+ (CYFPSTimer *)scheduledFPSTimerWithFrameInterval:(NSUInteger)frameInterval  bindTo:(id)aTarget block:(void (^)(void))block API_AVAILABLE(ios(8.0));

@end

NS_ASSUME_NONNULL_END
