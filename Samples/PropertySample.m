//
//  PropertySample.m
//  RuntimeTest
//
//  Created by 胡金友 on 2017/9/14.
//
//

#import "PropertySample.h"
#import <objc/runtime.h>
#import <AppKit/AppKit.h>


@interface PropertyTestModel : NSObject

@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) NSInteger age;
@property (retain, nonatomic) NSString *job;

@end

@implementation PropertyTestModel

@end

@implementation PropertySample

+ (void)test
{
    [self logTest:[PropertyTestModel class]];
    
    
    printf("\n\n\n");
    
    
    
    objc_property_attribute_t rT = {"T", "@\"NSString\""};
    objc_property_attribute_t rC = {"C", ""};
    objc_property_attribute_t rV = {"V", "_job"};
    objc_property_attribute_t rAttribtues[] = {rT, rC, rV};
    
    class_replaceProperty([PropertyTestModel class], "job", rAttribtues, 3);
    
    objc_property_t property_t = class_getProperty([PropertyTestModel class], "job");
    
    const char *property_attributes = property_getAttributes(property_t);
    
    printf("修改后的job属性：%s\n\n", property_attributes);
    
    
    
    
    printf("\n\n\n\n--------------------------------------------------------------\n\n");
    printf("测试一下系统的类\n\n\n");
    
    
    [self logTest:[NSView class]];
}

+ (void)logTest:(Class)cls
{
    unsigned int property_count = 0;
    
    objc_property_attribute_t aT = {"T", "@\"NSString\""};
    objc_property_attribute_t aR = {"&", ""};
    objc_property_attribute_t aN = {"N", ""};
    objc_property_attribute_t aV = {"V", "_phoneNumber"};
    objc_property_attribute_t aAttributes[] = {aT, aR, aN, aV};
    
    class_addProperty(cls, "phoneNumber", aAttributes, 4);
    
    
    objc_property_t *property_list = class_copyPropertyList(cls, &property_count);
    for (NSInteger i = 0; i < property_count; i ++) {
        objc_property_t property_t = property_list[i];
        const char *property_name = property_getName(property_t);
        const char *property_attributes = property_getAttributes(property_t);
        
        printf("%s (%s)\n", property_name, property_attributes);
        
        unsigned int property_attribute_count = 0;
        objc_property_attribute_t *property_attribute_list = property_copyAttributeList(property_t, &property_attribute_count);
        for (unsigned int j = 0; j < property_attribute_count; j ++) {
            objc_property_attribute_t property_attribute_t = property_attribute_list[j];
            char *attributValue = property_copyAttributeValue(property_t, property_attribute_t.name);
            printf("    | %s --> %s\n", property_attribute_t.name, attributValue);
        }
    }
}

@end
