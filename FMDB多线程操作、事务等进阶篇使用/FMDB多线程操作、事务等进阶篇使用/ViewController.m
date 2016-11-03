//
//  ViewController.m
//  FMDB多线程操作、事务等进阶篇使用
//
//  Created by 张国兵 on 16/9/21.
//  Copyright © 2016年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <FMDB.h>
@interface ViewController ()
@property(nonatomic,strong) FMDatabase *db;
@property(nonatomic,strong) FMDatabaseQueue *queue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  今天被人问到关于FMDatabaseQueue的问题我很尴尬表示没有用过
     *  因为我们的应用中操作数据库都是单线程的只需要简单的FMDatabase就可以了。
     *  应用中不可在多个线程中共同使用一个FMDatabase对象操作数据库，这样会引起数据库数据混乱
     *  FMDatabaseQueue就是为了解决在多线程中处理数据库对象导致的线程安全的问题
     *  今天也来大体说一下这个东西。
     *  基本的操作我们今天不说，因为大家都清楚
     *  今天我们只说多线程操作数据库和事务的使用
     */
    //DB创建接下来我们可能会用到的表
    //[self createDataTable];
    //如果是多线程操作数据库的话，创建方式就应该是下面的这种了。
    //[self createQueueTable];
    
    //我们先来一个错误实例
    //[self wrongTest];
    //正确的打开方式
    //[self rightTest];
    //事务操作
    //[self transaction];
    //[self transaction2];
    [self testTryCatch];
 
    
}
-(void)testTryCatch{
    
    @try {
        // 5
        NSString *str = @"abc";
        [str substringFromIndex:111]; // 程序到这里会崩
    }
    @catch (NSException *exception) {
        // 捕捉到异常不抛出程序不会崩溃，相当于打断消息转发
        //@throw exception; // 抛出异常，即由上一级处理
        // 7
        NSLog(@"%s\n%@", __FUNCTION__, exception);
    }
    @finally {
        // 8 无论异常是不是抛出这里面的代码一定执行。
        NSLog(@"tryTwo - 我一定会执行");
    }
    
    // 9
    // 如果抛出异常，那么这段代码则不会执行
    NSLog(@"如果这里抛出异常，那么这段代码则不会执行");

}
-(void)transaction{
    /**
     *
     *  事务
     *  事务解决的事情
     *  如果你想要所有的数据库操作全部成功或者是全部失败那就用到事务这个概念了
     *  而且FMDB中已经封装好了事务的一些方法我们可以直接使用
     *  关于事务的一些基本的概念和特性在下面的一篇文章中已经说的很详细了
     *  http://blog.csdn.net/x32sky/article/details/45531229
     *  下面还是来简单的介绍一下事务的基本概念吧 
     *  主要论述什么是事务？
     *  事务有哪些特性？
     *  事务可以用来干什么？
     *   一、什么是事务？
     *   事务（Transaction）是并发控制的基本单位。所谓的事务，它是一个操作序列，这些操作要么都执行，要么都不执行，它是一个不可分割的工作单位。例如，银行转账工作：从一个账号扣款并使另一个账号增款，这两个操作要么都执行，要么都不执行。所以，应该把它们看成一个事务。事务是数据库维护数据一致性的单位，在每个事务结束时，都能保持数据一致性。
     *   事务的提出主要是为了解决并发情况下保持数据一致性的问题。
     *   二、事务的特性
     *   Atomic（原子性）：事务中包含的操作被看做一个逻辑单元，这个逻辑单元中的操作要么全部成功，要么全部失败。
     *   Consistency（一致性）：只有合法的数据可以被写入数据库，否则事务应该将其回滚到最初状态。
     *   Isolation（隔离性）：事务允许多个用户对同一个数据进行并发访问，而不破坏数据的正确性和完整性。同时，并行事务的修改必须与其他并行事务的修改相互独立。
     *   Durability（持久性）：事务结束后，事务处理的结果必须能够得到固化
     *   三、事务的保存点（savePoint）
     *   用户在事务（transaction）内可以声明（declare）被称为保存点（savepoint）
         的标记。保存点将一个大事务划分为较小的片断。
     *   用户可以使用保存点（savepoint）在事务（transaction）内的任意位置作标
         记。之后用户在对事务进行回滚操作（rolling back）时，就可以选择从当前
         执行位置回滚到事务内的任意一个保存点。例如用户可以在一系列复杂的更
         新（update）操作之间插入保存点，如果执行过程中一个语句出现错误，用
         户 可以回滚到错误之前的某个保存点，而不必重新提交所有的语句。
     
     *   在开发应用程序时也同样可以使用保存点（savepoint）。如果一个过程
         （procedure）内包含多个函数（function），用户可以在每个函数的开始位置
         创建一个保存点。当一个函数失败时， 就很容易将数据恢复到函数执行之前
         的状态，回滚（roll back）后可以修改参数重新调用函数，或执行相关的错误
         处理。
         当事务（transaction）被回滚（rollback）到某个保存点（savepoint）后，
         Oracle将释放由被回滚语句使用的锁。其他等待被锁资源的事务就可以继续
         执行。需要更新（update）被锁数据行的事务也可以继续执行。
         将事务（transaction）回滚（roll back）到某个保存点（savepoint）的过程如
         下：
         1. Oracle 回滚指定保存点之后的语句
         2. Oracle 保留指定的保存点，但其后创建的保存点都将被清除
         3. Oracle 释放此保存点后获得的表级锁（table lock）与行级锁（row
         lock），但之前的数据锁依然保留。
         被部分回滚的事务（transaction）依然处于活动状态，可以继续执行。
         一个事务（transaction）在等待其他事务的过程中，进行回滚（roll back）到
         某个保存点（savepoint）的操作不会释放行级锁（row lock）。为了避免事务
         因为不能获得锁而被挂起，应在执行 UPDATE 或 DELETE 操作前使用 FOR
         UPDATE ... NOWAIT 语句。（以上内容讲述的是回滚保存点之前所获得的
         锁。而在保存点之后获得的行级锁是会被释放的，同时保存点之后执行的
         SQL 语句也会被完全回滚）。
     *  一般来说保存点不建议大家自己去维护系统会默认帮我们维护，类似我们提交svn上svn会为我们记录我们提交的版本，可以支持版本回退，
     * 基本的扫盲知识点已经补充完毕，下面可以开始我们的测试阶段了
     * 先来看看我们FMDB中为我们提供的方法
     */
    [self.db beginTransaction];
    NSString *s_name=[NSString stringWithFormat:@"Andy%d",arc4random()%100];
    NSNumber *s_age=@(arc4random()%100);
    BOOL a = [self.db executeUpdate:@"INSERT INTO t_student(name,age,id) VALUES(?,?)",s_name,s_age,@51];
   
    BOOL b = [self.db executeUpdate:@"INSERT INTO t_student(name,age,id) VALUES(?,?)",s_name,s_age,@55];
    if(a*b){
        //如果都成功则提交修改数据库
        [self.db commit];
    }else{
        //否则的话回滚
        [self.db rollback];
    }
    
    
}

