//
//  VDImageCache.h
//  VDImageCache
//
//  Created by Vu.Doan on 11/13/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MAXIMUM_MEMORY_RATIO 0.8
#define MINIMUM_MEMORY_RATIO 0.05
#define EXPIRATION_DAYS 30                  // Clear file on disk after 30 days

@interface VDImageCache : NSObject

+ (id)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - storeImage
- (void)storeImage:(UIImage *)image withKey:(NSString *)key;

#pragma mark - imageFromKey
- (UIImage *)imageFromKey:(NSString *)key storeToMem:(BOOL)storeToMem;

#pragma mark - imageFromKey
- (UIImage *)imageFromKey:(NSString *)key withSize:(CGSize)size;

#pragma mark - removeImageForKey
- (void)removeImageForKey:(NSString *)key;

#pragma mark - removeAllCache
- (void)removeAllCache;

- (void)imageFromKey:(NSString *)key storeToMem:(BOOL)storeToMem completion:(void (^) (UIImage *))completion;
- (void)imageFromKey:(NSString *)key withSize:(CGSize)size completion:(void (^) (UIImage *))completion;

@end
