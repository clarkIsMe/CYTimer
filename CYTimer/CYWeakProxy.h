//
//  CYWeakProxy.h
//  CYTimerDemo
//
//  Created by 马春雨 on 2020/6/1.
//  Copyright © 2020 cytimerdemo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYWeakProxy : NSProxy

+ (instancetype)proxyWithTarget:(id)aTarget;

- (instancetype)initWithTarget:(id)aTarget;

@end

NS_ASSUME_NONNULL_END
