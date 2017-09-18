//
//  IvarSample.m
//  RuntimeTest
//
//  Created by 胡金友 on 2017/9/15.
//
//

#import "IvarSample.h"
#import <objc/runtime.h>



@interface IvarTestModel : NSObject

@property (assign, nonatomic) NSInteger arg;
@property (retain, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *school;


@end

@implementation IvarTestModel

@end

@implementation IvarSample

+ (void)test
{
    unsigned int ivar_count = 0;
    Ivar *ivar_list = class_copyIvarList([IvarTestModel class], &ivar_count);
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

@end
