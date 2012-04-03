## ActiveRecord without CoreData.
### Only SQLite.
### Only HardCore.

### [Follow](https://twitter.com/#!/iactiverecord) this repo on Twitter.
    
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

### Check [Wiki](https://github.com/AlexDenisov/iActiveRecord/wiki) to see details!
