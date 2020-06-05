//
//  UIViewController+ObserveLifeCyle.m
//  CYTimerDemo
//
//  Created by 马春雨 on 2020/6/2.
//  Copyright © 2020 cytimerdemo. All rights reserved.
//

#import "UIViewController+ObserveLifeCyle.h"
#import <objc/runtime.h>
#import "CYTimerPrivateEnum.h"

@implementation UIViewController (ObserveLifeCyle)

+ (void)swizzleInstanceMethod:(Class)target original:(SEL)originalSelector swizzled:(SEL)swizzledSelector {
    Method originMethod = class_getInstanceMethod(target, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(target, swizzledSelector);
    method_exchangeImplementations(originMethod, swizzledMethod);
}

+ (void)load {
    [self swizzleInstanceMethod:[UIViewController class] original:@selector(viewWillAppear:) swizzled:@selector(swizzle_viewWillAppear:)];
    [self swizzleInstanceMethod:[UIViewController class] original:@selector(viewDidAppear:) swizzled:@selector(swizzle_viewDidAppear:)];
    [self swizzleInstanceMethod:[UIViewController class] original:@selector(viewWillDisappear:) swizzled:@selector(swizzle_viewWillDisappear:)];
    [self swizzleInstanceMethod:[UIViewController class] original:@selector(viewDidDisappear:) swizzled:@selector(swizzle_viewDidDisappear:)];
}
/// hook
- (void)swizzle_viewWillAppear:(BOOL)animated {
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] postNotificationName:CYTimerViewControlerLifeCyleNotification object:@[@(CYTimerAOPViewControllerWillAppear), weakSelf]];
    [self swizzle_viewWillAppear:animated];
}
- (void)swizzle_viewDidAppear:(BOOL)animated {
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] postNotificationName:CYTimerViewControlerLifeCyleNotification object:@[@(CYTimerAOPViewControllerDidAppear), weakSelf]];
    [self swizzle_viewDidAppear:animated];
}
- (void)swizzle_viewWillDisappear:(BOOL)animated {
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] postNotificationName:CYTimerViewControlerLifeCyleNotification object:@[@(CYTimerAOPViewControllerWillDisappear), weakSelf]];
    [self swizzle_viewWillDisappear:animated];
}
- (void)swizzle_viewDidDisappear:(BOOL)animated {
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] postNotificationName:CYTimerViewControlerLifeCyleNotification object:@[@(CYTimerAOPViewControllerDidDisappear), weakSelf]];
    [self swizzle_viewDidDisappear:animated];
}


@end
