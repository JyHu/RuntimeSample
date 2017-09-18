//
// Copyright 2011-2014 NimbusKit
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NIActions.h"  /* for NIActionsDataSource */
#import "NIPreprocessorMacros.h" /* for weak */

#if NS_BLOCKS_AVAILABLE
typedef UITableViewCell* (^NITableViewModelCellForIndexPathBlock)(UITableView* tableView, NSIndexPath* indexPath, id object);
#endif // #if NS_BLOCKS_AVAILABLE

@protocol NITableViewModelViewsDelegate;


#pragma mark Sectioned Array Objects

// Classes used when creating NITableViewModels.
@class NITableViewModelFooter;  // Provides the information for a footer.

typedef enum {
    NITableViewModelSectionIndexNone, // Displays no section index.
    NITableViewModelSectionIndexDynamic, // Generates a section index from the first letters of the section titles.
    NITableViewModelSectionIndexAlphabetical, // Generates an alphabetical section index.
} NITableViewModelSectionIndex;

/**
 * A non-mutable table view model that complies to the UITableViewDataSource protocol.
 *
 * This model allows you to easily create a data source for a UITableView without having to
 * implement the UITableViewDataSource methods in your UITableViewController.
 *
 * This base class is non-mutable, much like an NSArray. You must initialize this model with
 * the contents when you create it.
 *
 * @ingroup TableViewModels
 */
@interface NITableViewModel : NSObject <NIActionsDataSource, UITableViewDataSource>

#pragma mark Creating Table View Models

// Designated initializer.
- (id)initWithDelegate:(id<NITableViewModelViewsDelegate>)delegate;
- (id)initWithListArray:(NSArray *)sectionedArray delegate:(id<NITableViewModelViewsDelegate>)delegate;
// Each NSString in the array starts a new section. Any other object is a new row (with exception of certain model-specific objects).
- (id)initWithSectionedArray:(NSArray *)sectionedArray delegate:(id<NITableViewModelViewsDelegate>)delegate;

#pragma mark Accessing Objects

// This method is not appropriate for performance critical codepaths.
- (NSIndexPath *)indexPathForObject:(id)object;

#pragma mark Configuration

// Immediately compiles the section index.
- (void)setSectionIndexType:(NITableViewModelSectionIndex)sectionIndexType showsSearch:(BOOL)showsSearch showsSummary:(BOOL)showsSummary;

@property (nonatomic, readonly, assign) NITableViewModelSectionIndex sectionIndexType; // Default: NITableViewModelSectionIndexNone
@property (nonatomic, readonly, assign) BOOL sectionIndexShowsSearch; // Default: NO
@property (nonatomic, readonly, assign) BOOL sectionIndexShowsSummary; // Default: NO

#pragma mark Creating Table View Cells

@property (nonatomic, weak) id<NITableViewModelViewsDelegate> delegate;

#if NS_BLOCKS_AVAILABLE
// If both the delegate and this block are provided, cells returned by this block will be used
// and the delegate will not be called.
@property (nonatomic, copy) NITableViewModelCellForIndexPathBlock createCellBlock;
#endif // #if NS_BLOCKS_AVAILABLE

/**
 获取当前tableView Model里的所有的数据
 
 @return 以二维数组的方式返回，每个一位数组为一个section里的所有数据
 */
- (NSArray *)allDatas;

- (NSArray *)objectsInSection:(NSUInteger)sectionIndex;

@end

/**
 * A protocol for NITableViewModel to fetch rows to be displayed for the table view.
 *
 * @ingroup TableViewModels
 */
@protocol NITableViewModelViewsDelegate <NSObject>

@required

/**
 * Fetches a table view cell at a given index path with a given object.
 *
 * The implementation of this method will generally use object to customize the cell.
 */
