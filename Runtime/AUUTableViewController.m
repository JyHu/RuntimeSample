//
//  AUUTableViewController.m
//  RuntimeTest
//
//  Created by 胡金友 on 2017/9/16.
//
//

#import "AUUTableViewController.h"
#import <Nimbus/NICellFactory.h>

@interface AUUTableViewController ()

@property (retain, nonatomic) UITableView *pri_tableView;

@end

@implementation AUUTableViewController

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.pri_tableView];
    
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleDone target:self action:@selector(backHome)];
    }
}

- (void)backHome
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)removeObjectsInSection:(NSInteger)section
{
    for (NSInteger i = [self.tableModel tableView:self.tableView numberOfRowsInSection:section] - 1; i >= 0; i --) {
        [self.tableModel removeObjectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
    }
}

- (UITableView *)pri_tableView
{
    if (!_pri_tableView) {
        _pri_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _pri_tableView.delegate = [self.tableActions forwardingTo:self];
        _pri_tableView.dataSource = self.tableModel;
        _pri_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return _pri_tableView;
}

- (UITableView *)tableView
{
    return self.pri_tableView;
}

- (NIMutableTableViewModel *)tableModel
{
    if (!_tableModel) {
        _tableModel = [[NIMutableTableViewModel alloc] initWithDelegate:(id <NITableViewModelDelegate>)[NICellFactory class]];
    }
    
    return _tableModel;
}

- (NITableViewActions *)tableActions
{
    if (!_tableActions) {
        _tableActions = [[NITableViewActions alloc] initWithTarget:self];
    }
    
    return _tableActions;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
