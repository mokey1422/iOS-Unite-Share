//
//  TestProxy.h
//  TimerRetain导致循环引用问题探讨
//
//  Created by 张国兵 on 16/9/19.
//  Copyright © 2016年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestProxy : NSProxy
@property (nonatomic, weak, readonly) id target;
- (instancetype)initWithTarget:(id)target;
+ (instancetype)proxyWithTarget:(id)target;
@end
