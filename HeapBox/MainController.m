//
//  MainController.m
//  HeapBox
//
//  Created by 陈彦龙 on 15/2/16.
//  Copyright (c) 2015年 陈彦龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainController.h"
#import "GameController.h"

@interface MainController() {
    GameController *game;
}

@end

@implementation MainController

@synthesize startButton;

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setBackgroundImage: [UIImage imageNamed:@"main"]];
    [self setBackgroundTransparent: startButton];
}

- (IBAction) startGame:(UIButton *)sender {
    game = [[GameController alloc] init];
    [self.view.window addSubview: game.view];
    [self.view removeFromSuperview];
}

@end