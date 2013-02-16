//
//  HAAppDelegate.h
//  Octyrion
//
//  Created by Wilson Lee on 2/16/13.
//  Copyright (c) 2013 Wilson Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HAAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
