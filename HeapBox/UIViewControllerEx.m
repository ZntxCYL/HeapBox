//
//  UIViewControllerEx.m
//  HeapBox
//
//  Created by 陈彦龙 on 15/2/14.
//  Copyright (c) 2015年 陈彦龙. All rights reserved.
//

#import "UIViewControllerEx.h"

@implementation UIViewControllerEx

// 获取屏幕大小
- (CGSize) getScreenSize {
    CGRect rect = [[UIScreen mainScreen] bounds];
    return rect.size;
}

// 设置背景图片
- (void) setBackgroundImage: (UIImage *) image {
    image = [self resizeImage:image toSize:[self getScreenSize]];
    [self.view setBackgroundColor: [UIColor colorWithPatternImage: image]];
}

// 重设图片大小
- (UIImage *) resizeImage: (UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizeImage;
}

// 设置背景透明
- (void) setBackgroundTransparent: (UIView *) view {
    [view setBackgroundColor: [UIColor clearColor]];
}

@end