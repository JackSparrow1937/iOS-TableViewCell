//
//  JListView.m
//  TableViewCellStyle
//
//  Created by Jack-Sparrow on 2020/3/23.
//  Copyright © 2020 Jack-Sparrow. All rights reserved.
//

#import "JListView.h"
#import "JListTap.h"

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define LineLabelColor RGBCOLOR(214, 221, 226)

@interface JListView()
@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)NSMutableArray *nums;//cell数
@property (nonatomic, strong)NSMutableArray *headViews;//头部view集合 由字典组成:@"view"/@"height"/@"section" 三个参数
@property (nonatomic, strong)NSMutableArray *cellViews;//cell的集合 由字典组织:@"view"/@"height"/@"indexPath" 三个参数
@property (nonatomic, strong)NSMutableArray *sectionStyle;//分区级别添加样式列表 由字典组成:@"radius"/@"color"

@property (nonatomic, assign)CGFloat contentSizeHeight;//滚动视图的滚动高度

@end
@implementation JListView

//滚动视图和父类视图的背景色保持一致
- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    self.scrollView.backgroundColor = backgroundColor;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [self initUI];
}

- (void)initUI{
    self.separatorStyle = YES;
    self.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    [self addSubview:self.scrollView];
}

#pragma mark -- 加载数据
- (void)reloadData{
    self.contentSizeHeight = 0;
    [self getNumsOfCellAndSection];//获取全部cell
    [self getHeadView];//获取头部标题
    [self getShaowAndRadius];//获取分区样式
    
    //cellview用约束布局时,延迟0.1秒.获取frame
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getCellView];//获取cell, 需要根据内容适配cell.
        [self foundUI];
    });
}

