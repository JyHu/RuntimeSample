//
//  ProtocolSample.m
//  RuntimeTest
//
//  Created by 胡金友 on 2017/9/15.
//
//

#import "ProtocolSample.h"
#import <objc/runtime.h>


@protocol TestProtocol0 <NSObject>
@optional
- (void)methodInProtocol0:(id)arg;
@property (assign, nonatomic) NSInteger propertyInProtocol0;
@end


@protocol TestProtocol1 <NSObject>
@optional
- (void)methodInProtocol1:(id)arg;
@property (assign, nonatomic) NSInteger propertyInProtocol1;
@end


@protocol TestProtocol2 <TestProtocol1>
@required
- (void)protocol2InstanceRequiredMethod:(id)arg;
+ (void)protocol2ClassRequiredMethod:(id)arg;
@optional
- (void)protocol2InstanceOptionalMethod:(id)arg;
+ (void)protocol2ClassOptionalMethod:(id)arg;
@property (assign, nonatomic) NSInteger propertyInProtocol2;
@end


@protocol TestProtocol3 <NSObject>
@end


@interface ProtocolTestModel : NSObject <TestProtocol2, TestProtocol0>
@end
@implementation ProtocolTestModel
- (void)protocol2InstanceRequiredMethod:(id)arg {}
+ (void)protocol2ClassRequiredMethod:(id)arg {}
@end



// #######################################################################################################################################
// #######################################################################################################################################



@implementation ProtocolSample

+ (void)test
{
    [self testConfirm];
    
    printf("\n##############################################################################\n\n\n");
    
    [self testSample];
    
    printf("\n##############################################################################\n\n\n");
    
    [self testDynamic];
}

