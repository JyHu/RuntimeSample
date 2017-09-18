//
//  AUURuntimeViewController.m
//  RuntimeTest
//
//  Created by 胡金友 on 2017/9/18.
//
//

#import "AUURuntimeViewController.h"

@implementation AUURuntimeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.image_name != NULL) {
        [self loadLib];
    } else if (self.class_name != NULL) {
        [self loadClass];
    } else if (self.protocol) {
        [self loadProtocol];
    } else if (self.loadProtocols) {
        [self loadProtocolList];
    } else {
        [self loadLibs];
    }
}

/**
 测试加载所有库
 */
- (void)loadLibs
{
    self.title = @"Libraries";
    
    unsigned int image_count = 0;
    const char **image_name_list = objc_copyImageNames(&image_count);
    NSMutableArray *imagesArr = [[NSMutableArray alloc] init];
    for (unsigned int i = 0; i < image_count; i ++) {
        [imagesArr addObject:[self imageCellObjectWithImageName:image_name_list[i]]];
    }
    
    [self.tableModel addObjectsFromArray:[imagesArr sorted]];
}

/**
 测试加载所有协议
 */
- (void)loadProtocolList
{
    self.title = @"Protocols";
    
    unsigned int protocol_count = 0;
    Protocol * __unsafe_unretained * protocol_list = objc_copyProtocolList(&protocol_count);
    if (protocol_count > 0) {
        NSMutableArray *protocols = [[NSMutableArray alloc] init];
        for (unsigned int i = 0; i < protocol_count; i ++) {
            [protocols addObject:[self protocolCellObjectWithProtocol:protocol_list[i]]];
        }
        [self.tableModel addObjectsFromArray:[protocols sorted]];
    }
}

/**
 测试加载指定库
 */
- (void)loadLib
{
    self.title = @"Library";
    self.navigationItem.prompt = [[[NSString stringWithUTF8String:self.image_name] componentsSeparatedByString:@"/"] lastObject];
    
    [self.tableModel appendSectionHeaderWithTitle:@"非私有类"];
    [self.tableModel appendSectionHeaderWithTitle:@"私有类"];
    
    unsigned int class_count = 0;
    const char **class_names = objc_copyClassNamesForImage(self.image_name, &class_count);
    
    NSMutableArray *publicClasses = [[NSMutableArray alloc] init];
    NSMutableArray *privateClasses = [[NSMutableArray alloc] init];
    
    for (unsigned int i = 0; i < class_count; i ++) {
        const char *class_name = class_names[i];
        
        __weak AUURuntimeViewController *weakSelf = self;
        
        NITitleCellObject *object = [self.tableActions attachToObject:[NITitleCellObject objectWithTitle:[NSString stringWithUTF8String:class_name]] tapBlock:^BOOL(id object, id target, NSIndexPath *indexPath) {
            __strong AUURuntimeViewController *strongSelf = weakSelf;
            AUURuntimeViewController *clsVC = [[AUURuntimeViewController alloc] init];
            clsVC.class_name = class_name;
            [strongSelf.navigationController pushViewController:clsVC animated:YES];
            return YES;
        }];
        
        if ([[NSString stringWithUTF8String:class_name] hasPrefix:@"_"]) {
            [privateClasses addObject:object];
        } else  {
            [publicClasses addObject:object];
        }
    }
    
    [self.tableModel addObjectsFromArray:[publicClasses sorted] toSection:0];
    [self.tableModel addObjectsFromArray:[privateClasses sorted] toSection:1];
}

/**
 测试加载类中的所有协议、属性、方法
 */
