//
//  LYRevolveView.h
//  AudioControl
//
//  Created by iOS程序员 on 16/10/25.
//  Copyright © 2016年 leye. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LYRevolveView;
@protocol LYRevolveViewDelegate <NSObject>

-(void)revolveView:(LYRevolveView *)view offsetValue:(int) y;
@end

@interface LYRevolveView : UIImageView

@property (nonatomic,weak) id<LYRevolveViewDelegate> revolveDelegate;

@property (nonatomic,copy) NSString *StartNumble;

@end
