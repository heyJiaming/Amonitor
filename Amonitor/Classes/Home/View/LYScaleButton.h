//
//  LYScaleButton.h
//  Amonitor
//
//  Created by iOS程序员 on 16/10/28.
//  Copyright © 2016年 leye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYScaleButton : UIView
@property (nonatomic,assign)BOOL statu;
-(void)image:(UIImage *)image selectImage:(UIImage *)selecImage title:(NSString *)title scale:(float)scale;
@end