- (void)loadClass
{
    Class cls = objc_getClass(self.class_name);
    
    self.title = @"Class";
    self.navigationItem.prompt = [NSString stringWithUTF8String:self.class_name];
    
    
    __weak AUURuntimeViewController *weakSelf = self;
    
    
    const char *image_name = class_getImageName(cls);
    if (image_name != NULL) {
        [self.tableModel appendSectionHeaderWithTitle:@"所在库"];
        [self.tableModel addObject:[self imageCellObjectWithImageName:image_name]];
    }
    
    Class supCls = class_getSuperclass(cls);
    if (supCls) {
        [self.tableModel appendSectionHeaderWithTitle:@"父类"];
        [self.tableModel addObject:[self.tableActions attachToObject:[NITitleCellObject objectWithTitle:[NSString stringWithUTF8String:class_getName(supCls)]] tapBlock:^BOOL(id object, id target, NSIndexPath *indexPath) {
            
            __strong AUURuntimeViewController *strongSelf = weakSelf;
            
            AUURuntimeViewController *clsVC = [[AUURuntimeViewController alloc] init];
            clsVC.class_name = class_getName(supCls);
            [strongSelf.navigationController pushViewController:clsVC animated:YES];
            
            return YES;
        }]];
    }
    
    
    unsigned int protocol_count = 0;
    Protocol *__unsafe_unretained * protocol_list = class_copyProtocolList(cls, &protocol_count);
    if (protocol_count > 0) {
        [self.tableModel appendSectionHeaderWithTitle:@"协议"];
        NSMutableArray *protocolsArr = [[NSMutableArray alloc] init];
        for (unsigned int i = 0; i < protocol_count; i ++) {
            [protocolsArr addObject:[self protocolCellObjectWithProtocol:protocol_list[i]]];
        }
        [self.tableModel addObjectsFromArray:[protocolsArr sorted]];
    }
    
    unsigned int property_count = 0;
    objc_property_t *property_list = class_copyPropertyList(cls, &property_count);
    if (property_count > 0) {
        [self.tableModel appendSectionHeaderWithTitle:@"属性"];
        NSMutableArray *propertyArr = [[NSMutableArray alloc] init];
        for (unsigned int i = 0; i < property_count; i ++) {
            [propertyArr addObject:[self propertyCellObjectWithProperty:property_list[i]]];
        }
        [self.tableModel addObjectsFromArray:[propertyArr sorted]];
    }
    
    unsigned int method_count = 0;
    Method *method_list = class_copyMethodList(cls, &method_count);
    if (method_count > 0) {
        [self.tableModel appendSectionHeaderWithTitle:@"方法"];
        NSMutableArray *methodsArr = [[NSMutableArray alloc] init];
        for (unsigned int i = 0; i < method_count; i ++) {
            Method method = method_list[i];
            [methodsArr addObject:[self.tableActions attachToObject:[NITitleCellObject objectWithTitle:[NSString stringWithUTF8String:sel_getName(method_getName(method))]] tapBlock:^BOOL(id object, id target, NSIndexPath *indexPath) {
                return YES;
            }]];
        }
        [self.tableModel addObjectsFromArray:[methodsArr sorted]];
    }
}

/**
 测试加载协议的所有协议、属性、方法
 */
