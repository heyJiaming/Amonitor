//
//  LYColorBlockView.m
//  Amonitor
//
//  Created by iOS程序员 on 16/10/31.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYColorBlockView.h"

@implementation LYColorBlockView

-(void)setColorArray:(NSArray *)colorArray{
    _colorArray = colorArray;
    
    
    //需要先移除所有的子空间
    for (UIView *sview in self.subviews) {
        [sview removeFromSuperview];
    }
    
    float y = 12;
    float w = 9;
    float h = 9;
    float disX = 13;
    float margin = 2.5;
    
    //根据colorArray 去创建 小色块
    for(int i = 0;i<8 ; i++){
         UIView *colorView =[UIView new];
        if(i<colorArray.count){
            colorView.backgroundColor = colorArray[i];
        }else{
            colorView.backgroundColor = [UIColor blackColor];
        }
        int x = disX +i*(w+margin);
        
        colorView.frame = CGRectMake(x, y, w, h);
     
        //然后添加新的
        [self addSubview:colorView];
    }
}

-(void)setCurrentStatus:(BOOL)currentStatus{
    _currentStatus = currentStatus;
    if(currentStatus == NO){
        self.image = [UIImage imageNamed:@"btn-2bg-n"];
    }else if(currentStatus == YES) {
    self.image = [UIImage imageNamed:@"btn-2bg-h"];
    //当前状态为YES的时候 把当前接收到到的数组 去创建ks
        [[NSNotificationCenter defaultCenter] postNotificationName:@"colorBlocArray" object:@[self.colorArray ,@(self.tag)]];
    }
}
@end
