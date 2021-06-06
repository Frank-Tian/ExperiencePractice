//
//  SSMonitorView.h
//  StarStar
//
//  Created by tian on 2019/5/20.
//  Copyright © 2019 tian. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSMonitorInfoModel : NSObject

@property (nonatomic, assign) CGFloat cpu;
@property (nonatomic, assign) CGFloat appCpu;
@property (nonatomic, assign) NSUInteger threadCount;
@property (nonatomic, assign) CGFloat memoryUsed;       // 当前APP 占用内存
@property (nonatomic, assign) CGFloat totalMemory;      // 总内存量
@property (nonatomic, assign) CGFloat availableMemory;  // 当前可用内存
@property (nonatomic, assign) CGFloat batteryLevel;
@property (nonatomic, copy) NSString *batteryState;
@property (nonatomic, assign) NSInteger fps;
@property (nonatomic, assign) NSInteger avgFps;

@end

@interface SSMonitorView : UIView

/// closeBtn
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *toggleBtn;

- (void)updateMonitorInfo:(SSMonitorInfoModel *)info;
@end

NS_ASSUME_NONNULL_END
