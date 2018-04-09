//
//  AllocationSample.m
//  RuntimeTest
//
//  Created by 胡金友 on 2017/9/15.
//
//

#import "AllocationSample.h"

/*
 
 // 创建一个实例
 id class_createInstance(Class cls, size_t extraBytes)
 // 在指定位置创建类实例
 id objc_constructInstance(Class cls, void *bytes)
 // 销毁类实例
 void *objc_destructInstance(id obj)
 // 创建新的类
 Class objc_allocateClassPair(Class superclass, const char *name, size_t extraBytes)
 // 注册创建的类
 void objc_registerClassPair(Class cls)
 // 用于KVO观察者
 Class objc_duplicateClass(Class original, const char *name, size_t extraBytes)
 // 销毁一个类及相关联的类
 void objc_disposeClassPair(Class cls)
 
 */

@implementation AllocationSample

@end