- (void)loadProtocol
{
    self.title = @"Protocol";
    self.navigationItem.prompt = [NSString stringWithUTF8String:protocol_getName(self.protocol)];
    
    unsigned int protocol_count = 0;
    Protocol * __unsafe_unretained * protocol_list = protocol_copyProtocolList(self.protocol, &protocol_count);
    
    if (protocol_count > 0) {
        [self.tableModel appendSectionHeaderWithTitle:@"协议"];
        NSMutableArray *protocolsArr = [[NSMutableArray alloc] init];
        for (unsigned int i = 0; i < protocol_count; i ++) {
            [protocolsArr addObject:[self protocolCellObjectWithProtocol:protocol_list[i]]];
        }
        [self.tableModel addObjectsFromArray:[protocolsArr sorted]];
    }
    
    __weak AUURuntimeViewController *weakSelf = self;
    
    NSArray * (^propertyObjectCreationBlock)(BOOL isRequired, BOOL isInstance) = ^NSArray *(BOOL isRequired, BOOL isInstance) {
        unsigned int temp_count = 0;
        __strong AUURuntimeViewController *strongSelf = weakSelf;
#warning - CFNetwork -- NSAboutURLProtocol -- NSURLProtocol -- NSURLRequest *request -- NSSecureCoding  Crash
        objc_property_t *property_list = protocol_copyPropertyList2(strongSelf.protocol, &temp_count, isRequired, isInstance);
        NSMutableArray *tempArr = [[NSMutableArray alloc] initWithCapacity:temp_count];
        if (temp_count > 0) {
            for (unsigned int i = 0; i < temp_count; i ++) {
                [tempArr addObject:[strongSelf propertyCellObjectWithProperty:property_list[i]]];
            }
        }
        return tempArr;
    };
    
    NSMutableArray *propertyArray = [[NSMutableArray alloc] init];
    [propertyArray addObjectsFromArray:propertyObjectCreationBlock(YES, YES)];
    [propertyArray addObjectsFromArray:propertyObjectCreationBlock(YES, NO)];
    [propertyArray addObjectsFromArray:propertyObjectCreationBlock(NO, YES)];
    [propertyArray addObjectsFromArray:propertyObjectCreationBlock(NO, NO)];
    
    if (propertyArray.count > 0) {
        [self.tableModel appendSectionHeaderWithTitle:@"属性"];
        [self.tableModel addObjectsFromArray:[propertyArray sorted]];
    }
    
    
    
    
    NSArray * (^methodObjectCreationBlock)(BOOL isRequired, BOOL isInstance) = ^NSArray *(BOOL isRequired, BOOL isInstance) {
        unsigned int temp_count = 0;
        __strong AUURuntimeViewController *strongSelf = weakSelf;
        struct objc_method_description * method_description_list = protocol_copyMethodDescriptionList(strongSelf.protocol, isRequired, isInstance, &temp_count);
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        if (temp_count > 0) {
            for (unsigned int i = 0; i < temp_count; i ++) {
                struct objc_method_description method_description = method_description_list[i];
                [tempArray addObject:[strongSelf.tableActions attachToObject:[NITitleCellObject objectWithTitle:[NSString stringWithUTF8String:sel_getName(method_description.name)]] tapBlock:^BOOL(id object, id target, NSIndexPath *indexPath) {
                    return YES;
                }]];
            }
        }
        return tempArray;
    };
    
    NSMutableArray *methodArray = [[NSMutableArray alloc] init];
    [methodArray addObjectsFromArray:methodObjectCreationBlock(YES, YES)];
    [methodArray addObjectsFromArray:methodObjectCreationBlock(YES, NO)];
    [methodArray addObjectsFromArray:methodObjectCreationBlock(NO, YES)];
    [methodArray addObjectsFromArray:methodObjectCreationBlock(NO, NO)];
    
    if (methodArray.count > 0) {
        [self.tableModel appendSectionHeaderWithTitle:@"方法"];
        [self.tableModel addObjectsFromArray:[methodArray sorted]];
    }
}

#pragma mark - help methods
#pragma mark -

- (NITitleCellObject *)imageCellObjectWithImageName:(const char *)image_name
{
    NSString *imagePath = [NSString stringWithUTF8String:image_name];
    
    NSString *imageName = [[imagePath backwordsSeperateBy:@"/"] lastObject];
    UIImage *imageIcon = ([UIImage imageNamed:![imageName containsString:@"."] ? @"framework_icon" : @"dylib_icon"]);
    
    __weak AUURuntimeViewController *weakSelf = self;
    return [self.tableActions attachToObject:[NISubtitleCellObject objectWithTitle:imageName subtitle:imagePath image:imageIcon]
                                    tapBlock:^BOOL(id object, id target, NSIndexPath *indexPath) {
                                        
                                        __strong AUURuntimeViewController *strongSelf = weakSelf;
                                        
                                        AUURuntimeViewController *libVC = [[AUURuntimeViewController alloc] init];
                                        libVC.image_name = image_name;
                                        [strongSelf.navigationController pushViewController:libVC animated:YES];
                                        
                                        return YES;
                                    }];
}

- (NITitleCellObject *)propertyCellObjectWithProperty:(objc_property_t)property_t
{
    __weak AUURuntimeViewController *weakSelf = self;
    return [self.tableActions attachToObject:[NISubtitleCellObject objectWithTitle:[self property:property_t] subtitle:[self descriptionForProperty:property_t]]
                                    tapBlock:^BOOL(id object, id target, NSIndexPath *indexPath) {
                                        __strong AUURuntimeViewController *strongSelf = weakSelf;
                                        NSString *type = [strongSelf _type:property_t];
                                        if ([type protocolType]) {
                                            Protocol *protocol = objc_getProtocol([[type protocolType] UTF8String]);
                                            if (protocol) {
                                                AUURuntimeViewController *testVC = [[AUURuntimeViewController alloc] init];
                                                testVC.protocol = protocol;
                                                [strongSelf.navigationController pushViewController:testVC animated:YES];
                                            }
                                        } else if ([type objectType]) {
                                            Class cls = objc_getClass([[type objectType] UTF8String]);
                                            if (cls) {
                                                AUURuntimeViewController *testVC = [[AUURuntimeViewController alloc] init];
                                                testVC.class_name = class_getName(cls);
                                                [strongSelf.navigationController pushViewController:testVC animated:YES];
                                            }
                                        }
                                        return YES;
                                    }];
}

