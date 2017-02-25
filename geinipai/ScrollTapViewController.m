//
//  ScrollTapViewController.m
//  geinipai
//
//  Created by Jason Geng on 2017/2/25.
//  Copyright © 2017年 Huaining. All rights reserved.
//

#import "ScrollTapViewController.h"
#import "DTScrollStatusView.h"

@interface ScrollTapViewController ()<DTScrollStatusDelegate>
@property (strong,nonatomic) DTScrollStatusView *scrollTapView;
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

-(void) refreshViewWithTag:(int)tag andIsHeader:(BOOL)isHeader {
    if(isHeader){
        if(tag==1){
            UITableView *table = _scrollTapView.tableArr[tag-1];
            [table reloadData];
        }
        NSLog(@"当前第%d个tableview的头部正在刷新",tag);
    } else {
        NSLog(@"当前第%d个tableview的尾部正在刷新",tag);
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    if (tableView.tag == 1) {
        cell.textLabel.text = @"答案";
    }
    else if(tableView.tag == 2)
    {
        cell.textLabel.text = @"讲座";
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1) {
        return 1;
    }
    else
    {
        return 2;
    }
    
}

@end
