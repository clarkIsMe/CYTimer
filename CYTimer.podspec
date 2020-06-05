Pod::Spec.new do |s|
s.name = 'CYTimer'
s.version = '1.0.0'
s.license = { :type => "MIT", :file => "LICENSE" }
s.summary = '对NSTimer、CADisplayLink、GCD定时器的封装，内部解决了循环引用、内存泄漏等问题，让我们更加专注在业务上，同时对Application和currentController的生命周期监控并提供了AOP回调'
s.homepage = 'https://github.com/clarkIsMe/CYTimer.git'
s.authors = { '马春雨' => '943051580@qq.com' }
s.source = { :git => 'https://github.com/clarkIsMe/CYTimer.git', :tag => s.version.to_s }
s.requires_arc = true
s.ios.deployment_target = '8.0'
s.source_files = 'CYTimer/CYTimer/*.{h,m}'
end
