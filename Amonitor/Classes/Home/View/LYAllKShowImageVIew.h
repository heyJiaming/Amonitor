//
//  LYAllKShowImageVIew.h
//  Amonitor
//
//  Created by iOS程序员 on 16/11/8.
//  Copyright © 2016年 leye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYAllKShowImageVIew : UIView
// 接受到的数据
@property (nonatomic,strong)NSArray *array;

-(void)clickKshow:(UITapGestureRecognizer *)gesture;
@end
