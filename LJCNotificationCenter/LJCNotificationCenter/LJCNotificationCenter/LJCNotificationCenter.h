//
//  LJCNotificationCenter.h
//  LJCNotificationCenter
//
//  Created by 林锦超 on 2019/3/9.
//  Copyright © 2019 林锦超. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *LJCNotificationName NS_EXTENSIBLE_STRING_ENUM;
@interface LJCNotification : NSObject <NSCopying, NSCoding>

@property (readonly, copy) LJCNotificationName name;
@property (nullable, readonly, retain) id object;
@property (nullable, readonly, copy) NSDictionary *userInfo;

- (instancetype)initWithName:(LJCNotificationName)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

//@end
//
//@interface LJCNotification (LJCNotificationCreation)

+ (instancetype)notificationWithName:(LJCNotificationName)aName object:(nullable id)anObject;
+ (instancetype)notificationWithName:(LJCNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo;

- (instancetype)init NS_UNAVAILABLE;    /* do not invoke; not a valid initializer for this class */

@end

//MARK: ----------
@interface LJCNotificationCenter : NSObject

@property (class, readonly, strong) LJCNotificationCenter *defaultCenter;

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable LJCNotificationName)aName object:(nullable id)anObject;

- (void)postNotification:(LJCNotification *)notification;
- (void)postNotificationName:(LJCNotificationName)aName object:(nullable id)anObject;
- (void)postNotificationName:(LJCNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo;

- (void)removeObserver:(id)observer;
- (void)removeObserver:(id)observer name:(nullable LJCNotificationName)aName object:(nullable id)anObject;

- (id <NSObject>)addObserverForName:(nullable LJCNotificationName)name object:(nullable id)obj queue:(nullable NSOperationQueue *)queue usingBlock:(void (^)(LJCNotification *note))block;
@end

NS_ASSUME_NONNULL_END
