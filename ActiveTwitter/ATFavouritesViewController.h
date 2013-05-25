//
//  ATFavouritesViewController.h
//  ActiveTwitter
//
//  Created by Alex Denisov on 25.05.13.
//  Copyright (c) 2013 okolodev.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATFavouritesViewController : UIViewController
    <UITableViewDelegate,
    UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
