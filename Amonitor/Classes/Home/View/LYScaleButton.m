//
//  LYScaleButton.m
//  Amonitor
//
//  Created by iOS程序员 on 16/10/28.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYScaleButton.h"
#import "Masonry.h"
@interface LYScaleButton ()
@property (nonatomic,weak)UIImageView *iconImg;
@property (nonatomic,weak)UILabel *lable;
@property (nonatomic,strong)UIImage *selectImage;
@property (nonatomic,strong)UIImage *normalImage;
@property (nonatomic,assign)float scale;
@end
@implementation LYScaleButton
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 创建 放入一个imageView
        UIImageView  *iconImg = [UIImageView new];
        self.iconImg = iconImg;
        [self addSubview:iconImg];
        [iconImg makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self).mas_offset(5);
            make.bottom.equalTo(self).mas_offset(-5);
            make.width.equalTo(@30);
        }];
        //创建一个lable
        UILabel *lable = [UILabel new];
        self.lable = lable;
        [self  addSubview:lable];
        [lable makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(iconImg.mas_right).mas_offset(15);
        }];
        UITapGestureRecognizer *tapGP = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickView)];
        [self addGestureRecognizer:tapGP];
        
        self.statu = 0;
    }
    return self;
}

-(void)clickView{
        self.statu = 1 ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scaleButton"object:@(self.tag)];
    
}

-(void)setStatu:(BOOL)statu{
    if(statu == 0){
        self.lable.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        self.iconImg.transform = CGAffineTransformMakeScale(0.75, 0.75);
        self.iconImg.image = self.normalImage;
    }else if(statu == 1){
        // 对img
        self.iconImg.transform = CGAffineTransformMakeScale(self.scale, self.scale);
        self.iconImg.image = self.selectImage;
        self.lable.textColor  = [UIColor colorWithRed:47/255.0 green:181/255.0 blue:233/255.0 alpha:1];
        
    }
}
-(void)image:(UIImage *)image selectImage:(UIImage *)selecImage title:(NSString *)title scale:(float)scale{
    self.iconImg.image = image;
    self.lable.text = title;
    self.selectImage = selecImage;
    self.scale = scale;
    self.normalImage = image;
}

@end
