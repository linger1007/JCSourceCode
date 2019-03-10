//
//  LJCNotificationCenter.m
//  LJCNotificationCenter
//
//  Created by 林锦超 on 2019/3/9.
//  Copyright © 2019 林锦超. All rights reserved.
//

#import "LJCNotificationCenter.h"

@interface __LJCObserver : NSObject

@end
@implementation __LJCObserver

@end
//MARK: ----------

typedef void(^LJCNotificationObserverBlock)(LJCNotification *note);

//- (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable LJCNotificationName)aName object:(nullable id)anObject
@interface LJCNotificationObserver : NSObject
@property (nonatomic, strong) id observer;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, copy) LJCNotificationName notificationName;
@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, copy) LJCNotificationObserverBlock block;
@end

@implementation LJCNotificationObserver

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %p {observer = %@; selector = %@; name = %@; object = %@}", [self class], self, self.observer, NSStringFromSelector(self.selector), self.notificationName, self.object];
}

@end
//MARK: ----------
@interface LJCNotification()
@property (readwrite, copy) LJCNotificationName name;
@property (nullable, readwrite, retain) id object;
@property (nullable, readwrite, copy) NSDictionary *userInfo;
@end

@implementation LJCNotification

- (instancetype)initWithName:(LJCNotificationName)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo
{
    if (self = [super init]) {
        _name = name;
        _object = object;
        _userInfo = userInfo;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %p {name = %@; object = %@; userInfo = %@}", [self class], self, self.name, self.object, self.userInfo];
}

+ (instancetype)notificationWithName:(LJCNotificationName)aName object:(nullable id)anObject
{
    return [self notificationWithName:aName object:anObject userInfo:nil];
}
+ (instancetype)notificationWithName:(LJCNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo
{
    return [[[self class] alloc] initWithName:aName object:anObject userInfo:aUserInfo];
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    return [LJCNotification notificationWithName:self.name object:self.object userInfo:self.userInfo];
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.object forKey:@"object"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [LJCNotification notificationWithName:[aDecoder decodeObjectForKey:@"name"]
                                          object:[aDecoder decodeObjectForKey:@"object"]
                                        userInfo:[aDecoder decodeObjectForKey:@"userInfo"]];
}
@end

//MARK: ----------
@interface LJCNotificationCenter()
@property (nonatomic, strong) NSMutableArray<LJCNotificationObserver *> *observers;
@end
@implementation LJCNotificationCenter

+ (instancetype)defaultCenter
{
    static LJCNotificationCenter *center = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        center = [[LJCNotificationCenter alloc] init];
    });
    return center;
}

- (instancetype)init
{
    if (self = [super init]) {
        _observers = [NSMutableArray array];
    }
    return self;
}

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable LJCNotificationName)aName object:(nullable id)anObject
{
    LJCNotificationObserver *obs = [LJCNotificationObserver new];
    obs.observer = observer;
    obs.selector = aSelector;
    obs.notificationName = aName;
    obs.object = anObject;
    [self.observers addObject:obs];
}

- (void)postNotification:(LJCNotification *)notification
{
    [self.observers enumerateObjectsUsingBlock:^(LJCNotificationObserver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.notificationName isEqualToString:notification.name] &&
            (!obj.object || [obj.object isEqual:notification.object])) {    //nil或者object相同(isEqual:)
            if (obj.selector) {
                if ([obj.observer respondsToSelector:obj.selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [obj.observer performSelector:obj.selector withObject:notification];
#pragma clang diagnostic pop
                }
            }
            else if (obj.block) {
                NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                    obj.block(notification);
                }];
                [obj.operationQueue addOperation:operation];
            }
        }
    }];
}
- (void)postNotificationName:(LJCNotificationName)aName object:(nullable id)anObject
{
    [self postNotificationName:aName object:anObject userInfo:nil];
}
- (void)postNotificationName:(LJCNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo
{
    [self postNotification:[LJCNotification notificationWithName:aName object:anObject userInfo:aUserInfo]];
}

- (void)removeObserver:(id)observer
{
    [self removeObserver:observer name:nil object:nil];
}
- (void)removeObserver:(id)observer name:(nullable LJCNotificationName)aName object:(nullable id)anObject
{
    __weak __typeof(self) weakSelf = self;
    [self.observers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(LJCNotificationObserver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.observer isEqual:observer] &&
            (!aName || [obj.notificationName isEqualToString:aName]) &&
            (!anObject || [obj.object isEqual:anObject]) ) {    //nil is ok
            [weakSelf.observers removeObject:obj];
        }
    }];
}

- (id <NSObject>)addObserverForName:(nullable LJCNotificationName)name object:(nullable id)obj queue:(nullable NSOperationQueue *)queue usingBlock:(void (^)(LJCNotification *note))block
{
    LJCNotificationObserver *obs = [LJCNotificationObserver new];
    obs.observer = [__LJCObserver new];
    obs.notificationName = name;
    obs.object = obj;
    obs.operationQueue = queue;
    obs.block = block;
    [self.observers addObject:obs];
    
    return obs.observer;
}
@end
