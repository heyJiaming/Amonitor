//
//  LYReverbViewController.m
//  AudioControl
//
//  Created by iOS程序员 on 16/10/25.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYReverbViewController.h"
#import "LYRevolveView.h"
#import "Masonry.h"
#import "LYOffOnBtn.h"
#import "CustomPopOverView.h"
#import "LYReverbLevelViewController.h"
#import  "GCDSocketTools.h"
#import "LYReverbModel.h"

#define BLUEFONTCOLOR [UIColor colorWithRed:58/255.0 green:197/255.0 blue:254/255.0 alpha:1]
#define FONT 8
@interface LYReverbViewController () <LYRevolveViewDelegate>

@property (nonatomic ,strong)UILabel *leftLable;
@property (nonatomic ,strong)UILabel *rightLable;
@property (nonatomic,weak)UIView *BGView;


// 赋值四个数
@property (nonatomic,assign)float leftStr1;
@property (nonatomic,assign)float leftStr2;
@property (nonatomic,assign)float rightStr1;
@property (nonatomic,assign)float rightStr2;

// 需要操作的控件
@property (nonatomic,weak)UIButton *offONBtn;
@property (nonatomic,weak)LYRevolveView *leftRevolveView;
@property (nonatomic,weak)LYRevolveView *rightRevolveView;

@end

@implementation LYReverbViewController

