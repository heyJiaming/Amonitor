//
//  LYRevolveCompandView.m
//  Amonitor
//
//  Created by iOS程序员 on 16/11/2.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYRevolveCompandView.h"
#import  "GCDSocketTools.h"
@interface LYRevolveCompandView ()
@property (nonatomic,assign)float currenty;
@property (nonatomic,assign)float y;
@end

@implementation LYRevolveCompandView

CGPoint orginalCompandPoint;
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    orginalCompandPoint = [touch locationInView:self];
    
    
    NSLog(@"compand:star %f",self.currenty);
    if([self.delegate respondsToSelector:@selector(revolveCompand:showLable:showValue:)]){
        [self.delegate revolveCompand:self showLable:YES showValue:self.y];
        
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    
    if(self.tag == 1){
    self.y = ((orginalCompandPoint.y - point.y)/3) +self.currenty;
    }else{
     self.y = ((orginalCompandPoint.y - point.y)/10) +self.currenty;
    }
    
    if(self.y>=0 && self.y < 81){
       
       
        UIImage *cutImage = [UIImage imageNamed:[NSString stringWithFormat:@"rb%d",(int)self.y]];
        self.image = cutImage;
    }
    
    if(self.y<0){
        self.y = 0;
    }else if (self.y > 80) {
        self.y = 80;
    }

    NSLog(@"compand:move %f",self.y);
    if([self.delegate respondsToSelector:@selector(revolveCompand:showLable:showValue:)]){

        [self.delegate revolveCompand:self showLable:YES showValue:self.y];
    }
    
    if(self.tag == 1 ){
    //发出一个通知

        [[NSNotificationCenter defaultCenter] postNotificationName:@"gainValue" object:@(self.y)];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    UITouch *touch = touches.anyObject;
    
    CGPoint point = [touch locationInView:self];
    
    // 记下增量
    if(self.tag == 1){
    self.currenty = ((orginalCompandPoint.y - point.y)/3) + self.currenty;
    }else{
        self.currenty = ((orginalCompandPoint.y - point.y)/10) + self.currenty;
    }
    
    // 设置范围 (0~80)
    if(self.currenty < 0){
        self.currenty = 0;
    }else if (self.currenty >80){
        self.currenty = 80;
    }
    
    NSLog(@"compand:end %f",self.currenty);
    if([self.delegate respondsToSelector:@selector(revolveCompand:showLable:showValue:)]){
        [self.delegate revolveCompand:self showLable:NO showValue:self.y];
    }

    // 结束的时候可能会发网络请求
    
    if(self.tag == 0){
     NSString *str = [NSString stringWithFormat:@"%d",(int)(self.y*3.7375+1)];
        [[GCDSocketTools sharedInstance] sendDict:nil OrString:[NSString stringWithFormat:@"compand:at:%@",str] returnMsg:nil returnError:nil andTag:53];
    
    }else if(self.tag == 1){
    NSString *str = [NSString stringWithFormat:@"%.1f",self.y*0.25-10];
        [[GCDSocketTools sharedInstance] sendDict:nil OrString:[NSString stringWithFormat:@"compand:gain:%@",str] returnMsg:nil returnError:nil andTag:54];
    }else if(self.tag == 2){
   NSString *str =  [NSString stringWithFormat:@"%d",(int)(self.y*37.375+10)];
        [[GCDSocketTools sharedInstance] sendDict:nil OrString:[NSString stringWithFormat:@"compand:rt:%@",str] returnMsg:nil returnError:nil andTag:55];
    }
}

- (void)setStartNumble:(NSString *)StartNumble{
    _StartNumble  = StartNumble.copy;
    if(self.tag == 0){
        self.currenty = ([StartNumble floatValue] -1)* 0.26756 ;
        
        UIImage *cutImage = [UIImage imageNamed:[NSString stringWithFormat:@"rb%d",(int)self.currenty]];
        self.image = cutImage;
     
        self.y = self.currenty;
        
        if([self.delegate respondsToSelector:@selector(revolveCompand:showLable:showValue:)]){
            [self.delegate revolveCompand:self showLable:NO showValue:self.currenty];
        }
        

    }else if (self.tag == 1){
        self.currenty = (([StartNumble floatValue] + 10)*4) ;
        self.y = self.currenty;
        UIImage *cutImage = [UIImage imageNamed:[NSString stringWithFormat:@"rb%d",(int)self.currenty]];
        self.image = cutImage;
        if([self.delegate respondsToSelector:@selector(revolveCompand:showLable:showValue:)]){
            [self.delegate revolveCompand:self showLable:NO showValue:self.currenty];
        }
    
    }else if (self.tag == 2){
       self.currenty = (([StartNumble floatValue] - 10)*0.026756);
        self.y = self.currenty;     
        UIImage *cutImage = [UIImage imageNamed:[NSString stringWithFormat:@"rb%d",(int)self.currenty]];
        self.image = cutImage;
        
        if([self.delegate respondsToSelector:@selector(revolveCompand:showLable:showValue:)]){
            [self.delegate revolveCompand:self showLable:NO showValue:self.currenty];
        }
    }
}




@end
