//
// Created by Alex Denisov on 25.05.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ATTweetTableViewCell.h"
#import "Tweet.h"

@implementation ATTweetTableViewCell {
@private
    Tweet *_tweet;
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    self.textLabel.text = _tweet.text;
}

@end