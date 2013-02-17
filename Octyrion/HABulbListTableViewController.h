//
//  HABulbListTableViewController.h
//  Octyrion
//
//  Created by Stanley Wang on 2/17/13.
//  Copyright (c) 2013 Wilson Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HABulb.h"
#import "HABulbControlViewController.h"

@interface HABulbListTableViewController : UITableViewController<HABulbControlViewControllerDelegate>
    @property (strong, nonatomic) NSMutableArray *bulbs;
@property (strong, nonatomic) UITableViewCell *firstCell;
@property (strong, nonatomic) UITableView *cell;
@end
