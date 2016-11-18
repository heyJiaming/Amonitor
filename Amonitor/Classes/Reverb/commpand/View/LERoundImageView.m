//
//  LERoundImageView.m
//  testone
//
//  Created by iOS程序员 on 16/10/17.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LERoundImageView.h"
#import "UIView+HMCategory.h"
#import "LYCompandMode.h"
@interface LERoundImageView ()
@property (nonatomic,assign)float ganv;
@end

@implementation LERoundImageView

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        UILongPressGestureRecognizer *longpresee = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cancelClickbottom:)];
       // longpresee.minimumPressDuration = 2;
        [self addGestureRecognizer:longpresee];
    }
    return self;
}
-(void)cancelClickbottom:(UILongPressGestureRecognizer *)gesture{
    
    if(gesture.state == UIGestureRecognizerStateBegan){
    if(self.cancelBlock){
        self.cancelBlock(self.tag);
    }
    [self removeFromSuperview];
    }
}
CGPoint originaRoundLocation;
// 让这个图案 和自己的手指一起移动的
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
   originaRoundLocation =  [touch locationInView:self];
    //self.transform = CGAffineTransformMakeScale(2, 2);
    self.image  = [UIImage imageNamed:@"contact-click"];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // self.transform = CGAffineTransformMakeScale(2, 2);
    self.image = [UIImage imageNamed:@"contact-click"];
   

    UITouch *touch = touches.anyObject;
    CGPoint currentPoint = [touch locationInView:self];
    
    //设置偏移
 CGFloat offsetY = currentPoint.y - originaRoundLocation.y;
    CGFloat offsetX = currentPoint.x - originaRoundLocation.x;
    self.x += offsetX;
    self.y += offsetY;
 
    if([self.delegate respondsToSelector:@selector(roundImage:)]){
        [self.delegate roundImage:self];
    }
//    NSLog(@"round2-Scan %f",self.ganv);
//    if(self.frame.origin.y+self.frame.size.height/2 < 30 + self.ganv){
//        self.centerY = 30+self.ganv;
//    }else if(self.frame.origin.y+self.frame.size.height/2 >301 +30 + self.ganv ){
//        self.centerY = 301 +30+self.ganv;
//    }
    
    
    // 获取当前点的上一个 下一个坐标点
    // 获取这个点的上一个点 和 下一个点
    NSString *perPointStr = self.array[self.tag-1];
    CGPoint perPoint = CGPointFromString(perPointStr);
    NSString *lastPointStr = self.array[self.tag + 1];
    CGPoint lastPoint = CGPointFromString(lastPointStr);
    
    if(self.center.x < lastPoint.x){
        self.centerX = lastPoint.x;
    } else if (self.center.x > perPoint.x){
        self.centerX = perPoint.x;
    }
// touch 方法里面直接能够过去到当前的的 控件的frame
    NSString *finalPointStr = NSStringFromCGPoint(self.center);
    NSDictionary *dict = @{@(self.tag):finalPointStr};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RoundImageMove" object:dict];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
   // self.transform = CGAffineTransformMakeScale(1, 1);
// 获取到最后一个点在父坐标的位置上 然后一直把这个位置的坐标去替换
   // UITouch *touch = touches.anyObject;
  //  CGPoint finalPoint = [touch locationInView:self.superview];
    //发出一个请求
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RoundImageMoveEnd" object:nil];
    self.image = [UIImage imageNamed:@"contact"];
}
-(void)setArray:(NSArray *)array{
    _array = array;
}
@end
