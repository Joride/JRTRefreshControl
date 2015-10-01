//
//  TableViewController.m
//  RefreshControl
//
//  Created by Joride on 04/09/15.
//  Copyright (c) 2015 KerrelInc. All rights reserved.
//

#import "TableViewController.h"
#import "UIColor+Additions.h"
#import "JRTNewtonsCradleRefreshControlView.h"

@interface TableViewController ()
<UITableViewDataSource,
UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, readonly) NSMutableDictionary * colorsByIndexPath;
@end

@implementation TableViewController

-(UIScrollView *)scrollView
{
    return self.tableView;
}
- (CGFloat ) relativeChangeOffset
{
    return 1.5;
}
- (CGFloat ) relativeChangeRate
{
    return 12.0f;
}
#pragma mark -
@synthesize colorsByIndexPath = _colorsByIndexPath;
-(NSMutableDictionary *)colorsByIndexPath
{
    if (nil == _colorsByIndexPath)
    {
        _colorsByIndexPath = [[NSMutableDictionary alloc] init];
    }
    return _colorsByIndexPath;
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView
numberOfRowsInSection:(NSInteger)section
{
    return 40;
}
-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellID = @"cellID";
    UITableViewCell * cell = [tableView cellForRowAtIndexPath: indexPath];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                      reuseIdentifier: cellID];
    }
    [self configureCell: cell
            atIndexPath: indexPath];
    return cell;
    
}

#pragma mark -
- (void) configureCell: (UITableViewCell *) cell
           atIndexPath: (NSIndexPath *) indexPath
{
    UIColor * color = self.colorsByIndexPath[indexPath];
    if (nil == color)
    {
        color = [UIColor randomColor];
        self.colorsByIndexPath[indexPath] = color;    
    }
    
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    
    [color getRed: &red
            green: &green
             blue: &blue
            alpha: NULL];
    
    cell.contentView.backgroundColor = color;
    cell.textLabel.text = [NSString stringWithFormat: @"Row %ld\t red: %1.1f green: %1.1f blue: %1.1f",
                           (long) indexPath.row,
                           red,
                           green,
                           blue];
}
-(Class)refreshControlViewClass
{
    return [JRTNewtonsCradleRefreshControlView class];
}
@end
