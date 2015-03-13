//
//  TTMPeripheralLogger.h
//
//  Created by Shuichi Tsutsumi on 2015/03/13.
//  Copyright (c) 2015 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifdef DEBUG
#define PeripheralLog(peripheral)  PeripheralLogF(peripheral, nil)
#define PeripheralLogF(peripheral, ...)  [[TTMPeripheralLogger sharedLogger] logForPeripheral:peripheral function:NSStringFromSelector(_cmd) format:__VA_ARGS__]

#else
#define PeripheralLog(peripheral)  while(0) {}
#define PeripheralLogF(peripheral, ...)  while(0) {}

#endif


@class CBPeripheral;


@interface TTMPeripheralLogger : NSObject

+ (instancetype)sharedLogger;

- (void)logForPeripheral:(CBPeripheral *)peripheral function:(NSString *)function format:(NSString *)format, ...;

@end
