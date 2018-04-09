//
//  OtherSample.m
//  RuntimeTest
//
//  Created by 胡金友 on 2017/9/15.
//
//

#import "OtherSample.h"


/*
 
 // 返回指定sel的方法的名称
 const char *sel_getName(SEL sel)
 // 注册一个Objective-C运行时系统的方法名称
 SEL sel_registerName(const char *str)
 // 比较两个selector是否相等
 BOOL sel_isEqual(SEL lhs, SEL rhs)
 sel_getUid     注册方法
 
 
 
 
 
 // 当发现突变的foreach迭代过程中时插入编译器
 void objc_enumerationMutation(id obj)
 OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0);
 // 设置当前突变的处理程序
 void objc_setEnumerationMutationHandler(void (*handler)(id))
 // 设置函数调用objc_msgForward
 void objc_setForwardHandler(void *fwd, void *fwd_stret)
 // 创建一个当调用此方法时调用指定块的函数指针
 IMP imp_implementationWithBlock(id block)
 // 返回一个使用imp_implementationWithBlock创建的与块相关的函数指针
 id imp_getBlock(IMP anImp)
 // 移除与函数指针相关联的块
 BOOL imp_removeBlock(IMP anImp)
 
 
 
 
 // 加载弱指针引用的对象并返回它
 id objc_loadWeak(id *location)
 // 存储_weak变量的新值
 id objc_storeWeak(id *location, id obj)
 
 */


@implementation OtherSample

@end
