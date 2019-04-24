//
//  NSObject+ZHSafeKVO.m
//  ZHSafeKVO
//
//  Created by 郑晗 on 2019/4/24.
//  Copyright © 2019年 郑晗. All rights reserved.
//

#import "NSObject+ZHSafeKVO.h"
#import <objc/runtime.h>

@implementation NSObject (ZHSafeKVO)

+ (void)load {
    
    Method originAddM = class_getInstanceMethod([self class], @selector(addObserver:forKeyPath:options:context:));
    Method swizzAddM = class_getInstanceMethod([self class], @selector(swizz_addObserver:forKeyPath:options:context:));
    
    Method originRemoveM = class_getInstanceMethod([self class], @selector(removeObserver:forKeyPath:context:));
    Method swizzRemoveM = class_getInstanceMethod([self class], @selector(swizz_removeObserver:forKeyPath:context:));
    
    IMP originAddMIMP = class_getMethodImplementation([self class], @selector(addObserver:forKeyPath:options:context:));
    IMP originRemoveIMP = class_getMethodImplementation([self class], @selector(removeObserver:name:object:));
    
    BOOL hasAddM = class_addMethod([self class], @selector(addObserver:forKeyPath:options:context:), originAddMIMP, method_getTypeEncoding(originAddM));
    
    BOOL hasRemoveM = class_addMethod([self class], @selector(removeObserver:forKeyPath:context:), originRemoveIMP, method_getTypeEncoding(originRemoveM));
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!hasAddM) {
            method_exchangeImplementations(originAddM, swizzAddM);
        }
        if (!hasRemoveM) {
            method_exchangeImplementations(originRemoveM, swizzRemoveM);
        }
    });
}

- (void)swizz_addObserver:(nonnull NSObject *)observer forKeyPath:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context {
    if (![self hasKey:keyPath]) {
        
        [self swizz_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}
- (void)swizz_removeObserver:(nonnull NSObject *)observer forKeyPath:(nonnull NSString *)keyPath context:(nullable void *)context {
    if ([self hasKey:keyPath]) {
        [self swizz_removeObserver:observer forKeyPath:keyPath context:context];
    }
}

- (void)removeAllObserverdKeyPath {
    id info = self.observationInfo;
    NSArray *arr = [info valueForKeyPath:@"_observances._property._keyPath"];
    for (NSString *keyPath in arr) {
        [self removeObserver:self forKeyPath:keyPath context:nil];
    }
}

- (BOOL)hasKey:(NSString *)kvoKey {
    BOOL hasKey = NO;
    id info = self.observationInfo;
    NSArray *arr = [info valueForKeyPath:@"_observances._property._keyPath"];
    for (id keypath in arr) {
        
        if ([keypath isEqualToString:kvoKey]) {
            hasKey = YES;
            break;
        }
    }
    return hasKey;
}

@end
