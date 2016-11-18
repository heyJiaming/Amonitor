//
//  LEBackgroundVIew.m
//  testone
//
//  Created by iOS程序员 on 16/10/9.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LEBackgroundVIew.h"
#import "UIView+HMCategory.h"
#import  "LERoundImageView.h"
#import "GCDSocketTools.h"
#define  YELLOWLINECOLOR [UIColor colorWithRed:223/255.0 green:252/255.0 blue:134/255.0 alpha:1]
@interface LEBackgroundVIew ()<LERoundImageViewDelegate>

@property (nonatomic,strong)UILongPressGestureRecognizer *gestureRecognizer;
@property (nonatomic,assign)int pointTag;
// 初始点
@property (nonatomic,assign)CGPoint originalPoint;
//新添加的点
@property (nonatomic,assign)CGPoint newPoint;
//最后的点
@property (nonatomic,assign)CGPoint finalPoint;

// @property (nonatomic,strong)NSMutableArray *arrM;

@property (nonatomic,weak)LERoundImageView *imageView;
@end
@implementation LEBackgroundVIew
// 计算最后一个点的函数 (得到的点是以 (0,0 ))
-(void)getFinalPoint:(CGPoint)point{
    
    CGFloat x = point.x;
    CGFloat y = point.y;
    self.finalPoint = CGPointMake(0, x+y);
    NSString *finalpointStr = NSStringFromCGPoint(self.finalPoint);
    [self.arrM addObject:finalpointStr];
}

-(void)drawRect:(CGRect)rect{
   
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 异步绘制
   // dispatch_queue_t queue = dispatch_queue_create("ding", 0);
  //  dispatch_sync(queue, ^{
        //把数组的第一个点作为第一个点
        [path  moveToPoint:CGPointFromString(self.arrM[0])];
        // 第二个点开始连线
        for (int i= 1;i<self.arrM.count; i++) {
            NSString *str = self.arrM[i];
            CGPoint point = CGPointFromString(str);
            [path addLineToPoint:point];
        }
        //设置绘制的线宽
        path.lineWidth = 2;
        path.lineJoinStyle = kCGLineJoinBevel;
        path.lineCapStyle = kCGLineCapRound;
//         path.strokeColor =  YELLOWLINECOLOR.CGColor;
    [YELLOWLINECOLOR set];
        [path stroke];

    //});
    }
//根据初始化去绘制点
-(void)setArrM:(NSMutableArray *)arrM{
    _arrM = arrM;
    [self drawPointWithArray:arrM];
//    for(int i = 0;i<arrM.count;i++){
//        if(i>0&&i<arrM.count -1){
//            CGPoint p = CGPointFromString(arrM[i]);
//            LERoundImageView *roundView = [[LERoundImageView alloc]initWithImage:[UIImage imageNamed:@"contact"]];
//            roundView.userInteractionEnabled = YES;
//            roundView.center = p;
//            
//            [self addSubview:roundView];
//            
//            roundView.tag= i;
//            roundView.array = arrM;
//            [self setNeedsDisplay];
//            roundView.cancelBlock = ^(NSInteger i){
//                [arrM removeObject:arrM[i]];
//                if([self.arrayDelegate respondsToSelector:@selector(LEBackgroundVIewSendArray:)]){
//                    [self.arrayDelegate LEBackgroundVIewSendArray:self.arrM.copy];
//                    
//                }
//                [self setNeedsDisplay];
//                [self drawPointWithArray:arrM];
//            };
//        }
//    }
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 为这个 View 添加一个 长按的手势
        UILongPressGestureRecognizer *longpPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(greatpoint:)];
         //加入带这个View上
        
        self.gestureRecognizer = longpPressGesture;
        [self addGestureRecognizer:longpPressGesture];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"RoundImageMove" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            NSDictionary *dict = note.object;
            int index =  [[[dict allKeys] lastObject] intValue];
            NSString *pointStr = [[dict allValues] lastObject];
            self.arrM[index] = pointStr;
            // 如果是倒数第一个点的话 最后一个点的位置 就得改变
            if(index == self.arrM.count - 2){
                // 清除掉原来的点 然后一直得到的是新点
                [self.arrM removeLastObject];
            
                [self getFinalPoint:CGPointFromString(pointStr)];
            }
            [self setNeedsDisplay];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"RoundImageMoveEnd" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if([self.arrayDelegate respondsToSelector:@selector(LEBackgroundVIewSendArray:)]){
                [self.arrayDelegate LEBackgroundVIewSendArray:self.arrM.copy];
            }
            
        }];
   }
    return self;
}

