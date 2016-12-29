//
//  LYDiscoverViewController.m
//  Amonitor
//
//  Created by iOS程序员 on 16/11/1.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYDiscoverViewController.h"
#import "Masonry.h"
#import  "LYImageVIew.h"

@interface LYDiscoverViewController ()

@end

@implementation LYDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    UIView *ctrView = [[UIView alloc]init];
    
    ctrView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:ctrView];
    
    [ctrView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    
    //btn-green-n btn-pink-n btn-orange-n btn-cyan-n btn-purple-n btn-blue-n btn-white-n
    LYImageVIew *dynamicView = [LYImageVIew new];
    // 设置初始状态
     dynamicView.tag = 1;
    dynamicView.scaleValue = 0;
   
    dynamicView.userInteractionEnabled = YES;
    [dynamicView image:[UIImage imageNamed:@"btn-green-n"] title:@"dynamic" color:[UIColor colorWithRed:162/255.0 green:207/255.0 blue:107/255.0 alpha:1]];
    [ctrView addSubview:dynamicView];
    
    LYImageVIew *pinkView =  [[LYImageVIew alloc]initWithFrame:CGRectMake(542, 129, 107.5, 91.5)];
    pinkView.userInteractionEnabled = YES;
    pinkView.tag = 2;
    [pinkView image:[UIImage imageNamed:@"btn-pink-n"] title:@"equalizer" color:[UIColor colorWithRed:254/255.0 green:180/255.0 blue:183/255.0 alpha:1]];
    [ctrView addSubview:pinkView];
    
    LYImageVIew *orangeView = [[LYImageVIew alloc]initWithFrame:CGRectMake(543, 228, 107.5, 91.5)];
    orangeView.userInteractionEnabled = YES;
    orangeView.tag = 3;
    [orangeView image:[UIImage imageNamed:@"btn-orange-n"] title:nil color:nil];
    [ctrView addSubview:orangeView];
    
    LYImageVIew *cyanView = [[LYImageVIew alloc]initWithFrame:CGRectMake(457, 278, 107.5, 91.5)];
    cyanView.userInteractionEnabled = YES;
    cyanView.tag = 4;
    [cyanView image:[UIImage imageNamed:@"btn-cyan-n"] title:nil color:nil];
    [ctrView addSubview:cyanView];
    
    LYImageVIew *purpleView = [[LYImageVIew alloc]initWithFrame:CGRectMake(371,  228, 107.5, 91.5)];
    purpleView.userInteractionEnabled = YES;
    purpleView.tag = 5;
    [purpleView image:[UIImage imageNamed:@"btn-purple-n"] title:nil color:nil];
    [ctrView addSubview:purpleView];
    
    LYImageVIew *reverbView = [[LYImageVIew alloc]initWithFrame:CGRectMake(371, 129, 107.5, 91.5)];
    reverbView.userInteractionEnabled = YES;
    reverbView.tag = 6;
    [reverbView image:[UIImage imageNamed:@"btn-blue-n"] title:@"reverb" color:[UIColor colorWithRed:66/255.0 green:191/255.0 blue:245/255.0 alpha:1]];
    [ctrView addSubview:reverbView];
    
    LYImageVIew *whiteView = [[LYImageVIew alloc]initWithFrame:CGRectMake(457, 179, 107.5, 91.5)];
    whiteView.userInteractionEnabled = YES;
    whiteView.tag = 7;
    [whiteView image:[UIImage imageNamed:@"btn-white-n"] title:nil color:nil];
    [ctrView addSubview:whiteView];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"fromHome" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        if( [note.object intValue] == 1){
            for ( LYImageVIew *view in ctrView.subviews) {
                view.scaleValue = 1;
            }
        }else{
            for (LYImageVIew *view in ctrView.subviews) {
                view.scaleValue = 0;
            }
        }

    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    // 移除所有的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
