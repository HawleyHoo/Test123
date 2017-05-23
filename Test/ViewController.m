//
//  ViewController.m
//  Test
//
//  Created by 胡杨 on 2017/4/27.
//  Copyright © 2017年 net.fitcome.www. All rights reserved.
//

#import "ViewController.h"

#import "UIViewController+AssociatedObjects.h"
#import "HYTextField.h"

#import "ElfinsArray.h"

#import <objc/runtime.h>
#include <pthread.h>
#import <libkern/OSAtomic.h>

__weak NSString *string_weak_assign = nil;
__weak NSString *string_weak_retain = nil;
__weak NSString *string_weak_copy   = nil;


// html特殊字符
// =	 &#61;
// .	 &#46;
// (	 &#40;
// )	 &#41;
#define AUTOREALEASE_CASE 3
__weak NSString *string_weak = nil;
@interface ViewController ()<NSStreamDelegate>

@property (nonatomic,strong) NSString *filePath;

@property (nonatomic,assign) int location;

@end

@implementation ViewController
/*
__weak NSString *string_weak_ = nil;
- (void)viewDidLoad {
    [super viewDidLoad];
    // 我感觉是 iOS9中，[NSString stringWithFormat:@"leichunfeng"];  这样创建出来的对象是指向常量区的，不会销毁。
    // 场景 1
    //    NSString *string = [NSString stringWithFormat:@"leichunfeng"];
    //    string_weak_ = string;
    // 场景 2
    //    @autoreleasepool {
    //        NSString *string = [NSString stringWithFormat:@"leichunfeng"];
    //        string_weak_ = string;
    //    }
    // 场景 3
    NSString *string = nil;
    @autoreleasepool {
        string = @"huyang";
        //[NSString stringWithFormat:@"lei%@", @"chunfeng"];
        //[NSString stringWithFormat:@"leichunfeng"];
        string_weak_ = string;
    }
    NSLog(@"1 string: %@", string_weak_);
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"2 string: %@", string_weak_);
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"3 string: %@", string_weak_);
}
*/
 - (void)viewDidLoad {
     [super viewDidLoad];
     
     
     
     ElfinsArray *elfinsArr = [[ElfinsArray alloc] init];
     elfinsArr.count = 3;
     NSArray *elfins = [elfinsArr valueForKey:@"elfins"];
     //elfins为KVC代理数组
//     NSLog(@"%@", elfins);
     
//     self.associatedObject_assign = [NSString stringWithFormat:@"leichunfeng1"];
//     self.associatedObject_retain = [NSString stringWithFormat:@"leichunfeng2"];
//     self.associatedObject_copy   = [NSString stringWithFormat:@"leichunfeng3"];
//     string_weak_assign = self.associatedObject_assign;
//     string_weak_retain = self.associatedObject_retain;
//     string_weak_copy   = self.associatedObject_copy;
//     
//     for (int index = 0; index < 5; index++) {
//     CGFloat yy = 20 + index * 60;
//     HYTextField *textField = [HYTextField customInputTextFieldWithOriginY:yy];
//     if (index == 0) {
//         textField.allowedPaste = NO;
//     } else if (index == 1) {
//         textField.allowedSelect = NO;
//     } else if (index == 2) {
//         textField.allowedSelectAll = NO;
//     } else if (index == 3) {
//         textField.allowedCopy = NO;
//     } else if (index == 4) {
//         textField.allowedCut = NO;
//     }
//     
//         [self.view addSubview:textField];
//     }
 
 
//     [self isatest];
//     [self runLock];
//     [self dispatchSignal];
     
     [self createTestFile];
}


// 创建一个测试文件。

- (void)createTestFile{
    _filePath = NSHomeDirectory();
    _filePath = [_filePath stringByAppendingPathComponent:@"Documents/test_data.txt"];
    NSError *error;
    NSString *msg = @"测试数据，需要的测试数据，测试数据显示。";
    bool  isSuccess = [msg writeToFile:_filePath atomically:true encoding:NSUTF8StringEncoding error:&error];
    if (isSuccess) {
        NSLog(@"数据写入成功了");
    }else{
        NSLog(@"error is %@",error.description);
    }
    
    // 追加数据
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:_filePath];
    [handle seekToEndOfFile];
    NSString *newMsg = @".....我将添加到末尾你处";
    NSData *data = [newMsg dataUsingEncoding:NSUTF8StringEncoding];
    [handle writeData:data];
    [handle closeFile];
}



