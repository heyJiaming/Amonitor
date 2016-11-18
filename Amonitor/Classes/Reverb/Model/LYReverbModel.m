//
//  LYReverbModel.m
//  Amonitor
//
//  Created by iOS程序员 on 16/10/26.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "LYReverbModel.h"

@implementation LYReverbModel
+(instancetype)sharedInstance{
    static LYReverbModel *reverbModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reverbModel = [[LYReverbModel alloc]init];
    });
    return  reverbModel;
}
@end
