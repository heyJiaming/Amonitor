//
//  LYTabBarView.m
//  Amonitor
//
//  Created by iOS程序员 on 16/11/1.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYTabBarView.h"
#import "UIView+HMCategory.h"
@interface LYTabBarView ()
@property (nonatomic,strong)UIButton *selectButton;
@property (nonatomic,strong)UIButton *secondeButton;
@property (nonatomic,strong)UIButton *compandButton;
@property (nonatomic,strong)UIButton *equalizerButton;
@end
@implementation LYTabBarView
-(UIButton *)secondeButton{
    if(_secondeButton == nil){
       _secondeButton = [self setupButtonWithIcon:@"btn-reverb-n" heightIcon:@"btn-reverb-h" title:@"reverb"];
        _secondeButton.tag = 1;
    }
    return _secondeButton;
}
-(UIButton *)compandButton{
    if(_compandButton == nil){
        _compandButton = [self setupButtonWithIcon:@"btn-dynamic-n" heightIcon:@"btn-dynamic-h" title:@"dynamic"];
        _compandButton.tag = 2;
    }
    return _compandButton;
}
-(UIButton *)equalizerButton{
    if(_equalizerButton == nil){
        _equalizerButton = [self setupButtonWithIcon:@"btn-dynamic-n" heightIcon:@"btn-dynamic-h" title:@"eq"];
        _equalizerButton.tag = 3;
    }
    return _equalizerButton;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:29/255.0 green:29/255.0 blue:29/255.0 alpha:1];
        // 创建一个按钮
    UIButton *firstButton = [self setupButtonWithIcon:@"btn-discover-n" heightIcon:@"btn-discover-h" title:@"discover"];
        firstButton.tag = 0;
        // 选中状态
          firstButton.enabled = NO;
      
        self.selectButton = firstButton;
        
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"distance" object: nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if([note.object intValue] == 6){
           [self clickButton:self.secondeButton];
                [self setNeedsLayout];
            }
            if([note.object intValue] == 1){
                [self clickButton:self.compandButton];
                [self setNeedsLayout];
            }
            if([note.object intValue] == 2){
                [self clickButton:self.equalizerButton];
                [self setNeedsLayout];
            }
            
        }];
        
        // 切换到discover控制器
        [[NSNotificationCenter defaultCenter] addObserverForName:@"returnDiscover" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
           // 2 去掉界面上其他的三个元素
            for (int i=0;i < self.subviews.count;i++ ) {
                if(self.subviews.count>1){
                    [self.subviews[1] removeFromSuperview];
                    i--;
                }
            }
            //1.切换
            [self clickButton:firstButton];
         //3.至空
            self.secondeButton = nil;
            self.compandButton = nil;
            self.equalizerButton = nil;
        }];
        
    }
    return self;
}
// @"btn-discover-n" @"btn-discover-h
-(UIButton *)setupButtonWithIcon:(NSString *)icon heightIcon:(NSString *)hicon title:(NSString *)title
{
    // 基本属性的设置
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed: hicon] forState:UIControlStateDisabled];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
   // button.titleLabel.alignmentRectInsets = UIEdgeInsetsMake(0, <#CGFloat left#>, <#CGFloat bottom#>, <#CGFloat right#>)
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
    [button setTitleColor:[UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:49/255.0 green:191/255.0 blue:249/255.0 alpha:1] forState:UIControlStateDisabled];
    //添加方法
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    button.size = CGSizeMake(100, self.frame.size.height);
    //[button sizeToFit];
    // 添加到 view上
    [self addSubview:button];
 
    return button;
}

-(void)clickButton:(UIButton *)sender{
    
    // 1 把之前的按钮设置为正常状态
    self.selectButton.enabled = YES;
    //设置当前按钮为 特殊状态
    sender.enabled = NO;
    //让当前 控件成为选中的控件
    self.selectButton  = sender;

    // 发出一个 tabbar改变的通知
    if([sender.titleLabel.text isEqualToString:@"discover"]){
     [[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarDidchange" object:nil userInfo:@{@"buttonIndex": @(0)}];
    }else{
     [[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarDidchange" object:nil userInfo:@{@"buttonIndex": @(sender.tag)}];
    }
}
// 布局子空间
-(void)layoutSubviews{
    [super layoutSubviews];
    NSInteger count  = self.subviews.count;
    //遍历子视图
    for (int i = 0; i < count; i++) {
        // 获取到加入到的按钮
        UIButton  *button = self.subviews[i];
        CGFloat btnX = 212  +  i * (button.frame.size.width + 75);
        button.frame = CGRectMake(btnX, 0, button.frame.size.width, button.frame.size.height);
    }

}

-(void)dealloc{
    // 移除所有的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