// NSOutPutStream 处理  写

- (IBAction)outPutStramAction:(id)sender {
    
    NSString *path = @"/Users/yubo/Desktop/stream_ios.txt";
    NSOutputStream *writeStream = [[NSOutputStream alloc]initToFileAtPath:path append:true];
    
    // 手动创建文件， 如果是系统创建的话， 格式编码不一样。
    bool flag = [@"Ios----->" writeToFile:path atomically:true encoding:NSUTF8StringEncoding error:nil];
    if (flag) {
        NSLog(@"创建成功");
    }
    
    writeStream.delegate = self;
    [writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [writeStream open];
}


// NSInPutStream 处理   读

- (IBAction)inPutStreamAction:(id)sender {
    
    NSInputStream *readStream = [[NSInputStream alloc]initWithFileAtPath:_filePath];
    [readStream setDelegate:self];
    
     //这个runLoop就相当于死循环，一直会对这个流进行操作。
    [readStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [readStream open];
}


#pragma mark  NSStreamDelegate代理

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    switch (eventCode) {
            
        case NSStreamEventHasSpaceAvailable:{ // 写
            
            NSString *content = [NSString stringWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:nil];
            NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
            
            NSOutputStream *writeStream = (NSOutputStream *)aStream;
            [writeStream write:data.bytes maxLength:data.length];
            [aStream close];
            
            // 用buf的还没成功
            
            //          [writeStream write:<#(nonnull const uint8_t *)#> maxLength:<#(NSUInteger)#>]; 乱码形式
            
            break;
        }
        case NSStreamEventHasBytesAvailable:{ // 读
            uint8_t buf[1024];
            NSInputStream *reads = (NSInputStream *)aStream;
            NSInteger blength = [reads read:buf maxLength:sizeof(buf)];
            if (blength != 0) {
                NSData *data = [NSData dataWithBytes:(void *)buf length:blength];
                NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"文件内容如下：----->%@",msg);
            }else{
                [aStream close];
            }
            break;
        }
        case NSStreamEventErrorOccurred:{// 错误处理
            
            NSLog(@"错误处理");
            break;
            
        }
        case NSStreamEventEndEncountered: {
            [aStream close];
            break;
        }
        case NSStreamEventNone:{// 无事件处理
            
            NSLog(@"无事件处理");
            break;
        }
        case  NSStreamEventOpenCompleted:{// 打开完成
            
            NSLog(@"打开文件");
            break;
        }
        default:
            break;
    }
}


