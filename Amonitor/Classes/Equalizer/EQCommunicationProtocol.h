//
//  EQCommunicationProtocol.h
//  Amonitor
//
//  Created by 乐野 on 2017/1/6.
//  Copyright © 2017年 leye. All rights reserved.
//

#ifndef EQCommunicationProtocol_h
#define EQCommunicationProtocol_h
#import <Foundation/Foundation.h>

//typedef struct{
//    int open;
//    /**
//     0: high pass
//     1: low shelf
//     2: bell
//     3: high shelf
//     4: low pass
//     */
//    int filterType;
//    float gain;
//    float fc;
//    float qValue;
//}EQInformation;

@interface EQInformation : NSObject
@property int open;
/**
 0: high pass
 1: low shelf
 2: bell
 3: high shelf
 4: low pass
 */
@property int filterType;
@property float gain;
@property float fc;
@property float qValue;
@end

@interface EQInitInformation : NSObject

@property int eqOpen;
@property NSArray<EQInformation*> *eq;

@end

@protocol EQCommunicationProtocol <NSObject>

/**
 获取 EQInitInformation 对象
 */
-(EQInitInformation*) getEQInitInformation;

/**
 设置某个eq的open
 */
-(void) setOpen:(int)open forEqualizer:(int)equalizer;

/**
 设置某个eq的filterType
 */
-(void) setFilterType:(int)type forEqualizer:(int)equalizer;

/**
 设置某个eq的gain
 */
-(void) setGain:(float)gain forEqualizer:(int)equalizer;

/**
 设置某个eq的fc
 */
-(void) setFC:(float)fc forEqualizer:(int)equalizer;

/**
 设置某个eq的qValue
 */
-(void) setQValue:(float)lllvalue forEqualizer:(int)equalizer;


@end





#endif /* EQCommunicationProtocol_h */
