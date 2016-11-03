//
//  ViewController.m
//  TimerRetain导致循环引用问题探讨
//
//  Created by 张国兵 on 16/9/1.
//  Copyright © 2016年 __MyCompanyName__. All rights reserved.


#import "ViewController.h"
#import "ViewController1.h"
#import "TestProxy.h"
@interface ViewController ()

@end

@implementation ViewController
- (void)dealloc{
    
    NSLog(@"%s",__FUNCTION__);
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  补充知识：NSProxy
     *  说实话这个东西我在开发中并不常用，准确的说是我在整理这篇文章的时候才注意到这个东西。
     *  关于这个东西我百度了很多资料
     *  先分享几篇扫盲篇的文章给大家
     *  连接地址：http://blog.csdn.net/yanghua_kobe/article/details/8395535
     
     *　 NSProxy类在分布式对象架构中是很重要的。由于作用比较特别，NSProxy在Cocoa程序中出现频率很低。
     *   NSProxy 是一个抽象类，它为一些表现的像是其它对象替身或者并不存在的对象定义一套API。一般的，发送给代理的消息被转发给一个真实的对象或者代理本身load(或者将本身转换成)一个真实的对象。NSProxy的基类可以被用来透明的转发消息或者耗费巨大的对象的lazy 初始化。
     
     *   NSProxy实现了包括NSObject协议在内基类所需的基础方法，但是作为一个虚拟的基类并没有提供初始化的方法。它接收到任何自己没有定义的方法他都会产生一个异常，所以一个实际的子类必须提供一个初始化方法或者创建方法，并且重载forwardInvocation:方法和methodSignatureForSelector:方法来处理自己没有实现的消息。一个子类的forwardInvocation:实现应该采取所有措施来处理invocation,比如转发网络消息，或者加载一个真实的对象，并把invocation转发给他。methodSignatureForSelector:需要为给定消息提供参数类型信息，子类的实现应该有能力决定他应该转发消息的参数类型，并构造相对应的NSMethodSignature对象。详细信息可以查看NSDistantObject, NSInvocation, and NSMethodSignature的类型说明。
     
     *  这个类存在的意义主要是为了实现消息的转发
     *  利用这个特性我们可以通过NSProxy实现伪多继承、AOP、弱化持有对象等常见操作。
     *  文章中有提到过aop这个概念，大家可能对这个概念不是很熟悉，但是大家对oop这个概念应该很熟悉，如果不熟悉的请面壁思过去oc、c++等都是oop的典型
     *  oop即面向对象编程  aop是oop的延伸（面向切面编程）
     *  下面是AOP的官方释义
     *  AOP为Aspect Oriented Programming的缩写，意为：面向切面编程，通过预编译方式和运行期动态代理实现程序功能的统一维护的一种技术。AOP是OOP的延续，是软件开发中的一个热点，也是Spring框架中的一个重要内容，是函数式编程的一种衍生范型。利用AOP可以对业务逻辑的各个部分进行隔离，从而使得业务逻辑各部分之间的耦合度降低，提高程序的可重用性，同时提高了开发的效率。
     *  AOP的存在意义在于解耦，解耦是程序员的一直索追求的，AOP也是为了解耦所诞生。具体的思想就是：定义一个切面，在切面的纵向定义处理方法，处理完成之后，回到横向业务流。
     *  AOP 在Spring框架中被作为核心组成部分之一，的确Spring将AOP发挥到很强大的功能。最常见的就是事务控制。工作之余，对于使用的工具，不免需要了解其所以然。学习了一下，写了些程序帮助理解。
     *  AOP 主要是利用代理模式的技术来实现的。
     
     *  现在先泛型的讲述一下什么是aop对于这部分的内容涵盖面很广，会单独出一文章来阐述AOP的

     */
    self.view.backgroundColor=[UIColor whiteColor];
    TestProxy*testProxy=[TestProxy proxyWithTarget:self];

    NSTimer*timer=[NSTimer scheduledTimerWithTimeInterval:1 target:testProxy selector:@selector(run) userInfo:nil repeats:YES];
    [timer fire];
}
-(void)run{
    
    NSLog(@"%s__",__FUNCTION__);
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    ViewController1*vc=[[ViewController1 alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
