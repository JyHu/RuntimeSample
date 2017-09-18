//
//  AUURuntimeViewController.h
//  RuntimeTest
//
//  Created by 胡金友 on 2017/9/18.
//
//

#import "AUUTableViewController.h"

@interface AUURuntimeViewController : AUUTableViewController

@property (assign, nonatomic) BOOL loadProtocols;

@property (nonatomic) const char *image_name;

@property (nonatomic) const char *class_name;

@property (nonatomic) Protocol *protocol;

@end

@interface NSString (AUUHelper)

- (NSArray *)backwordsSeperateBy:(NSString *)seperater;
- (NSString *)protocolType;
- (NSString *)objectType;

@end

@interface NSArray (AUUHelper)

- (NSArray *)sorted;

@end
