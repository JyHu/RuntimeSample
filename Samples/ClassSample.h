//
//  ClassSample.h
//  RuntimeTest
//
//  Created by 胡金友 on 2017/9/15.
//
//

#import <Foundation/Foundation.h>

@interface ClassSample : NSObject

@end

/*
 
 id object_copy(id obj, size_t size)
 
 // 释放给定对象所占用的内存空间
 object_dispose(id obj)
 
 // 获取对象的类
 Class object_getClass(id obj)
 // 设置对象的类
 Class object_setClass(id obj, Class cls)
 // 是否是对象
 BOOL object_isClass(id obj)
 // 返回指定的类
 Class objc_getClass(const char *name)
 // 返回指定的元类
 Class objc_getMetaClass(const char *name)
 // 返回指定的类
 Class objc_lookUpClass(const char *name)
 // 返回指定的类
 Class objc_getRequiredClass(const char *name)
 // 返回已注册的类定义的列表
 int objc_getClassList(Class *buffer, int bufferCount)
 // 创建并返回一个指向所有已注册类的指针列表
 Class *objc_copyClassList(unsigned int *outCount)
 // 返回类的类名
 const char *class_getName(Class cls)
 // 是否是元类
 BOOL class_isMetaClass(Class cls)
 // 返回类的父类
 Class class_getSuperclass(Class cls)
 // 给类指定一个父类
 Class class_setSuperclass(Class cls, Class newSuper)
 // 返回类版本号
 int class_getVersion(Class cls)
 // 设置类版本号
 void class_setVersion(Class cls, int version)
 // 返回实例类的大小
 size_t class_getInstanceSize(Class cls)
 // 通过CoreFoundation's自由连接。不能自己调用此方法 ???????????????????????????????????????
 Class objc_getFutureClass(const char *name)
 
 */