+ (void)testDynamic
{
    /**
     http://www.informit.com/articles/article.aspx?p=1843893
     If you call objc_allocateProtocol() and then objc_registerProtocol(), the next time you try to call objc_allocateProtocol() with the same protocol name, it will return NULL, as you'd expect; you can't create two protocols with the same name. However, if you call objc_allocateProtocol() twice (perhaps in two threads) with the same argument, it will return two protocols. When you try to register them, the registration will succeed in both cases, and the second call will replace the first. This is almost certainly not the intended behavior.
     */
    Protocol *protocol = objc_allocateProtocol("TestProtocol4");
    
    objc_property_attribute_t attributes[] = {{"T", "@\"NSString\""}, {"&"}, {"N"}, {"V", "_propertyOfProtocol4"}};
    
    // 动态的往protocol中添加属性
#warning - 动态添加属性有问题
    protocol_addProperty(protocol, "propertyOfProtocol4", attributes, 4, NO, NO);
    
    objc_property_t property_t = protocol_getProperty(protocol, "propertyOfProtocol4", NO, NO);
    
    if (property_t) {
        printf("获取添加的属性%s %s\n", property_getName(property_t), property_getAttributes(property_t));
    } else {
        printf("获取添加的属性propertyOfProtocol4失败\n");
    }
    
    
    // =================================================================================================================
    
    
    // 动态的往protocol中添加方法
    protocol_addMethodDescription(protocol, @selector(dynamicMethod:arg2:), "q@:@q", YES, YES);
    struct objc_method_description method_description_1 = protocol_getMethodDescription(protocol, @selector(dynamicMethod:arg2:), YES, YES);
    if (method_description_1.name == NULL) {
        printf("获取动态添加的方法失败\n");
    } else {
        printf("获取动态添加的方法成功 ： %s - %s\n", sel_getName(method_description_1.name), method_description_1.types);
    }
    
    struct objc_method_description method_description_2 = protocol_getMethodDescription(protocol, @selector(dynamicMethod:arg2:), NO, YES);
    if (method_description_2.name == NULL) {
        printf("获取动态添加的方法失败\n\n");
    } else {
        printf("获取动态添加的方法成功 ： %s - %s\n\n", sel_getName(method_description_2.name), method_description_2.types);
    }
    
    
    // =================================================================================================================
    
    
    printf("\n------------------测试给类添加协议\n\n");
    
    
    unsigned int protocol_count = 0;
    Protocol * __unsafe_unretained *protocolList1 = class_copyProtocolList([ProtocolTestModel class], &protocol_count);
    printf("给类ProtocolTestModel添加协议**前**类实现的协议列表：\n");
    for (unsigned int i = 0; i < protocol_count; i ++) {
        printf("    |- %s\n", protocol_getName(protocolList1[i]));
    }
    
    class_addProtocol([ProtocolTestModel class], @protocol(TestProtocol3));
    Protocol * __unsafe_unretained *protocolList2 = class_copyProtocolList([ProtocolTestModel class], &protocol_count);
    printf("给类ProtocolTestModel添加协议**后**类实现的协议列表：\n");
    for (unsigned int i = 0; i < protocol_count; i ++) {
        printf("    |- %s\n", protocol_getName(protocolList2[i]));
    }
    
    
    // =================================================================================================================
    
    
    printf("\n------------------测试给未注册的协议添加协议\n\n");
    
    
    Protocol *__unsafe_unretained *protocolList3 = protocol_copyProtocolList(protocol, &protocol_count);
    printf("给协议TestProtocol4添加协议**前**协议实现的协议列表：\n");
    for (unsigned int i = 0; i < protocol_count; i ++) {
        printf("    |- %s\n", protocol_getName(protocolList3[i]));
    }
    
    protocol_addProtocol(protocol, @protocol(TestProtocol3));
    Protocol *__unsafe_unretained *protocolList4 = protocol_copyProtocolList(protocol, &protocol_count);
    printf("给协议TestProtocol4添加协议**后**协议实现的协议列表：\n");
    for (unsigned int i = 0; i < protocol_count; i ++) {
        printf("    |- %s\n", protocol_getName(protocolList4[i]));
    }
    
    
    // =================================================================================================================
    
    
    printf("\n------------------测试给已注册的协议添加协议\n\n");
    
    Protocol *__unsafe_unretained *protocolList5 = protocol_copyProtocolList(@protocol(TestProtocol2), &protocol_count);
    printf("给协议TestProtocol2添加协议**前**协议实现的协议列表：\n");
    for (unsigned int i = 0; i < protocol_count; i ++) {
        printf("    |- %s\n", protocol_getName(protocolList5[i]));
    }
    
    protocol_addProtocol(@protocol(TestProtocol2), @protocol(TestProtocol3));
    Protocol *__unsafe_unretained *protocolList6 = protocol_copyProtocolList(@protocol(TestProtocol2), &protocol_count);
    printf("给协议TestProtocol2添加协议**后**协议实现的协议列表：\n");
    for (unsigned int i = 0; i < protocol_count; i ++) {
        printf("    |- %s\n", protocol_getName(protocolList6[i]));
    }
    
    // 向系统注册一个protocol，注册完以后就不可更改
    objc_registerProtocol(protocol);
    
    printf("\n\n");
}

- (NSInteger)dynamicMethod:(id)arg1 arg2:(NSInteger)arg2
{
    return 1;
}

// #######################################################################################################################################



