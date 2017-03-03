//
//  TitlesAndContentViews.h
//  MyKomastu2
//
//  Created by gaoyang on 17/2/20.
//  Copyright © 2017年 lsj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitlesAndContentViews : UIView
/** 点击index */
@property (nonatomic, copy)void(^indexBlock)(NSInteger index);
/**r */
@property (nonatomic, assign)NSInteger colorR;
/** g */
@property (nonatomic, assign)NSInteger colorG;
/** b */
@property (nonatomic, assign)NSInteger colorB;
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray*)titles views:(NSArray*)views titleColor:(UIColor*)titleColor lineColor:(UIColor*)lineColor;
@end
