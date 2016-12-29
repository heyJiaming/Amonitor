//
//  LYUdpBroadcastTool.m
//  Amonitor
//
//  Created by iOS程序员 on 16/11/2.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYUdpBroadcastTool.h"
#import  "GCDAsyncUdpSocket.h"
#import  "GCDSocketTools.h"
#define TIMEOUT -1
#define SERVER_PORT1 8500
#define SERVER_HOST1 @"255.255.255.255"

#import "LYReverbModel.h"
#import "LYCompandMode.h"
#import <UIKit/UIKit.h>
@interface LYUdpBroadcastTool ()<GCDAsyncUdpSocketDelegate>

@property (nonatomic,strong)NSMutableArray *arrayM;
@end

@implementation LYUdpBroadcastTool
+(instancetype)defaultInstance{
  static  LYUdpBroadcastTool *instance  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYUdpBroadcastTool alloc]init];
    });
    return  instance;
}
//懒加载数组
-(NSMutableArray *)arrayM{
    if(!_arrayM){
        _arrayM = [NSMutableArray arrayWithCapacity:8];
    }
    return _arrayM;
}
// 懒加载这个socket
-(GCDAsyncUdpSocket *)udpSocket{
    if(!_udpSocket){
        //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //
        dispatch_queue_t dQueue = dispatch_queue_create("My socket queue", NULL);
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *error;
        // 绑定端口
        [_udpSocket bindToPort:8602 error:&error];
        if(error){
            NSLog(@"%@",error);
        }
        //开启广播属性
        NSError *error1;
        [_udpSocket enableBroadcast:YES error:&error1];
        if(error1){
            NSLog(@"%@",error1);
        }
        //等待接受对方的消息
        NSError *error2;
        [_udpSocket beginReceiving:&error2];
        if(error2){
            NSLog(@"%@",error2);
        }
        //[_udpSocket receiveWithTimeout:1000 tag:1];
    
       
    }
    return _udpSocket;
}
// 代理方法
//收到数据的方法
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    
   // NSString *s = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   
    
    NSArray *arr = [str componentsSeparatedByString:@":"];
    if([arr[0] isEqualToString:@"reverb"]){   // 针对reverb 界面做的解析
        // 拿到单利模型
        LYReverbModel *reverbModel = [LYReverbModel sharedInstance];
        
        if([arr[1] isEqualToString:@"mode"]){
            reverbModel.mode = arr[2];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mode" object:nil];
        }else if([arr[1] isEqualToString:@"open"]){
            reverbModel.open = [arr[2] intValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"open" object:nil];
        }else if([arr[1] isEqualToString:@"mix"]){
            
            reverbModel.mix = [NSString stringWithFormat:@"%.2f",[arr[2] floatValue]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mix" object:nil];
        }else if([arr[1] isEqualToString:@"decay"]){
            reverbModel.decay = [NSString stringWithFormat:@"%.1f",[arr[2] floatValue]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"decay"object:nil];
        }else if([arr[1] isEqualToString:@"level"]){
            NSArray *arr3 = [arr[2] componentsSeparatedByString:@"#"];
            
            NSArray *arr4 = [arr3[0] componentsSeparatedByString:@","];
            
            NSArray *arr5 = [arr3[1] componentsSeparatedByString:@","];
            
            leverStruct leverstr = {[arr4[0] floatValue], [arr4[1] floatValue],[arr5[0] floatValue],[arr5[1] floatValue]};
            reverbModel.lever = leverstr;
            // 当数据来的时候发出一个通知
            //  [[NSNotificationCenter defaultCenter] postNotification:@"updataData"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updataData" object:nil];
        }
    }else if([arr[0] isEqualToString:@"compand"]){ //compand 界面的数据解析
        
        // 拿到单利模型
        LYCompandMode *compandMode = [LYCompandMode sharedInstance];
        
        if([arr[1] isEqualToString:@"open"]){
            compandMode.open = [arr[2] intValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CompandOpen" object:nil];
        }else if([arr[1] isEqualToString:@"at"]){
            compandMode.at = arr[2];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CompandAt" object:nil];
        }else if([arr[1] isEqualToString:@"rt"]){
            
            compandMode.rt = arr[2];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CompandRt" object:nil];
        }else if([arr[1] isEqualToString:@"gain"]){
            NSLog(@"接受到的数据:%@",str);
            compandMode.gain = [NSString stringWithFormat:@"%.1f",[arr[2] floatValue]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CompandGain"object:nil];
        }else if([arr[1] isEqualToString:@"level"]){
            NSArray *arr3 = [arr[2] componentsSeparatedByString:@"#"];
            
            NSArray *arr4 = [arr3[0] componentsSeparatedByString:@","];
            
            NSArray *arr5 = [arr3[1] componentsSeparatedByString:@","];
            
            NSString *lev1 = arr4[0];
            NSString *lev2 = arr4[1];
            NSString *lev3 = arr5[0];
            NSString *lev4 = arr5[1];
            if([lev1 isEqualToString:@"-inf"]){
            lev1 = @"-60";
            }
            if([lev2 isEqualToString:@"-inf"]){
                lev2 = @"-60";
            }
            if([lev3 isEqualToString:@"-inf"]){
                lev3 = @"-60";
            }
            if([lev4 isEqualToString:@"-inf"]){
                lev4 = @"-60";
            }
            
            compandLeverStruct leverstr = {[lev1 floatValue], [lev2 floatValue],[lev3 floatValue],[lev4 floatValue]};
            compandMode.lever = leverstr;
            // 当数据来的时候发出一个通知
             // NSLog(@"接受到的数据:%@",str);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CompandUpdata" object:nil];
        }else if ([arr[1] isEqualToString:@"points"]){
             NSLog(@"接受到的数据:%@",str);
            NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:5];
            NSArray *arr3 = [arr[2] componentsSeparatedByString:@"#"];
            for (NSString *str in arr3) {
                NSArray *arr4 = [str componentsSeparatedByString:@","];
                CGPoint point = CGPointMake([arr4[0] floatValue], [arr4[1] floatValue]);
                NSString *strPoint = NSStringFromCGPoint(point);
                [arrM addObject:strPoint];
            }
            compandMode.points = arrM.copy;
            // 数据发出一个通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CompandPoints" object:nil];
        }else if([arr[1] isEqualToString:@"softknee"]){
            compandMode.softknee = [arr[2] intValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CompandSoftknee" object:nil];
        }
    }else if([arr[0] isEqualToString:@"register"]){
        NSLog(@"register: 接受到的数据:%@",str);
        NSDictionary *dict = @{arr[1]:arr[2]};
        
        [self.arrayM addObject:dict];
        
//      // 测试
//        
//
//        for(int i = 0;i<50;i++){
//            NSString *str = [NSString stringWithFormat:@"ks201612020666%d",i];
//        NSDictionary *dict2 = @{str:@"192.168.1.89"};
//            [self.arrayM addObject:dict2];
//        }
//           // 接收到的数据通过block 传值
        if(self.dataBlock){
            self.dataBlock(self.arrayM.copy);
        }
    }
    // 准备接受下一次数据
    NSError *error = nil;
    [sock receiveOnce:&error];
    // 接受到的值
    // NSLog(@"接收到的值:%@",s);
}
//消息发送失败
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"数据发送成功 %ld",tag);
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error{
    NSLog(@"数据发送失败");
}
-(void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"断开连接");
}



-(void)sendString:(NSString *)string Tag:(long)tag{
    NSData *data  = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpSocket sendData:data toHost:SERVER_HOST1 port:SERVER_PORT1 withTimeout:TIMEOUT tag:tag];
}

-(void)dealloc{
        [_udpSocket close];
        
        _udpSocket = nil;
    
}



@end
