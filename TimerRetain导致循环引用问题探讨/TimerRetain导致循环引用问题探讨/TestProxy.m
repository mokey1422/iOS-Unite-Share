//
//  TestProxy.m
//  TimerRetain导致循环引用问题探讨
//
//  Created by 张国兵 on 16/9/19.
//  Copyright © 2016年 __MyCompanyName__. All rights reserved.
//

#import "TestProxy.h"

@implementation TestProxy
- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[self alloc] initWithTarget:target];
}
//最关键的一句话就是这里消息拦截本来
- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}
- (void)forwardInvocation:(NSInvocation *)invocation {

    
    
}

@end
