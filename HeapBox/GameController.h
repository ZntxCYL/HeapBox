//
//  ViewController.h
//  HeapBox
//
//  Created by 陈彦龙 on 15/2/4.
//  Copyright (c) 2015年 陈彦龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewControllerEx.h"

@interface GameController : UIViewControllerEx

- (void) initialize;

- (void) createLawn;
- (UIImageView *) createBox;
- (UIImageView *) createAutoSizeBox;
- (void) createLifeLabel;
- (void) createEgg;
- (void) refreshLife;
- (void) setWithEgg1:(BOOL)one andEgg2:(BOOL)two andEgg3:(BOOL)three;
- (void) createScoreLabel;
- (void) refreshScore;
- (int) calcOffset: (UIImageView *) box;
- (void) calcScore;
- (NSString *) getperformanceTip;
- (void) removeAllView;
- (void) exitApp;

- (void) runCollisionFeedback: (UIImageView *) box;

- (void) setAnimation;
- (void) downBox;
- (void) downAnimation: (UIImageView *) box right: (BOOL) right;
- (void) setAngle: (UIImageView *) box;
- (void) allDownAnimation: (BOOL) right;
- (void) refreshAnimation;
- (void) stopAnimation;
- (void) addScope;
- (void) setPath: (float) offset;
- (void) restoreStateAnimation: (UIImageView *) box;
- (void) addElasticAnimation: (UIImageView *) box;
- (void) createJellyAnimation;
- (void) runCollisionAnimation: (UIImageView *) box;
- (void) scoreTip: (UIImageView *) box;
- (void) performanceTip;

@end