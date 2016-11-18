//
//  LYImageVIew.m
//  Amonitor
//
//  Created by iOS程序员 on 16/10/31.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYImageVIew.h"
#import "Masonry.h"
#import "UIView+HMCategory.h"
@interface LYImageVIew ()
@property (nonatomic,weak)UILabel *lable;
@end

@implementation LYImageVIew

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 创建一个lable
        UILabel *lable = [UILabel new];
        self.lable = lable;
        lable.font = [UIFont systemFontOfSize:15];
        [self addSubview:lable];
        [lable makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];

    }
    return self;
}
-(void)image:(UIImage *)img title:(NSString *)str color:(UIColor *)color{
    self.image = img;
    self.lable.text = str;
    self.lable.textColor = color;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView:self];
   CGFloat dist = sqrt(((p.x - 53.73) *(p.x - 53.73) + (p.y - 45.75)*(p.y - 45.75)));
   
    if(dist <= 40.75){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"distance" object:@(self.tag)];
    }
}

-(void)setScaleValue:(float)scaleValue{
    _scaleValue = scaleValue;
    
    if(scaleValue == 0){
        switch (self.tag) {
            case 1:
                self.frame = CGRectMake(457, 80, 107.5, 91.5);
                break;
            case 2:
                self.frame = CGRectMake(542, 129, 107.5, 91.5);
                break;
            case 3:
                self.frame = CGRectMake(543, 228, 107.5, 91.5);
                break;
            case 4:
                self.frame = CGRectMake(457, 278, 107.5, 91.5);
                break;
            case 5:
                self.frame = CGRectMake(371, 228, 107.5, 91.5);
              
                break;
            case 6:
                  self.frame = CGRectMake(371, 129, 107.5, 91.5);
                break;
            case 7:
                self.frame = CGRectMake(457, 179, 107.5, 91.5);
                break;
            default:
                break;
        }
    }else if (scaleValue == 1){
        switch (self.tag) {
            case 1:
                self.frame = CGRectMake(463, 70.5, 97 , 83);
                break;
            case 2:
                self.frame = CGRectMake(540 , 115, 97, 83);
                break;
            case 3:
                self.frame = CGRectMake(540, 204, 97, 83);
                break;
            case 4:
                self.frame = CGRectMake(463, 249, 97, 83);
                break;
            case 5:
                self.frame = CGRectMake(386, 204, 97, 83);
                break;
            case 6:
                self.frame = CGRectMake(386, 115, 97, 83);
                break;
            case 7:
                self.frame = CGRectMake(463, 160, 97, 83);
                break;
            default:
                break;
        }

    
    
    }
  
    
   
}

@end
