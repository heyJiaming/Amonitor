//
//  LYHomeViewController.m
//  Amonitor
//
//  Created by iOS程序员 on 16/10/27.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYHomeViewController.h"
#import "GCDSocketTools.h"
#import "LYReverbModel.h"
#import "LYGetIPAdress.h"

#import "Masonry.h"
#import "UIView+HMCategory.h"
#import "LYScaleButton.h"
#import "LYImageVIew.h"
#import "LYKshowImageView.h"
#import  "LYColorBlockView.h"
#import  "LYTabBarView.h"
#import  "LYDiscoverViewController.h"
#import "LYReverbViewController.h"
#import  "LYCompandViewController.h"
#import  "LYUdpBroadcastTool.h"
#import "XHScanToolController.h"
//创建上面6个颜色块的类
#import "LYAllColorBlock.h"
#import "LYAllKShowImageVIew.h"
#define DRAKCOLOR [UIColor colorWithRed:29/255.0 green:29/255.0 blue:29/255.0 alpha:1]
#define BLUECL [UIColor colorWithRed:47/255.0 green:181/255.0 blue:233/255.0 alpha:1]

//需要随机选择的7中色系
#define Color_Blue [UIColor colorWithRed:59/255.0 green:197/255.0 blue:254/255.0 alpha:1]
#define Color_Cyan [UIColor colorWithRed:175/255.0 green:243/255.0 blue:230/255.0 alpha:1]
#define Color_Green [UIColor colorWithRed:223/255.0 green:252/255.0 blue:134/255.0 alpha:1]
#define Color_Orange [UIColor colorWithRed:255/255.0 green:196/255.0 blue:122/255.0 alpha:1]
#define Color_Pink [UIColor colorWithRed:254/255.0 green:121/255.0 blue:146/255.0 alpha:1]
#define Color_purple [UIColor colorWithRed:179/255.0 green:163/255.0 blue:255/255.0 alpha:1]
#define Color_Red [UIColor colorWithRed:255/255.0 green:64/255.0 blue:65/255.0 alpha:1]


@interface LYHomeViewController ()<UISearchBarDelegate,XHScanToolControllerDelegate>
@property (nonatomic,weak)UIView *selecView;
@property (nonatomic,weak)LYTabBarView *tabbarView;
@property (nonatomic,weak)UIView *ctrView;
@property (nonatomic,weak)LYKshowImageView *ks1ImageView;
@property (nonatomic,weak)LYKshowImageView *ks2ImageView;

@property (nonatomic,weak)UIView *ksSelecView;

// 改变的lable
@property (nonatomic,weak)UILabel *changeLable;
//接受数据的数组
@property (nonatomic,strong)NSArray *dataArray;
// 正在显示的自控制器
@property (nonatomic, strong)UIViewController *selectChildVC;
// 设置lable的初始值为 1
@property (nonatomic, assign) NSInteger changeIndex;
//设置当前选中的view kshowView
@property (nonatomic,strong)LYColorBlockView *selectedColorBlockView;
@property (nonatomic,weak)LYKshowImageView *selectedKsimageView;

@property (nonatomic,weak)LYAllColorBlock *allColorBlockView;
@property (nonatomic,weak)LYAllKShowImageVIew *allKshowView;

//scan(扫一扫)
@property(nonatomic,weak)XHScanToolController *ScanVc;
@property(nonatomic,weak)UIButton *scanBtn;

@end



