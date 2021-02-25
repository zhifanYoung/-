//
//  ViewController.m
//  BZ
//
//  Created by Young on 16/7/14.
//  Copyright © 2016年 Young. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import "MBProgressHUD+Extension.h"
#import "model.h"
#import "Cell.h"
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import <MJRefresh.h>
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, MJPhotoBrowserDelegate>

@property (nonatomic, strong) NSMutableArray *modelM;

@property (nonatomic, strong) NSMutableArray *urlM;

@property (weak, nonatomic) IBOutlet UICollectionView *cView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
}

- (void)setupRefresh {

    self.cView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{

        [self addUrlM];
        [self.cView.mj_footer endRefreshing];
        [self.cView reloadData];
    }];
}

- (void)setupData {
    
    // http://unsplash.it/4320/3240?image=102 https://unsplash.it/list
    MBProgressHUD *hud = [MBProgressHUD hudWithText:nil withView:self.view isGraceTime:YES];
    [hud show:YES];
    [[AFHTTPSessionManager manager] GET:@"https://unsplash.it/list" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        [hud removeFromSuperview];
        
        self.modelM = [model mj_objectArrayWithKeyValuesArray:responseObject];
        [self setupTable];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud removeFromSuperview];
        [MBProgressHUD showError];
        NSLog(@"%@", error);
    }];
}

- (void)setupTable {
    
    [self setupRefresh];
    
    [self addUrlM];
    [self.cView reloadData];

}

- (void)addUrlM {

    int i = 0;
    if (self.modelM.count - self.urlM.count >= 20) {
        
        while (i < 20) {
            model *m = self.modelM[arc4random_uniform((uint32_t)self.modelM.count)];
            if (![self.urlM containsObject:m]) {
                [self.urlM addObject:m];
                i ++;
            }
        }
    } else {
        while (i < self.modelM.count - self.urlM.count) {
            model *m = self.modelM[arc4random_uniform((uint32_t)self.modelM.count)];
            if (![self.urlM containsObject:m]) {
                [self.urlM addObject:m];
                i ++;
            }
        }
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    NSString *urlStr = [NSString stringWithFormat:@"https://unsplash.it/120/140?image=%@", [self.urlM[indexPath.item] id]];
    NSURL *url = [NSURL URLWithString:urlStr];
    [cell.iconView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.urlM.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger count = self.urlM.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForItem:i inSection:0];
        Cell *c = (Cell *)[collectionView cellForItemAtIndexPath:index];
        NSString *urlStr = [NSString stringWithFormat:@"https://unsplash.it/414/736?image=%@", [self.urlM[i] id]];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:urlStr];
        photo.srcImageView = c.iconView;
        photo.placeholder = c.iconView.image ? c.iconView.image : [UIImage imageNamed:@"placeholder"];
        [photos addObject:photo];
    }
    
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = indexPath.item;
    browser.photos = photos;
    browser.delegate = self;
    [browser show];
}

- (void)photoBrowserHide:(NSUInteger)index {

    NSArray *tmp = [self.cView visibleCells];
    Cell *cell = (Cell *)[self.cView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    if (![tmp containsObject:cell]) {
        
        [self.cView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition: UICollectionViewScrollPositionCenteredVertically animated:YES];
    }
}

- (NSMutableArray *)modelM {
    if (!_modelM) {
        _modelM = [NSMutableArray array];
    }
    return _modelM;
}

- (NSMutableArray *)urlM {
    if (!_urlM) {
        _urlM = [NSMutableArray array];
    }
    return _urlM;
}

@end