#pragma mark -- 开始布局cell和headView
- (void)foundUI{
    
    //加载前清除原有数据
    for (UIView *subView in self.scrollView.subviews) {
        if ([subView respondsToSelector:@selector(removeFromSuperview)]) {
            [subView removeFromSuperview];
        }
    }
    
    CGFloat YShat;
    if(self.JListViewheadView != nil){
        self.contentSizeHeight = self.contentSizeHeight + CGRectGetMaxY(self.JListViewheadView.frame);
        [self.scrollView addSubview:self.JListViewheadView];
        YShat = CGRectGetMaxY(self.JListViewheadView.frame);
    }else{
        YShat = 0;
    }
    
    //设置scrollerView的contentSize
    self.scrollView.contentSize = CGSizeMake(0, self.contentSizeHeight);
    
    
    //布局UI
    for (int i = 0; i < self.nums.count; i++) {//布局headView
        
        NSInteger section = [[self.nums[i] valueForKey:@"section"] integerValue];
        NSInteger rowCount = [[self.nums[i] valueForKey:@"row"] integerValue];
        NSDictionary *headDict = self.headViews[section];
        id headPara = [headDict valueForKey:@"view"];
        CGFloat headViewHeight = [[headDict valueForKey:@"height"] floatValue];
        if(headPara != nil){
            if([headPara isKindOfClass:[UIView class]]){
                UIView *headView = (UIView *)headPara;
                headView.frame = CGRectMake(0, YShat, self.scrollView.frame.size.width, headViewHeight);
                [self.scrollView addSubview:headPara];
                YShat = YShat + headViewHeight;
            }
        }
        
        CGPoint shadowStartPoint = CGPointMake(0, YShat);
        CGPoint shadowEndPoint = CGPointMake(0, 0);
        
        
        //分区cell带有圆角
        CGFloat raduis = 0;
        if(self.sectionStyle.count != 0){
            if(![[self.sectionStyle[section] valueForKey:@"radius"] isKindOfClass:[NSString class]]){
                raduis = [[self.sectionStyle[section] valueForKey:@"radius"] floatValue];
            }
        }
        
        for (NSInteger j = 0; j < rowCount; j++) {//布局cell
            NSDictionary *cellDict = (NSDictionary *)self.cellViews[section][j];
            UIView *cellView = [cellDict valueForKey:@"view"];
            CGFloat cellHeight = [[cellDict valueForKey:@"height"] floatValue];
            cellView.frame = CGRectMake(CGRectGetMinX(cellView.frame), YShat, CGRectGetWidth(cellView.frame), cellHeight);
            
            if(raduis != 0){
                UIRectCorner cornerRadius = 100;
                CGFloat viewRadius = 0;
                if(j == 0){//设置第一个cell的圆角
                    if(j == rowCount - 1){
                        cornerRadius = UIRectCornerAllCorners;
                    }else{
                        cornerRadius = UIRectCornerTopRight | UIRectCornerTopLeft;
                    }
                    viewRadius = raduis;
                }else if (j == rowCount - 1){//设置最后一个cell的圆角
                    cornerRadius = UIRectCornerBottomLeft | UIRectCornerBottomRight;
                    viewRadius = raduis;
                }
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:cellView.bounds
                                                           byRoundingCorners:cornerRadius
                                                                 cornerRadii:CGSizeMake(viewRadius, viewRadius)];
                CAShapeLayer *shapeLayer = [CAShapeLayer layer];
                shapeLayer.frame = cellView.bounds;
                shapeLayer.path = path.CGPath;
                cellView.layer.mask = shapeLayer;
            }else{
                
            }
            
            [self.scrollView addSubview:cellView];
            YShat = YShat + cellView.frame.size.height;
            //记录阴影位置
            shadowStartPoint = CGPointMake(cellView.frame.origin.x, shadowStartPoint.y);
            shadowEndPoint = CGPointMake(CGRectGetMaxX(cellView.frame), YShat);
            
            if(self.separatorStyle && j != rowCount - 1){
                UILabel *lineLabel = [[UILabel alloc]init];
                lineLabel.frame = CGRectMake(0, CGRectGetHeight(cellView.frame) - 0.5, cellView.frame.size.width, 0.5);
                lineLabel.backgroundColor = LineLabelColor;
                [cellView addSubview:lineLabel];
                [cellView bringSubviewToFront:lineLabel];
            }
            //添加点击事件
            [self addTapToViewAtRow:j section:section targetView:cellView];
        }
        
        //添加分区的阴影
        [self addSectionShaowStartPoint:shadowStartPoint endPoint:shadowEndPoint section:section];
    }
}

//添加点击事件
- (void)addTapToViewAtRow:(NSInteger)row section:(NSInteger)section targetView:(UIView *)taghetView{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    //添加点击事件
    JListTap *tap = [[JListTap alloc]init];
    tap.indexPath = indexPath;
    tap.targetView = taghetView;
    [tap addTarget:self action:@selector(cellSelected:)];
    [taghetView addGestureRecognizer:tap];
}

#pragma mark -- 添加点击手势
- (void)cellSelected:(JListTap *)sender{
    if([self.delegate respondsToSelector:@selector(JListViewdidSelectRowCell:indexPath:)]){
        [self.delegate JListViewdidSelectRowCell:sender.targetView indexPath:sender.indexPath];
    }
}

#pragma mark -- 给分区添加阴影
- (void)addSectionShaowStartPoint:(CGPoint)start endPoint:(CGPoint)end section:(NSUInteger)section{
    
    if(self.sectionStyle.count >= section){
        if([self.sectionStyle[section] valueForKey:@"color"] != nil && [[self.sectionStyle[section] valueForKey:@"color"] isKindOfClass:[UIColor class]]){
            UIView *shadowView = [[UIView alloc]init];
            shadowView.frame = CGRectMake(start.x, start.y, end.x - start.x, end.y - start.y);
            [self.scrollView addSubview:shadowView];
            [self.scrollView sendSubviewToBack:shadowView];
            
            CGFloat raduis = [[self.sectionStyle[section] valueForKey:@"radius"] floatValue];
            //shadowView.layer.masksToBounds = YES;
            shadowView.layer.cornerRadius = raduis;
            
            UIColor *shadowColor = (UIColor *)[self.sectionStyle[section] valueForKey:@"color"];
            // 因为shandowOffset默认为(0,3),此处需要修正下
            shadowView.layer.shadowOffset = CGSizeMake(0, 0);
            shadowView.layer.shadowColor = shadowColor.CGColor;//RGBACOLOR(255, 255, 255, 1).CGColor;
            shadowView.layer.shadowOpacity = 1;
            // 设置阴影的路径 此处效果为在view周边添加宽度为4的阴影效果
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(-3, -3, CGRectGetWidth(shadowView.frame) + 6, CGRectGetHeight(shadowView.frame) + 6)];
            shadowView.layer.shadowPath = path.CGPath;
        }
    }
}

