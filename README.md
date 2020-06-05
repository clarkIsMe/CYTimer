# CYTimer

>这个库提供了6个类方法，包含了NSTimer、CADisplayLink、GCD定时器的Target-Action调用方式和Block调用方式。
内部解决了内存泄漏的问题，使用这个6个类方法去创建定时器，可以完全忽略定时器给我们带来的坑，让我们更加专注在业务开发上。
同时提供了APP进入后台，进入前台，以及当前控制器生命周期的AOP回调，让我们在写相关场景的业务时代码不再到处飞了。

*后期会更新哦，有兴趣的小伙伴可以关注下，准备加上一些自带定时器的控件，定时器与控件的生命周期绑定，完全不再操心定时器的任何问题。*

### 导入工程
```pod 'CYTimer’```

### 使用方式，6个类方法

```Objective-C
/// NSTimer的Target-Action实现方式，自动检测runloop并添加，  
///内部解决了循环引用问题，内部自动调用了invalidate，避免内存泄漏  
/// @param ti 调用间隔，单位 s  
/// @param aTarget 目标对象  
/// @param aSelector 回调方法  
/// @param userInfo 传参  
/// @param yesOrNo 是否重复执行  

+ (CYTimer *)scheduledNormalTimerWithTimeInterval:(NSTimeInterval)ti   
target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo   
repeats:(BOOL)yesOrNo API_AVAILABLE(ios(8.0));


/// NSTimer的Block实现方式，自动检测runloop并添加，内部解决了循环引用问题，内部自动调用了invalidate，避免内存泄漏  
/// @param interval 调用间隔，单位 s  
/// @param aTarget CYTimer的生命周期与aTarget绑定，aTarget不建议使用weak 引用，虽然weak引用不会导致任何问题。  
/// @param repeats 是否重复执行  
/// @param block 回调  

+ (CYTimer *)scheduledNormalTimerWithTimeInterval:(NSTimeInterval)interval   
bindTo:(id)aTarget repeats:(BOOL)repeats block:(void (^)(CYTimer *timer))  
block API_AVAILABLE(ios(8.0));


/// CADisplayLink的Target-Action实现方式，自动检测runloop并添加，内部解决了循环引用问题，内部  
/// 自动调用了invalidate，避免内存泄漏  
/// @param ti 调用间隔，单位 s  
/// @param aTarget 目标对象  
/// @param aSelector 回调方法  

+ (CYTimer *)scheduledFPSTimerWithFrameInterval:(NSUInteger)ti   
target:(id)aTarget selector:(SEL)aSelector API_AVAILABLE(ios(8.0));


/// CADisplayLink的Block实现方式，自动检测runloop并添加，内部解决了循环引用问题，
/// 内部自动调用了invalidate，避免内存泄漏   
/// @param interval  iOS 10以后该参数代表每秒执行的次数，0 为代表每一帧都调用；  
/// iOS 10以前每 frameInterval  帧的调用一次，1 为每一帧都调用，不可以小于1    
/// @param aTarget CYTimer的生命周期与aTarget绑定，aTarget不建议使用weak 引用，  
/// 虽然weak引用不会导致任何问题。   
/// @param block 回调   

+ (CYTimer *)scheduledFPSTimerWithFrameInterval:(NSUInteger)interval   
bindTo:(id)aTarget block:(void (^)(CYTimer *timer))block API_AVAILABLE(ios(8.0));


/// GCD定时器的Target-Action实现方式，自动检测runloop并添加，内部解决了循环引   
/// 用问题，内部自动调用了invalidate，避免内存泄漏  
/// @param ti  iOS 10以后该参数代表每秒执行的次数，0 为代表每一帧都调用；iOS 10   
/// 以前每 frameInterval  帧的调用一次，1 为每一帧都调用，不可以小于1   
/// @param aTarget 目标对象   
/// @param aSelector 回调方法   

+ (CYTimer *)scheduledGCDTimerWithTimeInterval:(NSUInteger)ti    
target:(id)aTarget selector:(SEL)aSelector API_AVAILABLE(ios(8.0));


/// GCD定时器的Block实现方式，自动检测runloop并添加，内部解决了循环引用问题，   
/// 内部自动调用了invalidate，避免内存泄漏   
/// @param interval 调用间隔，单位 s   
/// @param aTarget CYTimer的生命周期与aTarget绑定，aTarget不建议使用weak    
/// 引用，虽然weak引用不会导致任何问题。   
/// @param block 回调   

+ (CYTimer *)scheduledGCDTimerWithTimeInterval:(NSUInteger)interval   
bindTo:(id)aTarget block:(void (^)(CYTimer *timer))block API_AVAILABLE(ios(8.0));
```
### 回调方法

