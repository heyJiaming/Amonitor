//
//  LYAllColorBlock.m
//  Amonitor
//
//  Created by iOS程序员 on 16/11/8.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYAllColorBlock.h"
#import "LYColorBlockView.h"
@interface LYAllColorBlock()
@property (nonatomic,strong)LYColorBlockView *selectedColorBlockView;
@end

@implementation LYAllColorBlock

-(void)setColorArray:(NSArray *)colorArray{
    _colorArray = colorArray;
    
    
    //按8个一组分好数组
  NSArray *AllColorArray = [self getNewArrayWithArray:colorArray];
  
    //先移除所有的子控件
    for (LYColorBlockView *view in self.subviews) {
        [view removeFromSuperview];
    }
    //----创建上面的小方块--
    float colorMarginX = 143;
    float colorY = 14;
    float colorW = 113.5;
    float colorH = 36;
    float colorMargin = 12;
    for(int i = 0;i<6;i++){
        NSLog(@"%d",i);
        float colorX = colorMarginX + (colorW + colorMargin)*i;
        LYColorBlockView  *colorBlockView = [[LYColorBlockView alloc]init];
         colorBlockView.tag = i+1;
        colorBlockView.userInteractionEnabled = YES;
        //添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickTap:)];;
        [colorBlockView addGestureRecognizer:tap];
        
        colorBlockView.frame = CGRectMake(colorX, colorY, colorW, colorH);
       
        
        // colorBlockView.colorArray = AllColorArray[i];
        [self addSubview:colorBlockView];
        if(i<AllColorArray.count){
            colorBlockView.colorArray = AllColorArray[i];
        }else{
            colorBlockView.colorArray = [NSArray array];
        }
        if(i == 0 ){
            // self.selectedColorBlockView = colorBlockView;
            colorBlockView.currentStatus = YES;
            self.selectedColorBlockView = colorBlockView;
        }else{
            colorBlockView.currentStatus = NO;
           // colorBlockView.colorArray = [NSArray array];
        }
    }
}

-(void)clickTap:(UITapGestureRecognizer *)recognizer{
    LYColorBlockView *currentSelectedView = (LYColorBlockView *)recognizer.view;
    if(currentSelectedView.currentStatus == NO){
        self.selectedColorBlockView.currentStatus = NO;
        currentSelectedView.currentStatus = YES;
        self.selectedColorBlockView = currentSelectedView;

        // [[NSNotificationCenter defaultCenter] postNotificationName:@"returnDiscover" object:nil];
        //切换标签的通知
          [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorClockChangeIndex" object:@(currentSelectedView.tag)];
        
    }
}
-(NSArray *)getNewArrayWithArray:(NSArray *)arr{
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *array = arr.mutableCopy;
    while (array.count > 8) {
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:8];
        for(int i = 0 ;i<8;i++){
            [temp addObject:array[i]];
        }
        [mutableArray addObject:temp.copy];
        [array removeObjectsInRange:NSMakeRange(0,8)];
    }
    if(arr != nil){
    
     [mutableArray addObject:array.copy];
    }
   
    NSLog(@"%@",mutableArray.copy);
    return mutableArray.copy;
}
@end
