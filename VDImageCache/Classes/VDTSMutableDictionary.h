//
//  VDTSMutableDictionary.h
//  VDImageCache
//
//  Created by Vu.Doan on 11/13/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDTSMutableDictionary : NSObject

#pragma mark - objectForKeyedSubscript
- (id)objectForKeyedSubscript:(id)key;

#pragma mark - setObject
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

#pragma mark - toNSDictionary
- (NSDictionary *)toNSDictionary;

#pragma mark - removeObjectForkey
- (void)removeObjectForkey:(NSString *)key;

#pragma mark - LRU removeAllObjects
- (void)removeAllObjects;

@end
