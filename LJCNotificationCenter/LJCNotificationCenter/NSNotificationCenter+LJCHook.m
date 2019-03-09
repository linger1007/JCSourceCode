//
//  NSNotificationCenter+LJCHook.m
//  LJCNotificationCenter
//
//  Created by 林锦超 on 2019/3/9.
//  Copyright © 2019 林锦超. All rights reserved.
//

#import "NSNotificationCenter+LJCHook.h"
#import <objc/runtime.h>

@implementation NSNotificationCenter (LJCHook)

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // switch present
        [self _swizzleMethod:@selector(addObserver:selector:name:object:) with:@selector(ljc_addObserver:selector:name:object:)];
        [self _swizzleMethod:@selector(addObserverForName:object:queue:usingBlock:) with:@selector(ljc_addObserverForName:object:queue:usingBlock:)];
        
        [self _swizzleMethod:@selector(postNotificationName:object:userInfo:) with:@selector(ljc_postNotificationName:object:userInfo:)];
        [self _swizzleMethod:@selector(postNotificationName:object:) with:@selector(ljc_postNotificationName:object:)];
        [self _swizzleMethod:@selector(postNotification:) with:@selector(ljc_postNotification:)];
        
        [self _swizzleMethod:@selector(removeObserver:name:object:) with:@selector(ljc_removeObserver:name:object:)];
        [self _swizzleMethod:@selector(removeObserver:) with:@selector(ljc_removeObserver:)];
        
    });
}

+ (void)_swizzleMethod:(SEL)originalSelector with:(SEL)swizzledSelector
{
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

// swizzled
- (void)ljc_addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject
{
    if ([self _isLjcMethodObserved:aName]) {
        NSLog(@"%s", __func__);
    }
    [self ljc_addObserver:observer selector:aSelector name:aName object:anObject];
}

- (void)ljc_postNotification:(NSNotification *)notification
{
    NSLog(@"%s", __func__);
    [self ljc_postNotification:notification];
}

- (void)ljc_postNotificationName:(NSNotificationName)aName object:(nullable id)anObject
{
    // call postNotificationName:object:userInfo:
    if ([self _isLjcMethodObserved:aName]) {
        NSLog(@"%s", __func__);
    }
    [self ljc_postNotificationName:aName object:anObject];
}

- (void)ljc_postNotificationName:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo
{
    if ([self _isLjcMethodObserved:aName]) {
        NSLog(@"%s", __func__);
    }
    [self ljc_postNotificationName:aName object:anObject userInfo:aUserInfo];
}

- (void)ljc_removeObserver:(id)observer
{
    NSLog(@"%s", __func__);
    [self ljc_removeObserver:observer];
}

- (void)ljc_removeObserver:(id)observer name:(nullable NSNotificationName)aName object:(nullable id)anObject
{
    if ([self _isLjcMethodObserved:aName]) {
        NSLog(@"%s", __func__);
    }
    [self ljc_removeObserver:observer name:aName object:anObject];
}

- (id <NSObject>)ljc_addObserverForName:(nullable NSNotificationName)name object:(nullable id)obj queue:(nullable NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *note))block
{
    if ([self _isLjcMethodObserved:name]) {
        NSLog(@"%s", __func__);
    }
    return [self ljc_addObserverForName:name object:obj queue:queue usingBlock:block];
}

- (BOOL)_isLjcMethodObserved:(NSString *)name
{
    if (name.length >= 3 && [[name substringToIndex:3] isEqualToString:@"LJC"]) {
        return YES;
    }
    return NO;
}
@end
