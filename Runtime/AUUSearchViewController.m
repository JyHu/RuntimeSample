//
//  AUUSearchViewController.m
//  RuntimeTest
//
//  Created by 胡金友 on 2017/9/18.
//
//

#import "AUUSearchViewController.h"
#import "AUURuntimeViewController.h"

@interface AUUSearchViewController () <UISearchBarDelegate>

@property (retain, nonatomic) UISearchBar *searchBar;

@property (retain, nonatomic) NITitleCellObject *classCellObject;
@property (retain, nonatomic) NITitleCellObject *protocolCellObject;

@end

@implementation AUUSearchViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.prompt = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationItem.prompt = @"Search";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate =self;
    self.navigationItem.titleView = self.searchBar;
    
    __weak AUUSearchViewController *weakSelf = self;
    
    [self.tableModel addObject:[self.tableActions attachToObject:[NITitleCellObject objectWithTitle:@"All Libraires"] tapBlock:^BOOL(id object, id target, NSIndexPath *indexPath) {
        __strong AUUSearchViewController *strongSelf = weakSelf;
        
        [strongSelf.searchBar resignFirstResponder];
        
        [strongSelf.navigationController pushViewController:[[AUURuntimeViewController alloc] init] animated:YES];
        return YES;
    }]];
    
    [self.tableModel addObject:[self.tableActions attachToObject:[NITitleCellObject objectWithTitle:@"All Protocols"] tapBlock:^BOOL(id object, id target, NSIndexPath *indexPath) {
        __strong AUUSearchViewController *strongSelf = weakSelf;
        
        [strongSelf.searchBar resignFirstResponder];
        
        AUURuntimeViewController *testVC = [[AUURuntimeViewController alloc] init];
        testVC.loadProtocols = YES;
        [strongSelf.navigationController pushViewController:testVC animated:YES];
        return YES;
    }]];
    
    
    [self.tableModel addSectionWithTitle:@"Search"];
    [self.tableModel addSectionWithTitle:@"History"];
    
    [self loadHistory];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - HELPER

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect kframe = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval timeInterval = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:timeInterval animations:^{
        CGRect rect = self.tableView.frame;
        rect.size.height = self.view.frame.size.height - kframe.size.height;
        self.tableView.frame = rect;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSTimeInterval timeInterval = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:timeInterval animations:^{
        CGRect rect = self.tableView.frame;
        rect.size.height = self.view.frame.size.height;
        self.tableView.frame = rect;
    }];
}

- (void)cacheKeywords
{
    NSArray *history = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.jyhu.searchHistory"];
    if (!history) {
        history = [[NSArray alloc] init];
        
    }
    
    NSMutableSet *historySet = [[NSMutableSet alloc] initWithArray:history];
    [historySet addObject:self.searchBar.text];
    
    [[NSUserDefaults standardUserDefaults] setObject:historySet.allObjects forKey:@"com.jyhu.searchHistory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self loadHistory];
    [self.tableView reloadData];
}

- (void)loadHistory
{
    NSMutableArray *set = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.jyhu.searchHistory"];
    if (set) {
        [self removeObjectsInSection:2];
        
        for (NSString *keywords in set) {
            
            __weak AUUSearchViewController *weakSelf = self;
            
            [self.tableModel addObject:[self.tableActions attachToObject:[NITitleCellObject objectWithTitle:keywords] tapBlock:^BOOL(id object, id target, NSIndexPath *indexPath) {
                __strong AUUSearchViewController *strongSelf = weakSelf;
                
                void (^protocolAction)(id) = ^(id obj) {
                    AUURuntimeViewController *testVC = [[AUURuntimeViewController alloc] init];
                    testVC.protocol = objc_getProtocol([keywords UTF8String]);
                    [strongSelf.navigationController pushViewController:testVC animated:YES];
                };
                
                void (^classAction)(id) = ^(id obj) {
                    AUURuntimeViewController *testVC = [[AUURuntimeViewController alloc] init];
                    testVC.class_name = [keywords UTF8String];
                    [strongSelf.navigationController pushViewController:testVC animated:YES];
                };
                
                if (objc_getClass([keywords UTF8String]) && objc_getProtocol([keywords UTF8String])) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                    
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Class" style:UIAlertActionStyleDefault handler:classAction]];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Protocol" style:UIAlertActionStyleDefault handler:protocolAction]];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                    
                    [strongSelf presentViewController:alertController animated:YES completion:nil];
                } else {
                    if (objc_getClass([keywords UTF8String])) {
                        classAction(nil);
                    } else if (objc_getProtocol([keywords UTF8String])) {
                        protocolAction(nil);
                    }
                }
                
                return YES;
            }]];
        }
    }
}

- (void)compileSearch
{
    [self removeObjectsInSection:1];
    
    if (objc_getClass([self.searchBar.text UTF8String])) {
        [self.tableModel addObject:self.classCellObject toSection:1];
    }
    
    if (objc_getProtocol([self.searchBar.text UTF8String])) {
        [self.tableModel addObject:self.protocolCellObject toSection:1];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self compileSearch];
}

#pragma mark - GETTER

- (NITitleCellObject *)protocolCellObject
{
    if (!_protocolCellObject) {
        
        __weak AUUSearchViewController *weakSelf = self;
        
        _protocolCellObject = [self.tableActions attachToObject:[NITitleCellObject objectWithTitle:@"Protocol"] tapBlock:^BOOL(id object, id target, NSIndexPath *indexPath) {
            __strong AUUSearchViewController *strongSelf = weakSelf;
            
            [strongSelf.searchBar resignFirstResponder];
            [strongSelf cacheKeywords];
            
            AUURuntimeViewController *testVC = [[AUURuntimeViewController alloc] init];
            testVC.protocol = objc_getProtocol([strongSelf.searchBar.text UTF8String]);
            [strongSelf.navigationController pushViewController:testVC animated:YES];
            return YES;
        }];
    }
    
    return _protocolCellObject;
}

- (NITitleCellObject *)classCellObject
{
    if (!_classCellObject) {
        __weak AUUSearchViewController *weakSelf = self;
        
        _classCellObject = [self.tableActions attachToObject:[NITitleCellObject objectWithTitle:@"Class"] tapBlock:^BOOL(id object, id target, NSIndexPath *indexPath) {
            __strong AUUSearchViewController *strongSelf = weakSelf;
            
            [strongSelf.searchBar resignFirstResponder];
            [strongSelf cacheKeywords];
            
            AUURuntimeViewController *testVC = [[AUURuntimeViewController alloc] init];
            testVC.class_name = [strongSelf.searchBar.text UTF8String];
            [strongSelf.navigationController pushViewController:testVC animated:YES];
            return YES;
        }];
    }
    
    return _classCellObject;
}

@end
