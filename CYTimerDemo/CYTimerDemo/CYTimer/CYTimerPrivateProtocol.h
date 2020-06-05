//
//  CYTimerPrivateProtocol.h
//  CYTimerDemo
//
//  Created by 马春雨 on 2020/6/2.
//  Copyright © 2020 cytimerdemo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYTimerPublicEnum.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^VoidBlock)(void);

#pragma mark - 真实定时器类实现的协议接口
@protocol CYTimerActionDelegate <NSObject>

@required
/// 立刻执行一次
- (void)fire;

/// 暂定定时器
- (void)suspend;

/// 恢复定时器
- (void)resume;

/// 使定时器失效
- (void)invalidate;

- (CYTimerStatus)status;

@end

NS_ASSUME_NONNULL_END
