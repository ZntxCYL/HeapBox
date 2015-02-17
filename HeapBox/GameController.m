//
//  ViewController.m
//  HeapBox
//
//  Created by 陈彦龙 on 15/2/4.
//  Copyright (c) 2015年 陈彦龙. All rights reserved.
//

#import "GameController.h"
#import "Score.h"

// 接口声明属性
@interface GameController() {
    int currentLife;
    int currentScore;
    enum Score preScore;
    int boxSize;
    int boxCount;
    float currentAngle;
    int currentOffset;
    UIImageView *lawn;
    UIImageView *imageViewBox;
    CAKeyframeAnimation *swingAnimation;
    CAKeyframeAnimation *jellyAnimation;
    CALayer *layer;
    NSMutableArray *boxes;
    UIImageView *currentBox;
    UIImageView *preBox;
    UIDynamicAnimator *animator;
    UIGravityBehavior *gravity;
    UICollisionBehavior *collision;
    UILabel *lifeLable;
    UILabel *scoreLabel;
    UILabel *scoreShowLabel;
    UIImageView *egg1;
    UIImageView *egg2;
    UIImageView *egg3;
}

@end

@implementation GameController

#define MAX_LIFE 3
#define MAX_HEAP_COUNT 3
#define MAX_ANGLE 0.16

#pragma mark - 构造初始化

// 视图加载
- (void) viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    [self initialize];
    [self setAnimation];
    [self createJellyAnimation];
}

// 初始化
- (void) initialize {
    [self setBackgroundImage: [UIImage imageNamed:@"sky"]];
    [self createEgg];
    
    lifeLable = 0;
    scoreLabel = 0;
    [self createLifeLabel];
    [self createScoreLabel];
    [self createScoreShowLabel];
    
    swingAnimation = [CAKeyframeAnimation animationWithKeyPath: @"position"];
    
    currentLife = MAX_LIFE;
    currentScore = 0;
    preScore = 0;
    currentAngle = 0;
    boxCount = 0;
    preBox = NULL;
    
    boxSize = [self getScreenSize].width / 5;
    boxes = [[NSMutableArray alloc] init];

    [self createLawn];
    
    animator = [[UIDynamicAnimator alloc] initWithReferenceView: self.view];
    gravity = [[UIGravityBehavior alloc] init];
    gravity.magnitude = 1;
    collision = [[UICollisionBehavior alloc] init];
}

#pragma mark - 事件

// 触摸开始事件
- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
    if (imageViewBox.alpha == 0)
        return;
    [collision removeAllBoundaries];
    [animator removeAllBehaviors];
    [self stopAnimation];
    layer = imageViewBox.layer.presentationLayer;
    [self downBox];
}

// 摇摆动画开始事件
- (void) animationDidStart: (CAAnimation *) anim {
    [UIView animateWithDuration:1 animations:^{
        imageViewBox.alpha = 1;
    }];
}

// 摇摆动画结束事件
- (void) animationDidStop: (CAAnimation *) anim finished: (BOOL) flag {
    imageViewBox.alpha = 0;
}

// 提示框按钮点击事件
- (void)alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self exitApp];
            break;
        case 1:
            [self removeAllView];
            [self.view.layer removeAllAnimations];
            [self initialize];
            [self setAnimation];
            break;
    }
}

#pragma mark - 方法

// 创建草地
- (void) createLawn {
    UIImage *image = [UIImage imageNamed:@"lawn"];
    CGSize size = [self getScreenSize];
    image = [self resizeImage:image toSize: size];
    lawn = [[UIImageView alloc] initWithImage: image];
    float height = size.height / 4;
    lawn.layer.bounds = CGRectMake(0, 0, size.width, height);
    lawn.center = CGPointMake(size.width / 2, size.height - height/2);
    [self.view addSubview: lawn];
    [boxes addObject: lawn];
}

// 创建方块
- (UIImageView *) createBox {
    UIImageView *box = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"chicken"]];
    // 设置位置使其不可见
    box.layer.position = CGPointMake(-100, -100);
    box.layer.bounds = CGRectMake(0, 0, boxSize, boxSize);
    return box;
}

// 创建自适应大小的下降方块
- (UIImageView *) createAutoSizeBox {
    currentBox = [self createBox];
    currentBox.layer.position = layer.position;
    currentBox.layer.transform = layer.transform;
    currentBox.layer.bounds = layer.bounds;
    [self.view addSubview: currentBox];
    [boxes addObject: currentBox];
    return currentBox;
}