- (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object;

@optional
// 留给外部调用的，实现这个方法用于创建section的表头和表尾
- (UITableViewHeaderFooterView *)tableViewModel:(NITableViewModel *)tableViewModel
                             headerForTableView:(UITableView *)tableView
                                      inSection:(NSUInteger)section
                                     withObject:(id)object;

- (UITableViewHeaderFooterView *)tableViewModel:(NITableViewModel *)tableViewModel
                             footerForTableView:(UITableView *)tableView
                                      inSection:(NSUInteger)section
                                     withObject:(id)object;

/**
 当页面tablemodel切换过快或者滑动过快的时候会出现找不到CellObject的情况，导致返回空的cell，导致程序崩溃
 可以实现这个代理，用来返回一个占位的cell，避免崩溃
 */
- (id)placeholderCellObjectForTableViewModel:(NITableViewModel *)tableViewModel;

@end



/** @name Creating Table View Models */

/**
 * Initializes a newly allocated static model with the given delegate and empty contents.
 *
 * This method can be used to create an empty model.
 *
 * @fn NITableViewModel::initWithDelegate:
 */

/**
 * Initializes a newly allocated static model with the contents of a list array.
 *
 * A list array is a one-dimensional array that defines a flat list of rows. There will be
 * no sectioning of contents in any way.
 *
 * <h3>Example</h3>
 *
 * @code
 * NSArray* contents =
 * [NSArray arrayWithObjects:
 *  [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"],
 *  [NSDictionary dictionaryWithObject:@"Row 2" forKey:@"title"],
 *  [NSDictionary dictionaryWithObject:@"Row 3" forKey:@"title"],
 *  nil];
 * [[NIStaticTableViewModel alloc] initWithListArray:contents delegate:self];
 * @endcode
 *
 * @fn NITableViewModel::initWithListArray:delegate:
 */

/**
 * Initializes a newly allocated static model with the contents of a sectioned array.
 *
 * A sectioned array is a one-dimensional array that defines a list of sections and each
 * section's contents. Each NSString begins a new section and any other object defines a
 * row for the current section.
 *
 * <h3>Example</h3>
 *
 * @code
 * NSArray* contents =
 * [NSArray arrayWithObjects:
 *  @"Section 1",
 *  [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"],
 *  [NSDictionary dictionaryWithObject:@"Row 2" forKey:@"title"],
 *  @"Section 2",
 *  // This section is empty.
 *  @"Section 3",
 *  [NSDictionary dictionaryWithObject:@"Row 3" forKey:@"title"],
 *  [NITableViewModelFooter footerWithTitle:@"Footer"],
 *  nil];
 * [[NIStaticTableViewModel alloc] initWithSectionedArray:contents delegate:self];
 * @endcode
 *
 * @fn NITableViewModel::initWithSectionedArray:delegate:
 */


/** @name Accessing Objects */

/**
 * Returns the object at the given index path.
 *
 * If no object exists at the given index path (an invalid index path, for example) then nil
 * will be returned.
 *
 * @fn NITableViewModel::objectAtIndexPath:
 */

/**
 * Returns the index path of the given object within the model.
 *
 * If the model does not contain the object then nil will be returned.
 *
 * @fn NITableViewModel::indexPathForObject:
 */

/** @name Configuration */

/**
 * Configures the model's section index properties.
 *
 * Calling this method will compile the section index depending on the index type chosen.
 *
 * @param sectionIndexType The type of section index to display.
 * @param showsSearch      Whether or not to show the search icon at the top of the index.
 * @param showsSummary     Whether or not to show the summary icon at the bottom of the index.
 * @fn NITableViewModel::setSectionIndexType:showsSearch:showsSummary:
 */

/**
 * The section index type.
 *
 * You will likely use NITableViewModelSectionIndexAlphabetical in practice.
 *
 * NITableViewModelSectionIndexNone by default.
 *
 * @fn NITableViewModel::sectionIndexType
 */

/**
 * Whether or not the search symbol will be shown in the section index.
 *
 * NO by default.
 *
 * @fn NITableViewModel::sectionIndexShowsSearch
 */

/**
 * Whether or not the summary symbol will be shown in the section index.
 *
 * NO by default.
 *
 * @fn NITableViewModel::sectionIndexShowsSummary
 */


/** @name Creating Table View Cells */

/**
 * A delegate used to fetch table view cells for the data source.
 *
 * @fn NITableViewModel::delegate
 */

#if NS_BLOCKS_AVAILABLE

/**
 * A block used to create a UITableViewCell for a given object.
 *
 * @fn NITableViewModel::createCellBlock
 */

#endif // #if NS_BLOCKS_AVAILABLE