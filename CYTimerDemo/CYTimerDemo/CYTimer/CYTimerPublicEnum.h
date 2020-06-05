//
//  CYTimerPublicEnum.h
//  CYTimerDemo
//
//  Created by 马春雨 on 2020/6/3.
//  Copyright © 2020 cytimerdemo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CYTimerStatus) {
    CYTimerStatusRun = 0, //定时器正在运行
    CYTimerStatusSuspend = 1, //定时器暂停，可恢复
    CYTimerStatusStop = 0, //定时器停止，已失效，不能恢复
};

@interface CYTimerPublicEnum : NSProxy

@end

NS_ASSUME_NONNULL_END
