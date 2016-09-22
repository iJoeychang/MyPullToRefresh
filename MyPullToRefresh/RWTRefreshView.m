//
//  RWTRefreshView.m
//  MyPullToRefresh
//
//  Created by chang on 16/9/21.
//  Copyright © 2016年 chang. All rights reserved.
//

#import "RWTRefreshView.h"
#import "RWTRefreshItem.h"

static CGFloat kSceneHeight = 120.f;

@interface RWTRefreshView ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) CGFloat progress;

@property (strong, nonatomic) UIImageView *ground;
@property (strong, nonatomic) UIImageView *buildings;
@property (strong, nonatomic) UIImageView *sun;
@property (strong, nonatomic) UIImageView *capeBack;
@property (strong, nonatomic) UIImageView *cat;
@property (strong, nonatomic) UIImageView *capeFront;
@property (strong, nonatomic) NSMutableArray *refreshItems;
@property (assign, nonatomic) BOOL refreshing;

@property (strong, nonatomic) UIImageView *sign;
@property (strong, nonatomic) RWTRefreshItem *readyItem;
@property (assign, nonatomic) BOOL showingReadyItem;

@property (strong, nonatomic) UIView *cloudView1;
@property (strong, nonatomic) UIView *cloudView2;

@end


@implementation RWTRefreshView

-(instancetype)initWithFrame:(CGRect)frame scrollView:(UIScrollView *)scrollView{
   
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = scrollView;
        [self refreshColor];
        
        _refreshItems = [NSMutableArray array];
        [self setupItems];
    }
    return self;
}

- (void)refreshColor {
    
     NSLog(@"self.progress=== %f ",self.progress);
    
    CGFloat value = (0.7f * self.progress) + 0.2f;
    self.backgroundColor = [UIColor colorWithRed:value green:value blue:value alpha:1.f];

}

- (void)setupItems {
    
    self.ground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ground"]];
    self.buildings = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buildings"]];
    self.sun = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sun"]];
    self.capeBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cape_back"]];
    self.cat = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cat"]];
    self.capeFront = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cape_front"]];
    self.sign = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sign"]];
    
    [self addRefreshItem:[[RWTRefreshItem alloc] initWithView:self.buildings centerEnd:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.ground.bounds) - CGRectGetHeight(self.buildings.bounds)/2) parallaxRatio:1.5 sceneHeight:kSceneHeight]];
    
    [self addRefreshItem:[[RWTRefreshItem alloc] initWithView:self.sun centerEnd:CGPointMake(CGRectGetWidth(self.bounds) * 0.1, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.ground.bounds) - CGRectGetHeight(self.sun.bounds)) parallaxRatio:3.f sceneHeight:kSceneHeight]];
    
    [self addRefreshItem:[[RWTRefreshItem alloc] initWithView:self.ground centerEnd:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.ground.bounds)/2) parallaxRatio:0.5f sceneHeight:kSceneHeight]];
    
    [self addRefreshItem:[[RWTRefreshItem alloc] initWithView:self.capeBack centerEnd:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.ground.bounds)/2 - CGRectGetHeight(self.capeBack.bounds)/2) parallaxRatio:-1.f sceneHeight:kSceneHeight]];
    
    [self addRefreshItem:[[RWTRefreshItem alloc] initWithView:self.cat centerEnd:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.ground.bounds)/2 - CGRectGetHeight(self.cat.bounds)/2) parallaxRatio:1.f sceneHeight:kSceneHeight]];
    
    [self addRefreshItem:[[RWTRefreshItem alloc] initWithView:self.capeFront centerEnd:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.ground.bounds)/2 - CGRectGetHeight(self.capeFront.bounds)/2) parallaxRatio:-1.f sceneHeight:kSceneHeight]];

    self.readyItem = [[RWTRefreshItem alloc] initWithView:self.sign centerEnd:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.sign.bounds)/2) parallaxRatio:0.5f sceneHeight:kSceneHeight];
    [self addSubview:self.readyItem.view];
    
    // 浮动的云
    self.cloudView1 = [self createCloudView];
    self.cloudView2 = [self createCloudView];
    self.cloudView1.alpha = 0;
    self.cloudView2.alpha = 0;
    [self insertSubview:self.cloudView1 atIndex:0];
    [self insertSubview:self.cloudView2 atIndex:0];
    
}
- (void)addRefreshItem:(RWTRefreshItem *)item {
    [self addSubview:item.view];
    [self.refreshItems addObject:item];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
   
    if (self.refreshing) return;
    
    CGFloat visibleHeight = MAX(-scrollView.contentOffset.y - scrollView.contentInset.top, 0);
    self.progress = MIN(MAX(visibleHeight / kSceneHeight, 0.f), 1.f);
    [self refreshColor];

    for (RWTRefreshItem *item in self.refreshItems) {
        [item centerForProgress:self.progress];
    }

    if (self.progress >= 1.0) {
        [self showReadyItem:YES];
    } else {
        [self showReadyItem:NO];
    }
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    if (self.progress >= 1.f) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshViewDidRefresh:)]) {
            [self beginRefreshing];
            *targetContentOffset = CGPointMake(0, -self.scrollView.contentInset.top);
            [self.delegate refreshViewDidRefresh:self];
        }
    }
    
}

