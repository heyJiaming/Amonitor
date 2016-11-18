//
//  LYCompandViewController.m
//  Amonitor
//
//  Created by iOS程序员 on 16/11/2.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYCompandViewController.h"
#import "LYRevolveCompandView.h"
#import "Masonry.h"
#import "LEBackgroundVIew.h"
#import "UIView+HMCategory.h"
#import "LYCompandMode.h"
#import "GCDSocketTools.h"
#define  YELLOWCOLOR  [UIColor colorWithRed:221/255.0 green:252/255.0 blue:133/255.0 alpha:1]
#define FONT 8
@interface LYCompandViewController ()<LYRevolveCompandViewDelegate,LEBackgroundVIewDelegate>
@property (nonatomic,strong)UILabel *cpTopLable;
@property (nonatomic,strong)UILabel *cpRightLable;
@property (nonatomic,strong)UILabel *cpBottomLable;


//变化的值
@property (nonatomic,assign)float leftStr1;
@property (nonatomic,assign)float leftStr2;
@property (nonatomic,assign)float rightStr1;
@property (nonatomic,assign)float rightStr2;

// 以下属性 都是获取到在父坐标上的点
@property (nonatomic,strong)NSArray *pointArray;
@property (nonatomic,weak)UIView *lineImageView;
@property (nonatomic,weak)LEBackgroundVIew *backgroundView;


@end

@implementation LYCompandViewController

//实现代理方法 获取到点 在背景上的位置
-(void)LEBackgroundVIewSendArray:(NSArray *)array{
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (NSString *str in array) {
        CGPoint point = CGPointFromString(str);
        CGPoint bgPoint = [self.backgroundView  convertPoint:point toView:self.lineImageView];
        NSString *bgStr = NSStringFromCGPoint(bgPoint);
        [mutableArray addObject:bgStr];
    }
    self.pointArray = mutableArray.copy;
    NSLog(@"pointAray:%@",self.pointArray);
    //[self getsendDataWithArray:self.pointArray];
    
    //发数据给服务器端
      [[GCDSocketTools sharedInstance] sendDict:nil OrString:[NSString stringWithFormat:@"compand:points:%@",[self getsendDataWithArray:self.pointArray]] returnMsg:nil returnError:nil andTag:60];
    
 
}

-(NSString *)getsendDataWithArray:(NSArray*)array{
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSString *str in array) {
        CGPoint point = CGPointFromString(str);
        float x = point.x/3.55 - 100;
        float y = -(point.y/3.01 + [self.cpRightLable.text floatValue]);
        NSString *strP = [NSString stringWithFormat:@"%.1f,%.1f",x,y];
        NSLog(@"%@",strP);
        [arrM addObject:strP];
    }