- (NITitleCellObject *)protocolCellObjectWithProtocol:(Protocol *)protocol
{
    __weak AUURuntimeViewController *weakSelf = self;
    return [self.tableActions attachToObject:[NITitleCellObject objectWithTitle:[NSString stringWithUTF8String:protocol_getName(protocol)]]
                                    tapBlock:^BOOL(id object, id target, NSIndexPath *indexPath) {
                                        
                                        __strong AUURuntimeViewController *strongSelf = weakSelf;
                                        
                                        AUURuntimeViewController *protocolVC = [[AUURuntimeViewController alloc] init];
                                        protocolVC.protocol = protocol;
                                        [strongSelf.navigationController pushViewController:protocolVC animated:YES];
                                        
                                        return YES;
                                    }];
}

- (NSString *)property:(objc_property_t)property_t
{
    NSString *type = [self _type:property_t];
    
    if (type) {
        if ([type protocolType]) {
            type = [NSString stringWithFormat:@"id<%@>", [type protocolType]];
        } else if ([type objectType]) {
            type = [NSString stringWithFormat:@"%@ *", [type objectType]];
        }
        
        return [NSString stringWithFormat:@"%@ %s", type, property_getName(property_t)];
    }
    
    return [NSString stringWithUTF8String:property_getName(property_t)];
}

- (NSString *)_type:(objc_property_t)property_t
{
    unsigned int property_attribute_count = 0;
    objc_property_attribute_t *property_attribute_list = property_copyAttributeList(property_t, &property_attribute_count);
    
    objc_property_attribute_t property_attribute_t = property_attribute_list[0];
    
    if (strcmp(property_attribute_t.value, "c") == 0) {
        return @"char";
    }
    
    if (strcmp(property_attribute_t.value, "i") == 0) {
        return @"int";
    }
    
    if (strcmp(property_attribute_t.value, "s") == 0) {
        return @"short";
    }
    
    if (strcmp(property_attribute_t.value, "l") == 0) {
        return @"long";
    }
    
    if (strcmp(property_attribute_t.value, "q") == 0) {
        return @"long long";
    }
    
    if (strcmp(property_attribute_t.value, "C") == 0) {
        return @"unsigned char";
    }
    
    if (strcmp(property_attribute_t.value, "I") == 0) {
        return @"unsigned int";
    }
    
    if (strcmp(property_attribute_t.value, "S") == 0) {
        return @"unsigned short";
    }
    
    if (strcmp(property_attribute_t.value, "L") == 0) {
        return @"unsigned long";
    }
    
    if (strcmp(property_attribute_t.value, "Q") == 0) {
        return @"unsigned long long";
    }
    
    if (strcmp(property_attribute_t.value, "f") == 0) {
        return @"float";
    }
    
    if (strcmp(property_attribute_t.value, "d") == 0) {
        return @"double";
    }
    if (strcmp(property_attribute_t.value, "B") == 0) {
        return @"bool";
    }
    
    if (strcmp(property_attribute_t.value, "v") == 0) {
        return @"void";
    }
    
    if (strcmp(property_attribute_t.value, "*") == 0) {
        return @"char *";
    }
    
    if (strcmp(property_attribute_t.value, "@") == 0) {
        return @"id";
    }
    
    if (strcmp(property_attribute_t.value, "#") == 0) {
        return @"Class";
    }
    
    if (strcmp(property_attribute_t.value, ":") == 0) {
        return @"SEL";
    }
    
    if (strcmp(@encode(CGRect), property_attribute_t.value) == 0) {
        return @"CGRect";
    }
    
    if (strcmp(@encode(CGSize), property_attribute_t.value) == 0) {
        return @"CGSize";
    }
    
    if (strcmp(@encode(CGPoint), property_attribute_t.value) == 0) {
        return @"CGPoint";
    }
    
    if (strcmp(@encode(UIEdgeInsets), property_attribute_t.value) == 0) {
        return @"UIEdgeInsets";
    }
    
    if (strcmp(@encode(CGAffineTransform), property_attribute_t.value) == 0) {
        return @"CGAffineTransform";
    }
    
    
    
    // 类 @"UIView"
    // 协议  @"<NSURLProtocol>"
    return[NSString stringWithUTF8String:property_attribute_t.value];
}