@implementation LYHomeViewController
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if(self.dataArray){
        for (int i=0;i<self.dataArray.count;i++) {
            NSDictionary *dic = self.dataArray[i];
            NSString *textStr = [dic allKeys].firstObject;
        if([searchBar.text isEqualToString:[textStr substringFromIndex:2]] || [searchBar.text isEqualToString:[textStr substringFromIndex:textStr.length - 4]]){
            // 获取在第几组
            int sec = i/8+1;
            for (LYColorBlockView *view in self.allColorBlockView.subviews) {
                if(view.tag == sec){
                    [self.allColorBlockView clickTap:view.gestureRecognizers.firstObject];
                }
            }
            //获取在第几行
            int row = (i+1) %8;
            if(row == 0){
                row = sec*8;
            }
            for(LYKshowImageView *view in self.allKshowView.subviews){
                if(view.tag == row){
                    for(int i=0;i<view.gestureRecognizers.count;i++){
                        NSLog(@"%@",view.gestureRecognizers[i]);
                    }
                    [self.allKshowView clickKshow:view.gestureRecognizers.lastObject];
                }
            }
          
            searchBar.text = nil;
            searchBar.placeholder = nil;
            // 辞去第一响应者
            [searchBar resignFirstResponder];
            return;
        }
    }
        searchBar.text = nil;
        searchBar.placeholder = @"目前暂无此编号";
    }else{
        searchBar.text  = nil;
        searchBar.placeholder = @"一切空空!";
    
    }
    // 辞去第一响应者
    [searchBar resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.view.backgroundColor = [UIColor redColor];
    // 创建 控制器
    [self setupChildViewController];
    // 注册通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tabBarDidchange:) name:@"tabBarDidchange" object:nil];
       // 二: 选择kshow界面的背景view
    UIView *selecView = [[UIView alloc]init];
    self.selecView = selecView;
    selecView.backgroundColor = [UIColor redColor];
    [self.view addSubview:selecView];
    [selecView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(@264);
    }];
    //选择kShow的view的整个界面
    UIView *ksSelecView = [UIView new];
    self.ksSelecView = ksSelecView;
    ksSelecView.backgroundColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1];
    [selecView addSubview:ksSelecView];
    [ksSelecView makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(selecView);
        make.height.equalTo(@194);
    }];
    
    // 创建一个专门管理上面6个的view
    LYAllColorBlock *allColorBlockView = [LYAllColorBlock new];
    self.allColorBlockView = allColorBlockView;
    allColorBlockView.backgroundColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1];
    [ksSelecView addSubview:allColorBlockView];
    [allColorBlockView makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(ksSelecView);
        make.height.equalTo(@50);
    }];
    
    //创建一个专门管理下面8个view的view
    LYAllKShowImageVIew *allKshowView = [LYAllKShowImageVIew new];
    self.allKshowView = allKshowView;
    allKshowView.backgroundColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1];
    [ksSelecView addSubview:allKshowView];
    [allKshowView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(allColorBlockView.mas_bottom);
        make.left.right.equalTo(ksSelecView);
        make.height.equalTo(@144);
    }];
   //当都没有响应的时候
    if(self.dataArray == nil){
        allColorBlockView.colorArray = self.dataArray;

    }
    // 获取数据
    [LYUdpBroadcastTool defaultInstance].dataBlock = ^(NSArray *array){
        self.dataArray = array;
        allKshowView.array = array;
             //准备一个可变数组
         NSMutableArray *Marr = [NSMutableArray array];
        NSArray *randomArray = [[NSArray alloc]initWithObjects:Color_Blue,Color_Cyan,Color_Green,Color_Orange,Color_Pink,Color_purple,Color_Red,nil];
        for(int x=0;x<array.count;x++){
            int r = arc4random()%[randomArray count];
            [Marr addObject:randomArray[r]];
        }
        //创建上面小的View
        allColorBlockView.colorArray =Marr.copy;
        //---------------创建下面的kshow的方块-------------------
        // 便利这个颜色 获取到对应的字符串的数组  拿到的数据数组 是：array (dataArray)
       // NSArray *selImageArray = [self getimageNameWirhColor:Marr.copy];
        
        // [self.view setNeedsLayout];

    };
        //创建一个向左 向右的小箭头
    UIButton *selectLeftButton = [[UIButton alloc]initWithFrame:CGRectMake(105, 85, 28, 80)];
    [selectLeftButton setImage:[UIImage imageNamed:@"btn-left arrow"] forState:UIControlStateNormal];
    
    
    [ksSelecView addSubview:selectLeftButton];
    
    UIButton *selectRightButton = [[UIButton alloc]initWithFrame:CGRectMake(895, 85, 28, 80)];
    [selectRightButton setImage:[UIImage imageNamed:@"btn-right arrow"] forState:UIControlStateNormal];
    [ksSelecView addSubview:selectRightButton];
    
    //为左 和 右 加上一个点击的方法
    [selectLeftButton addTarget:self action:@selector(click_left_ks:) forControlEvents:UIControlEventTouchUpInside];
    [selectRightButton addTarget:self action:@selector(click_right_ks:) forControlEvents :UIControlEventTouchUpInside];
    
    // 选择回到主界面的按钮
    UIView *backView = [UIView new];
    backView.backgroundColor = DRAKCOLOR;
    [selecView addSubview:backView];
    [backView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(selecView);
        make.height.equalTo(@70);
    }];
    //创建一个home的按钮
    LYScaleButton *homeBtn = [[LYScaleButton alloc]initWithFrame:CGRectMake(347, 15, 96, 40)];
    [homeBtn  image:[UIImage imageNamed:@"btn-home-n"] selectImage:[UIImage imageNamed:@"btn-home-h"] title:@"home" scale:1.33];
    homeBtn.tag = 0;
    homeBtn.statu = 1;
    [backView addSubview:homeBtn];
    
    //创建record按钮
    LYScaleButton *recordBtn = [[LYScaleButton alloc]initWithFrame:CGRectMake(515, 15, 96, 40)];
    [recordBtn image:[UIImage imageNamed:@"btn-record-n"] selectImage:[UIImage imageNamed:@"btn-record-h"] title:@"record" scale:1.33];
    recordBtn.tag = 1;
    recordBtn.statu = 0;
    [backView addSubview:recordBtn];
    // 接受到 该按钮发出的通知
    [[NSNotificationCenter defaultCenter] addObserverForName:@"scaleButton" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSNumber *btnTag =  note.object;
        for (LYScaleButton *btn in backView.subviews) {
            if(btn.tag == [btnTag intValue] ){
                btn.statu = 1;
            }else{
                btn.statu = 0;
            }
        }
    }];
