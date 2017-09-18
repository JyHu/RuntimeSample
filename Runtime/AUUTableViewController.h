//
//  AUUTableViewController.h
//  RuntimeTest
//
//  Created by 胡金友 on 2017/9/16.
//
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Nimbus/NimbusCore.h>
#import <Nimbus/NimbusModels.h>

@interface AUUTableViewController : UIViewController <UITableViewDelegate>

@property (retain, nonatomic, readonly) UITableView *tableView;

@property (retain, nonatomic) NIMutableTableViewModel *tableModel;
@property (retain, nonatomic) NITableViewActions *tableActions;

@end
