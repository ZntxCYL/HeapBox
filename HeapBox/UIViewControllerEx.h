//
//  UIViewControllerEx.h
//  HeapBox
//
//  Created by 陈彦龙 on 15/2/14.
//  Copyright (c) 2015年 陈彦龙. All rights reserved.
//

#ifndef HeapBox_UIViewControllerEx_h
#define HeapBox_UIViewControllerEx_h

#import <UIKit/UIKit.h>

@interface UIViewControllerEx : UIViewController

- (CGSize) getScreenSize;
- (void) setBackgroundImage: (UIImage *) image;
- (UIImage *) resizeImage: (UIImage *)image toSize:(CGSize)size;
- (void) setBackgroundTransparent: (UIView *) view;

@end

#endif