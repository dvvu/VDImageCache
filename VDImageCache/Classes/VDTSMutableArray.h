//
//  VDTSMutableArray.h
//  VDImageCache
//
//  Created by Vu.Doan on 11/13/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDTSMutableArray : NSObject

#pragma mark - init
- (instancetype)init;

#pragma mark - initWithArray
- (instancetype)initWithArray:(NSArray *)array;

#pragma mark - addObject
- (void)addObject:(NSObject *)object;

#pragma mark - addObjectsFromArray
- (void)addObjectsFromArray:(NSArray *)array;

#pragma mark - insertObject
- (void)insertObject:(NSObject *)object atIndex:(NSUInteger)index;

#pragma mark - removeObject
- (void)removeObject:(NSObject *)object;

#pragma mark - removeObjectAtIndex
- (void)removeObjectAtIndex:(NSUInteger)index;

#pragma mark - removeAllObjects
- (void)removeAllObjects;

#pragma mark - pop
- (id)pop;

#pragma mark - objectAtIndex
- (id)objectAtIndex:(NSUInteger)index;

#pragma mark - count
- (NSUInteger)count;

#pragma mark - filteredArrayUsingPredicate
- (NSArray *)filteredArrayUsingPredicate: (NSPredicate *) predicate;

#pragma mark - indexOfObject
- (NSInteger)indexOfObject: (NSObject *)object;

#pragma mark - containsObject
- (BOOL)containsObject: (id)object;

#pragma mark - toNSArray
- (NSArray *)toNSArray;

@end
