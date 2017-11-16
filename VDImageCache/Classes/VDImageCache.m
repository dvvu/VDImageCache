//
//  VDImageCache.m
//  VDImageCache
//
//  Created by Vu.Doan on 11/13/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import "VDImageCache.h"
#import "NSDate+Extension.h"
#import "VDSystemHelper.h"
#import "VDLRUMemoryCache.h"

@interface VDImageCache()

@property (nonatomic) NSFileManager* icFileManager;     // File manager
@property (nonatomic) VDLRUMemoryCache* icMemCache;     // Memory cache
@property (nonatomic) dispatch_queue_t icIOQueue;       // Queue for read/write file serial
@property (nonatomic) NSString* icDirPath;              // Directory path for save file

@end

@implementation VDImageCache

#pragma mark - Contructors

- (instancetype)init {
    
    self = [super init];
    
    _icMemCache = [[VDLRUMemoryCache alloc] init];
    [self maximizeMemoryCache];
    
    _icIOQueue = dispatch_queue_create("Personal.VDImageCache", DISPATCH_QUEUE_SERIAL);
    
    // I/O
    dispatch_async(_icIOQueue, ^{
        
        // File manager
        _icFileManager = [NSFileManager defaultManager];
        
        // Create directory path
        NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* docsPath = [dirPaths objectAtIndex:0];
        _icDirPath = [docsPath stringByAppendingString:@"/Personal.VDImageCache"];
        
        // Create directory if not exist
        if (![_icFileManager fileExistsAtPath:_icDirPath]) {
            
            [_icFileManager createDirectoryAtPath:_icDirPath
                      withIntermediateDirectories:NO
                                       attributes:nil
                                            error:nil];
        }
    });
    
    // Clear memory cache if mem warning
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearMemory)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    // Delete old files when app terminated
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteOldFiles)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    // Maximize memory cache when application enters foreground
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(maximizeMemoryCache)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    // Minimize memory cache when application enters background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(minimizeMemoryCache)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    return self;
}

#pragma mark - Destructors

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Static methods

+ (id)sharedInstance {
    
    static VDImageCache* sharedImageCache;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedImageCache = [[self alloc] init];
    });
    
    return sharedImageCache;
}

#pragma mark - Public methods

- (void)storeImage:(UIImage *)image withKey:(NSString *)key {
    
    [self storeImageToDisk:image withKey:key];
}

#pragma mark - imageFromKey

- (UIImage *)imageFromKey:(NSString *)key storeToMem:(BOOL)storeToMem {
    
    UIImage* image = [self imageFromMemCacheWithKey:key];
   
    if (image) {
    
        return image;
    }
    
    return [self imageFromDiskWithKey:key storeToMem:storeToMem];
}

#pragma mark - imageFromKey

- (void)imageFromKey:(NSString *)key storeToMem:(BOOL)storeToMem completion:(void (^) (UIImage *))completion {
    
    UIImage* image = [self imageFromMemCacheWithKey:key];
    
    if (image) {
        
        if (completion) {
            
            completion(image);
        }
    } else {
        
        [self imageFromDiskWithKey:key storeToMem:storeToMem];
    }
}

#pragma mark - imageFromKey-Size

- (UIImage *)imageFromKey:(NSString *)key withSize:(CGSize)size {
    
    NSString* thumbnailKey = [NSString stringWithFormat:@"%@-%fx%f",key,size.width,size.height];
    UIImage* image = [self imageFromKey:thumbnailKey storeToMem:YES];
    
    if (image == nil) {
    
        image = [self imageFromDiskWithKey:key size:size];
    }
    
    return image;
}

#pragma mark - imageFromKey-Size

