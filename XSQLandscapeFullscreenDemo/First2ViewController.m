//
//  First2ViewController.m
//  XSQLandscapeFullscreenDemo
//
//  Created by cfans on 2019/4/5.
//  Copyright © 2019 XSQ. All rights reserved.
//

#import "First2ViewController.h"
#import "MovieView.h"

@interface VideoCell : UITableViewCell
@property  MovieView * video;
@end

@implementation VideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    _video = [[MovieView alloc] init];
    [self addSubview:_video];
    _video.frame = self.frame;
    return self;
}
@end



@interface First2ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
    UITableView * tableView;
    NSArray * arr;
    NSIndexPath * index;

}
@property (nonatomic, strong) MovieView *movieView;

@end

@implementation First2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    arr = [[NSArray alloc] initWithObjects:@"movie",@"movie",@"movie",@"movie",@"movie",@"movie",@"movie",@"movie",nil];
    tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:VideoCell.class forCellReuseIdentifier:@"Cell"];
    
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
   
    VideoCell * cell = (VideoCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.video.frame = cell.bounds;
    cell.video.image = [UIImage imageNamed:arr[indexPath.row]];
    cell.backgroundColor = UIColor.redColor;

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arr.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self->index != indexPath) {
        
        if (self->index != nil){
            VideoCell * cell = (VideoCell *) [tableView cellForRowAtIndexPath:self->index];
            cell.video.userInteractionEnabled = false;
        }
        
        self->index = indexPath;
        VideoCell * cell = (VideoCell *) [tableView cellForRowAtIndexPath:indexPath];
        self.movieView = cell.video;
        self.movieView.userInteractionEnabled = true;
        
        [self enterFullscreen];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self.movieView addGestureRecognizer:tapGestureRecognizer];
    }

}


- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.movieView.state == MovieViewStateSmall) {
            [self enterFullscreen];
        }
        else if (self.movieView.state == MovieViewStateFullscreen) {
            [self exitFullscreen];
        }
    }
}

- (void)enterFullscreen {
    
    if (self.movieView.state != MovieViewStateSmall) {
        return;
    }
    
    self.movieView.state = MovieViewStateAnimating;
    
    /*
     * 记录进入全屏前的parentView和frame
     */
    self.movieView.movieViewParentView = self.movieView.superview;
    self.movieView.movieViewFrame = self.movieView.frame;
    
    /*
     * movieView移到window上
     */
    CGRect rectInWindow = [self.movieView convertRect:self.movieView.bounds toView:[UIApplication sharedApplication].keyWindow];
    [self.movieView removeFromSuperview];
    self.movieView.frame = rectInWindow;
    [[UIApplication sharedApplication].keyWindow addSubview:self.movieView];
    
    /*
     * 执行动画
     */
    [UIView animateWithDuration:0.5 animations:^{
        self.movieView.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.movieView.bounds = CGRectMake(0, 0, CGRectGetHeight(self.movieView.superview.bounds), CGRectGetWidth(self.movieView.superview.bounds));
        self.movieView.center = CGPointMake(CGRectGetMidX(self.movieView.superview.bounds), CGRectGetMidY(self.movieView.superview.bounds));
    } completion:^(BOOL finished) {
        self.movieView.state = MovieViewStateFullscreen;
    }];
}

- (void)exitFullscreen {
    
    if (self.movieView.state != MovieViewStateFullscreen) {
        return;
    }
    
    self.movieView.state = MovieViewStateAnimating;
    
    CGRect frame = [self.movieView.movieViewParentView convertRect:self.movieView.movieViewFrame toView:[UIApplication sharedApplication].keyWindow];
    [UIView animateWithDuration:0.5 animations:^{
        self.movieView.transform = CGAffineTransformIdentity;
        self.movieView.frame = frame;
    } completion:^(BOOL finished) {
        /*
         * movieView回到小屏位置
         */
        [self.movieView removeFromSuperview];
        self.movieView.frame = self.movieView.movieViewFrame;
        [self.movieView.movieViewParentView addSubview:self.movieView];
        self.movieView.state = MovieViewStateSmall;
    }];
}
@end


