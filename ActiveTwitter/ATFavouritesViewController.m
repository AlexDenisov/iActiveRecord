//
//  ATFavouritesViewController.m
//  ActiveTwitter
//
//  Created by Alex Denisov on 25.05.13.
//  Copyright (c) 2013 okolodev.org. All rights reserved.
//

#import "ATFavouritesViewController.h"

@interface ATFavouritesViewController ()

@end

@implementation ATFavouritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
