//
//  LKFlowLayout.h
//  瀑布流
//
//  Created by 雷凯 on 15/11/26.
//  Copyright © 2015年 leikai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LKFlowLayout;
@protocol  LKFlowLayoutDelagate<NSObject>

@required
-(CGFloat)flowLayoutWithItemHight:(LKFlowLayout *)flowLayout andItemW:(CGFloat)itemW andCellIndexPath:(NSIndexPath *)cellIndexPath;

@end


@interface LKFlowLayout : UICollectionViewFlowLayout

//设置每一行cell的列数
@property (nonatomic, assign) NSInteger columnCount;

//代理属性
@property(nonatomic,strong)id <LKFlowLayoutDelagate> delegate;

@end
