//
//  GCDSocketTools.h
//  socket心跳包
//
//  Created by iOS程序员 on 16/10/19.
//  Copyright © 2016年 baidu. All rights reserved.
//    1. udp
//    创建  bindToport blind  发送  // 代理回调 是发送成功 还是发送失败了 得到服务器接受的消息(这个 )

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
//IP
#define SERVER_HOST @"192.168.1.125"
//端口
#define SERVER_PORT 8601
#define TIMEOUT -1

typedef void(^ReturnMsg) (NSDictionary *dict,NSString *msg);
typedef void (^ReturnError)(NSError *error);


@interface GCDSocketTools : NSObject <GCDAsyncUdpSocketDelegate>
@property (nonatomic,strong)GCDAsyncUdpSocket *udpSocket;
@property (nonatomic,copy)ReturnMsg returnMsg;
@property (nonatomic,copy)ReturnError returnError;
@property (nonatomic,copy)NSString *server_host;

+(instancetype)sharedInstance;

-(void)disconnect;

-(void)sendDict:(NSDictionary *)dict OrString:(NSString *)string returnMsg:(__autoreleasing ReturnMsg)returnMsg returnError:(__autoreleasing ReturnError) returnError andTag:(long)tag;
@end
