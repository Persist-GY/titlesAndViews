//
//  TitlesAndContentViews.m
//  MyKomastu2
//
//  Created by gaoyang on 17/2/20.
//  Copyright © 2017年 lsj. All rights reserved.
//

#import "TitlesAndContentViews.h"
#import "QSSuperView.h"
#define kSelfW self.bounds.size.width
#define kSelfH self.bounds.size.height

@interface TitlesAndContentViews ()<UIScrollViewDelegate>
@property(nonatomic, strong)NSArray *viewsArr;
/** titles */
@property (nonatomic, strong)NSArray *titlesArr;
/** 蓝色细线 */
@property (nonatomic, strong)UIView *blueLine;
/** scrollView */
@property (nonatomic, strong)UIScrollView *scrollView;
/** 纪录下拉刷新view 确保只是第一次刷新数据,而后,手动下拉刷新 */
@property (nonatomic, strong)NSMutableArray *recordViewArr;
/** titleColor */
@property (nonatomic, strong)UIColor *titleColor;
/** lineColor */
@property (nonatomic, strong)UIColor *lineColor;
@end

@implementation TitlesAndContentViews
{
    CGFloat _xxxx;//记录scrollView的contentOffSetX
    int titlesss;//记录点击titles就不让scrollView协议执行
    UBLabel* _selectLb;//记录点击label
}
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray*)titles views:(NSArray*)views titleColor:(UIColor *)titleColor lineColor:(UIColor *)lineColor{
    if (self = [super initWithFrame:frame]) {
        self.colorR = 11;
        self.colorG = 49;
        self.colorB = 143;
//        self.colorR = 255;
//        self.colorG = 0;
//        self.colorB = 0;
        self.viewsArr = [NSArray arrayWithArray:views];
        self.titlesArr = [NSArray arrayWithArray:titles];
        self.recordViewArr = [NSMutableArray array];
        self.titleColor = titleColor;
        self.lineColor = lineColor;
        [self initView];
    }
    return self;
}
- (void)initView{
    //细线1
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSelfW, 1)];
    view1.backgroundColor = [UIColor colorWithRed:(203)/255.0 green:(206)/255.0 blue:(214)/255.0 alpha:1.0];
    [self addSubview:view1];
    
    //文字标题
    CGFloat titleW = kSelfW/self.titlesArr.count;
    for (int i=0; i<self.titlesArr.count; i++) {
        UBLabel *lb = [[UBLabel alloc]initWithFrame:CGRectMake(i*titleW, 1, titleW, 28)];
        lb.text = self.titlesArr[i];
        lb.font = [UIFont systemFontOfSize:15];
        lb.textAlignment = NSTextAlignmentCenter;
        lb.tag = 100+i;
        lb.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [lb addGestureRecognizer:tap];
        [self addSubview:lb];
        if (i==0) {
            _selectLb = lb;
            lb.textColor = self.titleColor;
        }
    }
    
    //细线2
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0,34, kSelfW, 1)];
    view2.backgroundColor = [UIColor colorWithRed:(203)/255.0 green:(206)/255.0 blue:(214)/255.0 alpha:1.0];
    [self addSubview:view2];
    
    //蓝色细线
    self.blueLine = [[UIView alloc]initWithFrame:CGRectMake((titleW-[self getTitleWidth:self.titlesArr[0]])/2, 33, [self getTitleWidth:self.titlesArr[0]], 2)];
    self.blueLine.backgroundColor = self.lineColor;
    [self addSubview:self.blueLine];
    
    //内容views
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 35, kSelfW, kSelfH-35)];
    self.scrollView.contentSize = CGSizeMake(kSelfW*self.viewsArr.count, kSelfH-35);
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    for (int i=0; i<self.viewsArr.count; i++) {
        QSSuperView *view = self.viewsArr[i];
        if (i==0) {
            [view.tableView.mj_header beginRefreshing];
            [self.recordViewArr addObject:@"0"];
        }
        view.frame = CGRectMake(i*kSelfW, 0, kSelfW, kSelfH-35);
        [self.scrollView addSubview:view];
    }
    [self addSubview:self.scrollView];
