//
//  CustomURLCache.m
//  testia
//
//  Created by frederic Visticot on 28/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import "CustomURLCache.h"

static NSString * const customURLCacheExpirationKey = @"CustomURLCacheExpiration";
static NSTimeInterval const customURLCacheExpirationInterval = 60;

@implementation CustomURLCache

+ (instancetype)standardURLCache {
    static CustomURLCache *_standardURLCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _standardURLCache = [[CustomURLCache alloc]
                             initWithMemoryCapacity:(2 * 1024 * 1024)
                             diskCapacity:(100 * 1024 * 1024)
                             diskPath:nil];
    });
    
    return _standardURLCache;
}

#pragma mark - NSURLCache

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    NSCachedURLResponse *cachedResponse = [super cachedResponseForRequest:request];
    
    if (cachedResponse) {
        NSDate* cacheDate = cachedResponse.userInfo[customURLCacheExpirationKey];
        NSDate* cacheExpirationDate = [cacheDate dateByAddingTimeInterval:customURLCacheExpirationInterval];
        if ([cacheExpirationDate compare:[NSDate date]] == NSOrderedAscending) {
            [self removeCachedResponseForRequest:request];
            NSLog(@"Request to old, clearing cache");
            return nil;
        }
    }
    NSLog(@"[%@] Reponse returned from cache", [request.URL absoluteString]);
    if (cachedResponse.userInfo.allKeys.count > 0) {
        NSLog(@"Yeah1");
    }
    return cachedResponse;
}




- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse
                 forRequest:(NSURLRequest *)request
{
    
    if (cachedResponse.userInfo.allKeys.count > 0) {
        NSLog(@"Yeah");
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:cachedResponse.userInfo];
    
    userInfo[customURLCacheExpirationKey] = [NSDate date];
    
    NSCachedURLResponse *modifiedCachedResponse = [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response data:cachedResponse.data userInfo:userInfo storagePolicy:cachedResponse.storagePolicy];
    
    [super storeCachedResponse:modifiedCachedResponse forRequest:request];
    
    NSLog(@"Storing cached request");
}

@end
