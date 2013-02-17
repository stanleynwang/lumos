//
//  HABulb.h
//  Octyrion
//
//  Created by Stanley Wang on 2/17/13.
//  Copyright (c) 2013 Wilson Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HABulb : NSObject
    @property (nonatomic, copy) NSString *name;
    @property (nonatomic, assign) CGFloat brightness;
    @property (nonatomic, copy) UIColor *color;

    +(HABulb *) new;
@end