- (NSString *)descriptionForProperty:(objc_property_t)property_t
{
    unsigned int property_attribute_count = 0;
    objc_property_attribute_t *property_attribute_list = property_copyAttributeList(property_t, &property_attribute_count);
    if (property_attribute_count > 0) {
        NSMutableArray *attributesArr = [[NSMutableArray alloc] init];
        if (property_attribute_count >= 2 && strcmp(property_attribute_list[1].name, "D") == 0) {
            return [NSString stringWithFormat:@"(@dynamic)"];
        } else {
            for (unsigned int i = 1; i < property_attribute_count; i ++) {
                objc_property_attribute_t property_attribute_t = property_attribute_list[i];
                NSString *type = [self propertyAttribute:property_attribute_t];
                if (type) {
                    [attributesArr addObject:type];
                }
            }
            
            if (attributesArr.count > 0) {
                return [NSString stringWithFormat:@"(%@)", [attributesArr componentsJoinedByString:@", "]];
            } else {
                return @"(..)";
            }
        }
    }
    
    return [NSString stringWithUTF8String:property_getName(property_t)];
}

- (NSString *)propertyAttribute:(objc_property_attribute_t)property_attribute_t
{
    if (strcmp(property_attribute_t.name, "R") == 0) {
        return @"readonly";
    } else if (strcmp(property_attribute_t.name, "C") == 0) {
        return @"copy";
    } else if (strcmp(property_attribute_t.name, "&") == 0) {
        return @"retain";
    } else if (strcmp(property_attribute_t.name, "N") == 0) {
        return @"nonatomic";
    } else if (strcmp(property_attribute_t.name, "W") == 0) {
        return @"weak";
    } else if (strcmp(property_attribute_t.name, "V") == 0) {
        // @synchronized
        return nil;
    }
    else {
        NSString *type = [NSString stringWithUTF8String:property_attribute_t.name];
        NSString *value = [NSString stringWithUTF8String:property_attribute_t.value];
        if ([type hasPrefix:@"S"]) {
            return [NSString stringWithFormat:@"setter=%@", value];
        } else if ([type hasPrefix:@"G"]) {
            return [NSString stringWithFormat:@"getter=%@", value];
        } else {
            return nil;
        }
    }
    
}

@end




@implementation NSString (AUUHelper)

- (NSArray *)backwordsSeperateBy:(NSString *)seperater
{
    NSRange range = [self rangeOfString:seperater options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        return @[[self substringToIndex:range.location],
                 [self substringFromIndex:range.location + range.length]];
    }
    return @[self];
}

- (NSString *)matchResultWithPattern:(NSString *)pattern
{
    NSError *rError;
    
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&rError];
    
    if (rError)
    {
        NSLog(@"%@", rError.userInfo);
        
        return nil;
    }
    
    NSTextCheckingResult *textCheckingResult = [regularExpression firstMatchInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length)];
    
    if (textCheckingResult.numberOfRanges > 0)
    {
        NSRange range = [textCheckingResult rangeAtIndex:0];
        
        if (range.location != NSNotFound && range.length <= self.length)
        {
            return [self substringWithRange:range];
        }
    }
    
    return nil;
}

- (NSString *)protocolType
{
    return [self matchResultWithPattern:@"(?<=@\"<).*?(?=>\")"];
}

- (NSString *)objectType
{
    return [self matchResultWithPattern:@"(?<=@\").+?(?=\")"];
}

@end

@implementation NSArray (AUUHelper)

- (NSArray *)sorted
{
    return [self sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
}

@end
