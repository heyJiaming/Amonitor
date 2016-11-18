//
//  LYRevolveView.m
//  AudioControl
//
//  Created by iOS程序员 on 16/10/25.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYRevolveView.h"
#import "GCDSocketTools.h"
@interface LYRevolveView ()

//保留最后的偏移值的
@property (nonatomic,assign)int y;
@property (nonatomic,assign)int currenty;
@property (nonatomic,assign)float currentx;

@end


@implementation LYRevolveView

CGPoint orginaLocation3;

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = touches.anyObject;
    
    orginaLocation3 =  [touch locationInView:self];

    // 按住的时候 代理去让 lable 显示 
    if([self.revolveDelegate respondsToSelector:@selector(revolveView:offsetValue:)] ){
        [self.revolveDelegate revolveView:self offsetValue:self.currenty];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appear" object:@(self.tag)];
    
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    
    //设置偏移量 只取小数部分(还可以 向下取证 向上取整 四舍五入的取整)
    self.y = -(int)((point.y - orginaLocation3.y)/5) +self.currenty;

    //每次去 y的整数部分  限制旋钮旋转的范围
    if(self.y>=1 && self.y<=80){
        
//        UIImage *image = [UIImage imageNamed:@"alphablackplastic"];
//        CGFloat h = image.size.height/80;
//        CGFloat w = image.size.width;
//        
//        CGRect rect =  CGRectMake(0 ,self.y*h, w, h);
//        
//        UIImage *cutImage =[self imageFromImage:image inRect:rect];
        
        UIImage *cutImage = [UIImage imageNamed:[NSString stringWithFormat:@"rotary-knob%d",self.y]];
        self.image = cutImage;
        
    
    }
    
    // setoff的y 需要一直给到控制器
    if(self.y<0){
        self.y = 0;
    }else if (self.y > 80) {
        self.y = 80;
    }
    // 按住的时候 代理去让 lable 显示
    if([self.revolveDelegate respondsToSelector:@selector(revolveView:offsetValue:)] ){
        [self.revolveDelegate revolveView:self offsetValue:self.y];
    }

    
    //计算出 当前手指移动的横向 偏移值
//    CGFloat offsetX =point.x - orginaLocation3.x ;
//    
//    NSArray *arr = @[@(offsetX),@(self.y)];
    //发出通知
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"setoff" object:arr];
//    NSLog(@"%d",self.y);
    
    // 需求在移动的时候能够出现一条线
      // [[NSNotificationCenter defaultCenter] postNotificationName:@"appear" object:@(self.tag)];
}
/**
 *从图片中按指定的位置大小截取图片的一部分
 * UIImage image 原始的图片
 * CGRect rect 要截取的区域
 */
- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = touches.anyObject;
    
    CGPoint point = [touch locationInView:self];
    
    self.currenty = (int)( - (point.y - orginaLocation3.y)/5) +self.currenty;
    
    if(self.currenty < 0){
        self.currenty = 0;
    }else if (self.currenty >80){
        self.currenty = 80;
    }
    
    self.currentx = point.x - orginaLocation3.x + self.currentx;
    // 移动结束 还是会发出一个 通知 然后控制这个
    [[NSNotificationCenter defaultCenter] postNotificationName:@"moveEnd" object:nil];
    
    
    if(self.tag == 1){
     NSString * labelValue = [NSString stringWithFormat:@"%.2f",self.y/80.0];
        [[GCDSocketTools sharedInstance] sendDict:nil OrString:[NSString stringWithFormat:@"reverb:mix:%@",labelValue] returnMsg:nil returnError:nil andTag:12];
    }else if(self.tag == 2){
        NSString * labelValue = [NSString stringWithFormat:@"%.1f",(self.y*1.25/100*4.7 + 0.3)];
        [[GCDSocketTools sharedInstance] sendDict:nil OrString:[NSString stringWithFormat:@"reverb:decay:%@",labelValue] returnMsg:nil returnError:nil andTag:13];
    }
    
       [[NSNotificationCenter defaultCenter] postNotificationName:@"hidden" object:@(self.tag)];
}

- (void)setStartNumble:(NSString *)StartNumble{
    _StartNumble  = StartNumble.copy;
    if(self.tag == 1){
    self.currenty = (int)([StartNumble floatValue] * 80) ;

    if([self.revolveDelegate respondsToSelector:@selector(revolveView:offsetValue:)] ){
        [self.revolveDelegate revolveView:self offsetValue:self.currenty];
    }
    }else if (self.tag == 2){
        self.currenty = (int)((([StartNumble floatValue] - 0.3)/4.7)*80) ;
        if([self.revolveDelegate respondsToSelector:@selector(revolveView:offsetValue:)] ){
            [self.revolveDelegate revolveView:self offsetValue:self.currenty];
        }
    }
 
}


@end
