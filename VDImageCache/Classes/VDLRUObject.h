//
//  VDLRUObject.h
//  VDImageCache
//
//  Created by Macbook on 11/15/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDLRUObject : NSObject

@property (nonatomic, readonly) NSString *key;      // key of object
@property (nonatomic, readonly) id value;           // Value of object
@property NSUInteger cost;                          // cost of object

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithKey:(NSString *)key value:(id)value cost:(NSUInteger)cost;

@end
