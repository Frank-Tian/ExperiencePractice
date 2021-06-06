//
//  MemoryHelper.h
//  MaxMemoryBudget
//
//  Created by Tian on 2021/6/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MemoryHelper : NSObject

// 获取本机内存（单位：MB）
+ (double)getTotalMemorySize;
// 获取当前任务所占用的内存（单位：MB）
+ (double)currentAppUsedMemory;
// 获取当前设备可用内存(单位：MB）
+ (double)availableMemory;

@end

NS_ASSUME_NONNULL_END
