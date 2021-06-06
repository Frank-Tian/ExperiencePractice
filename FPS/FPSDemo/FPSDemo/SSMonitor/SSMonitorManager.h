//
//  SSMonitorManager.h
//
//  Created by tian on 2019/5/20.
//  Copyright © 2019 tian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSMonitorView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSMonitorManager : NSObject

/// 悬浮窗视图
@property (nonatomic, strong, readonly) SSMonitorView *floatWindow;

/**
 获取单例对象
 
 @return 单例对象
 */
+ (instancetype)sharedManager;

- (void)starMonitor;
/**
 显隐监控视图
 */
- (void)toggleMonitorView;
@end

NS_ASSUME_NONNULL_END