- (void)imageFromKey:(NSString *)key withSize:(CGSize)size completion:(void (^)(UIImage *))completion {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
        NSString* thumbnailKey = [NSString stringWithFormat:@"%@-%fx%f",key,size.width,size.height];
        UIImage* image = [self imageFromKey:thumbnailKey storeToMem:YES];
        
        if (!image) {
            
            image = [self imageFromDiskWithKey:key size:size];
        }
        
        if (completion) {
            
            completion(image);
        }
    });
}

#pragma mark - imageFromDiskWithKey-Size

- (UIImage *)imageFromDiskWithKey:(NSString *)key size:(CGSize)size {
    
    NSURL* filePath = [NSURL fileURLWithPath:[self getFilePathFromKey:key]];
    
    UIImage* image = [self resizeImageAtPath:filePath maxSize:(size.height > size.width) ? size.height : size.width];
   
    if (image) {
        
        [self storeImage:image withKey:[NSString stringWithFormat:@"%@-%fx%f",key,size.width,size.height]];
    }
    
    return image;
}

#pragma mark - removeImageForKey

- (void)removeImageForKey:(NSString *)key {
    
    [self removeImageInMemWithKey:key];
    [self removeImageOnDiskWithKey:key];
}

#pragma mark - removeAllCache

- (void)removeAllCache {
    
    [self removeAllCacheOnMem];
    [self removeAllCacheOnDisk];
}

#pragma mark - removeAllCacheOnMem

- (void)removeAllCacheOnMem {
    
    [_icMemCache removeAllObjects];
}

#pragma mark - removeAllCacheOnDisk

