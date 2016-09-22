//
//  RWTRefreshingTableViewController.m
//  MyPullToRefresh
//
//  Created by chang on 16/9/21.
//  Copyright © 2016年 chang. All rights reserved.
//

#import "RWTRefreshingTableViewController.h"

#import "RWTRefreshView.h"

static CGFloat kTestViewHeight = 200.f;

@interface RWTRefreshingTableViewController ()<RWTRefreshViewDelegate>
@property (nonatomic, strong) RWTRefreshView *refreshView;
@end

@implementation RWTRefreshingTableViewController

- (void)viewDidLoad {
    
    self.refreshView = [[RWTRefreshView alloc] initWithFrame:CGRectMake(0, -kTestViewHeight, CGRectGetWidth(self.view.bounds), kTestViewHeight) scrollView:(UIScrollView *)self.view];
    self.refreshView.translatesAutoresizingMaskIntoConstraints = NO;
    self.refreshView.delegate = self;
    [self.view insertSubview:self.refreshView atIndex:0];

    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.refreshView scrollViewDidScroll:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self.refreshView scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)artificialDelay {
    
    __weak RWTRefreshingTableViewController *weakSelf = self;
    double delayInSeconds = 3.f;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^(void) {
        [weakSelf endRefreshing];
    });
    
}
- (void)endRefreshing {
    [self.refreshView endRefreshing];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier=@"MyCell";
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Row %ld", (long)indexPath.row];
    
    return cell;
}

#pragma mark - RWTRefreshViewDelegate

- (void)refreshViewDidRefresh:(RWTRefreshView *)refreshView {
    [self artificialDelay];
}


@end
