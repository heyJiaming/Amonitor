//
//  LYCompandMode.m
//  Amonitor
//
//  Created by iOS程序员 on 16/11/4.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYCompandMode.h"

@implementation LYCompandMode
+(instancetype)sharedInstance{
    static LYCompandMode *compandMode = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        compandMode = [[LYCompandMode alloc]init];
    });
    return  compandMode;
}
@end
