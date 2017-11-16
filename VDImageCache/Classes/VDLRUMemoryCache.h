//
//  VDLRUMemoryCache.h
//  VDImageCache
//
//  Created by Vu.Doan on 11/13/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDLRUMemoryCache : NSObject

#pragma mark - init
- (instancetype)init;

#pragma mark - initWithTotalCostLimit
- (instancetype)initWithTotalCostLimit:(NSUInteger)totalCost;

#pragma mark - setObject
- (void)setObject:(id)object forKey:(NSString *)key cost:(NSUInteger)cost;

#pragma mark - objectForKey
- (id)objectForKey:(NSString *)key;

#pragma mark - removeObjectForKey
- (void)removeObjectForKey:(NSString *)key;

#pragma mark - removeAllObjects
- (void)removeAllObjects;

#pragma mark - setTotalCostLimit
- (void)setTotalCostLimit:(NSUInteger)totalCost;

@end
