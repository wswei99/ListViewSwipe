//
//  ViewController.m
//  test
//
//  Created by shengwei on 16/1/28.
//  Copyright © 2016年 shengwei. All rights reserved.
//

#import "ViewController.h"
#define Screen_Width [[UIScreen mainScreen] bounds].size.width
#define Screen_Height [[UIScreen mainScreen] bounds].size.height
/**
 *  问题:5个列表页,左右滑动的效果.点击上面的按钮跳转的相对应的页面,如果是相邻页面,则可以平滑的推出来,如果是相隔页面,要么关闭动画,直接出现,要么是刷刷刷刷通过中间的页面,效果不好.
    需求:要是相隔的页面,也能像相邻页面一样,平缓的推出,效果就好很多..
    解决:思路-->平缓推出下一页的前提是,两个页面相邻-->那相隔页面,如果经过我们调整,也能让它们相邻,问题就迎刃而解了.
    -->假设-->当前页为第一页...点击btn为最后一页,即第五页.点击后,让第一页和第四页交换位置-->把scrollview的视图 无动画 切换到第四页,那这个时候给人的感觉是,屏幕一点儿变化没有-->然后 动画 从第四页推出第五页-->最后,把第一页和第四页的位置重新对调回来...完成整个流程
   2016.2.1 ~不完美之处:快速点击多个btn,会造成没来得及归位,列表页错乱..有时间再想办法解决吧.写的有点儿粗糙.wswei99@126.com..有好想法也联系我吧
 */
@interface ViewController ()<UIScrollViewDelegate>
{
    //记录上次列表页下标(0~5)
    int selectIndex ;
    //点击所在的视图页下标(0~5)
    int num;
}
@property (nonatomic,strong )UIScrollView *scrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    selectIndex = 0;//初始为第一页
    
    //创建5个btn,用以点击切换视图
    for (int i = 0; i< 5; i++) {
        UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
        [btn setTitle:[NSString stringWithFormat:@"%d视图",i+1] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        btn.frame = CGRectMake(Screen_Width/5 *i +5, 20, Screen_Width/5 -5, 30);
        btn.backgroundColor = [UIColor cyanColor];
        btn.tag = 100 + i;
        [btn addTarget: self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    //列表页承载器
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 55, Screen_Width, Screen_Height)];
    scrollView.backgroundColor = [UIColor greenColor];
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    float width= Screen_Width;
    float height= Screen_Height - 55;
    
    NSArray *array = @[@"火影08",@"火影04",@"火影52",@"火影48",@"火影44"];
    for (int i = 0; i < 5; i++) {
        //这里用五个imageView,你可以用UIView,或者UIViewcontroll....不过加载到scrollView的时候,记得要加载的是UIviewController.view哦
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width * i, 0, width, height)];
        imageView.tag = 200 + i;

        imageView.image = [UIImage imageNamed:array[i]];
        [self.scrollView addSubview:imageView];
        self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(imageView.frame), height);
    }
    
}

-(void) btnClick:(UIButton *)btn
{
    
    //第几个视图
     num = (int)btn.tag - 100;
    
    //点击页在当前页右面
    if (num - selectIndex >1) {
        //点击前的视图页
        UIImageView *imageView1 = (UIImageView *)[self.view viewWithTag:selectIndex + 200];
        //点击后即将出现的视图页  的  前一页
        UIImageView *imageView2 = (UIImageView *)[self.view viewWithTag:num -1+200];
        
        //将上两个视图位置替换
        imageView1.frame = CGRectMake(Screen_Width *(num - 1), 0, Screen_Width, Screen_Height-55);
        imageView2.frame = CGRectMake(Screen_Width *selectIndex, 0, Screen_Width, Screen_Height-55);
        //这个时候,即将出现页的前一页,就变成了点击前的视图页,然后直接把scrollView设置成当前位置,动画记得关掉
        [self.scrollView setContentOffset:CGPointMake(Screen_Width *(num -1), 0) animated:NO];
        //接下来,从即将出现的前一页,往后一推,就是点击要出现的view,这个时候需要动画过度.
        [self.scrollView setContentOffset:CGPointMake(Screen_Width * num, 0) animated:YES];

        
    }else if(num - selectIndex < -1){//点击页在当前页左面
        
        UIImageView *imageView1 = (UIImageView *)[self.view viewWithTag:selectIndex + 200];
        UIImageView *imageView2 = (UIImageView *)[self.view viewWithTag:num + 1 + 200];
        imageView1.frame = CGRectMake(Screen_Width *(num + 1), 0, Screen_Width, Screen_Height -55);
        imageView2.frame = CGRectMake(Screen_Width * selectIndex, 0, Screen_Width, Screen_Height - 55);
        [self.scrollView setContentOffset:CGPointMake(Screen_Width * (num + 1), 0) animated:NO];
        [self.scrollView setContentOffset:CGPointMake(Screen_Width * num, 0) animated:YES];
        
    }else if (num - selectIndex == 0){//点击页就是当前页
        
    }else{//点击页与当前页相邻,那就直接推出来
        [self.scrollView setContentOffset:CGPointMake(Screen_Width *num, 0) animated:YES];
        selectIndex = num;
    }
    
}
//手动左右滑减速后调用
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
    selectIndex = page;
}

//点击Btn滑动动画结束后调用
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self endScrolling];
}

- (void)endScrolling
{
    if (num - selectIndex >1) {
        //点击滑动结束后,把之前两个视图的位置再重新调回来,
        UIImageView *imageView1 = (UIImageView *)[self.view viewWithTag:selectIndex + 200];
        UIImageView *imageView2 = (UIImageView *)[self.view viewWithTag:num -1+200];
        imageView2.frame = CGRectMake(Screen_Width *(num - 1), 0, Screen_Width, Screen_Height-55);
        imageView1.frame = CGRectMake(Screen_Width *selectIndex, 0, Screen_Width, Screen_Height-55);
        selectIndex = num;
    }else if (num - selectIndex < -1){
        UIImageView *imageView1 = (UIImageView *)[self.view viewWithTag:selectIndex + 200];
        UIImageView *imageView2 = (UIImageView *)[self.view viewWithTag:num + 1 + 200];
        
        imageView2.frame = CGRectMake(Screen_Width *(num + 1), 0, Screen_Width, Screen_Height -55);
        imageView1.frame = CGRectMake(Screen_Width * selectIndex, 0, Screen_Width, Screen_Height - 55);
        selectIndex = num;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