/**
 * 多线程并发操作中事务的使用
 * 使用场景我们需要把处理一种业务的几个操作绑定在一起，同生共死，必须全部成功或者全部失败的时候。
 */
-(void)transaction1{
    //fmdb封装方法
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *s_name=[NSString stringWithFormat:@"Andy%d",arc4random()%100];
            NSNumber *s_age=@(arc4random()%100);
             BOOL a = [self.db executeUpdate:@"INSERT INTO t_student(name,age,id) VALUES(?,?)",s_name,s_age,@51];
            if(!a){
                *rollback=YES;
            }
        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *s_name=[NSString stringWithFormat:@"Andy%d",arc4random()%100];
            NSNumber *s_age=@(arc4random()%100);
            BOOL a = [self.db executeUpdate:@"INSERT INTO t_student(name,age,id) VALUES(?,?)",s_name,s_age,@55];
            if(!a){
                *rollback=YES;
            }
        });
    }];
    
}

/**
 *  事务的其他好处
 *  除了能保证数据的一致性和完整性，事务对数据库的处理效率也有很大的帮助
 *  举个例子说：
 *  比如说a操作一次数据提交一次快，还是a所有操作完成之后再全部提交结果快？
 *  更通俗讲：a答应b生产500件商品，是每次生产一件就给b运送过去还是生产完500件一次送过去，大家肯定选择的时候后者嘛，都是一个道理。
 *  下面我们来测试一下数据库在批量操作的时候事务是不是可以做到性能优化
 */
