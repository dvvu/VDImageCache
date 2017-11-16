//
//  UIImage+Extension.m
//
//  Created by Vu.Doan on 11/13/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage(RenderFromView)

+ (UIImage *)imageWithView:(UIView *)view {
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
