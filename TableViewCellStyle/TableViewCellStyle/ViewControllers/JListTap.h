//
//  JListTap.h
//  TableViewCellStyle
//
//  Created by Jack-Sparrow on 2020/3/24.
//  Copyright © 2020 Jack-Sparrow. All rights reserved.
//  JListView 点击时携带indexPath

#import <UIKit/UIKit.h>

@interface JListTap : UITapGestureRecognizer
@property (nonatomic, strong)NSIndexPath *indexPath;
@property (nonatomic, strong)UIView *targetView;
@end