// 手指按上去的代理
-(void)revolveView:(LYRevolveView *)view offsetValue:(int) y{
    if(view.tag == 1){
        NSString * labelValue = [NSString stringWithFormat:@"%.2f",y/80.0];
        self.leftLable.text = labelValue;
         self.leftRevolveView.image = [UIImage imageNamed:[NSString stringWithFormat:@"rotary-knob%d",y]];

    } else if(view.tag == 2){
        NSString * labelValue = [NSString stringWithFormat:@"%.1f",(y*1.25/100*4.7 + 0.3)];
        self.rightLable.text = labelValue;
              self.rightRevolveView.image = [UIImage imageNamed:[NSString stringWithFormat:@"rotary-knob%d",y]];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
    
    // 初始化数据模型
    LYReverbModel *model = [LYReverbModel sharedInstance];
    self.model = model;
    
    // 初始化 值
    self.leftStr1 = -60;
    self.leftStr2 = -60;
    self.rightStr1 = -60;
    self.rightStr2 = -60;
    
    //背景
    
    UIView *BGView = [UIView new];
    self.BGView = BGView;
     [self.view addSubview:BGView];
    [BGView makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
   
    
    UIImageView *reverbBg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"reverb background"]];
    
    [BGView addSubview:reverbBg];
    
    [reverbBg makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(BGView);
    }];
    
    //添加状态按钮
    LYOffOnBtn *offONBtn = [LYOffOnBtn new];
   //  offONBtn.selected = ! self.model.open;
    offONBtn.adjustsImageWhenHighlighted = NO;
    [offONBtn setImage:[UIImage imageNamed:@"OFF-ON"] forState:UIControlStateNormal];
    [offONBtn setImage:[UIImage imageNamed:@"OFF-ON-click"] forState:UIControlStateSelected];
    [offONBtn addTarget:self action:@selector(clickOffOnBtn:) forControlEvents:UIControlEventTouchUpInside];
    [offONBtn sizeToFit];
    offONBtn.frame = CGRectMake(72.5, 75.5, offONBtn.bounds.size.width, offONBtn.bounds.size.height);
    [BGView addSubview:offONBtn];
    
    // 添加选择按钮
    UIButton *selectBtn = [UIButton new];
    selectBtn.adjustsImageWhenHighlighted = NO;
    [selectBtn setBackgroundImage:[UIImage imageNamed:@"reverb"] forState:UIControlStateNormal];
    [selectBtn setTitle:@"tc-classic-hall" forState:UIControlStateNormal];
    [selectBtn setTitleColor:BLUEFONTCOLOR forState:UIControlStateNormal];
    
    selectBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [selectBtn addTarget:self action:@selector(clickSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
    [selectBtn sizeToFit];
    selectBtn.frame = CGRectMake(72.5, 325, selectBtn.bounds.size.width, selectBtn.bounds.size.height);
    [BGView addSubview:selectBtn];
    
    //添加两个控制按钮
    LYRevolveView *leftRevolveView = [[LYRevolveView alloc]initWithImage:[UIImage imageNamed:@"rotary-knob1"]];
    self.leftRevolveView = leftRevolveView;
    leftRevolveView.userInteractionEnabled = YES;
    leftRevolveView.frame = CGRectMake(241.5, 102, leftRevolveView.bounds.size.width, leftRevolveView.bounds.size.height);
    leftRevolveView.tag = 1;
    leftRevolveView.revolveDelegate = self;
    [BGView addSubview:leftRevolveView];
    
    LYRevolveView *rightRevolveView = [[LYRevolveView alloc]initWithImage:[UIImage imageNamed:@"rotary-knob1"]];
    self.rightRevolveView  = rightRevolveView;
    rightRevolveView.userInteractionEnabled = YES;
    rightRevolveView.frame = CGRectMake(513.5, 102, leftRevolveView.bounds.size.width, leftRevolveView.bounds.size.height);
    rightRevolveView.tag = 2;
    rightRevolveView.revolveDelegate = self;
    [BGView addSubview:rightRevolveView];
    
    //添加两个数字lable
    self.leftLable = [UILabel new];
    self.leftLable.hidden = YES;
    self.leftLable.text = self.model.mix;
     self.leftLable.font = [UIFont systemFontOfSize:12];
    self.leftLable.textColor = BLUEFONTCOLOR;
    [BGView addSubview:self.leftLable];
    [self.leftLable makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(leftRevolveView);
        make.bottom.equalTo(leftRevolveView.mas_top).mas_offset(-16);
    }];
    
    self.rightLable = [UILabel new];
    self.rightLable.hidden = YES;
    self.rightLable.text = self.model.decay;
    self.rightLable.font = [UIFont systemFontOfSize:12];
    self.rightLable.textColor = BLUEFONTCOLOR;
    [BGView addSubview:self.rightLable];
    [self.rightLable makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(rightRevolveView);
        make.bottom.equalTo(rightRevolveView.mas_top).mas_offset(-16);
    }];

    //添加两个lable
    UILabel *mixLable = [UILabel new];
    mixLable.text = @"mix";
    mixLable.textColor = BLUEFONTCOLOR;
    mixLable.font = [UIFont systemFontOfSize:15.5];
    [BGView addSubview:mixLable];
    [mixLable makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(leftRevolveView);
        make.top.equalTo(leftRevolveView.mas_bottom).mas_offset(10);
    }];
    
    UILabel *decayLable = [UILabel new];
    decayLable.text = @"decay";
    decayLable.textColor = BLUEFONTCOLOR;
    decayLable.font = [UIFont systemFontOfSize:15.5];
    [BGView addSubview:decayLable];
    [decayLable makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(rightRevolveView);
        make.top.equalTo(leftRevolveView.mas_bottom).mas_offset(10);
    }];
    
    //添加 input 和 output
     UIImageView *VULeft1BG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"VU2"]];
    VULeft1BG.frame = CGRectMake(786, 75.5, VULeft1BG.bounds.size.width, VULeft1BG.bounds.size.height);
    [BGView addSubview:VULeft1BG];
    
    
    UILabel *topLeftLable1 = [UILabel new];
    topLeftLable1.text = @"-70";
    topLeftLable1.textColor = BLUEFONTCOLOR;
    topLeftLable1.font = [UIFont systemFontOfSize:FONT];
    [BGView addSubview:topLeftLable1];
    [topLeftLable1 makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(VULeft1BG);
        make.bottom.equalTo(VULeft1BG.mas_top).mas_offset(-5);
    }];
    
    
      UIImageView *VULeft2BG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"VU2"]];
    [BGView addSubview:VULeft2BG];
    [VULeft2BG makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(VULeft1BG);
        make.left.equalTo(VULeft1BG.mas_right).mas_offset(5);
    }];
    UILabel *topLeftLable2 = [UILabel new];
    topLeftLable2.text = @"-70";
    topLeftLable2.textColor = BLUEFONTCOLOR;
    topLeftLable2.font = [UIFont systemFontOfSize:FONT];
    [BGView addSubview:topLeftLable2];
    [topLeftLable2 makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(VULeft2BG);
        make.bottom.equalTo(VULeft2BG.mas_top).mas_offset(-5);
    }];
    
    
    UIImageView *VUNumble = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"vu-number"]];
    [BGView addSubview:VUNumble];
    [VUNumble makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(BGView).mas_offset(93);
        make.left.equalTo(VULeft2BG.mas_right).mas_offset(31);
    }];
    
    
      UIImageView *VURight1BG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"VU2"]];\
    [BGView addSubview:VURight1BG];
    [VURight1BG makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(VULeft2BG);
        make.left.equalTo(VUNumble.mas_right).mas_offset(31);
    }];
    UILabel *topRightLable1 = [UILabel new];
    topRightLable1.text = @"-70";
    topRightLable1.textColor = BLUEFONTCOLOR;
    topRightLable1.font = [UIFont systemFontOfSize:FONT];
    [BGView addSubview:topRightLable1];
    [topRightLable1 makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(VURight1BG);
        make.bottom.equalTo(VURight1BG.mas_top).mas_offset(-5);
    }];
    
      UIImageView *VURight2BG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"VU2"]];
    [BGView addSubview:VURight2BG];
    [VURight2BG makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(VURight1BG);
        make.left.equalTo(VURight1BG.mas_right).mas_offset(5);
    }];
    UILabel *topRightLable2 = [UILabel new];
    topRightLable2.text = @"-70";
    topRightLable2.textColor = BLUEFONTCOLOR;
    topRightLable2.font = [UIFont systemFontOfSize:FONT];
    [BGView addSubview:topRightLable2];
    [topRightLable2 makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(VURight2BG);
        make.bottom.equalTo(VURight2BG.mas_top).mas_offset(-5);
    }];

    // input 和 output 下面的两个标签
    UIImageView *inputImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"input"]];
    [BGView addSubview:inputImage];
    [inputImage makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(VULeft1BG);
        make.top.equalTo(VULeft1BG.mas_bottom).mas_offset(5);
    }];
    
    UIImageView *outputImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"output"]];
    [BGView addSubview:outputImage];
    [outputImage makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(VURight1BG).mas_offset(-5);
        make.top.equalTo(VURight1BG.mas_bottom).mas_offset(5);
    }];
    
    // 添加VULeft1BG VULeft2BG  VURight1BG VURight2BG
    UIView *left1 = [UIView new];
    left1.backgroundColor = BLUEFONTCOLOR;
    [VULeft1BG addSubview:left1];
    [left1 makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(VULeft1BG);
        make.height.equalTo(@0);
    }];
    
    UIView *left2 = [UIView new];
    left2.backgroundColor = BLUEFONTCOLOR;
    [VULeft2BG addSubview:left2];
    [left2 makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(VULeft2BG);
        make.height.equalTo(@0);
    }];
    
    UIView *right1 = [UIView new];
    right1.backgroundColor = BLUEFONTCOLOR;
    [VURight1BG addSubview:right1];
    [right1 makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(VURight1BG);
        make.height.equalTo(@0);
    }];
    
    UIView *right2 = [UIView new];
    right2.backgroundColor = BLUEFONTCOLOR;
    [VURight2BG addSubview:right2];
    [right2 makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(VURight2BG);
        make.height.equalTo(@0);
    }];
    
    
    // 接收到通知
    [[NSNotificationCenter defaultCenter] addObserverForName:@"updataData" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if(-self.model.lever.inputLeft >= 60){
            self.leftStr1 = - 60;
        }else if(-self.model.lever.inputLeft <=0){
            self.leftStr1 = 0;
        }else{
        self.leftStr1 = self.model.lever.inputLeft;
        }
        
        if(-self.model.lever.inputRight >= 60){
            self.leftStr2 =  - 60;
        }else if(-self.model.lever.inputRight <=0){
            self.leftStr2 = 0;
        }else{
            self.leftStr2 = self.model.lever.inputRight;
        }
        
        if(-self.model.lever.outputLeft >= 60){
            self.rightStr1 =  - 60;
        }else if(-self.model.lever.outputLeft <= 0){
            self.rightStr1 = 0;
        }else{
            self.rightStr1 = self.model.lever.outputLeft;
        }
        
        if(-self.model.lever.outputRight >= 60){
            self.rightStr2 = - 60;
        }else if(-self.model.lever.outputRight <= 0){
            self.rightStr2 = 0;
        }else{
            self.rightStr2 = self.model.lever.outputRight;
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
        }
       ];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"open" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        offONBtn.selected = self.model.open;
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"mix" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        leftRevolveView.StartNumble = self.model.mix;
        
      
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"decay" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        rightRevolveView.StartNumble = self.model.decay;
    }];
    
    // 接受到lable隐藏的通知
    [[NSNotificationCenter defaultCenter] addObserverForName:@"hidden" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if([note.object intValue] == 1){
         self.leftLable.hidden = YES;
        }else if([note.object intValue] == 2){
          self.rightLable.hidden = YES;
        }
    }];
    // 出现lable的通知
    [[NSNotificationCenter defaultCenter] addObserverForName:@"appear" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if([note.object intValue] == 1){
            self.leftLable.hidden = NO;
        }else if([note.object intValue] == 2){
            self.rightLable.hidden = NO;
        }
    }];
}
                                