//    titlesss = 1;
    _xxxx = 0;
}
- (void)tapAction:(UITapGestureRecognizer *)tap{
    if (_selectLb == tap.view) {
        return;
    }
    _selectLb.textColor = [UIColor blackColor];
    
    _selectLb = (UBLabel*)tap.view;
    _selectLb.textColor = self.titleColor;
    titlesss = 1;
    NSInteger viewTag = tap.view.tag-100;
    [self move:viewTag];
}
#pragma mark ------------------ titles views 联动
- (void)move:(NSInteger)tag{
    CGFloat titleW = kSelfW/self.titlesArr.count;
    //移动蓝线
    [UIView animateWithDuration:0.3 animations:^{
        self.blueLine.frame = CGRectMake(titleW*(tag)+(titleW-[self getTitleWidth:self.titlesArr[(tag)]])/2, 33, [self getTitleWidth:self.titlesArr[(tag)]], 2);
    } completion:^(BOOL finished) {
        
    }];
    
    //移动view
    self.scrollView.contentOffset=CGPointMake(kSelfW*tag, 0);
    
    NSString *tagStr = [NSString stringWithFormat:@"%lu",tag];
    if (![self.recordViewArr containsObject:tagStr]) {
        [self.recordViewArr addObject:tagStr];
        QSSuperView *view = self.viewsArr[tag];
        [view.tableView.mj_header beginRefreshing];
        
    }
    if (self.indexBlock) {
        self.indexBlock(tag);
    }

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (titlesss == 1) {
        titlesss = 2;
        return;
    }
    
    CGFloat tag = scrollView.contentOffset.x/kSelfW;
    __block NSInteger tagI = (floor(tag));//不小于tag的整数
//    NSLog(@"%f    %lu",tag,tagI);
    CGFloat titleW = kSelfW/self.titlesArr.count;//每个标题的宽度
   __block CGFloat countt;
    //移动蓝线
    [UIView animateWithDuration:0.3 animations:^{
        if (scrollView.contentOffset.x>_xxxx) {
            if (tagI == self.viewsArr.count-1) {
                 self.blueLine.frame = CGRectMake(titleW*(tag)+(titleW-[self getTitleWidth:self.titlesArr[(tagI)]])/2, 33, [self getTitleWidth:self.titlesArr[(tagI)]], 2);
//                11  49  143
                
                
            }else{
               self.blueLine.frame = CGRectMake(titleW*(tag)+(titleW-[self getTitleWidth:self.titlesArr[(tagI)]])/2, 33, ([self getTitleWidth:self.titlesArr[(tagI+1)]]-[self getTitleWidth:self.titlesArr[(tagI)]])*(tag-tagI)+[self getTitleWidth:self.titlesArr[(tagI)]], 2);
                
                countt = tag - tagI;
                if (countt == 0) {
                    countt = 1;
                }
                UBLabel *lb2 = (UBLabel*)[self viewWithTag:100+tagI];
                lb2.textColor = [UIColor colorWithRed:self.colorR*(1-countt)/255.f green:self.colorG*(1-countt)/255.f blue:self.colorB*(1-countt)/255.f alpha:1];
                if (tag == tagI) {
                    tagI = tagI - 1;
                }
                UBLabel *lb = (UBLabel*)[self viewWithTag:100+tagI+1];
                lb.textColor = [UIColor colorWithRed:self.colorR*(countt)/255.f green:self.colorG*(countt)/255.f blue:self.colorB*(countt)/255.f alpha:1];
//                NSLog(@"#########%f   %lu",tag,tagI);
                
            }
           
        }else{
               self.blueLine.frame = CGRectMake(titleW*(tag)+(titleW-[self getTitleWidth:self.titlesArr[(tagI)]])/2, 33, ([self getTitleWidth:self.titlesArr[(tagI)]]-[self getTitleWidth:self.titlesArr[(tagI+1)]])*(1+tagI-tag)+[self getTitleWidth:self.titlesArr[(tagI+1)]], 2);
            
                countt = tag - tagI;
            
                UBLabel *lb2 = (UBLabel*)[self viewWithTag:100+tagI+1];
                lb2.textColor = [UIColor colorWithRed:self.colorR*(countt)/255.f green:self.colorG*(countt)/255.f blue:self.colorB*(countt)/255.f alpha:1];
                UBLabel *lb = (UBLabel*)[self viewWithTag:100+tagI];
                lb.textColor = [UIColor colorWithRed:self.colorR*(1-countt)/255.f green:self.colorG*(1-countt)/255.f blue:self.colorB*(1-countt)/255.f alpha:1];
//                NSLog(@"%f   %lu",tag,tagI);
            
        }
        
    } completion:^(BOOL finished) {
        
    }];
    _xxxx = scrollView.contentOffset.x;
    
    
    
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat tag = scrollView.contentOffset.x/kSelfW;
    __block NSInteger tagI = (floor(tag));
    UBLabel *lb = (UBLabel*)[self viewWithTag:100+tagI];
    if (_selectLb != lb) {
        _selectLb.textColor = [UIColor blackColor];
        _selectLb = lb;
        _selectLb.textColor = self.titleColor;
        if (self.indexBlock) {
            self.indexBlock(tagI);
        }
        NSString *tagStr = [NSString stringWithFormat:@"%lu",tagI];
        if (![self.recordViewArr containsObject:tagStr]) {
            [self.recordViewArr addObject:tagStr];
            QSSuperView *view = self.viewsArr[tagI];
            [view.tableView.mj_header beginRefreshing];
            
        }
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
}
//根据字数多少 获取title的宽度 从而算的线的宽度
- (CGFloat)getTitleWidth:(NSString *)text{
    CGFloat titleWidth=[text boundingRectWithSize:CGSizeMake(FLT_MAX, 33) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size.width;
    return titleWidth;
}
@end
