//
//  ImageSample.m
//  RuntimeMethods
//
//  Created by 胡金友 on 2017/9/14.
//  Copyright © 2017年 胡金友. All rights reserved.
//

#import "ImageSample.h"
#import <objc/runtime.h>

@implementation ImageSample

+ (void)test
{
    // 获取类所在的类库的名
    const char *imageName = class_getImageName([NSString class]);
    printf("NSString类所在的类库在：%s中\n\n\n", imageName);
    
    unsigned int imageCount = 0;
    // 获取系统中存在的类库列表
    const char **imageNames = objc_copyImageNames(&imageCount);
    for (unsigned int i = 0; i < imageCount; i ++) {
        printf("%s\n", imageNames[i]);
        unsigned int classCount = 0;
        // 获取类库中的类的列表
        const char **classNames = objc_copyClassNamesForImage(imageNames[i], &classCount);
        for (unsigned int j = 0; j < classCount; j ++) {
            printf("    | %s\n", classNames[j]);
        }
    }
}

@end
