//
//  VDTSMutableDictionary.m
//  VDImageCache
//
//  Created by Vu.Doan on 11/13/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import "VDTSMutableDictionary.h"

@interface VDTSMutableDictionary()

@property (nonatomic) NSMutableDictionary* internalDictionary;
@property (nonatomic) dispatch_queue_t tsQueue;

@end

@implementation VDTSMutableDictionary

#pragma mark - LRU removeAllObjects

- (instancetype)init {
    
    self = [super init];
    
    _internalDictionary = [[NSMutableDictionary alloc]init];
    _tsQueue = dispatch_queue_create("Personal.VDTSMutableDictionary", NULL);
    
    return self;
}

#pragma mark - LRU removeAllObjects

- (id)objectForKeyedSubscript:(id)key {
    
    NSObject* __block result;
    
    dispatch_sync(_tsQueue, ^{
        
        result = _internalDictionary[key];
    });
    
    return result;
}

#pragma mark - LRU removeAllObjects

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    
    dispatch_async(_tsQueue, ^{
        
        _internalDictionary[key] = obj;
    });
}

#pragma mark - toNSDictionary

- (NSDictionary *)toNSDictionary {
    
    NSDictionary* __block result;
    
    dispatch_sync(_tsQueue, ^{
        
        result = _internalDictionary;
    });
    
    return result;
}

#pragma mark - removeObjectForkey

- (void)removeObjectForkey:(NSString *)key {
    
    dispatch_async(_tsQueue, ^{
        
        [_internalDictionary removeObjectForKey:key];
    });
}

#pragma mark - LRU removeAllObjects

- (void)removeAllObjects {
    
    dispatch_async(_tsQueue, ^{
        
        [_internalDictionary removeAllObjects];
    });
}

@end
