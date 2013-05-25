//
//  ATSearchViewController.m
//  ActiveTwitter
//
//  Created by Alex Denisov on 25.05.13.
//  Copyright (c) 2013 okolodev.org. All rights reserved.
//

#import "ATSearchViewController.h"
#import "ATTweetTableViewCell.h"
#import "ATSearchManager.h"
#import "Tweet.h"

@implementation ATSearchViewController
{
    NSMutableArray *_tweets;
    ATSearchManager *_searchManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchManager = [ATSearchManager new];
    _tweets = [NSMutableArray arrayWithArray:[Tweet allRecords]];
    [self.tableView reloadData];
    NSLog(@"%@", _tweets);
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (!searchBar.text.length) {
        return;
    }
    [self loadingStarted];
    __weak ATSearchViewController *weakSelf = self;
    [_searchManager searchForKeyword:searchBar.text
                         withSuccess:^(NSArray *tweets) {
                             _tweets = [NSMutableArray arrayWithArray:tweets];
                             [weakSelf.tableView reloadData];
                             [weakSelf loadingFinished];
                         } failure:^(NSError *error) {
        _tweets = nil;
        [weakSelf.tableView reloadData];
        [weakSelf loadingFinished];
    }];
}

#pragma mark - UITableView data source & delegate

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kTweetCell = @"kTweetCell";
    ATTweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTweetCell];
    if (cell == nil) {
        cell = [[ATTweetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kTweetCell];
    }
    cell.tweet = _tweets[(NSUInteger) indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tweets.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = (NSUInteger) indexPath.row;
    Tweet *tweet = _tweets[index];
    BOOL rc = [tweet save];
    if (rc) {

        [self.tableView beginUpdates];

        [_tweets removeObjectAtIndex:index];

        [self.tableView deleteRowsAtIndexPaths:@[
                [NSIndexPath indexPathForRow:index inSection:0]
        ] withRowAnimation:UITableViewRowAnimationMiddle];

        [self.tableView endUpdates];
    }
}

#pragma mark - Loading management

- (void)loadingStarted {
    [self.view endEditing:YES];
}

- (void)loadingFinished {

}

@end