// 创建生命值标签
- (void) createLifeLabel {
    lifeLable = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 100, 20)];
    lifeLable.layer.position = CGPointMake(60, 30);
    [lifeLable setAutoresizesSubviews: YES];
    [lifeLable setText: @"LIFE："];
    [self setBackgroundTransparent: lifeLable];
    [self.view addSubview: lifeLable];
}

// 创建生命蛋
- (void) createEgg {
    UIImage *image = [UIImage imageNamed: @"egg"];
    egg1 = [[UIImageView alloc] initWithImage: image];
    egg2 = [[UIImageView alloc] initWithImage: image];
    egg3 = [[UIImageView alloc] initWithImage: image];
    CGRect rect = CGRectMake(0, 0, 30, 38);
    egg1.layer.frame = rect;
    egg2.layer.frame = rect;
    egg3.layer.frame = rect;
    egg1.layer.position = CGPointMake(70, 25);
    egg2.layer.position = CGPointMake(110, 25);
    egg3.layer.position = CGPointMake(150, 25);
    [self.view addSubview: egg1];
    [self.view addSubview: egg2];
    [self.view addSubview: egg3];
}

// 刷新生命
- (void) refreshLife {
    switch (currentLife) {
        case 1:
            [self setWithEgg1:NO andEgg2:YES andEgg3:YES];
            break;
        case 2:
            [self setWithEgg1:NO andEgg2:NO andEgg3:YES];
            break;
        case 3:
            [self setWithEgg1:NO andEgg2:NO andEgg3:NO];
            break;
        default:
            [self setWithEgg1:YES andEgg2:YES andEgg3:YES];
            break;
    }
}

// 设置生命蛋
- (void) setWithEgg1:(BOOL)one andEgg2:(BOOL)two andEgg3:(BOOL)three {
    [egg1 setHidden: one];
    [egg2 setHidden: two];
    [egg3 setHidden: three];
}

// 创建分数标签
- (void) createScoreLabel {
    scoreLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 120, 20)];
    scoreLabel.layer.position = CGPointMake([self getScreenSize].width-70, 30);
    [scoreLabel setAutoresizesSubviews: YES];
    [scoreLabel setText: @"SCORE："];
    [self setBackgroundTransparent: scoreLabel];
    [self.view addSubview: scoreLabel];
}

// 创建分数显示标签
- (void) createScoreShowLabel {
    scoreShowLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 40, 20)];
    [scoreShowLabel.layer setPosition: CGPointMake([self getScreenSize].width-40, 30)];
    [scoreShowLabel setAutoresizesSubviews: YES];
    [scoreShowLabel setTextColor: [UIColor orangeColor]];
    [self setBackgroundTransparent: scoreShowLabel];
    [self.view addSubview: scoreShowLabel];
}

// 刷新分数
- (void) refreshScore {
    [scoreShowLabel setText: [NSString stringWithFormat: @"%d", currentScore]];
}

// 计算偏移值
- (int) calcOffset: (UIImageView *) box {
    // 计算偏移值，第一次使用屏幕x中心点计算，第二次开始使用前一个方块中心进行计算
    int offset = box.center.x - (preBox != NULL ? preBox.center.x : [self getScreenSize].width / 2);
    return offset;
}

// 计算分数
- (void) calcScore {
    int offset = abs(currentOffset);
    if (offset < 2) {
        // 太棒了
        preScore = Great;
    }
    else if (offset < 20) {
        // 不错哦
        preScore = Good;
    }
    else if (offset < boxSize * 0.6) {
        // 歪了哦
        preScore = Crooked;
    }
    else {
        // 掉了哦
        preScore = Out;
    }
    currentScore += preScore;
}

// 获取表现提示内容
- (NSString *) getperformanceTip {
    switch (preScore) {
        case Great:
            return @"太棒了！";
        case Good:
            return @"不错哦！";
        case Crooked:
            return @"歪了哦！";
        case Out:
            return @"掉了哦！";
        default:
            return @"";
    }
}

// 移除所有控件
- (void) removeAllView {
    for (UIImageView *view in boxes) {
        [view removeFromSuperview];
    }
    [imageViewBox removeFromSuperview];
    [lifeLable removeFromSuperview];
    [scoreLabel removeFromSuperview];
    [scoreShowLabel removeFromSuperview];
    [egg1 removeFromSuperview];
    [egg2 removeFromSuperview];
    [egg3 removeFromSuperview];
}