- (void)beginRefreshing {
    
    self.refreshing = YES;
    [UIView animateWithDuration:0.4f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        UIEdgeInsets newInsets = self.scrollView.contentInset;
        newInsets.top += kSceneHeight;
        [self.scrollView setContentInset:newInsets];
        
    } completion:^(BOOL finished) {
    }];
    
    
    [self showReadyItem:NO];
    
    // Wiggle cat/cape
    self.capeBack.transform = CGAffineTransformMakeRotation(-M_PI/32);
    self.cat.transform = CGAffineTransformMakeTranslation(1.0, 0);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
        self.capeBack.transform = CGAffineTransformMakeRotation(M_PI/32);
        self.cat.transform = CGAffineTransformMakeTranslation(-1.0, 0);
    } completion:^(BOOL finished) {
        
    }];
    
    // Move ground
    [UIView animateWithDuration:1.f delay:0.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.ground.center = CGPointMake(self.ground.center.x, self.ground.center.y + kSceneHeight);
        self.buildings.center = CGPointMake(self.buildings.center.x, self.buildings.center.y + kSceneHeight);
    } completion:^(BOOL finished) {
    }];
    
    // Animate cloud view 1
    self.cloudView1.center = CGPointMake(CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds));
    self.cloudView1.alpha = 1;
    [UIView animateWithDuration:2.0 delay:0.25 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionCurveLinear animations:^{
        self.cloudView1.alpha = 1;
        self.cloudView1.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) + CGRectGetHeight(self.bounds));
    } completion:^(BOOL finished) {
        self.cloudView1.center = CGPointMake(CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds));
    }];
    
    // Animate cloud view 2
    self.cloudView2.center = CGPointMake(CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds));
    self.cloudView2.alpha = 1;
    [UIView animateWithDuration:2.0 delay:1.25 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionCurveLinear animations:^{
        self.cloudView2.alpha = 1;
        self.cloudView2.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) + CGRectGetHeight(self.bounds));
    } completion:^(BOOL finished) {
        self.cloudView2.center = CGPointMake(CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds));
    }];

}

- (void)endRefreshing {
    
    [UIView animateWithDuration:0.4f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        UIEdgeInsets newInsets = self.scrollView.contentInset;
        newInsets.top -= kSceneHeight;
        [self.scrollView setContentInset:newInsets];
        
        self.capeBack.transform = CGAffineTransformIdentity;
        self.cat.transform = CGAffineTransformIdentity;
        [self.capeBack.layer removeAllAnimations];
        [self.cat.layer removeAllAnimations];
        
        self.cloudView1.alpha = 0;
        [self.cloudView1.layer removeAllAnimations];
        self.cloudView2.alpha = 0;
        [self.cloudView2.layer removeAllAnimations];
        
    } completion:^(BOOL finished) {
        self.refreshing = NO;
    }];
    
}

- (void)showReadyItem:(BOOL)show {
    if (self.showingReadyItem == show) return;
    
    self.showingReadyItem = show;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.readyItem centerForProgress:show ? 1.f : 0.f];
    } completion:nil];
}

- (UIView *)createCloudView {
    
    UIView *cloudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    
    NSMutableArray *clouds1 = [NSMutableArray array];
    NSMutableArray *clouds2 = [NSMutableArray array];
    
    for (int i = 0; i < 3; ++i) {
        
        UIImageView *cloud1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloud_1"]];
        [cloudView addSubview:cloud1];
        [clouds1 addObject:cloud1];
        
        UIImageView *cloud2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloud_2"]];
        [cloudView addSubview:cloud2];
        [clouds2 addObject:cloud2];
        
    }
    
    ((UIImageView *)clouds1[0]).center = CGPointMake(CGRectGetWidth(cloudView.bounds) * 0.2, CGRectGetHeight(cloudView.bounds) * 0.2);
    ((UIImageView *)clouds2[0]).center = CGPointMake(CGRectGetWidth(cloudView.bounds) * 0.1, CGRectGetHeight(cloudView.bounds) * 0.8);
    
    ((UIImageView *)clouds1[1]).center = CGPointMake(CGRectGetWidth(cloudView.bounds) * 0.7, CGRectGetHeight(cloudView.bounds) * 0.3);
    ((UIImageView *)clouds2[1]).center = CGPointMake(CGRectGetWidth(cloudView.bounds) * 0.5, CGRectGetHeight(cloudView.bounds) * 0.5);
    
    ((UIImageView *)clouds1[2]).center = CGPointMake(CGRectGetWidth(cloudView.bounds) * 0.8, CGRectGetHeight(cloudView.bounds) * 0.8);
    ((UIImageView *)clouds2[2]).center = CGPointMake(CGRectGetWidth(cloudView.bounds) * 0.3, CGRectGetHeight(cloudView.bounds) * 0.4);
    
    return cloudView;
    
}
@end
