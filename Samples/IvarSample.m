//
//  IvarSample.m
//  RuntimeTest
//
//  Created by 胡金友 on 2017/9/15.
//
//

#import "IvarSample.h"
#import <objc/runtime.h>
#import <objc/message.h>


@interface IvarTestModel : NSObject

@property (assign, nonatomic) NSInteger arg;
@property (retain, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *school;

//@property (weak, nonatomic) IvarTestModel *model;

@end

@implementation IvarTestModel

@end

/*
 
 // 设置对象变量的值
 void object_setIvarWithStrongDefault(id obj, Ivar ivar, id value)
 // 更改实例变量的值，不支持ARC
 Ivar object_setInstanceVariable(id obj, const char *name, void *value)
 // 更改实例变量的值，不支持ARC
 Ivar object_setInstanceVariableWithStrongDefault(id obj, const char *name, void *value)
 // 获取对象的值，不支持arc
 Ivar object_getInstanceVariable(id obj, const char *name, void **outValue)

 // 只能在 objc_allocateClassPair 和 objc_registerClassPair之间调用，而不能给一个已经存在的类添加实例变量；
 void class_setIvarLayout(Class cls, const uint8_t *layout)
 void class_setWeakIvarLayout(Class cls, const uint8_t *layout)
 
 */

@implementation IvarSample

// http://blog.csdn.net/junjun150013652/article/details/48436329

- (void)dynamicMethod
{
    NSLog(@"you call me : %@", NSStringFromSelector(_cmd));
}


+ (void)test
{
    Class DynamicClass = objc_allocateClassPair([NSObject class], "DynamicClass", 0);
    class_addIvar(DynamicClass, "_name", sizeof(NSString *), log(sizeof(NSString *)), "@v:");
    class_addMethod(DynamicClass, @selector(dynamicMethod), class_getMethodImplementation([self class], @selector(dynamicMethod)), "v@:");
    objc_registerClassPair(DynamicClass);
    
    id obj = [[DynamicClass alloc] init];
    object_setIvar(obj, class_getInstanceVariable([DynamicClass class], "_name"), @"mike");
    NSLog(@"dynamic property name : %@", object_getIvar(obj, class_getInstanceVariable([DynamicClass class], "_name")));
    [obj performSelector:@selector(dynamicMethod)];
    
    
    
    
    
    IvarTestModel *testModel = ((IvarTestModel * (*)(id, SEL))objc_msgSend)((id)[IvarTestModel class], @selector(alloc));
    testModel = ((IvarTestModel * (*)(id, SEL))objc_msgSend)((id)testModel, @selector(init));
    
    
    
    Ivar argIvar = class_getInstanceVariable([testModel class], "_arg");
    object_setIvar(testModel, argIvar, (id)@120);
    
    id arg = object_getIvar(testModel, argIvar);
    NSLog(@"arg : %@", arg);
    
    
    // https://stackoverflow.com/questions/1980703/what-does-class-getclassvariable-do
    Ivar isaIvar = class_getClassVariable([testModel class], "isa");
    printf("isa : %s, encoding : %s, offset : %td\n\n", ivar_getName(isaIvar), ivar_getTypeEncoding(isaIvar), ivar_getOffset(isaIvar));
    
    
    [self logStrongLayout];
    [self logWeakLayout];
    
    unsigned int ivar_count = 0;
    Ivar *ivar_list = class_copyIvarList([testModel class], &ivar_count);
    for (unsigned int i = 0; i < ivar_count; i ++) {
        Ivar ivar = ivar_list[i];
        const char *ivar_name = ivar_getName(ivar);
        const char *ivar_type_encoding = ivar_getTypeEncoding(ivar);
        ptrdiff_t diff_t = ivar_getOffset(ivar);
        
        printf("%s\n", ivar_name);
        printf("    | %s\n", ivar_type_encoding);
        printf("    | %td\n", diff_t);
    }
}

+ (void)logStrongLayout
{
    const uint8_t *ivar_layout = class_getIvarLayout([IvarTestModel class]);
    if (ivar_layout != NULL) {
        int strong_index = 0;
        uint8_t value = ivar_layout[strong_index];
        printf("strong layout :\n");
        while (value != 0x0) {
            printf("\\x%02x",value);
            value = ivar_layout[++strong_index];
        }
    }
    
    printf("\n\n\n");
}

+ (void)logWeakLayout
{
    const uint8_t *weak_ivar_layout = class_getWeakIvarLayout([IvarTestModel class]);
    if (weak_ivar_layout != NULL) {
        printf("weak layout :\n");
        int weak_index = 0;
        uint8_t value = weak_ivar_layout[weak_index];
        while (value != 0x0) {
            printf("\\x%02x",value);
            value = weak_ivar_layout[++weak_index];
        }
    } else {
        printf("no weak layout info");
    }
    
    printf("\n\n\n");
}

@end
