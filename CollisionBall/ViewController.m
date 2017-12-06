//
//  ViewController.m
//  CollisionBall
//
//  Created by tpeng on 2017/11/30.
//  Copyright © 2017年 tpeng. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <YYKit.h>


#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()<UICollisionBehaviorDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray *balls;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UIDynamicItemBehavior *dynamic;
@property (nonatomic) CMMotionManager *motionManager;

@property (nonatomic, strong) UIView *nView;
@property (nonatomic, strong) UIView *oView;

@property (nonatomic, strong) UIButton *arrow;
@property(assign,nonatomic) BOOL isExpended;

@property (nonatomic, strong) UIButton *popView;
@property (nonatomic, strong) UIButton *touchBall;
@property (nonatomic, strong) UIButton *showBall;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _nView = [[UIView alloc] initWithFrame:CGRectMake(0,-(kScreenHeight-400), SCREEN_WIDTH, kScreenHeight)];
    _nView.backgroundColor = [UIColor lightGrayColor];
    _nView.layer.masksToBounds = YES;
    [self.view addSubview:self.nView];
    
    [self makeBalls];
    [self addAnimator];
    [self startAnim];
    
    UIButton *arrow = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2, 360, 30, 30)];
    [arrow setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [arrow addTarget:self action:@selector(changeBackViewSize) forControlEvents:UIControlEventTouchUpInside];
    _arrow = arrow;
    [self.view addSubview:arrow];
}

- (void)changeBackViewSize{
    
    [UIView animateWithDuration:1.0f animations:^{
        if (!self.isExpended) {

            _nView.transform = CGAffineTransformMakeTranslation(0, kScreenHeight-400);
            _arrow.transform = CGAffineTransformMakeTranslation(0, kScreenHeight - 400);
            
            
          
        }else{
            _nView.transform = CGAffineTransformIdentity;
            _arrow.transform = CGAffineTransformIdentity;
            
        }
        
        self.isExpended = !self.isExpended;

    } completion:^(BOOL finished) {
        
        
    }];
    
    
    
}


- (void)makeBalls {
    self.balls = [NSMutableArray array];
    
    NSUInteger numOfBalls = 6;
    for (NSUInteger i = 1; i <= numOfBalls; i ++) {
        
        UIButton *ball = [UIButton new];
        [ball setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",i]] forState:UIControlStateNormal];
        CGFloat width  = arc4random() % 30 + 40;;
        ball.layer.cornerRadius = width/2;
        ball.layer.masksToBounds = YES;
        CGRect frame = CGRectMake(arc4random()%((int)(SCREEN_WIDTH - width)), 0, width, width);
        [ball setFrame:frame];
        [self.nView addSubview:ball];
        [self.balls addObject:ball];
        [ball addTarget:self action:@selector(tapBall:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (void)tapBall:(UIButton *)ball{
//    NSLog(@"%@",[_collision boundaryWithIdentifier:@"top"]);
    self.touchBall = ball;
    [self showPopView];
   
}

- (void)showPopView{
    UIButton *popView = [[UIButton alloc]initWithFrame:self.view.bounds];
    popView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
    self.popView = popView;
    [self.view addSubview:popView];
    [self.view bringSubviewToFront:popView];
    [popView addTarget:self action:@selector(hidePopView) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * detailView = [[UIView alloc]initWithFrame:CGRectMake(40, 100, SCREEN_WIDTH-80, kScreenHeight-200)];
    detailView.backgroundColor = [UIColor whiteColor];
    [self.popView addSubview:detailView];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(15, 15, 40, 40)];
    [button setImage:self.touchBall.imageView.image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(changeImage) forControlEvents:UIControlEventTouchUpInside];
    [detailView addSubview:button];
    self.showBall = button;
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 60, SCREEN_WIDTH - 80 - 30, 100)];
    label.text = @"这是公司介绍。";
    [detailView addSubview:label];
    
    
    _popView.alpha = 0;
    _popView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.55 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _popView.transform = CGAffineTransformIdentity;
        _popView.alpha = 1;
    } completion:nil];
    
}

- (void)hidePopView{
    self.popView.hidden = YES;
    self.popView = nil;
    [self.popView removeFromSuperview];
    self.touchBall = nil;
    self.showBall = nil;
}

- (void)changeImage{
    UIActionSheet *sheet;
        // 判断是否支持相机
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        sheet  = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"更改图标",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"照相", nil),NSLocalizedString(@"相册", @"相册"), nil];
    }
    [sheet showInView:self.view];
    
}



#pragma mark - actionsheet delegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSUInteger sourceType = 0;
        // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (buttonIndex) {
            case 0:
                    // 相机
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            case 1:
                    // 相册
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                break;
            case 2:
                return;
        }
    }else {
        if (buttonIndex == 0) {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        } else {
            return;
        }
    }
        // 跳转到相机或相册页面
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = sourceType;
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - image picker delegte
    // 选择好照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.touchBall setImage:image forState:UIControlStateNormal];
    [self.showBall  setImage:image forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addAnimator {
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.nView];
    
    self.gravity = [[UIGravityBehavior alloc] initWithItems:self.balls];
    [self.animator addBehavior:self.gravity];
    
    self.collision = [[UICollisionBehavior alloc] initWithItems:self.balls];
    
    
    //bottom
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, _nView.height)];
    [path addQuadCurveToPoint:CGPointMake(SCREEN_WIDTH, _nView.height) controlPoint:CGPointMake(SCREEN_WIDTH/2, _nView.height-100)];
    [self.collision addBoundaryWithIdentifier:@"bottom" forPath:path];
    
    [self.collision addBoundaryWithIdentifier:@"left" fromPoint:CGPointMake(0, kScreenHeight) toPoint:CGPointMake(0, 0)];
    
    [self.collision addBoundaryWithIdentifier:@"top" fromPoint:CGPointMake(0,0) toPoint:CGPointMake(SCREEN_WIDTH, 0)];

    [self.collision addBoundaryWithIdentifier:@"right" fromPoint:CGPointMake(SCREEN_WIDTH,0) toPoint:CGPointMake(SCREEN_WIDTH, kScreenHeight)];
    
    self.collision.translatesReferenceBoundsIntoBoundary = YES;
    
    [self.animator addBehavior:self.collision];
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = path.CGPath;
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.fillColor = [UIColor whiteColor].CGColor;
    [self.nView.layer addSublayer:layer];
    
    self.dynamic = [[UIDynamicItemBehavior alloc] initWithItems:self.balls];
    self.dynamic.allowsRotation = YES;
    self.dynamic.elasticity = 0.6;
    [self.animator addBehavior:self.dynamic];
}

- (void)startAnim {
    self.motionManager = [[CMMotionManager alloc]init];
    self.motionManager.deviceMotionUpdateInterval = 0.01;
    
    __weak ViewController *weakSelf = self;
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:
     ^(CMDeviceMotion *_Nullable motion,NSError * _Nullable error) {
        double rotation = atan2(motion.attitude.pitch, motion.attitude.roll);
        weakSelf.gravity.angle = rotation;
        
    }];
    
}

- (void)dealloc {
    [self.motionManager stopDeviceMotionUpdates];
}
@end
