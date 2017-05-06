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
@interface ViewController ()

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
     NSLog(@"%@", elfins);
     
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
 
 
     [self isatest];
 
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