// 退出游戏
- (void) exitApp {
    CGSize size = [self getScreenSize];
    [UIView animateWithDuration:0.4 animations:^{
        self.view.alpha = 0;
        CGFloat x = size.width / 2;
        CGFloat y = size.height;
        self.view.frame = CGRectMake(x, y, 0, 0);
    } completion:^(BOOL finished) {
        exit(0);
    }];
}

#pragma mark - 动力仿真（重力 ＋ 碰撞检测）

// 运行碰撞反馈
- (void) runCollisionFeedback: (UIImageView *) box {
    // 添加重力
    [gravity addItem: box];
    // 添加碰撞
    [collision addItem: box];
    // 将前一个方块添加为碰撞边界（撞不动，要不然撞到会移位）
    CALayer *currentLayer = preBox.layer.presentationLayer;
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:currentLayer.frame];
    [collision addBoundaryWithIdentifier: @"preBox" forPath: path];
    
    // 执行动力仿真
    [animator addBehavior: gravity];
    [animator addBehavior: collision];
}

#pragma mark - 动画

// 设置摇摆动画
- (void) setAnimation {
    [swingAnimation setDuration: 1];
    [swingAnimation setRepeatCount: MAXFLOAT];
    [swingAnimation setRotationMode: @"auto"];
    [swingAnimation setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
    [swingAnimation setAutoreverses: YES];
    [swingAnimation setDelegate: self];
    imageViewBox = [self createBox];
    [self.view addSubview: imageViewBox];
    [self addScope];
    [self refreshAnimation];
}

// 降落方块(主要功能处理)
- (void) downBox {
    UIImageView *box = [self createAutoSizeBox];
    // 检查下降位置是否正确
    currentOffset = [self calcOffset: box];
    BOOL right = abs(currentOffset) < boxSize * 0.6;
    
    [self calcScore];
    // 恢复方块旋转状态
    [self restoreStateAnimation: box];
    
    if (preBox == NULL || right) {
        // 执行下降
        [self downAnimation:box right:right];
        // 增加摇摆幅度
        [self addScope];
    }
    else {
        // 如果iOS版本小于7.0则直接下降，否则使用动力下降并碰撞
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
            // 直接下降
            [self downAnimation:box right:right];
        }
        else {
            // 下降位置错误，执行碰撞反馈
            [self runCollisionFeedback: box];
        }
        --currentLife;
        // 延时执行
        [self performSelector: @selector(performanceTip) withObject: NULL afterDelay: 0.5];
    }
    
    // 第一次降落 或者 降落正确则增加堆积数量 并将当前方块赋值到前一个方块
    if (preBox == NULL || right) {
        ++boxCount;
        preBox = box;
    }
}

- (void) downAnimation: (UIImageView *) box right: (BOOL) right {
    // 第一次降落到鸡窝上 第二次开始降落到前一个方块的上方一半像素 否则直接掉落到不见
    float y = preBox == NULL ? lawn.center.y * 0.85 :
                        right ? preBox.layer.position.y - (boxSize / 2) :
                        [self getScreenSize].height + 100;
    
    // 下降位置
    [UIView animateWithDuration:right ? 0.5 : 1 delay:0 options: UIViewAnimationOptionCurveLinear animations:^{
        box.layer.position = CGPointMake(box.layer.position.x, y);
    } completion:^(BOOL finished) {
        // 如果降落错误则不执行下面的代码
        if (!right) return;

        // 碰撞动画
        [self runCollisionAnimation: box];
        // 偏移角度
        [self setAngle: box];
        // 全体下降
        [self allDownAnimation: right];
    }];
}

// 设置下降碰撞偏移角度
- (void) setAngle: (UIImageView *) box {
    [UIView animateWithDuration:0.2 animations:^{
        box.layer.transform = CATransform3DMakeRotation(currentOffset * M_PI / 180, 0, 0, 1);
    }];
}

// 全体下降动画
- (void) allDownAnimation: (BOOL) right {
    if (boxCount > MAX_HEAP_COUNT && right) {
        // 堆积全体方块下降
        [UIView animateWithDuration:0.2 animations:^{
            for (UIImageView *view in boxes) {
                view.layer.position = CGPointMake(view.layer.position.x, view.layer.position.y + (boxSize / 2));
            }
        }];
    }
}

