//
//  LYReverbModel.h
//  Amonitor
//
//  Created by iOS程序员 on 16/10/26.
//  Copyright © 2016年 leye. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct lever {
    float inputLeft;
    float inputRight;
    float outputLeft;
    float outputRight;
} leverStruct;

@interface LYReverbModel : NSObject

@property (nonatomic,strong)NSString *mode;
@property (nonatomic,assign)BOOL open;
@property (nonatomic,strong)NSString *mix;
@property (nonatomic,strong)NSString *decay;
@property (nonatomic,assign) leverStruct lever;

+(instancetype)sharedInstance;
@end
