//
//  NSTimer+Block.h
//  TimerRetain导致循环引用问题探讨
//
//  Created by 张国兵 on 16/9/6.
//  Copyright © 2016年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Block)
+ (NSTimer *)gb_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void(^)())block
                                       repeats:(BOOL)repeats;
@end