-(void)transaction2{
    
    [self insertData:0 useTransaction:NO];
    NSDate *date1 = [NSDate date];
    [self insertData:500 useTransaction:NO];
    NSDate *date2 = [NSDate date];
    NSTimeInterval a = [date2 timeIntervalSince1970] - [date1 timeIntervalSince1970];
    NSLog(@"不使用事务插入500条数据用时%.3f秒",a);
    [self insertData:1000 useTransaction:YES];
    NSDate *date3 = [NSDate date];
    NSTimeInterval b = [date3 timeIntervalSince1970] - [date2 timeIntervalSince1970];
    NSLog(@"使用事务插入500条数据用时%.3f秒",b);
    
    
}
- (void)insertData:(int)fromIndex useTransaction:(BOOL)useTransaction
{
    [_db open];
    if (useTransaction) {
        [_db beginTransaction];
        BOOL isRollBack = NO;
        @try {
            for (int i = fromIndex; i<500+fromIndex; i++) {
                NSString *nId = [NSString stringWithFormat:@"%d",i];
                NSString *strName = [[NSString alloc] initWithFormat:@"student_%d",i];
                NSString *sql = @"INSERT INTO t_student(id,name) VALUES(?,?)";
                BOOL a = [_db executeUpdate:sql,nId,strName];
                if (!a) {
                    NSLog(@"插入失败1");
                }
            }
        }
        @catch (NSException *exception) {
            isRollBack = YES;
            [_db rollback];
        }
        @finally {
            if (!isRollBack) {
                [_db commit];
            }
        }
    }else{
        for (int i = fromIndex; i<500+fromIndex; i++) {
            NSString *nId = [NSString stringWithFormat:@"%d",i];
            NSString *strName = [[NSString alloc] initWithFormat:@"student_%d",i];
            NSString *sql = @"INSERT INTO t_student(id,name) VALUES(?,?)";
            BOOL a = [_db executeUpdate:sql,nId,strName];
            if (!a) {
                NSLog(@"插入失败2");
            }
        }
    }

    

    /**
     *  实验结果分析
     *  结果：
     *  2016-09-30 15:24:56.830 FMDB多线程操作、事务等进阶篇使用[9980:764454] 不使用事务插入500条数据用时0.723秒
     *  2016-09-30 15:24:57.460 FMDB多线程操作、事务等进阶篇使用[9980:764454] 使用事务插入500条数据用时0.630秒
     *  从实际数据上来看我们不难看出使用事务可以提高我们的数据操作的效率
     *  所以如果一次性操作的数据的数量比较大的话还是建议采用事务的方式去优化一下数据的I/O性能。
     */
    
    
    
}