```Objective-C
- (void)applicationDidBecomeActiveWithTimer:(CYTimer*)timer currentTimeInterval:    
(NSTimeInterval)timeInterval;

- (void)applicationWillResignActivedWithTimer:(CYTimer*)timer currentTimeInterval:    
(NSTimeInterval)timeInterval;



- (void)currentControllerWillAppearWithTimer_every:(CYTimer*)timer currentTimeInterval:    
(NSTimeInterval)timeInterval;

- (void)currentControllerDidAppearWithTimer_every:(CYTimer*)timer currentTimeInterval:    
(NSTimeInterval)timeInterval;

- (void)currentControllerWillAppearWithTimer_first:(CYTimer*)timer currentTimeInterval:    
(NSTimeInterval)timeInterval;

- (void)currentControllerDidAppearWithTimer_first:(CYTimer*)timer currentTimeInterval:    
(NSTimeInterval)timeInterval;

- (void)currentControllerWillAppearWithTimer_not_first:(CYTimer*)timer currentTimeInterval:    
(NSTimeInterval)timeInterval;

- (void)currentControllerDidAppearWithTimer_not_first:(CYTimer*)timer currentTimeInterval:    
(NSTimeInterval)timeInterval;

- (void)currentControllerWillDisappearWithTimer:(CYTimer*)timer currentTimeInterval:    
(NSTimeInterval)timeInterval;

- (void)currentControllerDidDisappearWithTimer:(CYTimer*)timer currentTimeInterval:    
(NSTimeInterval)timeInterval;
```

>做个这个组件的初衷：  
 1、提供干净的定时器调用方式，不用考虑循环引用、内存泄漏等等问题，不用时刻想着销毁定时器，让我们更加专注在业务上。  
 2、提供不同原理实现的定时器来更好的适应业务场景。  
 3、提供适当的AOP。  

>需要知道的地方：  
 1、如果你声明了CYTimer类型的成员变量，然后直接调用CYTimer的类方法去执行任务，没有用 = 给成员变量赋值，那么这个赋值过程会自动发生；如果CYTimer类型的成员变量个数超过一个，这个自动赋值的过程就不会发生了。  
 2、如果你采用CYTimer的Block方式调用，那么你仍然要注意Block内部弱引用self，这个组件是解决定时器的问题，不是block。  
 3、除了block内部你自己写的代码里注意循环引用，其它地方你将不再需要关心self是否需要弱引用，怎么样都可以。  
 4、dealloc里不要求调用 invalidate 方法，当然你要调用也可以。  
 5、使用normal定时器，你不用关心runloop是否会释放NSTimer，这个释放过程是自动发生的。  
 6、normal和FPS的定时器都是在当前线程的runloop中，模式是 NSRunLoopCommonModes，如果你需要自己灵活设置模式，请告诉我。  
 7、block回调已经自动切回了主线程，你没必要在自己的block代码再切一次。  

>使用建议：  
 1、非动画类推荐使用用GCD的方法。  
 2、动画类的推荐使用FPS的方法。  
 3、如果你偏爱用NSTimer，那你也可以选择normal的方法，而且让你使用中不再有坑。但是它不准呀大兄弟，为啥你非得用。  
