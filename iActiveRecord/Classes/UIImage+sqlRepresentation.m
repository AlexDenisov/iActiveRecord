//
//  UIImage+toSql.m
//  iActiveRecord
//
//  Created by PAC on 26/11/2014.
//  Copyright (c) 2014 okolodev.org. All rights reserved.
//

#import "UIImage+sqlRepresentation.h"
#import "NSData+base64.h"

@implementation UIImage (sqlRepresentation)

- (NSString *)toSql {
    NSString *str = [UIImagePNGRepresentation(self) base64EncodedString];
    return str;
}

+ (id)fromSql:(NSString *)sqlData {
    if (sqlData == nil)
        return nil;
    return [UIImage imageWithData:[NSData dataFromBase64String:sqlData]];
}

+ (const char *)sqlType {
    return "uiimage";
}

@end
