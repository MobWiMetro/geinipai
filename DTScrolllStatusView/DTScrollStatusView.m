//
//  DTScrollStatusView.m

//
//  Created by zhenyong on 16/4/30.
//  Copyright © 2016年 com.lnl. All rights reserved.
//

#import "DTScrollStatusView.h"
#import "XRCollectionViewCell.h"
#import "XRWaterfallLayout.h"

@implementation DTScrollStatusView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame andTitleArr:(NSArray *)titleArr;
{
    self = [super initWithFrame:frame];
    [self setStatusViewWithTitle:titleArr];
    return self;
}
-(instancetype)initWithTitleArr:(NSArray *)titleArr andType:(ScrollTapType)type
{
    if (type == ScrollTapTypeWithNavigation) {
        self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64)];
    }
    else if(type == ScrollTapTypeWithNavigationAndTabbar)
    {
        self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64-49)];
    }
    else if(type == ScrollTapTypeWithNothing)
    {
        self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    }
    [self setStatusViewWithTitle:titleArr];
    return self;
}
-(instancetype)initWithTitleArr:(NSArray *)titleArr andType:(ScrollTapType)type andNormalTabColor:(UIColor *)normalTabColor andSelectTabColor:(UIColor *)selectTabColor
{
    if (type == ScrollTapTypeWithNavigation) {
        self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64)];
    }
    else if(type == ScrollTapTypeWithNavigationAndTabbar)
    {
        self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64-49)];
    }
    else if(type == ScrollTapTypeWithNothing)
    {
        self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    }
    curNormalTabColor = normalTabColor;
    curSelectTabColor = selectTabColor;
    [self setStatusViewWithTitle:titleArr];
    return self;

}

-(void)setStatusViewWithTitle:(NSArray *)titleArr
{
    float height = self.frame.size.height;
    self.statusView = [[DTStatusView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 45)];
    self.statusView.delegate = self;
    self.statusView.isScroll = YES;
    if (curNormalTabColor && curSelectTabColor) {
        [self.statusView setUpStatusButtonWithTitle:titleArr NormalColor:curNormalTabColor SelectedColor:curSelectTabColor LineColor:curSelectTabColor];
    }
    else
    {
    [self.statusView setUpStatusButtonWithTitle:titleArr NormalColor:DTColor(154, 156, 156, 1) SelectedColor:DTColor(10, 193, 147, 1) LineColor:DTColor(10, 193, 147, 1)];
    }
    [self addSubview:self.statusView];
    float y = 45;
    UIView *sessionLine = [[UIView alloc]initWithFrame:CGRectMake(0, y, kScreenWidth, 5)];
    sessionLine.backgroundColor = DTColor(242, 242, 242, 1);
    [self addSubview:sessionLine];
    y+=5;
    //
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, y, kScreenWidth, height-y)];
    _mainScrollView.delegate = self;
    _mainScrollView.bounces = NO;
    float mainScrollH = _mainScrollView.frame.size.height;
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.contentSize = CGSizeMake(kScreenWidth*titleArr.count, mainScrollH);
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_mainScrollView];
    _collectionArr = [NSMutableArray array];
    for ( int i = 0; i < titleArr.count; i++) {
        //创建瀑布流布局
        XRWaterfallLayout *waterfall = [XRWaterfallLayout waterFallLayoutWithColumnCount:3];
        
        //设置各属性的值
        //    waterfall.rowSpacing = 10;
        //    waterfall.columnSpacing = 10;
        //    waterfall.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        
        //或者一次性设置
        [waterfall setColumnSpacing:10 rowSpacing:10 sectionInset:UIEdgeInsetsMake(10, 10, 10, 10)];
        
        
        //设置代理，实现代理方法
        waterfall.delegate = self;
        /*
         //或者设置block
         [waterfall setItemHeightBlock:^CGFloat(CGFloat itemWidth, NSIndexPath *indexPath) {
         //根据图片的原始尺寸，及显示宽度，等比例缩放来计算显示高度
         XRImage *image = self.images[indexPath.item];
         return image.imageH / image.imageW * itemWidth;
         }];
         */
        //创建collectionView
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kScreenWidth*i, 0, kScreenWidth, mainScrollH) collectionViewLayout:waterfall];
        collectionView.backgroundColor = [UIColor whiteColor];
        [collectionView registerNib:[UINib nibWithNibName:@"XRCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
        collectionView.dataSource = self;
        collectionView.tag = i+1;
        __weak DTScrollStatusView *weakSelf = self;
        collectionView.mj_header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            isrefresh = YES;
            if (_scrollStatusDelegate) {
                
                [weakSelf.scrollStatusDelegate refreshViewWithTag:i+1 andIsHeader:YES];
                [collectionView.mj_header endRefreshing];
                isrefresh = NO;
            }
        }];
        collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            isrefresh = YES;
            if (_scrollStatusDelegate) {
                isrefresh = YES;
                [weakSelf.scrollStatusDelegate refreshViewWithTag:i+1 andIsHeader:NO];
            }
            [collectionView.mj_footer endRefreshing];
            isrefresh = NO;
        }];
        [_collectionArr addObject:collectionView];
        [_mainScrollView addSubview:collectionView];
    }
    //获取当前tableview
    if (_collectionArr.count > 0) {
        _curCollection = _collectionArr[0];
    }
}
#pragma mark--delegate
-(CGFloat)waterfallLayout:(XRWaterfallLayout *)waterfallLayout itemHeightForWidth:(CGFloat)itemWidth atIndexPath:(NSIndexPath *)indexPath
{
    if (_scrollStatusDelegate) {
        if ([_scrollStatusDelegate respondsToSelector:@selector(waterfallLayout:itemHeightForWidth:atIndexPath:)]) {
            return [_scrollStatusDelegate waterfallLayout:waterfallLayout itemHeightForWidth:itemWidth atIndexPath:indexPath];
        }
    }
    return 0;
}
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_scrollStatusDelegate) {
        if ([_scrollStatusDelegate respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            return [_scrollStatusDelegate collectionView:collectionView numberOfItemsInSection:section];
        }
    }
    return 0;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_scrollStatusDelegate collectionView:collectionView cellForItemAtIndexPath:indexPath];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(![scrollView isKindOfClass:[UITableView class]])
    {
    if (isrefresh == NO) {
        int scrollIndex = scrollView.contentOffset.x/kScreenWidth;
        [_statusView changeTag:scrollIndex];
        _curCollection = _collectionArr[scrollIndex];
    }
    }
}
- (void)statusViewSelectIndex:(NSInteger)index;
{
    
   [_mainScrollView setContentOffset:CGPointMake(kScreenWidth*index, 0) animated:YES];
    _curCollection = _collectionArr[index];
}
@end
