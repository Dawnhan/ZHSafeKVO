//
//  NSObject+ZHSafeKVO.h
//  ZHSafeKVO
//
//  Created by 郑晗 on 2019/4/24.
//  Copyright © 2019年 郑晗. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZHSafeKVO)

/**
 移除所有观察者keypath
 */
- (void)removeAllObserverdKeyPath;

@end

NS_ASSUME_NONNULL_END
