//
//  ViewController1.m
//  TimerRetain导致循环引用问题探讨
//
//  Created by 张国兵 on 16/9/1.
//  Copyright © 2016年 __MyCompanyName__. All rights reserved.
//

#import "ViewController1.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSTimer+Block.h"
#import "YYWeakProxy.h"
#import "TestProxy.h"
@interface ViewController1 (){
    
    
}
@property(nonatomic,strong)NSTimer*mTimer;
@property(nonatomic,strong)NSTimer*yTimer;
@property(nonatomic,strong)NSTimer*hTimer;
@end

@implementation ViewController1
//方法一
-(void)viewDidDisappear:(BOOL)animated{
    
    if([self.mTimer isValid]){
        [self.mTimer invalidate];
        self.mTimer=nil;
    }
}
- (void)dealloc{
 
    NSLog(@"%s",__FUNCTION__);
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  关于timer持有对象的问题
     *  由于计时器会保留其目标对象，使用计时器时很容易引起循环引用，如下代码所示：
     *  为什么定时器回去持有目标对象？你要先理解target的含义
     *  target是用来处理操作的对象，你实际发起消息的时候告诉系统的处理这个对事件的对象，系统会在这个对象的methodlist中查找对应的方法。
     *  简单的理解就是实际调用这个方法的对象
     *  因为timer是定时操作，所以如果定时操作不停止这个对象就会一直被持有并不会被释放，试想一下如果定时操作还在继续但是我调用方法的指针被释放了，那谁来执行者方法呢？系统这样做事没错的。所以我们要谨慎对待timer这个对象。
     */
    self.view.backgroundColor=[UIColor whiteColor];
    //当前的编译单元持有定时器，定时器又会持有target对象
//    __weak __typeof(self)weakself = self;
//    self.mTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:weakself selector:@selector(dealTimer) userInfo:nil repeats:YES];
//    self.yTimer=[NSTimer gb_scheduledTimerWithTimeInterval:2 block:^{
//        [weakself dealTimer2];
//        
//    } repeats:YES];
    
    /**
     *  测试结果
     *  timer不注销定时任务，当前对象会一直被持有导致当前的编译单元不被释放
     *  dealloc 方法并不会走。
     *  猜想1、直接弱化target指针
     *  猜想2、手动注销定时操作
     *  猜想3、block捕获指针并弱化
     *  猜想验证：
     *  1、直接弱化target指针对象这个方法是不可以的，等一下从本质上去解释一下为什么不可以（无效）
     *  2、每次离开当前编译单元的时候注销定时器，如果不是在控制器中请手动停止定时器。这样可以有效的解决这个问题但不是最完美的方案。描述一个场景来说明这个方案的不完美之处，当我们push下一个界面的时候如果这里有一个倒计时抢单，如果按照这个方案来说离开界面的时候手动注销timer,当前的对象并没有被释放，倒计时也应该继续，但是这种方案我们返回上一个界面的时候timer就会被初始化，计时归零，不符合需求。（有效）
     *  3、这个方案是目前来说比较完美的方案，巧用block特性。（有效）
     *
     */
    
    
    /**
     *  下面单独来解释一下为什么我们直接弱化target指针的方法并不好用，而通过block捕获对象并如果就好用了呢，这点就要从block的特性去解释了。
     *  分成两部分来探讨这个问题首先分析block
     *  在block中,block是对变量进行捕获,意思是对使用到的变量进行拷贝操作,注意是拷贝的不是对象,而是变量自身,拿上面的来说,block中只是对变量wself拷贝了一份,也就是说,block中也定义了一个weak对象,相当于,在block的内存区域中,定义了一个__weak blockWeak对象,然后执行了blockWeak = wself;注意到了没,这里并没有引起对象的持有量的变化,所以没有问题。
     *   (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)repeats
     *  来看一下苹果对target这个对象的说明
     *  The object to which to send the message specified by aSelector when the timer fires. The timer maintains a strong reference to this object until it (the timer) is invalidated
     *  简而言之，这个对象在被传入的时候会被强引用一次，也就是说不管你传入的是不是一个弱指针都会在传入的时候被强引用，对应的改变对象的持有量的变化。这和你直接传self进来是一样的效果，并不能达到解除强引用的作用!! 
     
     */
    
    /**
     *  还有一种写法可以借鉴YYLable里面的处理方式
     *  我们先来测试一下是否可以解决这个问题，再来讲解一下NSProxy这个根类的一些知识点
     *  经过测试是没有问题的可以完美释放
     *  但是这种处理方式感觉还是没有之前的block好用。
     *  下面我们可以返回前一页去补充一些关于NSProxy的知识点
     *
     */
    
//    self.hTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:[YYWeakProxy proxyWithTarget:self] selector:@selector(dealTimer3) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop]addTimer:self.hTimer forMode:NSRunLoopCommonModes];
    
    TestProxy*testProxy=[TestProxy proxyWithTarget:self];
    
    NSTimer*timer=[NSTimer scheduledTimerWithTimeInterval:1 target:testProxy selector:@selector(run) userInfo:nil repeats:YES];
    [timer fire];

}
-(void)run{
    
    NSLog(@"%s__",__FUNCTION__);
    
}
-(void)dealTimer3{
    
    NSLog(@"我是定时器3__%s",__FUNCTION__);
    
}
-(void)dealTimer2{
    
    NSLog(@"我是定时器2__%s",__FUNCTION__);
    
}
-(void)dealTimer{
    
    NSLog(@"我是定时器__%s",__FUNCTION__);
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
