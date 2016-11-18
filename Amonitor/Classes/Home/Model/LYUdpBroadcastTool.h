//
//  LYUdpBroadcastTool.h
//  Amonitor
//
//  Created by iOS程序员 on 16/11/2.
//  Copyright © 2016年 leye. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCDAsyncUdpSocket;

@interface LYUdpBroadcastTool : NSObject
+(instancetype)defaultInstance;
-(void)sendString:(NSString *)string Tag:(long)tag;


// block 回调数据
@property (nonatomic,copy)void(^dataBlock)(NSArray *array);
@property (nonatomic,strong)GCDAsyncUdpSocket *udpSocket;


@end
