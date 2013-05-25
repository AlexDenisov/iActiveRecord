//
//  ATAppDelegate.m
//  ActiveTwitter
//
//  Created by Alex Denisov on 25.05.13.
//  Copyright (c) 2013 okolodev.org. All rights reserved.
//

#import "ATAppDelegate.h"
#import "ActiveRecord.h"
#import "ARConfiguration.h"

@implementation ATAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ActiveRecord applyConfiguration:^(ARConfiguration *config) {
        config.databasePath = ARDocumentsDatabasePath(@"ActiveTweet");
        NSLog(@"%@", config.databasePath);
    }];
    return YES;
}
							
@end
