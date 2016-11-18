//
//  LYLitterNumberView.m
//  Amonitor
//
//  Created by iOS程序员 on 16/10/31.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYLitterNumberView.h"
#import "Masonry.h"
@interface LYLitterNumberView ()
@property (nonatomic,weak)UILabel *numberLable;
@end


@implementation LYLitterNumberView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    //添加一个lable
        UILabel *numberLable = [UILabel new];
        self.numberLable = numberLable;
    numberLable.textColor = [UIColor colorWithRed:139/255.0 green:139/255.0 blue:139/255.0 alpha:1];
        [self addSubview:numberLable];
        numberLable.font = [UIFont systemFontOfSize:12];
        [numberLable makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return self;
}
-(void)setNumberStr:(NSString *)numberStr{
    _numberStr = numberStr.copy;
    self.numberLable.text = numberStr;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.transform = CGAffineTransformMakeScale(0.8, 0.8);
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    self.transform = CGAffineTransformMakeScale(1.25, 1.25);
}



@end
