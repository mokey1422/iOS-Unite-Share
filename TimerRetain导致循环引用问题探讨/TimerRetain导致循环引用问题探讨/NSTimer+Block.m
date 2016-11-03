//
//  NSTimer+Block.m
//  TimerRetain导致循环引用问题探讨
//
//  Created by 张国兵 on 16/9/6.
//  Copyright © 2016年 __MyCompanyName__. All rights reserved.
//

#import "NSTimer+Block.h"

@implementation NSTimer (Block)
+ (NSTimer *)gb_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void(^)())block
                                       repeats:(BOOL)repeats{
    
    
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(gb_blockInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];
    
    
}
+ (void)gb_blockInvoke:(NSTimer *)timer {
    void (^block)() = timer.userInfo;
    if(block) {
        block();
    }
}
@end
