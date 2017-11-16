//
//  VDLRUObject.m
//  VDImageCache
//
//  Created by Macbook on 11/15/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import "VDLRUObject.h"

@implementation VDLRUObject

- (instancetype)initWithKey:(NSString *)key value:(id)value cost:(NSUInteger)cost {
    
    self = [super init];
    
    if (self) {
      
        _key = key;
        _value = value;
        _cost = cost;
    }

    return self;
}

@end