#pragma mark -- 获取cell和section个数
- (void)getNumsOfCellAndSection{
    //获取cell和section 个数整合
    if([self.delegate JListViewNumberForSection] <= 0){
        NSInteger cellNum = [self.delegate JListViewNumberOfCellForSection:0];
        if(cellNum > 0){
            [self.nums addObject:@{@"section":@"0",@"row":@(cellNum)}];
        }else{
            if([self.delegate respondsToSelector:@selector(JListViewLoadError:)]){
                [self.delegate JListViewLoadError:@"JListViewNumberOfCellForSection 方法未实现,或者返回0"];
            }
        }
    }else{
        NSInteger sectionNum = [self.delegate JListViewNumberForSection];
        for (int i = 0; i < sectionNum; i++) {
            NSInteger cellNum = [self.delegate JListViewNumberOfCellForSection:i];
            [self.nums addObject:@{@"section":@(i),@"row":@(cellNum)}];
        }
    }
}

#pragma mark -- 获取headView
- (void)getHeadView{
    //遍历nums,获取全部section.并保存headView的height和view
    for (int i = 0; i < self.nums.count; i++) {
        NSInteger section = [[self.nums[i] valueForKey:@"section"] integerValue];
        id headView;

        if([self.delegate respondsToSelector:@selector(JListViewOfHeadViewWithSection:)]){
            headView = [self.delegate JListViewOfHeadViewWithSection:section];
            if(headView == nil){
                headView = @"withoutview";
            }
        }else{
            headView = @"withoutview";
        }
        
        CGFloat headViewHeight = 0;
        if([self.delegate respondsToSelector:@selector(JListViewOfHeaderViewHeightWithSection:)]){
            headViewHeight = [self.delegate JListViewOfHeaderViewHeightWithSection:section];
        }
        
        if(headViewHeight <= 0){
            headViewHeight = 0;
        }
        
        self.contentSizeHeight = self.contentSizeHeight + headViewHeight;
        NSDictionary *headItem = @{@"section":@(section),@"view":headView,@"height":@(headViewHeight)};
        [self.headViews addObject:headItem];
    }
}

#pragma mark -- 获取全部cell
- (void)getCellView{
    for (int i = 0; i < self.nums.count; i++) {
        NSInteger section = [[self.nums[i] valueForKey:@"section"] integerValue];
        NSInteger rowCount = [[self.nums[i] valueForKey:@"row"] integerValue];//row的总数
        
        NSMutableArray *cellArray = [[NSMutableArray alloc]init];
        for (NSInteger j = 0; j < rowCount; j++) {//获取每一个分区下的每一个cell
            
            NSInteger row = j;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UIView *cellView = [self.delegate JListViewForCell:indexPath];
            
            CGFloat cellHeight = 20;
            if([self.delegate respondsToSelector:@selector(JListViewCellHeightWithSection:row:)]){
                cellHeight = [self.delegate JListViewCellHeightWithSection:section row:row];
            }
            
            if (cellHeight <= 0) {
                cellHeight = 20;
            }
            if (cellView == nil) {
                [self.delegate JListViewLoadError:[NSString stringWithFormat:@"cellView为空,row:%ld  section:%ld",(long)row,(long)section]];
            }
            NSDictionary *cellItem;
            if(self.autoAdaptation){//根据文字内容适配cell高度
                CGFloat cellAutoHeight = [self getTextHeight:cellView defaultHeight:cellHeight];
                self.contentSizeHeight = self.contentSizeHeight + cellAutoHeight;
                cellItem = @{@"view":cellView,@"height":@(cellAutoHeight),@"indexPath":indexPath};
            }else{
                self.contentSizeHeight = self.contentSizeHeight + cellHeight;
                cellItem = @{@"view":cellView,@"height":@(cellHeight),@"indexPath":indexPath};
            }
            [cellArray addObject:cellItem];
        }
        [self.cellViews addObject:cellArray];
    }
}

