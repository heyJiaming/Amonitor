//
//  LYAllKShowImageVIew.m
//  Amonitor
//
//  Created by iOS程序员 on 16/11/8.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYAllKShowImageVIew.h"
#import "LYKshowImageView.h"
#import "GCDSocketTools.h"

#define Color_Blue [UIColor colorWithRed:59/255.0 green:197/255.0 blue:254/255.0 alpha:1]
#define Color_Cyan [UIColor colorWithRed:175/255.0 green:243/255.0 blue:230/255.0 alpha:1]
#define Color_Green [UIColor colorWithRed:223/255.0 green:252/255.0 blue:134/255.0 alpha:1]
#define Color_Orange [UIColor colorWithRed:255/255.0 green:196/255.0 blue:122/255.0 alpha:1]
#define Color_Pink [UIColor colorWithRed:254/255.0 green:121/255.0 blue:146/255.0 alpha:1]
#define Color_purple [UIColor colorWithRed:179/255.0 green:163/255.0 blue:255/255.0 alpha:1]
#define Color_Red [UIColor colorWithRed:255/255.0 green:64/255.0 blue:65/255.0 alpha:1]


@interface LYAllKShowImageVIew ()
@property (nonatomic,weak)LYKshowImageView *currentSelectedView;
// 第几组
@property (nonatomic,assign) NSInteger p;
@end
@implementation LYAllKShowImageVIew

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        float ksMarginX = 144;
        float ksW = 80;
        float ksH = 80;
        float ksMargin = 14;
        float ksY = 30;
        // 上面颜色方块点击的通知
        [[NSNotificationCenter defaultCenter] addObserverForName:@"colorBlocArray" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //获取到在第几组
            NSInteger p = [note.object[1] integerValue];
            self.p = p;
            
            for (LYKshowImageView *v in self.subviews) {
                [v removeFromSuperview];
            }
            //获取到当前点击的是第几个
            int j = [note.object[1] intValue] - 1;
            NSLog(@"%d",j);
            NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:48];
        
            for(int i = 0;i< 48;i++){
                if(i<self.array.count){
                    [mutableArray addObject:self.array[i]];
                }else{
                    [mutableArray addObject:[NSDictionary dictionary]];
                }
            }
           NSArray *AlldataArray = [self getNewArrayWithArray:mutableArray.copy];
            // 获取到当前的数据
            NSArray *currentArray =AlldataArray[j];
            // 当前的颜色
            NSArray *array = note.object[0];
            NSLog(@"%@",array);
            //设置一个图片名称的数组
            NSArray *selImageArray = [self getimageNameWirhColor:array];
            NSLog(@"selImageArray :%@",selImageArray);
            
            for(int i = 0;i<8;i++){
                LYKshowImageView *ksimageView = [[LYKshowImageView alloc] initWithFrame:CGRectMake(ksMarginX+i*(ksW + ksMargin), ksY,ksW,ksH)];
                ksimageView.tag = i+1;
                NSLog(@"ksimageView:%zd",ksimageView.tag);
                ksimageView.userInteractionEnabled = YES;
                [self addSubview:ksimageView];
                if(i<selImageArray.count){
                    // 只为 有颜色的添加 轻拍的手势
                    UITapGestureRecognizer *tapGes=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickKshow:)];
                    [ksimageView addGestureRecognizer:tapGes];
                    
                    
                    ksimageView.colorStr = selImageArray[i];
                     NSDictionary *dict = currentArray[i];
                    //设置初始状态
                    
                    if(i == 0){
                         [ksimageView imageWithTitle:@"kshow" subTitle:[dict allKeys].firstObject changeTitle:[dict allValues].firstObject color:array[i]];
                        ksimageView.selStatu = NO;
                      //  self.currentSelectedView = ksimageView;

                    }else {
                        [ksimageView imageWithTitle:@"kshow" subTitle:[dict allKeys].firstObject changeTitle:[dict allValues].firstObject color:array[i]];
                        ksimageView.selStatu = NO;
                    }
                }else{
                   ksimageView.colorStr = @"grey";
                    ksimageView.selStatu = NO;
                    [ksimageView imageWithTitle:nil subTitle:nil changeTitle:nil color:nil];
                }
                
                }
            //读取的存储的偏好设置里面的值,如果什么都没有就点击第一个
           
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSUInteger  m = [defaults integerForKey:@"ROW"];
            // 如果优质
            if([defaults integerForKey:@"SECTION"]){
            if( [defaults integerForKey:@"SECTION"] == self.p){
          //  [self clickKshow:self.subviews[m-1].gestureRecognizers.lastObject];
//                
             LYKshowImageView *kgImage = self.subviews[m-1];
                kgImage.selStatu = YES;
           self.currentSelectedView = self.subviews[m-1];
            }
                
            }else{
                
                 [self clickKshow:self.subviews[0].gestureRecognizers.lastObject];
//                LYKshowImageView *kgImage = self.subviews[0];
//                kgImage.selStatu = YES;
//                self.currentSelectedView = self.subviews[0];
            }
        }];
    }
    return self;
}
-(void)clickKshow:(UITapGestureRecognizer *)gesture{
    
    LYKshowImageView *img = (LYKshowImageView *)gesture.view;
    if(img.selStatu == NO){
       
        // 在ip存在的时候 会发送一个断开连接
        if([GCDSocketTools sharedInstance].server_host){
        [[GCDSocketTools sharedInstance] sendDict:nil OrString:@"disconnect" returnMsg:nil returnError:nil andTag:110];
        }
        //切换了新的ip地址
        img.selStatu = YES;
        self.currentSelectedView.selStatu = NO;
        self.currentSelectedView = img;
        
        // 切换了 kshow 首先应该回到第一个控制器
        [[NSNotificationCenter defaultCenter] postNotificationName:@"returnDiscover" object:nil];
        //存档 把 第几组 和 几个元素存为偏好设置
        [[NSUserDefaults standardUserDefaults] setInteger:self.p forKey:@"SECTION"];
        [[NSUserDefaults standardUserDefaults] setInteger:img.tag forKey:@"ROW"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
   

}

// Color_Blue,Color_Cyan,Color_Green,Color_Orange,Color_Pink,Color_purple,Color_Red
-(NSArray *)getimageNameWirhColor:(NSArray *)colorArray{
    NSMutableArray *MTArray = [NSMutableArray array];
    for (UIColor *color in colorArray) {
        if(CGColorEqualToColor(color.CGColor,Color_Blue.CGColor)){
            [MTArray addObject:@"blue"];
        }else if(CGColorEqualToColor(color.CGColor, Color_Cyan.CGColor)){
            [MTArray addObject:@"cyan"];
        }else if(CGColorEqualToColor(color.CGColor, Color_Green.CGColor)){
            [MTArray addObject:@"green"];
        }else if(CGColorEqualToColor(color.CGColor, Color_Orange.CGColor)){
            [MTArray addObject:@"orange"];
        }else if (CGColorEqualToColor(color.CGColor, Color_Pink.CGColor)){
            [MTArray addObject:@"pink"];
        }else if (CGColorEqualToColor(color.CGColor, Color_purple.CGColor)){
            [MTArray addObject:@"purple"];
        }else if(CGColorEqualToColor(color.CGColor, Color_Red.CGColor)){
            [MTArray addObject:@"red"];
        }
    }
    return MTArray.copy;
}

-(NSArray *)getNewArrayWithArray:(NSArray *)arr{
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *array = arr.mutableCopy;
    while (array.count > 8) {
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:8];
        for(int i = 0 ;i<8;i++){
            [temp addObject:array[i]];
        }
        [mutableArray addObject:temp.copy];
        [array removeObjectsInRange:NSMakeRange(0,8)];
    }
    [mutableArray addObject:array.copy];
    NSLog(@"%@",mutableArray.copy);
    return mutableArray.copy;
}

-(void)dealloc{
    // 移除所有的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
