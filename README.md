_Note: I'm working on new version, with new features and a bugfixes_

## ActiveRecord without CoreData.
### Only SQLite.
### Only HardCore.

![Build status](https://travis-ci.org/AlexDenisov/iActiveRecord.png)

### This repo [available](https://twitter.com/#!/iactiverecord) on Twitter.
    
### Features

- ARC support
- unicode support
- migrations
- validations (with custom validator support)
- transactions
- support for custom data types
- relationships (BelongsTo, HasMany, HasManyThrough)
- sorting
- filters (where =, !=, IN, NOT IN and else)
- joins
- [CocoaPods](http://cocoapods.org/) support
- no more raw sql!!!

You do not need to create tables manually - just describe your ActiveRecord and enjoy!!!

    #import <ActiveRecord/ActiveRecord.h>

    @interface User : ActiveRecord

    @property (nonatomic, retain) NSString *name;

    @end

### Run tests

iActiveRecord uses [Cedar](https://github.com/pivotal/cedar) for UnitTests and [CocoaPods](https://github.com/CocoaPods/CocoaPods) for dependency management.
Follow this steps to run tests

```bash
[sudo] gem install cocoapods
pod setup
cd project_dir
pod install
open iActiveRecord.xcworkspace
```

Then build & run UnitTests target.

### Check [Wiki](https://github.com/AlexDenisov/iActiveRecord/wiki) to see details!


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/AlexDenisov/iactiverecord/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