//    NSLog(@"arrM:%@",arrM);
//    NSLog(@"arrM:%@",[arrM.copy componentsJoinedByString:@"#"]);
   return  [arrM componentsJoinedByString:@"#"];
}
// 实现代理方法
-(void)revolveCompand:(LYRevolveCompandView *)view showLable:(BOOL)hidden showValue:(float)y{
    if(view.tag == 0){
        self.cpTopLable.hidden = !hidden;
        self.cpTopLable.text = [NSString stringWithFormat:@"%dms",(int)(y*3.7375+1)];
    } else if(view.tag == 1){
        self.cpRightLable.hidden = !hidden;
        self.cpRightLable.text = [NSString stringWithFormat:@"%.1fdB",y*0.25-10];
        self.backgroundView.ganv = y*0.25 - 10;
    } else if(view.tag == 2){
        self.cpBottomLable.hidden = !hidden;
        self.cpBottomLable.text = [NSString stringWithFormat:@"%dms",(int)(y*37.375+10)];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =  [UIColor blackColor];
    // 初始化数据模型
    LYCompandMode *model = [LYCompandMode sharedInstance];
    self.compandMode = model;
    
    // 初始化 值
    self.leftStr1 = -60;
    self.leftStr2 = -60;
    self.rightStr1 = -60;
    self.rightStr2 = -60;
    
  // 1.设置3个旋转的view
    LYRevolveCompandView *revolveViewtop =  [[LYRevolveCompandView alloc]init];
    
    revolveViewtop.delegate = self;
    revolveViewtop.userInteractionEnabled = YES;
    revolveViewtop.tag = 0;
    revolveViewtop.image = [UIImage imageNamed:@"rb0"];
    [self.view addSubview:revolveViewtop];
    [revolveViewtop makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).mas_offset(64);
        make.left.equalTo(self.view).mas_offset(74);
    }];

    
    LYRevolveCompandView *revolveViewright= [[LYRevolveCompandView alloc]init];
    
    revolveViewright.delegate = self;
    revolveViewright.userInteractionEnabled = YES;
    revolveViewright.tag = 1;
    revolveViewright.image = [UIImage imageNamed:@"rb0"];
    [self.view addSubview:revolveViewright];
    [revolveViewright makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).mas_offset(270);
        make.left.equalTo(self.view).mas_offset(634);
    }];
    
    LYRevolveCompandView *revolveViewBottom =  [[LYRevolveCompandView alloc]init];

    revolveViewBottom.delegate = self;
    revolveViewBottom.userInteractionEnabled = YES;
    revolveViewBottom.tag = 2;
    revolveViewBottom.image = [UIImage imageNamed:@"rb0"];
    [self.view addSubview:revolveViewBottom];
    [revolveViewBottom makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(revolveViewright);
        make.left.equalTo(self.view).mas_offset(74);
    }];
    //添加3个显示数值的lable
    //添加两个数字lable
    self.cpTopLable = [UILabel new];
    self.cpTopLable.hidden = YES;
    self.cpTopLable.font = [UIFont systemFontOfSize:12];
    self.cpTopLable.textColor = YELLOWCOLOR;
    [self.view addSubview:self.cpTopLable];
    [self.cpTopLable makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(revolveViewtop);
        make.bottom.equalTo(revolveViewtop.mas_top).mas_offset(-16);
    }];
    
    self.cpRightLable = [UILabel new];
    self.cpRightLable.hidden = YES;
    self.cpRightLable.font = [UIFont systemFontOfSize:12];
    self.cpRightLable.textColor = YELLOWCOLOR;
    [self.view addSubview:self.cpRightLable];
    [self.cpRightLable makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(revolveViewright);
        make.bottom.equalTo(revolveViewright.mas_top).mas_offset(-16);
    }];
    
    self.cpBottomLable = [UILabel new];
    self.cpBottomLable.hidden = YES;
    self.cpBottomLable.font = [UIFont systemFontOfSize:12];
    self.cpBottomLable.textColor = YELLOWCOLOR;
    [self.view addSubview:self.cpBottomLable];
    [self.cpBottomLable makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(revolveViewBottom);
        make.bottom.equalTo(revolveViewBottom.mas_top).mas_offset(-16);
    }];
    
    
    //添加三个lable
    UILabel *attackLable = [UILabel new];
    attackLable.text = @"attack";
    attackLable.textColor = YELLOWCOLOR;
    attackLable.font = [UIFont systemFontOfSize:15.5];
    [self.view addSubview:attackLable];
    [attackLable makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(revolveViewtop);
        make.top.equalTo(revolveViewtop.mas_bottom).mas_offset(10);
    }];
    
    UILabel *gainLable = [UILabel new];
    gainLable.text = @"gain";
    gainLable.textColor = YELLOWCOLOR;
    gainLable.font = [UIFont systemFontOfSize:15.5];
    [self.view addSubview:gainLable];
    [gainLable makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(revolveViewright);
        make.top.equalTo(revolveViewright.mas_bottom).mas_offset(10);
    }];
    
    UILabel *releaseLable = [UILabel new];
    releaseLable.text = @"release";
    releaseLable.textColor = YELLOWCOLOR;
    releaseLable.font = [UIFont systemFontOfSize:15.5];
    [self.view addSubview:releaseLable];
    [releaseLable makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(revolveViewBottom);
        make.top.equalTo(revolveViewBottom.mas_bottom).mas_offset(10);
    }];
    
    // 设置中间uv表
    UIImageView *uvImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"刻度"]];
    [self.view addSubview:uvImageView];
    [uvImageView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@216);
        make.top.equalTo(@64);
    }];
    
    UIImageView *lineImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line"]];
   
    self.lineImageView = lineImageView;
    lineImageView.userInteractionEnabled = YES;
    [self.view addSubview:lineImageView];
    [lineImageView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@246);
        make.top.equalTo(@64);
    }];

    lineImageView.clipsToBounds = YES;
    
    //这个是手指按住加点的 0, 0,356, 361
    LEBackgroundVIew *backgroundView = [LEBackgroundVIew new];
    self.backgroundView = backgroundView;
    backgroundView.arrayDelegate = self;
    // 2 设置两个按钮
    UIButton *btn = [UIButton new];
    btn.adjustsImageWhenHighlighted = NO;
    [btn setBackgroundImage: [UIImage imageNamed:@"compandOff"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"compandOn"] forState:UIControlStateSelected];
    [btn sizeToFit];
    [btn addTarget:self action:@selector(clickOffOnBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).mas_offset(64);
        make.left.equalTo(self.view).mas_offset(630);
    }];
    
    UIButton  *softBtn = [UIButton new];
    softBtn .adjustsImageWhenHighlighted = NO;
    [softBtn setBackgroundImage:[UIImage imageNamed:@"SOFT"] forState:UIControlStateNormal];
    [softBtn setBackgroundImage:[UIImage imageNamed:@"SOFT-clik"] forState:UIControlStateSelected];
    [softBtn sizeToFit];
    [softBtn addTarget:self action:@selector(clickSoftBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:softBtn];
    [softBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).mas_offset(630);
        make.top.equalTo(self.view).mas_offset(167);
    }];
    //创建4个view表
    //添加 input 和 output
    UIImageView *VULeft1BG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"vu1"]];
    VULeft1BG.frame = CGRectMake(786, 75.5, VULeft1BG.bounds.size.width, VULeft1BG.bounds.size.height);
    [self.view addSubview:VULeft1BG];
    
    UILabel *topLeftLable1 = [UILabel new];
    topLeftLable1.text = @"-60";
    topLeftLable1.textColor = YELLOWCOLOR;
    topLeftLable1.font = [UIFont systemFontOfSize:FONT];
    [self.view addSubview:topLeftLable1];
    [topLeftLable1 makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(VULeft1BG);
        make.bottom.equalTo(VULeft1BG.mas_top).mas_offset(-5);
    }];
    
    
    UIImageView *VULeft2BG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"vu1"]];
    [self.view addSubview:VULeft2BG];
    [VULeft2BG makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(VULeft1BG);
        make.left.equalTo(VULeft1BG.mas_right).mas_offset(5);
    }];
    UILabel *topLeftLable2 = [UILabel new];
    topLeftLable2.text = @"-60";
    topLeftLable2.textColor = YELLOWCOLOR;
    topLeftLable2.font = [UIFont systemFontOfSize:FONT];
    [self.view addSubview:topLeftLable2];
    [topLeftLable2 makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(VULeft2BG);
        make.bottom.equalTo(VULeft2BG.mas_top).mas_offset(-5);
    }];
    
    
    UIImageView *VUNumble = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"vu-scale"]];
    [self.view addSubview:VUNumble];
    [VUNumble makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).mas_offset(93);
        make.left.equalTo(VULeft2BG.mas_right).mas_offset(31);
    }];
    
    UIImageView *VURight1BG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"vu1"]];
    [self.view addSubview:VURight1BG];
    [VURight1BG makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(VULeft2BG);
        make.left.equalTo(VUNumble.mas_right).mas_offset(31);
    }];
    UILabel *topRightLable1 = [UILabel new];
    topRightLable1.text = @"-60";
    topRightLable1.textColor = YELLOWCOLOR;
    topRightLable1.font = [UIFont systemFontOfSize:FONT];
    [self.view addSubview:topRightLable1];
    [topRightLable1 makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(VURight1BG);
        make.bottom.equalTo(VURight1BG.mas_top).mas_offset(-5);
    }];
    
    UIImageView *VURight2BG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"vu1"]];
    [self.view addSubview:VURight2BG];
    [VURight2BG makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(VURight1BG);
        make.left.equalTo(VURight1BG.mas_right).mas_offset(5);
    }];
    UILabel *topRightLable2 = [UILabel new];
    topRightLable2.text = @"-60";
    topRightLable2.textColor = YELLOWCOLOR;
    topRightLable2.font = [UIFont systemFontOfSize:FONT];
    [self.view addSubview:topRightLable2];
    [topRightLable2 makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(VURight2BG);
        make.bottom.equalTo(VURight2BG.mas_top).mas_offset(-5);
    }];
    // input 和 output 下面的两个标签
    UIImageView *inputImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"compandInput"]];
    [self.view addSubview:inputImage];
    [inputImage makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(VULeft1BG);
        make.top.equalTo(VULeft1BG.mas_bottom).mas_offset(5);
    }];

    UIImageView *outputImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"compandOutput"]];
    [self.view addSubview:outputImage];
    [outputImage makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(VURight1BG).mas_offset(-5);
        make.top.equalTo(VURight1BG.mas_bottom).mas_offset(5);
    }];
    
    // 添加VULeft1BG VULeft2BG  VURight1BG VURight2BG
    UIView *left1 = [UIView new];
    left1.backgroundColor = YELLOWCOLOR;
    [VULeft1BG addSubview:left1];
    [left1 makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(VULeft1BG);
        make.height.equalTo(@0);
    }];
    
    UIView *left2 = [UIView new];
    left2.backgroundColor = YELLOWCOLOR;
    [VULeft2BG addSubview:left2];
    [left2 makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(VULeft2BG);
        make.height.equalTo(@0);
    }];
    
    UIView *right1 = [UIView new];
    right1.backgroundColor = YELLOWCOLOR;
    [VURight1BG addSubview:right1];
    [right1 makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(VURight1BG);
        make.height.equalTo(@0);
    }];
    
    UIView *right2 = [UIView new];
    right2.backgroundColor = YELLOWCOLOR;
    [VURight2BG addSubview:right2];
    [right2 makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(VURight2BG);
        make.height.equalTo(@0);
    }];
    
    // 当接受到数据的时候 去更新高度就可以了!---------------------------------------------------
    
    // 接受到gain的通知
    [[NSNotificationCenter defaultCenter] addObserverForName:@"gainValue" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        int i = ([note.object floatValue]*0.25 - 10);
        
        // 由于 真实的数值和实际的是3倍
        backgroundView.y = -30  - i*3;
    }];

    //接受到数据的通知
    [[NSNotificationCenter defaultCenter] addObserverForName:@"CompandOpen" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        btn.selected = self.compandMode.open;
        
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"CompandAt" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        revolveViewtop.StartNumble = self.compandMode.at;
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"CompandRt" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        revolveViewBottom.StartNumble = self.compandMode.rt;
        
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"CompandSoftknee" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        softBtn.selected = self.compandMode.softknee;
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"CompandUpdata" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        //获取值去设置
        if(-self.compandMode.lever.inputLeft >= 60){
            self.leftStr1 = - 60;
        }else if(-self.compandMode.lever.inputRight <= 0){
            self.leftStr1 = 0;
        }else{
         self.leftStr1 = self.compandMode.lever.inputLeft;
        }
        
        if(-self.compandMode.lever.inputRight >= 60){
            self.leftStr2 =  - 60;
        }else if(-self.compandMode.lever.inputRight <= 0){
            self.leftStr2 = 0;
        }else{
        self.leftStr2 = self.compandMode.lever.inputRight;
        }
        
        if(-self.compandMode.lever.outputLeft >= 60){
            self.rightStr1 =  - 60;
        }else if(-self.compandMode.lever.outputLeft < 0){
            self.rightStr1 = 0;
        }else{
        self.rightStr1 = self.compandMode.lever.outputLeft;
        }
        
        
        if(-self.compandMode.lever.outputRight >= 60){
            self.rightStr2 = - 60;
        }else if(-self.compandMode.lever.outputRight < 0 ){
            self.rightStr2 = 0;
        }else{
          self.rightStr2 = self.compandMode.lever.outputRight;
        }
        // 接受到数据的时候更新约束
        [left1 updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@( (60 + self.leftStr1)*4.6));
        }];
        [left2 updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@((60 + self.leftStr2)*4.6));
        }];
        [right1 updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@((60 + self.rightStr1)*4.6));
        }];
        [right2 updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@((60 + self.rightStr2)*4.6));
        }];
        // 更新上面lable的值
        // topLeftLable1 topLeftLable2 topRightLable1 topRightLable2
        topLeftLable1.text = [NSString stringWithFormat:@"%.1f",self.leftStr1];
        
        topLeftLable2.text = [NSString stringWithFormat:@"%.1f",self.leftStr2];
        
        topRightLable1.text = [NSString stringWithFormat:@"%.1f",self.rightStr1];
        
        topRightLable2.text = [NSString stringWithFormat:@"%.1f",self.rightStr2];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"CompandPoints" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        
        NSArray *comParr = [[self.compandMode.points reverseObjectEnumerator] allObjects];
        NSMutableArray *arrM = comParr.mutableCopy;
        
        // 冒泡 有point.x值大小 由大到小的排序
        
        for(int i = 0;i<arrM.count;i++){
            for(int j = 0 ;j<arrM.count-i-1;j++){
                NSString *point1str = [arrM objectAtIndex:j];
                CGPoint point1 = CGPointFromString(point1str);
                NSString *point2str = [arrM objectAtIndex:j+1];
                CGPoint point2 = CGPointFromString(point2str);
                if(point1.x<point2.x){
                //交换两个元素
                   [arrM exchangeObjectAtIndex:j withObjectAtIndex:(j + 1)];
                }
            }
        }
        NSMutableArray *arrM2 = [NSMutableArray array];
        // 解析这个点的坐标
        for (NSString  *pointStr in arrM) {
            CGPoint p = CGPointFromString(pointStr);
            CGPoint p1 = CGPointMake((p.x+100)*3.55, -p.y*3.01 + 30);
            NSString *ptr = NSStringFromCGPoint(p1);
            [arrM2 addObject:ptr];
        }
        backgroundView.arrM = arrM2;
        [backgroundView setNeedsDisplay];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"CompandGain" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
          revolveViewright.StartNumble = self.compandMode.gain;
        
        //设置初始偏移量
        backgroundView.offsetY = 0;
        [lineImageView addSubview:backgroundView];
        backgroundView.frame = CGRectMake(0, -30  -([self.compandMode.gain floatValue])*3, lineImageView.size.width, 361);
        backgroundView.backgroundColor = [YELLOWCOLOR colorWithAlphaComponent:0];
        
          //设置backView的初始位置
        backgroundView.y = -30 -([self.compandMode.gain floatValue])*3;
  
    }];
    
    
}
//点击了soft开关
-(void)clickSoftBtn:(UIButton *)sender{
    sender.selected = !sender.selected;
    [[GCDSocketTools sharedInstance] sendDict:nil OrString:[NSString stringWithFormat:@"compand:softknee:%d",sender.selected] returnMsg:nil returnError:nil andTag:50];


}
// 点击了 off-on 开关
-(void)clickOffOnBtn:(UIButton *)sender{
    sender.selected = !sender.selected;
   [[GCDSocketTools sharedInstance] sendDict:nil OrString:[NSString stringWithFormat:@"compand:open:%d",sender.selected] returnMsg:nil returnError:nil andTag:51];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)test{
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"12",@"84", @"35", @"70", @"85", @"99", nil];
    NSInteger count = [array count];
    for (int i = 0; i < count; i++) {
        for (int j = 0; j < count - i - 1; j++) {
            // if ([[array objectAtIndex:j] intValue] > [[array objectAtIndex:(j + 1)] intValue]) {   //这里在用[array objectAtIndex:j]时候必须intValue
            //                if([[array objectAtIndex:j] compare:[array objectAtIndex:j + 1]] == -1){  //这里整体必须有一个返回值，－1，0，1，因为compare的返回值NSComparisonResult是一个枚举类型的值，所以要返回一个值
            
            if([[array objectAtIndex:j] compare:[array objectAtIndex:j + 1] options:NSNumericSearch] == 1){  //同上potions  NSNumericSearch = 64,
                [array exchangeObjectAtIndex:j withObjectAtIndex:(j + 1)];  //这里可以用exchangeObjectAtIndex:方法来交换两个位置的数组元素。
            }
        }
    }



}

@end
