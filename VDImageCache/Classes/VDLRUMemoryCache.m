//
//  VDLRUMemoryCache.m
//  VDImageCache
//
//  Created by Vu.Doan on 11/13/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import "VDLRUMemoryCache.h"
#import "VDTSMutableArray.h"
#import "VDTSMutableDictionary.h"
#import "VDLRUObject.h"
#import "VDLinkedList.h"

@interface VDLRUMemoryCache()

@property (nonatomic) VDTSMutableDictionary* storedObjects;
@property (nonatomic) VDLinkedList* lruList;

@property NSUInteger currentTotalCost;               // Total cost of all stored object
@property NSUInteger totalCostThreshold;             // Threshold of total cost

@end

@implementation VDLRUMemoryCache

#pragma mark - init

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _storedObjects = [[VDTSMutableDictionary alloc] init];
        _totalCostThreshold = NSUIntegerMax;
        _currentTotalCost = 0;
        _lruList = [[VDLinkedList alloc] init];
    }
    
    return self;
}

#pragma mark - initWithTotalCostLimit

- (instancetype)initWithTotalCostLimit:(NSUInteger)totalCost {
    
    self = [self init];
    
    [self setTotalCostLimit:totalCost];
    
    return self;
}

#pragma mark - setTotalCostLimit

- (void)setTotalCostLimit:(NSUInteger)totalCost {
    
    _totalCostThreshold = totalCost;
    
    // Free memory cache if necessary
    while (_currentTotalCost > _totalCostThreshold) {
        
        [self removeLRUObject];
    }
}

#pragma mark - objectForKey

- (id)objectForKey:(NSString *)key {
    
    NSAssert(key != nil && ![key isEqualToString:@""], @"Key must be non nil and non empty");
    
    VDLRUObject* lruObject = _storedObjects[key];
    
    if (lruObject != nil) {
        
        // Put object to head of LRU list
        [_lruList removeObjectEqualTo:lruObject];
        [_lruList pushFront:lruObject];
    }
    
    return lruObject.value;
}

#pragma mark - setObject

- (void)setObject:(id)object forKey:(NSString *)key cost:(NSUInteger)cost {
    
    NSAssert(object != nil, @"Object must be non nil");
    NSAssert(key != nil && ![key isEqualToString:@""], @"Key must be non nil and non empty");
    
    // if key exist --> Get old cost and calculate changed cost
    VDLRUObject* lruObject = _storedObjects[key];
    
    NSUInteger oldCost = 0;
    
    if (lruObject != nil) {
        
        oldCost = lruObject.cost;
        
        // remove old object in LRU List
        [_lruList removeObjectEqualTo:lruObject];
    }
    
    NSUInteger changedCost = cost - oldCost;
    
    // Change current total cost
    [self changeTotalCurrentCost:changedCost];
    
    // Store object
    VDLRUObject *newNode = [[VDLRUObject alloc] initWithKey:key value:object cost:cost];
    _storedObjects[key] = newNode;
    
    // Add object to head of LRU list
    [_lruList pushFront:newNode];
}

#pragma mark - removeObjectForKey

- (void)removeObjectForKey:(NSString *)key {
    
    VDLRUObject *lruObject = _storedObjects[key];
    
    if (lruObject == nil) {
        
        return;
    }
    
    _currentTotalCost -= lruObject.cost;
    [_storedObjects removeObjectForkey:key];
    [_lruList removeObjectEqualTo:lruObject];
}

#pragma mark - removeAllObjects

- (void)removeAllObjects {
    
    _currentTotalCost = 0;
    [_storedObjects removeAllObjects];
    [_lruList removeAllObjects];
}

#pragma mark - LRU algorithm

/**
 Remove one least-recently-used object
 */
- (void)removeLRUObject {
    
    // Remove last object (Least-recently-used)
    if ([_lruList size] > 0) {
        
        VDLRUObject* lastObject = _lruList.lastObject;
        [self removeObjectForKey:lastObject.key];
    }
}

/**
 Change current total cost and remove objects if out of limit
 
 @param changedCost - changed cost
 */

#pragma mark - LRU algorithm

- (void)changeTotalCurrentCost:(NSInteger)changedCost {
    
    _currentTotalCost += changedCost;
    
    while (_currentTotalCost > _totalCostThreshold) {
        
        [self removeLRUObject];
    }
}

@end
