//
//  LYCompandMode.h
//  Amonitor
//
//  Created by iOS程序员 on 16/11/4.
//  Copyright © 2016年 leye. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct lever1 {
    float inputLeft;
    float inputRight;
    float outputLeft;
    float outputRight;
} compandLeverStruct;

@interface LYCompandMode : NSObject

@property (nonatomic,assign)BOOL open;
@property (nonatomic,strong)NSString *at;
@property (nonatomic,strong)NSString *rt;
@property (nonatomic,assign)BOOL softknee;
@property (nonatomic,strong)NSString *gain;
@property (nonatomic,strong)NSArray *points;
@property (nonatomic,assign)compandLeverStruct lever;

+(instancetype)sharedInstance;
@end