// 控制frame的按钮
    UIButton *buttonBG1 = [[UIButton alloc]initWithFrame:CGRectMake(43, 81, 50, 24)];
    [buttonBG1 setBackgroundImage:[UIImage imageNamed:@"btn-1-n"] forState:UIControlStateNormal];
    [buttonBG1 setBackgroundImage:[UIImage imageNamed:@"btn-1-h"] forState:UIControlStateSelected];
    [self.view addSubview:buttonBG1];
    // 控制 frame变化的按钮
    [buttonBG1 addTarget:self action:@selector(clickChangeFrame:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *changelable = [UILabel new];
    self.changeLable = changelable;
    // 初始化
    self.changeIndex = 1;
    changelable.text = [NSString stringWithFormat:@"%ld",self.changeIndex];
    changelable.textColor = [UIColor colorWithRed:139/255.0 green:139/255.0 blue:139/255.0 alpha:1];
    [buttonBG1 addSubview:changelable];
    [changelable makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(buttonBG1);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ColorClockChangeIndex" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSInteger t = [note.object integerValue];
        self.changeIndex = t;
        changelable.text = [NSString stringWithFormat:@"%ld",self.changeIndex];
    }];
    // 一:searchBar
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    
    // 添加一个扫描 条形码的 模块
    UIButton *scanBtn = [UIButton new];
    self.scanBtn = scanBtn;
    [scanBtn  setTitle:@"扫一扫" forState:UIControlStateNormal];
    [scanBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [scanBtn addTarget:self action:@selector(clickScanBtn:) forControlEvents:UIControlEventTouchUpInside];
    [searchView addSubview:scanBtn];
    [scanBtn sizeToFit];
    [scanBtn makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(searchView.mas_right).mas_offset(-20);
        make.top.equalTo(searchView).mas_offset(10);
    }];
    
 
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(43, 12, 184, 28)];
    searchBar.delegate = self;
   searchBar.backgroundImage = [[UIImage alloc]init];
    searchBar.barTintColor = [UIColor whiteColor];
    UITextField *searchField = [searchBar valueForKey:@"searchField"];
    
    if(searchField){
        [searchField setBackgroundColor:DRAKCOLOR];
        searchField.textColor = [UIColor whiteColor];
        searchField.layer.cornerRadius = 12;
        searchField.layer.borderColor = [UIColor colorWithRed:62/255.0 green:62/255.0 blue:62/255.0 alpha:1].CGColor;
        searchField.layer.borderWidth = 1;
        searchField.layer.masksToBounds = YES;
    }
    [searchView addSubview:searchBar];
    
    searchView.backgroundColor = DRAKCOLOR;
    [self.view addSubview:searchView];
    //设置第四个view
    LYTabBarView *tabbarView1 = [[LYTabBarView alloc]initWithFrame:CGRectMake(0, 716, [UIScreen mainScreen].bounds.size.width, 52)];;
    self.tabbarView = tabbarView1;
    [self.view addSubview:tabbarView1];
    
    //  3 设置第三个view
    UIView *ctrView = [[UIView alloc]init];
    self.ctrView = ctrView;
    ctrView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:ctrView];
    [ctrView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(selecView.mas_bottom);
        make.bottom.equalTo(tabbarView1.mas_top);
    }];
    // 接受到 dicover 点击的通知
//    [[NSNotificationCenter defaultCenter] addObserverForName:@"distance" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
//        int t = [note.object intValue];
//        NSLog(@"%d",t);
//    }];
    // 初始化 自控制器
    UIViewController *newVc = self.childViewControllers[0];
    [self.view addSubview:newVc.view];
    self.selectChildVC = newVc;
    [newVc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.selecView.mas_bottom);
        make.bottom.equalTo(self.tabbarView.mas_top);
    }];
    }

//点击了扫一扫

