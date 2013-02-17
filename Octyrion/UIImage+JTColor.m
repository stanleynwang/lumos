//
//  UIImage+JTColor.m
//  Octyrion
//
//  Created by Stanley Wang on 2/17/13.
//  Copyright (c) 2013 Wilson Lee. All rights reserved.
//

#import "UIImage+JTColor.h"

@implementation UIImage (JTColor)

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
