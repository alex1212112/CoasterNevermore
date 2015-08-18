//
//  GHDocumentCache.m
//  Coaster
//
//  Created by Ren Guohua on 14-9-23.
//  Copyright (c) 2014年 ghren. All rights reserved.
//

#import "GHDocumentCache.h"
#import <sys/stat.h>


static  NSMutableDictionary *documentMemoryCache;
static  NSMutableArray *documentRecentlyAccessedKeys;
static int kDocumentCacheMemoryLimit;
static GHDocumentCache *instance = nil;

@implementation GHDocumentCache

/**
 *  单例，静态初始化方法
 *
 *  @return 返回一个单例
 */
+ (instancetype)shareCache{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

/**
 *  初始化方法,增加相关通知，并判断应用的版本信息来确定缓存数据是否要清除
 *
 *  @return self
 */
- (id)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveMemoryCacheToDisk:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveMemoryCacheToDisk:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveMemoryCacheToDisk:) name:UIApplicationWillTerminateNotification object:nil];
        
        //[self clearCacheDependOnVersion];
        
    }
    return self;
}

/**
 *  在应用结束、退回到后台、收到内存告警的时候将内存缓存中的数据存储到磁盘上
 *
 *  @param notification 收到的通知
 */
- (void)saveMemoryCacheToDisk:(NSNotification*)notification
{
    for (NSString *fileName in [documentMemoryCache allKeys])
    {
        
        NSString *filePath = [GHDocumentCache getFilePahtOfCacheWithFileName:fileName];
        id cacheData = [documentMemoryCache objectForKey:fileName];
        if ([cacheData isKindOfClass:[NSData class]])
        {
            NSData *data = (NSData*)cacheData;
            [data writeToFile:filePath atomically:YES];
        }
    }
    
    [documentMemoryCache removeAllObjects];
}
/**
 *  获取cache文件夹的路径
 *
 *  @return cache文件夹的路径
 */
+ (NSString*)cachePath
{
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}
/**
 *  获取在NSCachesDirectory下文件的路径
 *
 *  @param fileName 文件的名称
 *
 *  @return 文件的路径
 */
+ (NSString*)getFilePahtOfCacheWithFileName:(NSString*)fileName
{
    return [[GHDocumentCache cachePath] stringByAppendingPathComponent:fileName];
}


/**
 *  获取所有缓存文件的路径
 *
 *  @return 返回缓存文件路径的数组
 */
+ (NSMutableArray*)getAllFilePathsOfCaches
{
    
    NSMutableArray *filePathArray = [[NSMutableArray alloc] init];
    NSString *folderPath = [GHDocumentCache cachePath];
    NSFileManager* manager = [NSFileManager defaultManager];
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        [filePathArray addObject:fileAbsolutePath];
    }
    
    return filePathArray;
}

/**
 *  删除所有缓存里的文件,清除缓存
 */
- (void)clearCache
{
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:[GHDocumentCache cachePath] error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *fileName;
    while ((fileName = [e nextObject])) {
        
        [fileManager removeItemAtPath:[[GHDocumentCache cachePath] stringByAppendingPathComponent:fileName] error:nil];
    }
    [documentMemoryCache removeAllObjects];
}
/**
 *  删除单个缓存
 *
 *  @param fileName 缓存文件名称
 */
- (void)clearCacheWithFile:(NSString*)fileName
{
    NSString *filePath = [GHDocumentCache getFilePahtOfCacheWithFileName:fileName];
    NSFileManager* fileManager=[NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
    [documentMemoryCache removeObjectForKey:fileName];
}


/**
 *  将数据透明的缓存到内存缓存中，如果内存缓存超出大小限制，就采取最近最不经常使用算法将其存储到磁盘上
 *
 *  @param data     数据
 *  @param fileName 文件名称
 */
- (void)cacheData:(NSData*)data tofile:(NSString*)fileName
{
    if (documentMemoryCache == nil)
    {
        documentMemoryCache = [[NSMutableDictionary alloc] init];
    }
    if (documentRecentlyAccessedKeys == nil)
    {
        documentRecentlyAccessedKeys = [[NSMutableArray alloc] init];
    }
    if (kDocumentCacheMemoryLimit == 0)
    {
        kDocumentCacheMemoryLimit = 10;
    }
    
    [documentMemoryCache setObject:data forKey:fileName];
    
    if ([documentRecentlyAccessedKeys containsObject:fileName])
    {
        [documentRecentlyAccessedKeys  removeObject:fileName];
    }
    [documentRecentlyAccessedKeys insertObject:fileName atIndex:0];
    
    if ([documentRecentlyAccessedKeys count] > kDocumentCacheMemoryLimit)
    {
        NSString *leastRecentlyUsedFilename = [documentRecentlyAccessedKeys lastObject];
        NSData *leastRecentlyUsedData = [documentMemoryCache objectForKey:leastRecentlyUsedFilename];
        NSString *filePath = [GHDocumentCache getFilePahtOfCacheWithFileName:fileName];
        [leastRecentlyUsedData writeToFile:filePath atomically:YES];
        [documentRecentlyAccessedKeys removeLastObject];
        [documentMemoryCache removeObjectForKey:leastRecentlyUsedFilename];
    }
    
}
/**
 *  从内存缓存中透明的获取缓存数据，如果内存缓存中没有该数据，则从磁盘中获取，如果都没有，返回nil；
 *
 *  @param fileName 文件名称
 *
 *  @return 返回获取到的数据，如果获取不到数据，返回nil
 */
- (NSData*)dataFromFile:(NSString*)fileName
{
    NSData *data = [documentMemoryCache objectForKey:fileName];
    if (data)
    {
        return data;
    }
    
    NSString *filePath = [GHDocumentCache getFilePahtOfCacheWithFileName:fileName];
    data = [NSData dataWithContentsOfFile:filePath];
    if (data && data.length > 0)
    {
        [self cacheData:data tofile:fileName];
        return data;
    }
    return nil;
}


/**
 *  用c语言实现的获取目标文件的大小
 *
 *  @param filePath 目标文件路径
 *
 *  @return 目标文件大小
 */

+ (long long) fileSizeWithPath:(NSString*) filePath{
    struct stat st;
    if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0){
        return st.st_size;
    }
    return 0;
}
/**
 *  获取一个目录下所有文件的大小
 *
 *  @param folderPath 文件夹路径
 *
 *  @return 返回所有文件的大小
 */
+ (long long) folderSizeWithPath:(NSString*) folderPath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeWithPath:fileAbsolutePath];
    }
    return folderSize;
}

/**
 *  获取所有缓存文件的大小
 *
 *  @return 所有缓存文件的大小
 */
+ (long long) fileSizeWithCache;
{
    
    return [self folderSizeWithPath:[GHDocumentCache cachePath]];
}

- (void)dealloc
{
    
    documentMemoryCache = nil;
    
    documentRecentlyAccessedKeys = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}


@end
