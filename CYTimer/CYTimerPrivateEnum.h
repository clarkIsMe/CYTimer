//
//  CYTimerPrivateEnum.h
//  CYTimerDemo
//
//  Created by 马春雨 on 2020/6/2.
//  Copyright © 2020 cytimerdemo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CYTimerAOP) {
    CYTimerAOPViewControllerWillAppear = 0,
    CYTimerAOPViewControllerDidAppear = 1,
    CYTimerAOPViewControllerWillDisappear = 2,
    CYTimerAOPViewControllerDidDisappear = 3,
};

static NSNotificationName const CYTimerViewControlerLifeCyleNotification = @"CYTimerViewControlerLifeCyleNotification";

@interface CYTimerPrivateEnum : NSProxy

@end

NS_ASSUME_NONNULL_END
