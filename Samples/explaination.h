//
//  explaination.h
//  RuntimeTest
//
//  Created by 胡金友 on 2017/9/18.
//
//

#ifndef explaination_h
#define explaination_h

#pragma mark - image
#pragma mark -

/**
 返回所有已经加载的Objective-C Framework和动态库

 @param outCount 库文件的数量
 @return 返回所有已经加载的Objective-C Framework和动态库
 */
const char **objc_copyImageNames(unsigned int *outCount);

/**
 获取一个类所在的库文件的名称

 @param cls 要查询的类
 @return 库文件的名称
 */
const char *class_getImageName(Class cls);

/**
 返回库文件中所有的类的名称

 @param image 要查询的类库
 @param outCount 类的数量
 @return 类名列表
 */
const char **objc_copyClassNamesForImage(const char *image, unsigned int *outCount);





#pragma mark - objc_property_t
#pragma mark -

/**
 获取一个类中所有的属性

 @param cls 要获取的类
 @param outCount 属性的数量
 @return 属性列表
 */
objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount);

/**
 根据给定的属性名称和类获取一个Property属性

 @param cls 所属的类
 @param name 属性的名称
 @return 获取到的Property属性
 */
objc_property_t class_getProperty(Class cls, const char *name);

/**
 动态的为一个类添加属性

 @param cls 要添加的类
 @param name 属性的名称
 @param attributes 属性
 @param attributeCount <#attributeCount description#>
 @return <#return value description#>
 */
BOOL class_addProperty(Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount)

/**
 <#Description#>

 @param cls <#cls description#>
 @param name <#name description#>
 @param attributes <#attributes description#>
 @param attributeCount <#attributeCount description#>
 */
void class_replaceProperty(Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount)

/**
 <#Description#>

 @param property <#property description#>
 @return <#return value description#>
 */
const char *property_getName(objc_property_t property)

/**
 <#Description#>

 @param property <#property description#>
 @return <#return value description#>
 */
const char *property_getAttributes(objc_property_t property)

/**
 <#Description#>

 @param property <#property description#>
 @param outCount <#outCount description#>
 @return <#return value description#>
 */
objc_property_attribute_t *property_copyAttributeList(objc_property_t property, unsigned int *outCount)

/**
 <#Description#>

 @param property <#property description#>
 @param attributeName <#attributeName description#>
 @return <#return value description#>
 */
char *property_copyAttributeValue(objc_property_t property, const char *attributeName)


#pragma mark - help methods
#pragma mark -

#pragma mark - help methods
#pragma mark -

#pragma mark - help methods
#pragma mark -

#pragma mark - help methods
#pragma mark -

#pragma mark - help methods
#pragma mark -

#pragma mark - help methods
#pragma mark -


#endif /* explaination_h */
