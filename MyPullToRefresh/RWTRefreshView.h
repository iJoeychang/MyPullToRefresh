//
//  RWTRefreshView.h
//  MyPullToRefresh
//
//  Created by chang on 16/9/21.
//  Copyright © 2016年 chang. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RWTRefreshView;
// 代理方法实现下拉后锁定动画3秒效果
@protocol RWTRefreshViewDelegate <NSObject>
- (void)refreshViewDidRefresh:(RWTRefreshView *)refreshView;
@end

@interface RWTRefreshView : UIView<UIScrollViewDelegate>

@property (nonatomic, weak) id <RWTRefreshViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame scrollView:(UIScrollView *)scrollView;
- (void)beginRefreshing;
- (void)endRefreshing;

@end