-(void)clickScanBtn:(UIButton *)sender{
    XHScanToolController *vc = [[XHScanToolController alloc] init];
    NSLog(@"11");
    if (vc.isCameraValid && vc.isCameraAllowed) {
        self.ScanVc = vc;
        vc.scanDelegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    }else{
        if (!vc.isCameraAllowed) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在设备的设置-隐私-相机中允许访问相机。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }else if (!vc.isCameraValid){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请检查你的摄像头。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

// 扫一扫的 代理方法
- (void)scanToolController:(XHScanToolController *)scanToolController completed:(NSString *)result{
    [scanToolController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"%@",result);
    [self.scanBtn setTitle:result forState:UIControlStateNormal];
}

//获取到通知的方法
-(void)tabBarDidchange:(NSNotification *)notification{

    // 获取到索引
    NSInteger index = [notification.userInfo[@"buttonIndex"] integerValue];
    
    //2.切换控制器
    [self changeChildVC:index];
}
// 创建 6 个 控制器
-(void)setupChildViewController
{
    for(int i=0;i<3;i++){
        if(i== 0){
            LYDiscoverViewController *discoverVC = [LYDiscoverViewController new];
            [self addChildViewController:discoverVC];
        }else if(i == 1){
            LYReverbViewController *reverbVC = [LYReverbViewController new];
            [self addChildViewController:reverbVC];
        }else  if(i == 2){
            LYCompandViewController *compandController = [LYCompandViewController new];
            [self addChildViewController:compandController];
        }
    }
}

#pragma mark 切换控制器
-(void)changeChildVC:(NSInteger)index{

//1, 移除 之前 选中的控制器的 view --> 不能重复添加
    [self.selectChildVC.view removeFromSuperview];
    
//2. 获取控制器的view
    UIViewController *newVC = self.childViewControllers[index];
    //3.添加当前的view
    [self.view addSubview:newVC.view];
   // 4.选中当前的控制器
    self.selectChildVC = newVC;
    
    //布局控制器的view
    [newVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.selecView.mas_bottom);
        make.bottom.equalTo(self.tabbarView.mas_top);
    }];
    
    
    
    if(index==1){
        // 请求数据
        NSString *idAdree = [LYGetIPAdress  getIPAddress:YES];
     
        [[GCDSocketTools sharedInstance] sendDict:nil OrString:[NSString stringWithFormat:@"reverb:require:%@",idAdree] returnMsg:^(NSDictionary *dict, NSString *msg) {
            NSLog(@"%@",msg);
        } returnError:^(NSError *error) {
            NSLog(@"%@",error);
        } andTag:10];

        
    }else if(index == 2){
    
        [[GCDSocketTools sharedInstance] sendDict:nil OrString:[NSString stringWithFormat:@"compand:require:%@",[LYGetIPAdress getIPAddress:YES]] returnMsg:^(NSDictionary *dict, NSString *msg) {
            NSLog(@"%@",msg);
        } returnError:^(NSError *error) {
            NSLog(@"%@",error);
        } andTag:11];
    }
}

// 点击改变frame的
-(void)clickChangeFrame:(UIButton *)sender{
    sender.selected = ! sender.selected;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fromHome" object:@(sender.selected)];
    if(sender.selected){
[self.selecView updateConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.view).mas_offset(50);
}];
    }else{
        [self.selecView updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
        }];
    }
}
// 点击home的方法
- (void)clickHomeBtn:(UIButton *)sender{
  //  sender.imageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    sender.imageView.transform = CGAffineTransformScale(sender.imageView.transform, 2, 3);
}
// 点击record的方法
- (void)clickRecordBtn:(UIButton *)sender{
    sender.selected = !sender;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
 // 移除所有的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 点击了向左 向右的按钮
-(void)click_left_ks:(UIButton *)sender{
    //把原来选中的去掉选中效果
    self.selectedColorBlockView.currentStatus = NO;
    self.changeIndex --;
    if(self.changeIndex<1){
        self.changeIndex = 1;
    }
    self.changeLable.text = [NSString stringWithFormat:@"%ld",self.changeIndex];
  // 根据 tag 去选中 状态
    
    for (LYColorBlockView *view in self.allColorBlockView.subviews) {
        if(view.tag == self.changeIndex){
            [self.allColorBlockView clickTap:view.gestureRecognizers.firstObject];
         
        }
    }
}
-(void)click_right_ks:(UIButton *)sender{
    //同上
    self.selectedColorBlockView.currentStatus = NO;
    self.changeIndex++;
    if(self.changeIndex>6){
        self.changeIndex =6;
    }
    self.changeLable.text = [NSString stringWithFormat:@"%ld",self.changeIndex];
    // 根据 tag 去选中 状态
    for (LYColorBlockView *view in self.allColorBlockView.subviews) {
        if(view.tag == self.changeIndex){
            [self.allColorBlockView clickTap:view.gestureRecognizers.firstObject];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated{

}
@end
