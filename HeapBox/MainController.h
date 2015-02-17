//
//  MainController.h
//  HeapBox
//
//  Created by 陈彦龙 on 15/2/16.
//  Copyright (c) 2015年 陈彦龙. All rights reserved.
//

#ifndef HeapBox_MainController_h
#define HeapBox_MainController_h

#import <UIKit/UIKit.h>
#import "UIViewControllerEx.h"

@interface MainController : UIViewControllerEx

@property (nonatomic, strong) IBOutlet UIButton *startButton;

- (IBAction) startGame: (UIButton *) sender;

@end

#endif