//
//  LYKshowImageView.m
//  Amonitor
//
//  Created by iOS程序员 on 16/10/31.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYKshowImageView.h"
#import "Masonry.h"
#import  "GCDSocketTools.h"
@interface LYKshowImageView ()
@property (nonatomic,strong)UILabel *titleLable;
@property (nonatomic,strong)UILabel *subtitleLable;

@property (nonatomic,strong)UIColor *color;
//id 抛出去
@property (nonatomic,copy)NSString *idStr;

@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *subTitle;




// 是否按过当前的view
@property (nonatomic,assign)BOOL selecKsViewstatu;
@end

@implementation LYKshowImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        // 创建两个lable
        UILabel *titleLable= [UILabel new];
        self.titleLable = titleLable;
        titleLable.font = [UIFont systemFontOfSize:12];
        [self  addSubview:titleLable];
        [titleLable makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).mas_offset(33);
        }];
        
        UILabel *subtitleLable = [UILabel new];
        self.subtitleLable = subtitleLable;
        subtitleLable.font = [UIFont systemFontOfSize:8];
        [self addSubview:subtitleLable];
        [subtitleLable makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(titleLable.mas_bottom).mas_offset(2);
        }];
        // 长按的时候是做出一个手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(changeValue:)];
        longPress.minimumPressDuration = 0.3;
        [self addGestureRecognizer:longPress];
    }
    return self;
}


-(void)imageWithTitle:(NSString *)title  subTitle:(NSString *)subTitle changeTitle:(NSString *)idStr color:(UIColor *)color{
    self.titleLable.text = title;
    self.subtitle = [subTitle substringFromIndex:2];
    self.subtitleLable.text = self.subtitle;
    self.idStr = idStr;
    self.color = color;
    self.title = title;
    self.subTitle = [subTitle substringFromIndex:2];
}

-(void)setSelStatu:(BOOL)selStatu{
    _selStatu = selStatu;
    if(selStatu == NO){
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"btn-%@ bat-n",self.colorStr]];
        self.titleLable.textColor = self.color;
        self.subtitleLable.textColor = self.color;
    }else if(selStatu == YES){
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"btn-%@ bat-h",self.colorStr]];
        self.titleLable.textColor = [UIColor blackColor];
        self.subtitleLable.textColor = [UIColor blackColor];
        
        // 被选中的时候 会改变ip
        [GCDSocketTools sharedInstance].server_host = self.idStr;
  
    }
}
//长按手势的时候
-(void)changeValue:(UILongPressGestureRecognizer *)gesture{
   
    if(gesture.state == UIGestureRecognizerStateBegan){
        self.selecKsViewstatu = !self.selecKsViewstatu;
        if(self.selecKsViewstatu == YES){
            self.titleLable.text = self.idStr;
            self.subtitleLable.text = nil;
            CATransition *ca = [CATransition animation];
            ca.type = @"cube";
            ca.subtype = kCATransitionFromRight;
            ca.duration = 0.3;
            [self.layer addAnimation:ca forKey:@"1"];
            
        }else if(self.selecKsViewstatu == NO){
            self.titleLable.text = self.title;
            self.subtitleLable.text = self.subTitle;
            
            CATransition *ca1 = [CATransition animation];
            ca1.type = @"cube";
            ca1.subtype = kCATransitionFromRight;
            ca1.duration = 0.3;
            [self.layer addAnimation:ca1 forKey:@"2"];
        }
    }
      };
    //为ksImageView 添加的手势方法
    //创建核心动画
    // CATransition *ca=[CATransition animation];
    //告诉要执行什么动画
    //    NSString * const kCATransitionFade;//逐渐消失  @"cube";//---立方体  @"pageCurl";//101翻页起来
    //    　　NSString * const kCATransitionMoveIn;//移入 @"suckEffect";//103 吸走的效果  @"pageUnCurl";//102翻页下来
    //    　　NSString * const kCATransitionPush;//平移（暂且这么称呼吧）//@"oglFlip"  @"cameraIrisHollowOpen ";//107//镜头开
    //    　　NSString * const kCATransitionReveal;//显露  @"rippleEffect";//110波纹效果  @"cameraIrisHollowClose ";//106镜头关
    
    //设置过度效果
    // ca.type=@"cube";
    //设置动画的过度方向（向左）
    // ca.subtype=kCATransitionFromRight;
    //设置动画的时间
    // ca.duration=2.0;
    //添加动画
    // [self.ks1ImageView.layer addAnimation:ca forKey:nil];
@end
