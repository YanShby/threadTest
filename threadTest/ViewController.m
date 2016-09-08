//
//  ViewController.m
//  threadTest
//
//  Created by Yans on 16/9/6.
//  Copyright © 2016年 Yans. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic ,assign) NSUInteger num;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithRed:0.4879 green:0.8317 blue:0.8567 alpha:1.0];
    
    NSLog(@"--------%@",[NSThread currentThread]);
//    //串行
//    dispatch_queue_t queueA = dispatch_queue_create("queueA", NULL);
//    dispatch_queue_t queueB = dispatch_queue_create("queueB", NULL);
//    dispatch_queue_t queueC = dispatch_queue_create("queueC", NULL);
//    //deadLock
//    dispatch_sync(queueA, ^{      //同步: 不具备开启新线程的能力, 只能在当前线程执行任务.
//        NSLog(@"A-----%@",[NSThread currentThread]);
//        dispatch_sync(queueB, ^{
//            NSLog(@"B-----%@",[NSThread currentThread]);
//            dispatch_sync(queueC, ^{        //deadLock 对queueA而言, 这个任务在等第一个进入queueA的任务执行完, 而第一个任务又在等这个任务执行. 互相等待最后死锁.
//                NSLog(@"A-----%@",[NSThread currentThread]);
//            });
//        });
//    });
//    
//    dispatch_async(queueA, ^{
//        NSLog(@"ASYNC-A---%@",[NSThread currentThread]);
//        dispatch_async(queueB, ^{
//            NSLog(@"ASYNC-aB---%@",[NSThread currentThread]);
//        });
//        dispatch_async(queueC, ^{
//            NSLog(@"ASYNC-aC---%@",[NSThread currentThread]);
//        });
//    });

    
    
    [self asynSerial];
}

- (void)test {
    self.num = 100;
}

#pragma mark - 线程栗子

/*
 如果是在子线程中调用 同步函数 + 主队列, 那么没有任何问题
 */
- (void)syncMain2
{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        // block会在子线程中执行
        NSLog(@"%@", [NSThread currentThread]);
        
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_sync(queue, ^{
            // block一定会在主线程执行
            NSLog(@"%@", [NSThread currentThread]);
        });
    });
    NSLog(@"------------");
}
/*
 如果是在主线程中调用同步函数 + 主队列, 那么会导致死锁
 导致死锁的原因:
 sync函数是在主线程中执行的, 并且会等待block执行完毕. 先调用
 block是添加到主队列的, 也需要在主线程中执行. 后调用
 */
- (void)syncMain
{
    NSLog(@"%@", [NSThread currentThread]);
    // 主队列:
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    //  如果是调用 同步函数, 那么会等同步函数中的任务执行完毕, 才会执行后面的代码
    // 注意: 如果dispatch_sync方法是在主线程中调用的, 并且传入的队列是主队列, 那么会导致死锁
    dispatch_sync(queue, ^{
        NSLog(@"----------");
        NSLog(@"%@", [NSThread currentThread]);
    });
    NSLog(@"----------");
}
/*
 异步 + 主队列 : 不会创建新的线程, 并且任务是在主线程中执行
 */
- (void)asyncMain
{
    // 主队列:
    // 特点: 只要将任务添加到主队列中, 那么任务"一定"会在主线程中执行 \
    无论你是调用同步函数还是异步函数
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        NSLog(@"%@", [NSThread currentThread]);
    });
}
/*
 同步 + 并发 : 不会开启新的线程
 妻管严
 */
- (void)syncConCurrent
{
    // 1.创建一个并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    // 2.将任务添加到队列中
    dispatch_sync(queue, ^{
        NSLog(@"任务1  == %@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"任务2  == %@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"任务3  == %@", [NSThread currentThread]);
    });
    
    NSLog(@"---------");
}
/*
 同步 + 串行: 不会开启新的线程
 注意点: 如果是调用 同步函数, 那么会等同步函数中的任务执行完毕, 才会执行后面的代码
 */
- (void)syncSerial
{
    // 1.创建一个串行队列
    // #define DISPATCH_QUEUE_SERIAL NULL
    // 所以可以直接传NULL
    dispatch_queue_t queue = dispatch_queue_create("com.520it.lnj", NULL);

    // 2.将任务添加到队列中
    dispatch_sync(queue, ^{
        NSLog(@"任务1  == %@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"任务2  == %@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"任务3  == %@", [NSThread currentThread]);
    });
    
    NSLog(@"---------");
}
/*
 异步 +　串行：会开启新的线程
 但是只会开启一个新的线程
 注意: 如果调用 异步函数, 那么不用等到函数中的任务执行完毕, 就会执行后面的代码
 */
- (void)asynSerial
{
    // 1.创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("com.520it.lnj", DISPATCH_QUEUE_SERIAL);
    /*
     能够创建新线程的原因:
     我们是使用"异步"函数调用
     只创建1个子线程的原因:
     我们的队列是串行队列
     */
    // 2.将任务添加到队列中
    dispatch_async(queue, ^{
        NSLog(@"任务1  == %@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务2  == %@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务3  == %@", [NSThread currentThread]);
    });
    
    NSLog(@"-------- == %@",[NSThread currentThread]);
}

/*
 异步 + 并发 : 会开启新的线程
 如果任务比较多, 那么就会开启多个线程
 */
- (void)asynConcurrent
{
    /*
     执行任务
     dispatch_async
     dispatch_sync
     */
    
    /*
     第一个参数: 队列的名称
     第二个参数: 告诉系统需要创建一个并发队列还是串行队列
     DISPATCH_QUEUE_SERIAL :串行
     DISPATCH_QUEUE_CONCURRENT　并发
     */
    //    dispatch_queue_t queue = dispatch_queue_create("com.520it.lnj", DISPATCH_QUEUE_CONCURRENT);
    
    // 系统内部已经给我们提供好了一个现成的并发队列
    /*
     第一个参数: iOS8以前是优先级, iOS8以后是服务质量
     iOS8以前
     *  - DISPATCH_QUEUE_PRIORITY_HIGH          高优先级 2
     *  - DISPATCH_QUEUE_PRIORITY_DEFAULT:      默认的优先级 0
     *  - DISPATCH_QUEUE_PRIORITY_LOW:          低优先级 -2
     *  - DISPATCH_QUEUE_PRIORITY_BACKGROUND:
     
     iOS8以后
     *  - QOS_CLASS_USER_INTERACTIVE  0x21 用户交互(用户迫切想执行任务)
     *  - QOS_CLASS_USER_INITIATED    0x19 用户需要
     *  - QOS_CLASS_DEFAULT           0x15 默认
     *  - QOS_CLASS_UTILITY           0x11 工具(低优先级, 苹果推荐将耗时操作放到这种类型的队列中)
     *  - QOS_CLASS_BACKGROUND        0x09 后台
     *  - QOS_CLASS_UNSPECIFIED       0x00 没有设置
     
     第二个参数: 废物
     */
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    /*
     第一个参数: 用于存放任务的队列
     第二个参数: 任务(block)
     
     GCD从队列中取出任务, 遵循FIFO原则 , 先进先出
     输出的结果和苹果所说的原则不符合的原因: CPU可能会先调度其它的线程
     
     能够创建新线程的原因:
     我们是使用"异步"函数调用
     能够创建多个子线程的原因:
     我们的队列是并发队列
     */
    dispatch_async(queue, ^{
        NSLog(@"任务1  == %@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务2  == %@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务3  == %@", [NSThread currentThread]);
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
