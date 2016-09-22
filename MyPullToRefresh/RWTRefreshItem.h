//
//  RWTRefreshItem.h
//  MyPullToRefresh
//
//  Created by chang on 16/9/22.
//  Copyright © 2016年 chang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RWTRefreshItem : NSObject


- (instancetype)initWithView:(UIView *)view centerEnd:(CGPoint)centerEnd parallaxRatio:(CGFloat)parallaxRatio sceneHeight:(CGFloat)sceneHeight;
- (void)centerForProgress:(CGFloat)progress;

@property (nonatomic, weak) UIView *view;


@end