-(void)clickOffOnBtn:(UIButton *)sender{
    sender.selected = ! sender.selected;
    int i = sender.selected;
    // 改变状态的时候 发送数据
    [[GCDSocketTools sharedInstance] sendDict:nil OrString:[NSString stringWithFormat:@"reverb:open:%d",i] returnMsg:nil returnError:nil andTag:11];
    
}
-(void)clickSelectBtn:(UIButton *)sender{
//    UITableViewController *leverlView = [[UITableViewController alloc]init];
//    leverlView.view.frame = CGRectMake(0, 0, 118, 60);
//    leverlView.view.backgroundColor = [UIColor blackColor];
//    
//    CustomPopOverView *CustomView = [CustomPopOverView popOverView];
//   CustomView.containerBackgroudColor = BLUEFONTCOLOR;
//    CustomView.contentViewController = leverlView;
//    
//    [CustomView showFrom:sender alignStyle:CPAlignStyleRight];
    NSArray *titles = @[@"tc-classic-hall",@"tc-classic-hall",@"tc-classic-hall"];
    CustomPopOverView *popView = [[CustomPopOverView alloc]initWithBounds:CGRectMake(0, 0, 118, 66) titleMenus:titles];
    popView.containerBackgroudColor = BLUEFONTCOLOR;
    [popView showFrom:sender alignStyle:CPAlignStyleLeft];
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
