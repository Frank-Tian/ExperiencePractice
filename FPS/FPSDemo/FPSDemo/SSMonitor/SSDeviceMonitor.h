//
//  SSDeviceMonitor.h
//  StarStar
//
//  Created by tian on 2019/5/20.
//  Copyright © 2019 tian. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SSDeviceMonitor;

NS_ASSUME_NONNULL_BEGIN
@protocol SSDeviceMonitorDelegate <NSObject>

@optional
/**
 设备信息发生变化（1s定时刷新）
 */
- (void)deviceInformationDidChanged:(SSDeviceMonitor *)monitor;

@end
/**
 设备信息监控（内存、CPU、电量）
 */
@interface SSDeviceMonitor : NSObject

@property (nonatomic, assign, readonly) CGFloat     cpu;
@property (nonatomic, assign, readonly) CGFloat     appCpu;
@property (nonatomic, assign, readonly) NSUInteger  threadCount;
@property (nonatomic, assign, readonly) CGFloat     batteryLevel;
@property (nonatomic, assign, readonly) NSInteger   fps;
@property (nonatomic, copy,   readonly) NSString    *batteryState;
@property (nonatomic, weak) id<SSDeviceMonitorDelegate> delegate;

+ (instancetype)sharedInstance;
/// 启动FPS监控
- (void)startMonitor;
/// 停止FPS 监控
- (void)stopMonitor;
/// 强制刷新设备信息
- (void)fourceRefreshDeviceInfo;
@end

NS_ASSUME_NONNULL_END
