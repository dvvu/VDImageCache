//
//  VDTSMutableArray.m
//  VDImageCache
//
//  Created by Vu.Doan on 11/13/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import "VDTSMutableArray.h"

@interface VDTSMutableArray()

@property (nonatomic) NSMutableArray* internalArray;
@property (nonatomic) dispatch_queue_t tsQueue;

@end

@implementation VDTSMutableArray

#pragma mark - init

- (instancetype)init {
    
    self = [super init];
    
    _internalArray = [[NSMutableArray alloc]init];
    _tsQueue = dispatch_queue_create("Personal.VDTSMutableArray", NULL);
    
    return self;
}

#pragma mark - initWithArray

- (instancetype)initWithArray:(NSArray *)array {
    
    self = [super init];
    
    if (array == nil || [array count] == 0) {
        
        NSLog(@"Array must be nonnull and nonempty");
        _internalArray = [[NSMutableArray alloc]init];
    } else {
        
        _internalArray = [[NSMutableArray alloc] initWithArray:array copyItems:NO];
    }
    
    _tsQueue = dispatch_queue_create("Personal.VDTSMutableArray", NULL);
    
    return self;
}

#pragma mark - addObject

- (void)addObject:(NSObject *)object {
    
    // Valid input object
    if (object == nil) {
        
        NSLog(@"Object must be nonnull");
        return;
    }
    
    // Add to array
    dispatch_async(_tsQueue, ^{
        
        [_internalArray addObject:object];
    });
}

#pragma mark - addObjectsFromArray

- (void)addObjectsFromArray:(NSArray *)array {
    
    // Valid input array
    if (array == nil) {
       
        NSLog(@"Array must be nonnull");
        return;
    }
    
    if ([array count] == 0) {
       
        NSLog(@"Array must be not empty");
        return;
    }
    
    // Add objects from array
    dispatch_async(_tsQueue, ^{
        
        [_internalArray addObjectsFromArray:array];
    });
}

#pragma mark - insertObject

- (void)insertObject:(NSObject *)object atIndex:(NSUInteger)index {
    
    // Valid input object
    if (object == nil) {
        
        NSLog(@"Object must be nonnull");
        return;
    }
    
    // Valid input index
    NSUInteger numberOfElements = [self count];
    
    if (index > numberOfElements) {
    
        NSLog(@"Index %lu is out of range [0..%lu]",(unsigned long)index,(unsigned long)numberOfElements);
        return;
    }
    
    // Insert to array
    dispatch_async(_tsQueue, ^{
        
        [_internalArray insertObject:object atIndex:index];
    });
}

#pragma mark - removeObject

- (void)removeObject:(NSObject *)object {
    
    // Valid input object
    if (object == nil) {
        
        NSLog(@"Object must be nonnull");
        return;
    }
    
    // Remove object from array
    dispatch_async(_tsQueue, ^{
        
        [_internalArray removeObject:object];
    });
}

#pragma mark - removeObjectAtIndex

- (void)removeObjectAtIndex:(NSUInteger)index {
    
    // Valid input index
    NSUInteger numberOfElements = [self count];
   
    if (index >= numberOfElements) {
    
        NSLog(@"Index is out of range");
        return;
    }
    
    // Remove object at index from array
    dispatch_async(_tsQueue, ^{
        
        [_internalArray removeObjectAtIndex:index];
    });
}

#pragma mark - removeAllObjects

- (void)removeAllObjects {
    
    // Check nonempty array
    NSUInteger numberOfElements = [self count];
    
    if (numberOfElements == 0) {
     
        NSLog(@"Array is empty");
        return;
    }
    
    // Remove all objects from array
    dispatch_async(_tsQueue, ^{
    
        [_internalArray removeAllObjects];
    });
}

#pragma mark - objectAtIndex

- (id)objectAtIndex:(NSUInteger)index {
    
    // Valid input index
    NSUInteger numberOfElements = [self count];
   
    if (index >= numberOfElements) {
    
        NSLog(@"Index %lu is out of range [0..%lu]",(unsigned long)index,(unsigned long)numberOfElements);
        return nil;
    }
    
    // Return object at index in array
    id __block object;
    dispatch_sync(_tsQueue, ^{
        
        object = [_internalArray objectAtIndex:index];
    });
    return object;
}

#pragma mark - count

- (NSUInteger)count {
    
    NSUInteger __block count;
    
    dispatch_sync(_tsQueue, ^{
    
        count = [_internalArray count];
    });
    return count;
}

#pragma mark - filteredArrayUsingPredicate

- (NSArray *)filteredArrayUsingPredicate:(NSPredicate *)predicate {
    
    NSArray* __block result;
   
    dispatch_sync(_tsQueue, ^{
    
        result = [_internalArray filteredArrayUsingPredicate:predicate];
    });
    
    return result;
}

#pragma mark - indexOfObject

- (NSInteger)indexOfObject:(NSObject *)object {
    
    NSInteger __block result;
    
    dispatch_sync(_tsQueue, ^{
    
        result = [_internalArray indexOfObject:object];
    });
    
    return result;
}

#pragma mark - containsObject

- (BOOL)containsObject: (id)object {
    
    BOOL __block result;
    
    dispatch_sync(_tsQueue, ^{
    
        result = [_internalArray containsObject:object];
    });
    
    return result;
}

#pragma mark - toNSArray

- (NSArray *)toNSArray {
    
    NSArray* __block array;
    
    dispatch_sync(_tsQueue, ^{
        
        array = [[NSArray alloc] initWithArray:_internalArray];
    });
    
    return array;
}

#pragma mark - pop

- (id)pop {
    
    id __block obj;
    
    dispatch_sync(_tsQueue, ^{
    
        if ([_internalArray count] > 0) {
        
            obj = [_internalArray lastObject];
            [_internalArray removeLastObject];
        }
    });
    
    return obj;
}

@end
