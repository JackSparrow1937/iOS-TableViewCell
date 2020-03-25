//
//  JackViewController.m
//  TableViewCellStyle
//
//  Created by Jack-Sparrow on 2020/3/16.
//  Copyright © 2020 Jack-Sparrow. All rights reserved.
//

#import "JackViewController.h"
#import "JListView.h"

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

@interface JackViewController ()<JListViewDelegate>
@property (nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic, strong)JListView *jList;
@end

@implementation JackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout=UIRectEdgeBottom;//导航栏下方(0,0)开始
    self.title = @"分区模块";
    [self propreData];
    [self foundUI];
}

#pragma mark -- 正则判断是否是数字0-9
-(BOOL)inputShouldNumber:(NSString *)inputString {
    if (inputString.length == 0)
        return NO;
    NSString *regex = @"^[0-9]$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:inputString];
}

- (void)propreData{
    self.dataSource = [[NSMutableArray alloc]init];
    NSArray *itemCounts = @[@(10),@(1),@(5),@(15),@(8)];
    for (int i = 0; i < 5; i++) {
        NSMutableArray *items = [[NSMutableArray alloc]init];
        for (int j = 0; j < [itemCounts[i] intValue]; j++) {
            if(j == 0){
                [items addObject:@{@"title":[NSString stringWithFormat:@"显示标题:%d",j],@"contentTitle":@"和风花雪月浪漫,痴情人多半贪恋,爱恨情仇都好看,又让你痛不欲生,又让你趁醉装疯,终有天脱胎换骨,直到哭着笑才懂,欲问青天这人生有几何,怕这去日苦多,往事讨一杯相思喝,倘若这回还像曾经执着,心执念你一个,那我可能是多情了,浊酒一杯余生不悲不喜,何惧爱恨别离,一路纵马去斟酌,一曲相思入江水与山河,在油伞下走过,悠然入梦却恍若昨,这人间袅袅炊烟,和风花雪月浪漫,痴情人多半贪恋,爱恨情仇都好看,又让你痛不欲生,又让你趁醉装疯,终有天脱胎换骨,直到哭着笑才懂,欲问青天这人生有几何,怕这去日苦多,往事讨一杯相思喝,倘若这回还像曾经执着,心执念你一个,那我可能是多情了,浊酒一杯余生不悲不喜,何惧爱恨别离,一路纵马去斟酌,一曲相思入江水与山河,在油伞下走过,悠然入梦却恍若昨"}];
            }else{
                [items addObject:@{@"title":[NSString stringWithFormat:@"显示标题:%d",j],@"contentTitle":[NSString stringWithFormat:@"显示内容:%d",j]}];
            }
        }
        NSArray *array = [NSArray arrayWithArray:items];
        [self.dataSource addObject:array];
    }
    [self.jList reloadData];
}

#pragma mark --
- (void)foundUI{
    
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = [UIColor whiteColor];
    headView.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
    
    UILabel *title  = [[UILabel alloc]init];
    title.text = @"分区添加阴影";
    title.font = [UIFont boldSystemFontOfSize:22];
    title.textColor = RGBCOLOR(76, 84, 102);
    
    [headView addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView.mas_left).offset(20);
        make.top.equalTo(headView.mas_top).offset(20);
    }];
    
    self.jList.JListViewheadView = headView;
    [self.view addSubview:self.jList];
    [self.jList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(self.view);
    }];
}

#pragma mark -- JListView section个数
- (NSInteger)JListViewNumberForSection{
    return self.dataSource.count;
}

#pragma mark -- JListView cell个数
- (NSInteger)JListViewNumberOfCellForSection:(NSInteger)section{
    return ((NSArray *)self.dataSource[section]).count;
}

#pragma mark -- JListView cell高度
- (CGFloat)JListViewCellHeightWithSection:(NSInteger)section row:(NSInteger)row{
    return 55;
}

#pragma mark -- JListView headView高度
- (CGFloat)JListViewOfHeaderViewHeightWithSection:(NSInteger)section{
    return 40;
}

#pragma mark -- JListView 分区圆角
- (CGFloat)JListViewSectionCornerRadiusWithSection:(NSInteger)section{
    if(section == 0){
        return 0;
    }else{
        return 10;
    }
}

#pragma mark -- JListView headView高度
- (UIColor *)JListViewSectionShaowColorWithSection:(NSInteger)section{
    if(section == 0){
        return nil;
    }else if(section == 1){
        return [UIColor redColor];
    }else{
        return [UIColor colorWithWhite:0 alpha:0.09];
    }
    return nil;
}

#pragma mark -- JListView headView样式
- (UIView *)JListViewOfHeadViewWithSection:(NSInteger)section{
    UIView *headView = [[UIView alloc]init];
    
    UILabel *headTitle = [[UILabel alloc]init];
    headTitle.font = [UIFont systemFontOfSize:10];
    headTitle.text = [NSString stringWithFormat:@"第:%ld分区",(long)section];
    
    [headView addSubview:headTitle];
    [headTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView.mas_left).offset(16);
        make.centerY.equalTo(headView.mas_centerY);
    }];
    return headView;
}

#pragma mark -- JListView cell样式
- (UIView *)JListViewForCell:(NSIndexPath *)indexPath{
    UIView *cellView = [[UIView alloc]init];
    cellView.backgroundColor = [UIColor whiteColor];
    cellView.frame = CGRectMake(16, 0, self.view.frame.size.width - 32, 0);
    UILabel *titleLabel = [[UILabel alloc]init];
    UILabel *contentLabel = [[UILabel alloc]init];
    
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.frame = CGRectMake(16, 20, 100, 20);
    titleLabel.textColor = RGBCOLOR(3, 7, 25);
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.text = [self.dataSource[indexPath.section][indexPath.row] valueForKey:@"title"];
    
    
    contentLabel.font = [UIFont systemFontOfSize:16];
    contentLabel.textColor = RGBCOLOR(135, 139, 153);
    contentLabel.textAlignment = NSTextAlignmentRight;
    contentLabel.text = [self.dataSource[indexPath.section][indexPath.row] valueForKey:@"contentTitle"];
    contentLabel.numberOfLines = 0;
    contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    contentLabel.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame), 20, cellView.frame.size.width - CGRectGetMaxX(titleLabel.frame) - 10, 20);
    
    [cellView addSubview:titleLabel];
    [cellView addSubview:contentLabel];
    
    return cellView;
}

- (void)JListViewdidSelectRowCell:(UIView *)cell indexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击cell:%@  section:%ld   row:%ld",NSStringFromClass([cell class]),indexPath.section,indexPath.row);
}

- (void)JListViewLoadError:(NSString *)errorStr{
    NSLog(@"%@",errorStr);
}

- (JListView *)jList{
    if(!_jList){
        _jList = [[JListView alloc]init];
        _jList.delegate = self;
        _jList.autoAdaptation = YES;
        _jList.backgroundColor = RGBCOLOR(246, 245, 250);
        _jList.separatorStyle = NO;
    }
    return _jList;
}

@end
