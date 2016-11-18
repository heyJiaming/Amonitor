//
//  LYAllColorBlock.h
//  Amonitor
//
//  Created by iOS程序员 on 16/11/8.
//  Copyright © 2016年 leye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYAllColorBlock : UIView
@property (nonatomic,strong)NSArray *colorArray;
// 点击方法
-(void)clickTap:(UITapGestureRecognizer *)recognizer;
@end
