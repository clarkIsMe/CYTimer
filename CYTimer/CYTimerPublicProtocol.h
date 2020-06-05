//
//  CYTimerProtocol.h
//  CYTimerDemo
//
//  Created by 马春雨 on 2020/6/2.
//  Copyright © 2020 cytimerdemo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CYTimer;

#pragma mark - CYTimer在各个生命周期的时间切片
@protocol CYTimerLifeCycleDelegate <NSObject>

@optional

- (void)applicationDidBecomeActiveWithTimer:(CYTimer*)timer currentTimeInterval: (NSTimeInterval)timeInterval;

- (void)applicationWillResignActivedWithTimer:(CYTimer*)timer currentTimeInterval: (NSTimeInterval)timeInterval;



- (void)currentControllerWillAppearWithTimer_every:(CYTimer*)timer currentTimeInterval: (NSTimeInterval)timeInterval;

- (void)currentControllerDidAppearWithTimer_every:(CYTimer*)timer currentTimeInterval: (NSTimeInterval)timeInterval;

- (void)currentControllerWillAppearWithTimer_first:(CYTimer*)timer currentTimeInterval: (NSTimeInterval)timeInterval;

- (void)currentControllerDidAppearWithTimer_first:(CYTimer*)timer currentTimeInterval: (NSTimeInterval)timeInterval;

- (void)currentControllerWillAppearWithTimer_not_first:(CYTimer*)timer currentTimeInterval: (NSTimeInterval)timeInterval;

- (void)currentControllerDidAppearWithTimer_not_first:(CYTimer*)timer currentTimeInterval: (NSTimeInterval)timeInterval;

- (void)currentControllerWillDisappearWithTimer:(CYTimer*)timer currentTimeInterval: (NSTimeInterval)timeInterval;

- (void)currentControllerDidDisappearWithTimer:(CYTimer*)timer currentTimeInterval: (NSTimeInterval)timeInterval;


@end

NS_ASSUME_NONNULL_END
