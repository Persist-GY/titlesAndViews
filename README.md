# -
gaoyang
TitlesAndContentViews *view = [[TitlesAndContentViews alloc]initWithFrame:CGRectMake(0, 50, SWIDTH, SHEIGHT-50-64) titles:titles views:views titleColor:MAINBLUE lineColor:MAINBLUE];
    view.indexBlock = ^(NSInteger index){
//      NSLog(@"%lu",index);
        if (index == 2) {
            self.rightBtn.hidden = NO;
        }else{
            self.rightBtn.hidden = YES;
        }
    };

