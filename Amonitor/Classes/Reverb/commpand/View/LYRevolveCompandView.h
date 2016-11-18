//
//  LYRevolveCompandView.h
//  Amonitor
//
//  Created by iOS程序员 on 16/11/2.
//  Copyright © 2016年 leye. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LYRevolveCompandView;
@protocol LYRevolveCompandViewDelegate <NSObject>
// 带参数 控制lable的显示和隐藏
-(void)revolveCompand:(LYRevolveCompandView *)view showLable:(BOOL)hidden showValue:(float)y;
@end

@interface LYRevolveCompandView : UIImageView
@property (nonatomic,weak)id <LYRevolveCompandViewDelegate>delegate;

@property (nonatomic,copy) NSString *StartNumble;
@end
