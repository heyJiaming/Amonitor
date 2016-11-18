//
//  LEBackgroundVIew.h
//  testone
//
//  Created by iOS程序员 on 16/10/9.
//  Copyright © 2016年 leye. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LEBackgroundVIewDelegate <NSObject>

-(void)LEBackgroundVIewSendArray:(NSArray *)array;

@end
@interface LEBackgroundVIew : UIView

// 传入的 值 来控制 初始点的 位置
@property (nonatomic,weak)id <LEBackgroundVIewDelegate>arrayDelegate;

@property (nonatomic,assign)float offsetY;

@property (nonatomic,strong)NSMutableArray *arrM;
@property (nonatomic,assign)float ganv;
@end
