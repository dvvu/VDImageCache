//
//  NSString+Extension.m
//
//  Created by Vu.Doan on 11/13/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString(ContactPicker)

- (NSString *)toANSCI {
    
    return [self stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
}

- (NSString *)getFirstChar {
    
    unichar firstChar = [[self uppercaseString] characterAtIndex:0];
    
    if (!(firstChar >= 'A' && firstChar <= 'Z')
    
        && !(firstChar >= '0' && firstChar <= '9')) {
        firstChar = [[[self uppercaseString] toANSCI] characterAtIndex:0];
    }
    
    if (!(firstChar >= 'A' && firstChar <= 'Z')) {
    
        firstChar = '#';
    }
    return [NSString stringWithFormat:@"%c",firstChar];
}

@end
