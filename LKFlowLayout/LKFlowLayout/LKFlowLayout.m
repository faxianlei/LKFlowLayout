//
//  LKFlowLayout.m
//  瀑布流
//
//  Created by 雷凯 on 15/11/26.
//  Copyright © 2015年 leikai. All rights reserved.
//

#import "LKFlowLayout.h"
@interface LKFlowLayout ()

//用来保存所有布局属性的数组
@property (nonatomic, strong) NSMutableArray *attrArrM;

//用来记录每一列高度的词典
@property (nonatomic, strong) NSMutableDictionary *maxYcolDict;

@end

@implementation LKFlowLayout

#pragma mark - 如果是通过代码来创建布局对象时会调用此方法
//即在控制器中 : self.collectionView.collectionViewLayout = [[HMWaterFallFlowLayout alloc] init];
- (instancetype)init
{
    self = [super init];
    if (self) {
        // 默认列数
        self.columnCount = 3;
        // 给一个默认的cell间距及行间距
        self.minimumInteritemSpacing = 10;
        self.minimumLineSpacing = 10;
        
        // foterView 或headerView的默认尺寸
        self.footerReferenceSize = CGSizeMake(50, 50);
        self.headerReferenceSize = CGSizeMake(50, 50);
        self.sectionInset = UIEdgeInsetsMake(20, 0, 0, 0);
    }
    return self;
}

#pragma mark - 如果是在sotryboar或xib中来创建的会调用此方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        // 默认列数
        self.columnCount = 3;
        // 给一个默认的cell间距及行间距
        self.minimumInteritemSpacing = 10;
        self.minimumLineSpacing = 10;
        
        // foterView 或headerView的默认尺寸
        self.footerReferenceSize = CGSizeMake(50, 50);
        self.headerReferenceSize = CGSizeMake(50, 50);
        self.sectionInset = UIEdgeInsetsMake(20, 0, 0, 0);
        
        
    }
    return self;
}

// 1.当collectionView中的所有子控件即将显示的时候就会来调用此方法做布局前的准备工作,准备itemSize...等等属性
// 2.当布局的属性发生变化时也会来调用此方法
// 3.当刷新数据之后也会来调用此方法重新做布局前的准备工作

//prepare准备  Lauout 布局

-(void)prepareLayout{
    
    [super prepareLayout];
    
    //用来记录每一列默认的高度
    for (NSInteger i=0; i<self.columnCount; i++) {
        
        NSString *colStr = [NSString stringWithFormat:@"%ld",i];
        
        self.maxYcolDict[colStr] = @(self.sectionInset.top);
    }
    
    //获取collectionView中有多少个cell
    NSInteger cellCount = [self.collectionView numberOfItemsInSection:0];
    
    //把用来装所有布局属性的的数据做清空处理
    [self.attrArrM removeAllObjects];
    

    //遍历来创建所有的布局对象
    for (NSInteger i=0; i<cellCount; i++) {

        //1、创建当前cell的索引
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        
        //2、获取指定索引的布局对象
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        
        //3、把布局属性添加到数组中
        [self.attrArrM addObject:attrs];
        
    }
    
    
    /********************尾部视图的布局*******************/
    
    //1、创建尾部视图的索引
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    //2、添加尾部视图的布局属性
    UICollectionViewLayoutAttributes *footer = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:indexPath];
    
    //3、设置尾部视图的frame
    footer.frame = CGRectMake(0, [self.maxYcolDict[self.maxCol]floatValue] - self.minimumLineSpacing, self.collectionView.bounds.size.width, 50);
    
    //4、把尾部视图的布局属性添加到数组
    [self.attrArrM addObject:footer];
    
}


#pragma mark - 用来获取指定索引的布局属性
-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //1、创建一个布局对象
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    //2.计算cell的宽和高
    //内容的宽 = collectionView的宽 - 组的左边间距 - 右边间距
    CGFloat contentWidth = self.collectionView.bounds.size.width - self.sectionInset.left - self.sectionInset.right;
    
    //cell的宽 = (内容的宽 - (列数 - 1) * 最小间距) / 列数
    CGFloat cellW = (contentWidth - self.minimumInteritemSpacing * (self.columnCount-1))/self.columnCount;
    
    //cell的高
    CGFloat cellH = [self.delegate flowLayoutWithItemHight:self andItemW:cellW andCellIndexPath:indexPath];
    
    
    //获取到最矮的那一列,每一次添加时,应该找到最矮的那一列去添加
    NSInteger col = [[self minCol]integerValue];
   
    
    //3、计算cell的X和Y
    
    //计算X
    CGFloat cellX = self.sectionInset.left + (cellW + self.minimumInteritemSpacing) * col;
    
    //当前的列号转换成字典用来当字典的key
    NSString *colStr = [NSString stringWithFormat:@"%ld",col];
    
    //计算Y
    CGFloat cellY = [self.maxYcolDict[colStr]floatValue];
    
    
    //4、累计每一列的高度
    self.maxYcolDict[colStr] = @(cellY +cellH +self.minimumInteritemSpacing);
    
    //5、设置布局属性的frame
    attrs.frame = CGRectMake(cellX, cellY, cellW, cellH);
    
    //6、返回自定义的布局属性
    return attrs;

}


#pragma mark - 用来取出最高那一列的列号
-(NSString *)maxCol{
    
    __block NSString *max = @"0";
    [self.maxYcolDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj floatValue] > [self.maxYcolDict[max]floatValue]) {
            
            max = key;
        }
    }];
    return max;
    
    
}


#pragma mark - 用来取出最矮那一列的列号
-(NSString *)minCol{
    
    __block NSString *min = @"0";
    [self.maxYcolDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj floatValue] < [self.maxYcolDict[min]floatValue]) {
            
            min = key;
        }
    }];
    return min;
    
}



#pragma mark - 如果是自定义布局的时候一定要重写此方法，来返回真实的contentSize"collecitonView滚动范围"
-(CGSize)collectionViewContentSize{
    
    return CGSizeMake(0,[self.maxYcolDict[self.maxCol]floatValue]+self.footerReferenceSize.height - self.minimumLineSpacing);
}


#pragma mark - 返回计算好的所有布局属性
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    
    return self.attrArrM; 
}


#pragma mark - 懒加载实例化用来装所有布局属性的数组
-(NSMutableArray *)attrArrM{
    
    if (_attrArrM==nil) {
        
        //因为还要进行加载，所以不用指定数组的长度
        _attrArrM = [NSMutableArray array];
    }
    return _attrArrM;
}


#pragma mark - 懒加载-用来记录每一列最大的Y
-(NSMutableDictionary *)maxYcolDict{
    
    if (_maxYcolDict == nil) {
        
        _maxYcolDict = [NSMutableDictionary dictionaryWithCapacity:self.columnCount];
    }
    return _maxYcolDict;
}




@end
