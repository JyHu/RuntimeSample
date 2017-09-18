//
//  MethodSample.m
//  RuntimeTest
//
//  Created by 胡金友 on 2017/9/14.
//
//

//http://blog.csdn.net/xietao3/article/details/51306808

#import "MethodSample.h"
#import <objc/runtime.h>
#import <objc/message.h>



// ########################################################################################################################
// ########################################################################################################################


@interface MethodTestModel : NSObject

- (void)sampleMethodWithArg1:(id)arg1 arg2:(NSInteger)arg2;

@end

@implementation MethodTestModel

- (void)sampleMethodWithArg1:(id)arg1 arg2:(NSInteger)arg2 {
    
}

- (NSArray *)sampleMethodWithArg1:(NSString *)arg1 arg2:(CGFloat)arg2 arg3:(void (^)(NSString *p1, NSInteger p2))arg3 {
    return nil;
}

@end

// ########################################################################################################################
// ########################################################################################################################


int dynamicMethod() {
    return 100;
}

@implementation MethodSample

+ (void)test
{
    printf("==============================================================================================\n");
    printf("            方法属性的测试\n");
    printf("==============================================================================================\n\n\n");
    
    
    
    unsigned int methodCount = 0;
    Method *method_list = class_copyMethodList([MethodTestModel class], &methodCount);
    for (NSInteger i = 0; i < methodCount; i ++) {
        Method method = method_list[i];
        if (i % 2 == 0) {
            [self logMethod:method];
        } else {
            [self logMethod2:method];
        }
    }
    
    printf("\n\n\n");
    printf("==============================================================================================\n");
    printf("            动态添加、调用方法的测试\n");
    printf("==============================================================================================\n\n\n");
    
    [self dynamicTest];
    
    printf("==============================================================================================\n");
    printf("            方法属性的测试\n");
    printf("==============================================================================================\n\n\n");
    
    [self IMPTest];
}

// ########################################################################################################################

+ (void)logMethod:(Method)method
{
    SEL sel = method_getName(method);
    char *return_type = method_copyReturnType(method);
    const char *method_type_encoding = method_getTypeEncoding(method);
    
    printf("(%s)%s -> %s\n", return_type, sel_getName(sel), method_type_encoding);
    
    unsigned int arguments_count = method_getNumberOfArguments(method);
    for (unsigned int j = 0; j < arguments_count; j ++) {
        char *argument_type = method_copyArgumentType(method, j);
        printf("    | %s\n", argument_type);
    }
}

+ (void)logMethod2:(Method)method
{
    char return_type[256];
    method_getReturnType(method, return_type, 256);

    printf("\n(%s)%s\n", return_type, sel_getName(method_getName(method)));
    
    printf("argument at index :");
    unsigned int arguments_count = method_getNumberOfArguments(method);
    for (unsigned int i = 0; i < arguments_count; i ++) {
        char arg[256];
        method_getArgumentType(method, i, arg, 256);
        printf("    %d - %s\n", i, arg);
    }
}

// ########################################################################################################################

+ (void)dynamicTest
{
    MethodTestModel *testModel = [[MethodTestModel alloc] init];
    
    // 添加一个C类型的方法
    BOOL addRes = class_addMethod([testModel class], NSSelectorFromString(@"dynamicMethod"), (IMP)dynamicMethod,"@@:");
    printf("动态增加方法%s\n\n", addRes ? "成功" : "失败");
    int dynamicReturnValue = ((int (*)(id, SEL))objc_msgSend)((id)testModel, NSSelectorFromString(@"dynamicMethod"));
    printf("动态添加方法的调用结果 : %d\n\n", dynamicReturnValue);
    
    
    // 添加一个当前类里的方法
    class_addMethod([testModel class], @selector(dynamicMethod:arg2:), class_getMethodImplementation([self class], @selector(dynamicMethod:arg2:)), "v@:@q");
    BOOL responseAdded = class_respondsToSelector([testModel class], @selector(dynamicMethod:arg2:));
    printf("测试类%s可以响应动态添加的-dynamicMethod方法\n\n", responseAdded ? "" : "不");
    // 动态执行
    ((void (*)(id, SEL, id, NSInteger)) objc_msgSend)((id)testModel, @selector(dynamicMethod:arg2:), @"arg1", 2);
    
    // 直接获取方法
    Method dynamicMethod = class_getInstanceMethod([testModel class], @selector(dynamicMethod:arg2:));
    if (dynamicMethod != NULL) {
        struct objc_method_description *method_description = method_getDescription(dynamicMethod);
        if (method_description != NULL) {
            printf("Method Description : %s -- %s\n\n", method_description -> types, sel_getName(method_description -> name));
        }
    }
    
    Method testMethod = class_getClassMethod([self class], @selector(dynamicTest));
    if (testMethod) {
        struct objc_method_description *method_description = method_getDescription(testMethod);
        if (method_description) {
            printf("Method Description : %s -- %s\n\n", method_description -> types, sel_getName(method_description -> name));
        }
    }
    
    Method testMethod1 = class_getInstanceMethod([self class], @selector(dynamicTest));
    if (!testMethod1) {
        printf("Method Description : 获取不了类方法\n\n");
    }
}

- (void)dynamicMethod:(id)arg1 arg2:(NSInteger)arg2
{
    printf("-%s\n\n", sel_getName(_cmd));
}

// ########################################################################################################################

+ (void)IMPTest
{
    MethodSample *sample = [[MethodSample alloc] init];
    
    Method method1 = class_getInstanceMethod([sample class], @selector(replace_imp_1));
    Method method2 = class_getInstanceMethod([sample class], @selector(replace_imp_2));
    // 替换两个方法的实现
    method_exchangeImplementations(method1, method2);
    
    [sample replace_imp_1];
    [sample replace_imp_2];

    printf("call replace_imp_1 --> %s\n\n", [sample replace_imp_1]);
    printf("call replace_imp_2 --> %s\n\n", [sample replace_imp_2]);
    
    IMP imp_3 = imp_implementationWithBlock(^const char * () {
        return "rplaced : replace_imp_3";
    });
    Method i_method_1 = class_getInstanceMethod([sample class], @selector(replace_imp_1));
    // 设置方法的实现
    method_setImplementation(i_method_1, imp_3);
    
    printf("call replace_imp_1 --> %s\n\n", [sample replace_imp_1]);
    
    // 获取返回值为结构体的方法
    Method struct_method = class_getInstanceMethod([self class], @selector(impRect1:));
    printf("struct method encoding types : %s\n\n", method_getTypeEncoding(struct_method));
    
    // 获取返回值为结构体的方法实现
    IMP struct_imp_1 = class_getMethodImplementation_stret([self class], @selector(impRect1:));
    // 替换一个方法的实现
    class_replaceMethod([self class], @selector(impRect2:), struct_imp_1, "{CGRect={CGPoint=dd}{CGSize=dd}}@:q");
    NSLog(@"%@", NSStringFromRect([sample impRect1:1]));
    NSLog(@"%@", NSStringFromRect([sample impRect2:1]));
}

- (const char *)replace_imp_1
{
    return "rplaced : replace_imp_1";
}

- (const char *)replace_imp_2
{
    return "rplaced : replace_imp_2";
}

- (NSRect)impRect1:(NSInteger)t {
    return NSMakeRect(t, t, t, t);
}

- (NSRect)impRect2:(NSInteger)t {
    return NSMakeRect(t * 2, t * 2, t * 2, t * 2);
}

@end