- (void)removeAllCacheOnDisk {
    
    dispatch_async(_icIOQueue, ^{
        
        NSError* error;
        
        // Get all files in directory
        NSArray* files = [_icFileManager contentsOfDirectoryAtPath:_icDirPath error:&error];
        
        for (NSString* file in files) {
            // Delete file
            [_icFileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", _icDirPath, file] error:&error];
        }
    });
}

#pragma mark - storeImageToDisk

- (void)storeImageToDisk:(UIImage *)image withKey:(NSString *)key {
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
        NSString* filePath = [self getFilePathFromKey:key];
        NSData* imageData = UIImageJPEGRepresentation(image, 1.0);
        
        // Write to file
        dispatch_async(_icIOQueue, ^{
        
            [imageData writeToFile:filePath atomically:YES];
        });
//    });
}

#pragma mark - storeImageToMem

- (void)storeImageToMem:(UIImage *)image withKey:(NSString *)key cost:(NSUInteger)cost {
    
    [_icMemCache setObject:image forKey:key cost:cost];
}

#pragma mark - imageFromDiskWithKey

- (UIImage *)imageFromDiskWithKey:(NSString *)key storeToMem:(BOOL)storeToMem {
    
    NSString* filePath = [self getFilePathFromKey:key];
    
    // Read image data from disk
    NSData* __block imageData;
    
    dispatch_sync(_icIOQueue, ^{
    
        imageData = [NSData dataWithContentsOfFile:filePath];
    });
    
    // If has image fixed key, store image to mem cache
    UIImage* image = [UIImage imageWithData:imageData];
    
    if (storeToMem && image) {
        
        [self storeImageToMem:image withKey:key cost:[imageData length]];
    }
    
    return image;
}


#pragma mark - imageFromDiskWithKey

- (void)imageFromDiskWithKey:(NSString *)key storeToMem:(BOOL)storeToMem completion:(void (^) (UIImage *))completion {
    
    NSString* filePath = [self getFilePathFromKey:key];
    
    // Read image data from disk
    NSData* __block imageData;
    
    dispatch_sync(_icIOQueue, ^{
        
        imageData = [NSData dataWithContentsOfFile:filePath];
    });
    
    // If has image fixed key, store image to mem cache
    UIImage* image = [UIImage imageWithData:imageData];
    
    if (storeToMem && image) {
        
        [self storeImageToMem:image withKey:key cost:[imageData length]];
    }
    
    if (completion) {
        
        completion(image);
    }
}

#pragma mark - imageFromMemCacheWithKey

- (UIImage *)imageFromMemCacheWithKey:(NSString *)key {
    
    return [_icMemCache objectForKey:key];
}

#pragma mark - getFilePathFromKey

- (NSString *)getFilePathFromKey:(NSString *)key {
    
    NSString* __block databasePath;
    
    // Need to wait until directory is created
    dispatch_sync(_icIOQueue, ^{
        
        databasePath = [[NSString alloc] initWithString: [_icDirPath stringByAppendingPathComponent:key]];
    });
    
    return databasePath;
}

#pragma mark - removeImageInMemWithKey

- (void)removeImageInMemWithKey:(NSString *)key {
    
    [_icMemCache removeObjectForKey:key];
}

#pragma mark - removeImageOnDiskWithKey

- (void)removeImageOnDiskWithKey:(NSString *)key {
    
    dispatch_async(_icIOQueue, ^{
       
        NSError* error;
        [_icFileManager removeItemAtPath:[self getFilePathFromKey:key] error:&error];
        
#if DEBUG
        
        NSAssert(!error, error.debugDescription);
#endif
    });
}

#pragma mark - clearMemory

- (void)clearMemory {
    
    [_icMemCache removeAllObjects];
}

#pragma mark - deleteOldFiles

- (void)deleteOldFiles {
    
    dispatch_async(_icIOQueue, ^{
        
        NSError* error;
        
        // Get all files on disk
        NSArray* files = [_icFileManager contentsOfDirectoryAtPath:_icDirPath error:&error];
        
#if DEBUG
        NSAssert(!error, error.debugDescription);
#endif
        
        for (NSString* file in files) {
            
            NSString* path = [NSString stringWithFormat:@"%@/%@", _icDirPath, file];
            
            // Get modifidation date
            NSDictionary* attributes = [_icFileManager attributesOfItemAtPath:path error:nil];
            NSDate* lastModifiedDate = [attributes fileModificationDate];
            
            // Skip if last modified date is in threshold
            NSDate* today = [NSDate date];
            
            if ([NSDate daysBetweenDate:lastModifiedDate andDate:today] <= EXPIRATION_DAYS) {
            
                continue;
            }
            
            // Delete file
            [_icFileManager removeItemAtPath:path error:&error];
        }
    });
}

#pragma mark - setMemoryThreshold

- (void)setMemoryThreshold:(float)ratio {
    
    unsigned long freeMemory = [VDSystemHelper getFreeMemory];
    
    NSLog(@"%lu",freeMemory);
    if (freeMemory == 0) {  // Cannot get memory info
        
        return;
    }
    
    unsigned long threshold = floor(freeMemory * ratio);
    
    [self.icMemCache setTotalCostLimit:threshold];
}

#pragma mark - minimizeMemoryCache

- (void)minimizeMemoryCache {
    
    [self setMemoryThreshold:MINIMUM_MEMORY_RATIO];
}

#pragma mark - maximizeMemoryCache

- (void)maximizeMemoryCache {
    
    [self setMemoryThreshold:MAXIMUM_MEMORY_RATIO];
}

#pragma mark - maximizeMemoryCache

- (UIImage *)resizeImageAtPath:(NSURL *)imagePath maxSize:(CGFloat)maxSize {
    
    if (maxSize <= 0) {
        
        return nil;
    }
    // Create the image source
    CGImageSourceRef src = CGImageSourceCreateWithURL((__bridge CFURLRef) imagePath, NULL);
    
    if (src == nil) {
     
        return nil;
    }
    
    // Create thumbnail options
    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
                                                           (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                           (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                           (id) kCGImageSourceThumbnailMaxPixelSize : @(maxSize)
                                                           };
    
    // Generate the thumbnail
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(src, 0, options);
    CFRelease(src);
    
    // Write the thumbnail at path
    UIImage* image = [UIImage imageWithCGImage:thumbnail];
    
    return image;
}

@end
