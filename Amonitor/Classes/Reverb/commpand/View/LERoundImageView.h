//
//  LERoundImageView.h
//  testone
//
//  Created by iOS程序员 on 16/10/17.
//  Copyright © 2016年 leye. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LERoundImageView;
@protocol LERoundImageViewDelegate <NSObject>

-(void)roundImage:(LERoundImageView *)roundaImage;

@end

@interface LERoundImageView : UIImageView

@property (nonatomic,strong)NSArray *array;
@property (nonatomic,strong)void (^cancelBlock)(NSInteger);
@property (nonatomic,weak)  id <LERoundImageViewDelegate>delegate;
@end
