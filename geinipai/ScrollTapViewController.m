//
//  ScrollTapViewController.m
//  geinipai
//
//  Created by Jason Geng on 2017/2/25.
//  Copyright © 2017年 Huaining. All rights reserved.
//

#import "ScrollTapViewController.h"
#import "DTScrollStatusView.h"
#import "XRCollectionViewCell.h"
#import "XRImage.h"

@interface ScrollTapViewController ()<DTScrollStatusDelegate>
@property (strong,nonatomic) DTScrollStatusView *scrollTapView;
@property (nonatomic, strong) NSMutableArray<XRImage *> *images;
@end

@implementation ScrollTapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *orange = [UIColor orangeColor];
    _scrollTapView = [[DTScrollStatusView alloc] initWithTitleArr:@[@"问答",@"讲座"] andType:ScrollTapTypeWithNothing andNormalTabColor:DTColor(0x6D, 0x6D, 0x72, 0xFF) andSelectTabColor:orange];
    _scrollTapView.scrollStatusDelegate = self;
    [self.view addSubview:_scrollTapView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)images {
    //从plist文件中取出字典数组，并封装成对象模型，存入模型数组中
    if (!_images) {
        _images = [NSMutableArray array];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"1.plist" ofType:nil];
        NSArray *imageDics = [NSArray arrayWithContentsOfFile:path];
        for (NSDictionary *imageDic in imageDics) {
            XRImage *image = [XRImage imageWithImageDic:imageDic];
            [_images addObject:image];
        }
    }
    return _images;
}

-(void) refreshViewWithTag:(int)tag andIsHeader:(BOOL)isHeader {
    if(isHeader){
        if(tag==1){
            UITableView *table = _scrollTapView.collectionArr[tag-1];
            [table reloadData];
        }
        NSLog(@"当前第%d个tableview的头部正在刷新",tag);
    } else {
        NSLog(@"当前第%d个tableview的尾部正在刷新",tag);
    }
}

-(CGFloat)waterfallLayout:(XRWaterfallLayout *)waterfallLayout itemHeightForWidth:(CGFloat)itemWidth atIndexPath:(NSIndexPath *)indexPath
{
    //根据图片的原始尺寸，及显示宽度，等比例缩放来计算显示高度
    XRImage *image = self.images[indexPath.item];
    return image.imageH / image.imageW * itemWidth;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XRCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageURL = self.images[indexPath.item].imageURL;
    return cell;
}

@end
