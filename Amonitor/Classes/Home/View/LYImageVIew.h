//
//  LYImageVIew.h
//  Amonitor
//
//  Created by iOS程序员 on 16/10/31.
//  Copyright © 2016年 leye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYImageVIew : UIImageView
@property (nonatomic,assign) float scaleValue;
-(void)image:(UIImage *)img title:(NSString *)str color:(UIColor *)color;
@end
