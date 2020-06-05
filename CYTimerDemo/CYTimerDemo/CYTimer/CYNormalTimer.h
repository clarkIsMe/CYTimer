//
//  CYNormalTimer.h
//  CYTimerDemo
//
//  Created by 马春雨 on 2020/6/1.
//  Copyright © 2020 cytimerdemo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYTimerPrivateProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYNormalTimer : NSObject<CYTimerActionDelegate>

/// NSTimer的Target-Action实现方式，自动检测runloop并添加，内部解决了循环引用问题，内部自动调用了invalidate，避免内存泄漏
/// @param ti 调用间隔，单位 s
/// @param aTarget 目标对象
/// @param aSelector 回调方法
/// @param userInfo 传参
/// @param yesOrNo 是否重复执行

+ (CYNormalTimer *)scheduledNormalTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo API_AVAILABLE(ios(8.0));


/// NSTimer的Block实现方式，自动检测runloop并添加，内部解决了循环引用问题，内部自动调用了invalidate，避免内存泄漏
/// @param interval 调用间隔，单位 s
/// @param repeats 是否重复执行
/// @param block 回调
+ (CYNormalTimer *)scheduledNormalTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(void))block API_AVAILABLE(ios(8.0));

@end

NS_ASSUME_NONNULL_END