// 长按 会添加 添加点
-(void)greatpoint:(UILongPressGestureRecognizer  *)paramsender{
    if(self.arrM.count<6){
    
// 获取到了长按点位置
    CGPoint newPoint = [paramsender locationOfTouch:0 inView:self];
    //手指结束
    if(paramsender.state == UIGestureRecognizerStateBegan){
        //这个位置需要提前做一个逻辑上的判断 (判断的标准是 当前点 对于数组里面的点 碰到第一个x值 大的 就立马替换掉)
       __block int state = 0;
        
        [self.arrM enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGPoint arrPoint = CGPointFromString(obj);
            if(state == 0){
                
                // 一旦当前点 比 数组点 的x 大 就插入
            if(newPoint.x > arrPoint.x){
                state = 1;
                [self.arrM insertObject:NSStringFromCGPoint(newPoint) atIndex:idx];
                
                //NSLog(@"%@",self.arrM);
            
                //self.arrM[idx] = NSStringFromCGPoint(newPoint);
                   [self setNeedsDisplay];
                
                               if(idx == self.arrM.count - 2){
                    [self.arrM removeLastObject];
                    [self getFinalPoint:newPoint];
                }
                
                //把最新的点坐标发出去
                if([self.arrayDelegate respondsToSelector:@selector(LEBackgroundVIewSendArray:)]){
                    [self.arrayDelegate LEBackgroundVIewSendArray:self.arrM.copy];
                }
                // 根据数组 来创建对应的点
                [self drawPointWithArray:self.arrM];
                
//                for (LERoundImageView *view in self.subviews) {
//                    [view removeFromSuperview];
//                 }
//                //根据最新的数组去绘制点
//                // 遍历头尾的点 然后根据所有点去创建
//                for(int i=0; i<self.arrM.count;i++){
//                //第一个点 不用绘制 最后一个点 也不用绘制
//                    if(i>0 && i<self.arrM.count-1){
//                        
//                        LERoundImageView *imageView = [[LERoundImageView alloc]initWithImage:[UIImage imageNamed:@"contact"]];
//                        // 打开交互
//                        imageView.userInteractionEnabled = YES;
//                        
//                        // 为这个imageView 加入一个长按手势
//                        imageView.center = CGPointFromString(self.arrM[i]);
//                        
//                        
//                        [self addSubview:imageView];
//                        
//                       // imageView.tag  = idx;
//                        
//                        imageView.tag = i;
//                        NSLog(@"%zd",idx);
//                        imageView.array = self.arrM;
//                        [self setNeedsDisplay];
//                        
//                        imageView.cancelBlock = ^( NSInteger i){
//                            
//                            [self.arrM removeObject:self.arrM[i]];
//                            //删除掉数组里面的值后 把这个数组的值传出去
//                            if([self.arrayDelegate respondsToSelector:@selector(LEBackgroundVIewSendArray:)]){
//                                [self.arrayDelegate LEBackgroundVIewSendArray:self.arrM.copy];
//                                [self drawPointWithArray:self.arrM];
//                            }
//                            [self setNeedsDisplay];
//                        };
//                    }
//                
//                }
 
            }
                }
        }];
}
    }
}

// 根据数组去绘制点
-(void)drawPointWithArray:(NSMutableArray *)array{
    
    for (LERoundImageView *view in self.subviews) {
        [view removeFromSuperview];
    }
    //根据最新的数组去绘制点
    
    for(int i=0; i<array.count;i++){
        //第一个点 不用绘制 最后一个点 也不用绘制
        if(i>0 && i<array.count-1){
            
            LERoundImageView *imageView = [[LERoundImageView alloc]initWithImage:[UIImage imageNamed:@"contact"]];
            self.imageView = imageView;
            imageView.delegate = self;
           // imageView.ganv = self.ganv;
            // 打开交互
            imageView.userInteractionEnabled = YES;
            
            // 为这个imageView 加入一个长按手势
            imageView.center = CGPointFromString(self.arrM[i]);

            
            [self addSubview:imageView];
            
            // imageView.tag  = idx;
            
            imageView.tag = i;
            imageView.array = array;
            [self setNeedsDisplay];
            
            imageView.cancelBlock = ^( NSInteger i){
                
                //如果删除的是最后一个点 情况会变化
                
                if(i<array.count-1){
                    [array removeObject:array[i]];
                    [array removeObject:array.lastObject
                     ];
                    [self getFinalPoint:CGPointFromString(array.lastObject)];
                    //[array addObject:NSStringFromCGPoint([self getFinalPoint:CGPointFromString(array.lastObject)])];
                }else{
                 [array removeObject:array[i]];
                }
                
               
                
                //删除掉数组里面的值后 把这个数组的值传出去
                if([self.arrayDelegate respondsToSelector:@selector(LEBackgroundVIewSendArray:)]){
                    [self.arrayDelegate LEBackgroundVIewSendArray:array.copy];
                    [self drawPointWithArray:array];
                }
                [self setNeedsDisplay];
            };
        }
        
    }


}

-(void)roundImage:(LERoundImageView *)roundaImage{

        NSLog(@"round2-Scan %f",self.ganv);
        if(roundaImage.frame.origin.y+roundaImage.frame.size.height/2 < 30 + self.ganv*3){
            roundaImage.centerY = 30+self.ganv*3;
        }else if(roundaImage.frame.origin.y+roundaImage.frame.size.height/2 > 301 +30 +self.ganv*3 ){
            roundaImage.centerY = 301 +30 +self.ganv*3;
        }

}
@end
