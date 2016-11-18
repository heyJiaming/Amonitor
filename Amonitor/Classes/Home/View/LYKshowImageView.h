//
//  LYKshowImageView.h
//  Amonitor
//
//  Created by iOS程序员 on 16/10/31.
//  Copyright © 2016年 leye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYKshowImageView : UIImageView

// 传入这个是确定最后选择的图片
@property(nonatomic,copy)NSString *colorStr;

// 确定选中的状态
@property (nonatomic,assign)BOOL selStatu;

//把副标题暴露出来
@property (nonatomic,copy)NSString *subtitle;



- (void)imageWithTitle:(NSString *)title  subTitle:(NSString *)subTitle changeTitle:(NSString *)idStr color:(UIColor *)color;
@end