-(void)createQueueTable{
    
    NSString *filePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"queue.sqlite"];
    //创建数据库，并加入到队列中，此时已经默认打开了数据库，无须手动打开，只需要从队列中去取数据库即可
    self.queue=[FMDatabaseQueue databaseQueueWithPath:filePath];
    //取出数据库，这里的db就是数据库，在数据库中创建表
    [self.queue inDatabase:^(FMDatabase *db) {
        //创建表
        BOOL createTableResult=[db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_student (id integer PRIMARY KEY AUTOINCREMENT,name text,age integer)"];
        if (createTableResult) {
            NSLog(@"创建表成功");
        }else{
            NSLog(@"创建表失败");
        }
    }];
    
    
}
-(void)rightTest{

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSTimer* timer3=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(dealTimer3) userInfo:nil repeats:YES];
        [timer3 fire];
        [[NSRunLoop currentRunLoop]run];
        
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSTimer* timer4=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dealTimer4) userInfo:nil repeats:YES];
        [timer4 fire];
        [[NSRunLoop currentRunLoop]run];
        
    });
    
    
    
}
-(void)wrongTest{
    //假设现在的场景是有一个数据需要实时上传并且实时的回滚显示
    //上传动作和查询动作都是异步的
    //也就是说存在同时操作同一个dataBase对象的情况。
    /**
     *  实验结果：
     *  FMDatabase <FMDatabase: 0x7ff611714470> is currently in use.
     *  内部封装提示当前的db对象正在使用，故抛出异常。
     *  默认是不支持多个线程同时操作同一个db对象的。
     *
     */
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSTimer* timer1=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(dealTimer1) userInfo:nil repeats:YES];
        [timer1 fire];
        [[NSRunLoop currentRunLoop]run];
        
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSTimer* timer2=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dealTimer2) userInfo:nil repeats:YES];
        [timer2 fire];
        [[NSRunLoop currentRunLoop]run];
        
    });
    
    
    
}
-(void)dealTimer4{
    //FMDatabaseQueue 的inDatabase方法将一个闭包传入进去，然后在闭包中操作数据库对象FMDatabase，不直接参与数据库的管理，所以不会出现上面的那个错误：
    //FMDatabase <FMDatabase: 0x7ff611714470> is currently in use.
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *s_name=[NSString stringWithFormat:@"Andy%d",arc4random()%100];
        NSNumber *s_age=@(arc4random()%100);
        [db executeUpdate:@"INSERT INTO t_student(name,age,id) VALUES(?,?)",s_name,s_age,@51];
    }];
   
}
-(void)dealTimer3{
    
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs=[db executeQuery:@"SELECT * FROM t_student WHERE age>?",@20];
        while ([rs next]) {
            int ID=[rs intForColumn:@"id"];
            NSString *NAME=[rs stringForColumn:@"name"];
            int AGE=[rs intForColumn:@"age"];
            NSLog(@"%d %@ %d",ID,NAME,AGE);
        }

    }];
    
}
-(void)dealTimer2{
    
    NSString *s_name=[NSString stringWithFormat:@"Andy%d",arc4random()%100];
    NSNumber *s_age=@(arc4random()%100);
    [self.db executeUpdate:@"INSERT INTO t_student(name,age,id) VALUES(?,?)",s_name,s_age,@51];
    
}
-(void)dealTimer1{
    
    FMResultSet *rs=[self.db executeQuery:@"SELECT * FROM t_student WHERE age>?",@20];
    while ([rs next]) {
        int ID=[rs intForColumn:@"id"];
        NSString *NAME=[rs stringForColumn:@"name"];
        int AGE=[rs intForColumn:@"age"];
        NSLog(@"%d %@ %d",ID,NAME,AGE);
    }

}
//增
- (IBAction)insert:(UIButton *)sender {
    
    for (int index=0; index<50; index++) {
        NSString *s_name=[NSString stringWithFormat:@"Andy%d",arc4random()%100];
        NSNumber *s_age=@(arc4random()%100);
        [self.db executeUpdate:@"INSERT INTO t_student(name,age,id) VALUES(?,?)",s_name,s_age,index];
    }
    
}
//删
- (IBAction)delete:(UIButton *)sender {
    
     [self.db executeUpdate:@"DELETE FROM t_student WHERE id=?",@1];
    
}
//改
- (IBAction)update:(UIButton *)sender {
    
    [self.db executeUpdate:@"UPDATE t_student SET name='Jack' WHERE id=?",@2];
}
//查
- (IBAction)select:(UIButton *)sender {
    
    //获取结果集，返回参数就是查询结果
    FMResultSet *rs=[self.db executeQuery:@"SELECT * FROM t_student WHERE age>?",@20];
    while ([rs next]) {
        int ID=[rs intForColumn:@"id"];
        NSString *NAME=[rs stringForColumn:@"name"];
        int AGE=[rs intForColumn:@"age"];
        NSLog(@"%d %@ %d",ID,NAME,AGE);
    }
    
}
//建表
-(void)createDataTable{
    
    NSString *filePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"fmdb.sqlite"];
    //创建数据库
    self.db=[FMDatabase databaseWithPath:filePath];
    //打开数据库
    if ([self.db open]) {
        NSLog(@"打开数据库成功");
        //创建表格，除了select外，所有的操作都是更新
        BOOL createTableResult=[self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_student (id integer PRIMARY KEY AUTOINCREMENT,name text,age integer)"];
        if (createTableResult) {
            NSLog(@"创建表成功");
        }else{
            NSLog(@"创建表失败");
        }
    }else{
        NSLog(@"打开数据库失败");
    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