// 刷新动画，重新开始摇摆动画
- (void) refreshAnimation {
    [self refreshLife];
    [self refreshScore];
    
    if (currentLife != 0) {
        [imageViewBox.layer addAnimation: swingAnimation forKey: @"animation"];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"游戏结束" message:[NSString stringWithFormat: @"\n您当前的得分为：%d", currentScore] delegate:self cancelButtonTitle:@"退出游戏" otherButtonTitles: @"重新开始", NULL];
        [alert setDelegate: self];
        [alert show];
    }
}

// 停止摇摆动画
- (void) stopAnimation {
    [imageViewBox.layer removeAnimationForKey: @"animation"];
    [self performSelector: @selector(refreshAnimation) withObject: NULL afterDelay: 1];
}

// 添加摇摆幅度
- (void) addScope {
    if (currentAngle < MAX_ANGLE) {
        [self setPath: currentAngle += 0.01];
    }
    else {
        [swingAnimation setSpeed: swingAnimation.speed + 0.1];
    }
}

// 设置摇摆动画运动路线
- (void) setPath: (float) offset {
    float mid = 1.5;
    float startAngle = (mid - offset) * M_PI;
    float stopAngle = (mid + offset) * M_PI;
    
    CGSize size = [self getScreenSize];
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, width / 2, height / 2 + boxSize * 1.5, height / 2, startAngle, stopAngle, NO);
    
    [swingAnimation setPath: path];
    CGPathRelease(path);
}

// 恢复方块状态动画
- (void) restoreStateAnimation: (UIImageView *) box {
    [UIView animateWithDuration:1 delay:0 //usingSpringWithDamping:0.3 initialSpringVelocity:0
                        options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                            box.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
                        } completion:NULL];
}

// 弹性动画
- (void) addElasticAnimation: (UIImageView *) box {
    [UIView animateWithDuration:1 delay:0 //usingSpringWithDamping:0.3 initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveLinear animations:^{
                            box.transform = CGAffineTransformMakeTranslation(0, 10);
                        } completion: NULL];
}

// 果冻Q动画
- (void) createJellyAnimation {
    jellyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    NSMutableArray *values = [NSMutableArray array];
    [values addObject: [NSNumber numberWithFloat: 1.0]];
    [values addObject: [NSNumber numberWithFloat: 0.9]];
    [values addObject: [NSNumber numberWithFloat: 1.0]];
    [jellyAnimation setValues: values];
    [jellyAnimation setDuration: 0.3];
    [jellyAnimation setRemovedOnCompletion: YES];
    [jellyAnimation setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
}

// 运行碰撞动画
- (void) runCollisionAnimation: (UIImageView *) box {
    // 弹性动画
    [self addElasticAnimation: box];
    // 果冻动画
    [box.layer addAnimation: jellyAnimation forKey: @"jellyAnimation"];
    // 得分提示
    [self scoreTip: box];
    // 表现提示
    [self performanceTip];
}

// 得分提示
- (void) scoreTip: (UIImageView *) box {
    UILabel *tip = [[UILabel alloc] init];
    tip.frame = box.frame;
    tip.center = CGPointMake(box.center.x, box.center.y - boxSize/2);
    tip.textAlignment = NSTextAlignmentCenter;
    tip.text = [NSString stringWithFormat: @"+%d", preScore];
    tip.textColor = [UIColor orangeColor];
    tip.alpha = 0.0;
    tip.autoresizesSubviews = YES;
    [self setBackgroundTransparent: tip];
    [self.view addSubview: tip];
    [UIView animateWithDuration:2 animations:^{
        tip.center = CGPointMake(tip.center.x, tip.center.y - boxSize);
    }];
    [UIView animateWithDuration:1 animations:^{
        tip.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            tip.alpha = 0.0;
        } completion:^(BOOL finished) {
            [tip removeFromSuperview];
        }];
    }];
}

// 表现提示
- (void) performanceTip {
    UILabel *tip = [[UILabel alloc] init];
    tip.frame = CGRectMake(0, 0, 100, 30);
    CGSize size = [self getScreenSize];
    tip.center = CGPointMake(size.width * 0.9, size.height * 0.9);
    tip.text = [self getperformanceTip];
    tip.autoresizesSubviews = YES;
    [self setBackgroundTransparent: tip];
    [self.view addSubview: tip];
    [UIView animateWithDuration:1 animations:^{
        tip.center = CGPointMake(tip.center.x, tip.center.y - boxSize);
        tip.transform = CGAffineTransformMakeScale(2, 2);
    } completion:^(BOOL finished) {
        [tip removeFromSuperview];
    }];
}

@end