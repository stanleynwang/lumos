//
//  HADashboardViewController.h
//  Octyrion
//
//  Created by Stanley Wang on 2/17/13.
//  Copyright (c) 2013 Wilson Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HADashboardViewController : UIViewController<CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *SetCurrentLocationButton;
- (IBAction)setCurrentLocation;
@end
