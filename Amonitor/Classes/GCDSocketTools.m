
//
//  GCDSocketTools.m
//  socket心跳包
//
//  Created by iOS程序员 on 16/10/19.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "GCDSocketTools.h"
#import "LYReverbModel.h"
#import "LYCompandMode.h"
#import <UIKit/UIKit.h>

@implementation GCDSocketTools

//断开连接的方法
-(void)disconnect{

}
#pragma mark 字典转json
-(NSString *)dictionaryToJson:(NSDictionary *)dic{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(void)sendDict:(NSDictionary *)dict OrString:(NSString *)string returnMsg:(__autoreleasing ReturnMsg)returnMsg returnError:(__autoreleasing ReturnError)returnError andTag:(long)tag{
    if(dict){
        NSString *json = [self dictionaryToJson:dict];
        NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
        [self.udpSocket sendData:data toHost:self.server_host port:SERVER_PORT withTimeout:TIMEOUT tag:tag];
    }else{
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        [self.udpSocket sendData:data toHost:self.server_host port:SERVER_PORT withTimeout:TIMEOUT tag:tag];
    }
    // 为block 属性赋值 
    self.returnMsg = returnMsg;
    self.returnError = returnError;
}

#pragma mark - socket协议方法
//Called when the socket has received the requested datagram.
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(nonnull NSData *)address withFilterContext:(nullable id)filterContext{
// 接受到 数据的时候 把数据解析出来 然后打印出来

    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"接受到的数据:%@",str);
//    NSArray *arr = [str componentsSeparatedByString:@":"];
//    if([arr[0] isEqualToString:@"reverb"]){   // 针对reverb 界面做的解析
//    // 拿到单利模型
//    LYReverbModel *reverbModel = [LYReverbModel sharedInstance];
//    
//    if([arr[1] isEqualToString:@"mode"]){
//        reverbModel.mode = arr[2];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"mode" object:nil];
//    }else if([arr[1] isEqualToString:@"open"]){
//        reverbModel.open = [arr[2] intValue];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"open" object:nil];
//    }else if([arr[1] isEqualToString:@"mix"]){
//       
//        reverbModel.mix = [NSString stringWithFormat:@"%.2f",[arr[2] floatValue]];
//         [[NSNotificationCenter defaultCenter] postNotificationName:@"mix" object:nil];
//    }else if([arr[1] isEqualToString:@"decay"]){
//        reverbModel.decay = [NSString stringWithFormat:@"%.1f",[arr[2] floatValue]];
//         [[NSNotificationCenter defaultCenter] postNotificationName:@"decay"object:nil];
//    }else if([arr[1] isEqualToString:@"level"]){
//       NSArray *arr3 = [arr[2] componentsSeparatedByString:@"#"];
//        
//        NSArray *arr4 = [arr3[0] componentsSeparatedByString:@","];
//       
//        NSArray *arr5 = [arr3[1] componentsSeparatedByString:@","];
//       
//        leverStruct leverstr = {[arr4[0] floatValue], [arr4[1] floatValue],[arr5[0] floatValue],[arr5[1] floatValue]};
//        reverbModel.lever = leverstr;
//        // 当数据来的时候发出一个通知
//        //  [[NSNotificationCenter defaultCenter] postNotification:@"updataData"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"updataData" object:nil];
//        }
//    }else if([arr[0] isEqualToString:@"compand"]){ //compand 界面的数据解析
//        
//        // 拿到单利模型
//        LYCompandMode *compandMode = [LYCompandMode sharedInstance];
//        
//        if([arr[1] isEqualToString:@"open"]){
//            compandMode.open = [arr[2] intValue];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"CompandOpen" object:nil];
//        }else if([arr[1] isEqualToString:@"at"]){
//            compandMode.at = arr[2];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"CompandAt" object:nil];
//        }else if([arr[1] isEqualToString:@"rt"]){
//            
//            compandMode.rt = arr[2];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"CompandRt" object:nil];
//        }else if([arr[1] isEqualToString:@"gain"]){
//            compandMode.softknee = [NSString stringWithFormat:@"%.1f",[arr[2] floatValue]];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"CompandGain"object:nil];
//        }else if([arr[1] isEqualToString:@"level"]){
//            NSArray *arr3 = [arr[2] componentsSeparatedByString:@"#"];
//            
//            NSArray *arr4 = [arr3[0] componentsSeparatedByString:@","];
//            
//            NSArray *arr5 = [arr3[1] componentsSeparatedByString:@","];
//            
//            compandLeverStruct leverstr = {[arr4[0] floatValue], [arr4[1] floatValue],[arr5[0] floatValue],[arr5[1] floatValue]};
//            compandMode.lever = leverstr;
//            // 当数据来的时候发出一个通知
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"CompandUpdata" object:nil];
//        }else if ([arr[1] isEqualToString:@"points"]){
//            NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:5];
//            NSArray *arr3 = [arr[2] componentsSeparatedByString:@"#"];
//            for (NSString *str in arr3) {
//                NSArray *arr4 = [str componentsSeparatedByString:@","];
//                CGPoint point = CGPointMake([arr4[0] floatValue], [arr4[1] floatValue]);
//                NSString *strPoint = NSStringFromCGPoint(point);
//                [arrM addObject:strPoint];
//            }
//            compandMode.points = arrM.copy;
//            // 数据发出一个通知
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"CompandPoints" object:nil];
//        }else if([arr[1] isEqualToString:@"softknee"]){
//            compandMode.softknee = [arr[2] intValue];
//             [[NSNotificationCenter defaultCenter] postNotificationName:@"CompandSoftknee" object:nil];
//        }
//    }
    NSError *err = nil;
    [sock receiveOnce:&err];
}

// 消息发送失败
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"数据发送成功,Tag:%ld",tag);
}
// 消息发送失败
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    if(_returnError){
        _returnError(error);
    }
}
// 断开连接 
-(void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"断开连接");
}

#pragma mark - 懒加载 (get方法)
-(GCDAsyncUdpSocket *)udpSocket{

    if(!_udpSocket){
        dispatch_queue_t dQueue = dispatch_queue_create("client dp socket", NULL);
        // 创建一个socket
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue() socketQueue:nil];
        // 绑定一个端口 不绑定 随机生成一个
        NSError *err;
        [_udpSocket bindToPort:8602 error:&err];
        //3.等待接受对方的消息 //receiveOnce
        
        [_udpSocket beginReceiving:&err];
    }
    return _udpSocket;
}

#pragma mark -初始化 单利对象
+(instancetype)sharedInstance{
    static GCDSocketTools *socketConnet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socketConnet = [[GCDSocketTools alloc]init];
    });
    return  socketConnet;
}
-(void)dealloc{

          [_udpSocket close];
        
          _udpSocket = nil;    
}
@end