#pragma mark -- 根据文字获取高度. 遍历所有子label, 超过默认高度,给定新高度. 否则给定默认高度.
- (CGFloat)getTextHeight:(UIView *)cellView defaultHeight:(CGFloat)defaultHeight{
    CGFloat height = defaultHeight;
    for (UIView *subView in cellView.subviews) {
        if([subView isKindOfClass:[UILabel class]]){
            UILabel *label = (UILabel *)subView;
            CGFloat lineSpace = 5;
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineSpacing = lineSpace;
            paragraphStyle.alignment = label.textAlignment;
            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
            label.attributedText = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
            
            //文字高度
            CGFloat labelHeight = [self getString:label.text lineSpacing:lineSpace font:label.font width:label.frame.size.width];
            
            //原label高度
            CGFloat oldLabelHeight = label.frame.size.height;
            
            if(oldLabelHeight < labelHeight){//重新给定根据文字适配的控件高度
                height = labelHeight + defaultHeight - oldLabelHeight;
                label.frame = CGRectMake(CGRectGetMinX(label.frame), CGRectGetMinY(label.frame), CGRectGetWidth(label.frame), labelHeight);
            }
        }
    }
    return height;
}

//获取文字高度
- (CGFloat)getString:(NSString *)string lineSpacing:(CGFloat)lineSpacing font:(UIFont*)font width:(CGFloat)width {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineSpacing = lineSpacing;
    NSDictionary *dic = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle };
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return  ceilf(size.height);
}

#pragma mark -- 获取shaow集合
- (void)getShaowAndRadius{
    for (int i = 0; i < self.nums.count; i++) {
        NSInteger section = [[self.nums[i] valueForKey:@"section"] integerValue];
        NSMutableDictionary *styleDict = [[NSMutableDictionary alloc]init];
        //获取阴影
        if([self.delegate respondsToSelector:@selector(JListViewSectionShaowColorWithSection:)]){
            UIColor *color = [self.delegate JListViewSectionShaowColorWithSection:section];
            if(color != nil){
                [styleDict setValue:color forKey:@"color"];
            }else{
                [styleDict setValue:@"withcolor" forKey:@"color"];
            }
        }
        //获取圆角
        if([self.delegate respondsToSelector:@selector(JListViewSectionCornerRadiusWithSection:)]){
            CGFloat radius = [self.delegate JListViewSectionCornerRadiusWithSection:section];
            if(radius >= 0){
                [styleDict setValue:@(radius) forKey:@"radius"];
            }else{
                [styleDict setValue:@"withoutradius" forKey:@"raduis"];
            }
        }
        [self.sectionStyle addObject:styleDict];
    }
}

- (NSArray *)headViews{
    if(!_headViews){
        _headViews = [[NSMutableArray alloc]init];
    }
    return _headViews ;
}

- (NSMutableArray *)cellViews{
    if(!_cellViews){
        _cellViews = [[NSMutableArray alloc]init];
    }
    return _cellViews;
}

- (NSMutableArray *)nums{
    if(!_nums){
        _nums = [[NSMutableArray alloc]init];
    }
    return _nums;
}

- (NSMutableArray *)sectionStyle{
    if(!_sectionStyle){
        _sectionStyle = [[NSMutableArray alloc]init];
    }
    return _sectionStyle;
}

- (UIScrollView *)scrollView{
    if(!_scrollView){
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}
@end