- (void)dispatchSignal {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    // global queue 全局队列是一个并行队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_queue_t queue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    
    NSLog(@"begin task 1 %@", [NSThread currentThread]);
    dispatch_async(queue, ^{
        NSLog(@"async task 1 %@", [NSThread currentThread]);
        dispatch_semaphore_signal(semaphore);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"run task 1 %@", [NSThread currentThread]);
            //            sleep(2);
            NSLog(@"complete task 1 %@", [NSThread currentThread]);
        });
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            
//        });
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    
    NSLog(@"wait task 1 %@", [NSThread currentThread]);
    
    
    //任务2
    dispatch_async(queue, ^{
        NSLog(@"run task 2");
        sleep(2);
        NSLog(@"complete task 2");
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"wait task 2");
    
    
    //任务3
    dispatch_async(queue, ^{
        NSLog(@"run task 3");
        sleep(2);
        NSLog(@"complete task 3");
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"wait task 3");
}

- (void)runLock{
    CFTimeInterval timeBefore;
    CFTimeInterval timeCurrent;
    NSUInteger i;
    NSUInteger count = 1000*10000;//执行一千万次
    
    //@synchronized
    id obj = [[NSObject alloc] init];;
    timeBefore = CFAbsoluteTimeGetCurrent();
    for(i=0; i<count; i++){
        @synchronized(obj){
        }
    }
    timeCurrent = CFAbsoluteTimeGetCurrent();
    printf("@synchronized used : %f\n", timeCurrent-timeBefore);
    
    //NSLock
    NSLock *lock = [[NSLock alloc] init];
    timeBefore = CFAbsoluteTimeGetCurrent();
    for(i=0; i<count; i++){
        [lock lock];
        [lock unlock];
    }
    timeCurrent = CFAbsoluteTimeGetCurrent();
    printf("NSLock used : %f\n", timeCurrent-timeBefore);
    
    //NSCondition
    NSCondition *condition = [[NSCondition alloc] init];
    timeBefore = CFAbsoluteTimeGetCurrent();
    for(i=0; i<count; i++){
        [condition lock];
        [condition unlock];
    }
    timeCurrent = CFAbsoluteTimeGetCurrent();
    printf("NSCondition used : %f\n", timeCurrent-timeBefore);
    
    //NSConditionLock
    NSConditionLock *conditionLock = [[NSConditionLock alloc] init];
    timeBefore = CFAbsoluteTimeGetCurrent();
    for(i=0; i<count; i++){
        [conditionLock lock];
        [conditionLock unlock];
    }
    timeCurrent = CFAbsoluteTimeGetCurrent();
    printf("NSConditionLock used : %f\n", timeCurrent-timeBefore);
    
    //NSRecursiveLock
    NSRecursiveLock *recursiveLock = [[NSRecursiveLock alloc] init];
    timeBefore = CFAbsoluteTimeGetCurrent();
    for(i=0; i<count; i++){
        [recursiveLock lock];
        [recursiveLock unlock];
    }
    timeCurrent = CFAbsoluteTimeGetCurrent();
    printf("NSRecursiveLock used : %f\n", timeCurrent-timeBefore);
    
    //pthread_mutex
    pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    timeBefore = CFAbsoluteTimeGetCurrent();
    for(i=0; i<count; i++){
        pthread_mutex_lock(&mutex);
        pthread_mutex_unlock(&mutex);
    }
    timeCurrent = CFAbsoluteTimeGetCurrent();
    printf("pthread_mutex used : %f\n", timeCurrent-timeBefore);
    
    //dispatch_semaphore
    dispatch_semaphore_t semaphore =dispatch_semaphore_create(1);
    timeBefore = CFAbsoluteTimeGetCurrent();
    for(i=0; i<count; i++){
        dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
        dispatch_semaphore_signal(semaphore);
    }
    timeCurrent = CFAbsoluteTimeGetCurrent();
    printf("dispatch_semaphore used : %f\n", timeCurrent-timeBefore);
    
    //OSSpinLockLock
    OSSpinLock spinlock = OS_SPINLOCK_INIT;
    timeBefore = CFAbsoluteTimeGetCurrent();
    for(i=0; i<count; i++){
        OSSpinLockLock(&spinlock);
        OSSpinLockUnlock(&spinlock);
    }
    timeCurrent = CFAbsoluteTimeGetCurrent();
    printf("OSSpinLock used : %f\n", timeCurrent-timeBefore);
}

- (void)isatest {
    Class newclass = objc_allocateClassPair([UIView class], "HYView", 0);
    
    class_addMethod(newclass, @selector(loveView), (IMP)loveFunction, 0);
    
    objc_property_attribute_t type = {"T", "@\"NSString\""};
    objc_property_attribute_t ownership = { "C", ""};
    objc_property_attribute_t backingivar = { "V", "_privateName"};
    objc_property_attribute_t attrs[] = {type, ownership, backingivar};
    class_addProperty([newclass class], "name", attrs, 3);
    
    objc_registerClassPair(newclass);
    
    
    id newClassObjc = [[newclass alloc] init];
    [newClassObjc performSelector:@selector(loveView)];
    
    // 获取变量名列表
   unsigned int ivarcount = 0;
    Ivar *ivars = class_copyIvarList([newclass class], &ivarcount);
    for (const Ivar *p = ivars; p < ivars + ivarcount; ++p) {
        Ivar const ivar = *p;
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSLog(@" 变量名 %@", key);
    }
    u_int count = 0;
    Method *methods = class_copyMethodList([UIView class], &count);
    for (int i = 0; i < count; i++) {
        SEL name = method_getName(methods[i]);
        NSString *key = [NSString stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        NSLog(@" 方法名 %@", key);
    }
    free(methods);
    // 注意 运行时没有引用计数，所以没有等价的retain或release方法。如果从带有copy的函数得到一个值，就应调用free。如果用了不到copy单词的函数，千万不要用free();
}

void loveFunction(id self, SEL _cmd) {
    NSLog(@" isa %p", object_getClass([NSObject class]));
    NSLog(@" 对象 %p", [NSObject class]);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //    NSLog(@"self.associatedObject_assign: %@", self.associatedObject_assign); // Will Crash
    NSLog(@"self.associatedObject_retain: %@", self.associatedObject_retain);
    NSLog(@"self.associatedObject_copy:   %@", self.associatedObject_copy);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