+ (void)testConfirm
{
    BOOL protocolEqual1 = protocol_isEqual(objc_getProtocol("TestProtocol2"), @protocol(TestProtocol2));
    BOOL protocolEqual2 = protocol_isEqual(@protocol(TestProtocol1), @protocol(TestProtocol2));
    printf("TestProtocol2和TestProtocol2 %s\n", protocolEqual1 ? "相同" : "不同");
    printf("TestProtocol1和TestProtocol2 %s\n\n", protocolEqual2 ? "相同" : "不同");
    
    BOOL confirmTo1 = class_conformsToProtocol([ProtocolTestModel class], @protocol(TestProtocol1));
    BOOL confirmTo2 = class_conformsToProtocol([ProtocolTestModel class], @protocol(TestProtocol2));
    printf("ProtocolTestModel %s confirm to TestProtocol1\n", confirmTo1 ? "" : "NOT");
    printf("ProtocolTestModel %s confirm to TestProtocol2\n\n", confirmTo2 ? "" : "NOT");
    
    BOOL confirmTo21 = protocol_conformsToProtocol(@protocol(TestProtocol2), @protocol(TestProtocol1));
    BOOL confirmTo20 = protocol_conformsToProtocol(@protocol(TestProtocol2), @protocol(TestProtocol0));
    printf("TestProtocol2 is %s conforms to TestProtocol1\n", confirmTo21 ? "" : "NOT");
    printf("TestProtocol2 is %s conforms to TestProtocol0\n\n", confirmTo20 ? "" : "NOT");
    
    printf("\n\n");
    
}


// #######################################################################################################################################



+ (void)testSample
{
    unsigned int protocolCount = 0;
    Protocol * __unsafe_unretained *protocolList = class_copyProtocolList([ProtocolTestModel class], &protocolCount);
    for (unsigned int i = 0; i < protocolCount; i ++) {
        Protocol *protocol = protocolList[i];
        
        printf("%s\n", protocol_getName(protocol));
        
        [self logProtocol:protocol isRequired:YES isInstanceMethod:YES];
        [self logProtocol:protocol isRequired:YES isInstanceMethod:NO];
        [self logProtocol:protocol isRequired:NO isInstanceMethod:YES];
        [self logProtocol:protocol isRequired:NO isInstanceMethod:NO];
        
        [self logPropertyList:protocol];
        
        [self logProperty:protocol isRequired:YES isInstanceMethod:YES];
        [self logProperty:protocol isRequired:YES isInstanceMethod:NO];
        [self logProperty:protocol isRequired:NO isInstanceMethod:NO];
        [self logProperty:protocol isRequired:NO isInstanceMethod:YES];
        
        printf("\n\n");
    }
}

+ (void)logProtocol:(Protocol*)protocol isRequired:(BOOL)isRequired isInstanceMethod:(BOOL)isInstanceMethod
{
    unsigned int method_description_count = 0;
    struct objc_method_description *method_description_list = protocol_copyMethodDescriptionList(protocol, isRequired, isInstanceMethod, &method_description_count);
    printf("    Method  -->  Required:%s , Instance:%s\n", isRequired ? "YES" : "NO", isInstanceMethod ? "YES" : "NO");
    for (unsigned int j = 0; j < method_description_count; j ++) {
        struct objc_method_description method_description = method_description_list[j];
        printf("     |-- %s -- %s\n", sel_getName(method_description.name), method_description.types);
    }
}

+ (void)logPropertyList:(Protocol *)protocol
{
    unsigned int property_count = 0;
    objc_property_t *property_list = protocol_copyPropertyList(protocol, &property_count);
    printf("    Property  -->  protocol_copyPropertyList1\n");
    for (unsigned int i = 0; i < property_count; i ++) {
        objc_property_t property_t = property_list[i];
        printf("     |-- %s     %s\n", property_getName(property_t), property_getAttributes(property_t));
    }
}

+ (void)logProperty:(Protocol *)protocol isRequired:(BOOL)isRequired isInstanceMethod:(BOOL)isInstanceMethod
{
    unsigned int property_count = 0;
    objc_property_t *property_list = protocol_copyPropertyList2(protocol, &property_count, isRequired, isInstanceMethod);
    printf("    Property  -->  protocol_copyPropertyList2  -->  Required:%s , Instance:%s\n", isRequired ? "YES" : "NO", isInstanceMethod ? "YES" : "NO");
    for (unsigned int i = 0; i < property_count; i ++) {
        objc_property_t property_t = property_list[i];
        printf("     |-- %s     %s\n", property_getName(property_t), property_getAttributes(property_t));
    }
}

@end










