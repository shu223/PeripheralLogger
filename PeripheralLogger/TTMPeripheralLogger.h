//
//  TTMPeripheralLogger.h
//
//  Created by Shuichi Tsutsumi on 2015/03/13.
//  Copyright (c) 2015 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifdef BLE_LOG
#define PeripheralLog(peripheral)  PeripheralLogF(peripheral, nil)
#define PeripheralLogC(peripheral)  PeripheralLogCF(peripheral, nil)
#define PeripheralLogF(peripheral, ...)  [[TTMPeripheralLogger sharedLogger] logForPeripheral:peripheral class:NSStringFromClass([self class]) function:NSStringFromSelector(_cmd) toConsole:NO format:__VA_ARGS__]
#define PeripheralLogCF(peripheral, ...)  [[TTMPeripheralLogger sharedLogger] logForPeripheral:peripheral class:NSStringFromClass([self class]) function:NSStringFromSelector(_cmd) toConsole:YES format:__VA_ARGS__]
#else
#define PeripheralLog(peripheral)  while(0) {}
#define PeripheralLogC(peripheral)  while(0) {}
#define PeripheralLogF(peripheral, ...)  while(0) {}
#define PeripheralLogCF(peripheral, ...)  while(0) {}
#endif


@class CBPeripheral;


@interface TTMPeripheralLogger : NSObject

+ (instancetype)sharedLogger;

- (void)logForPeripheral:(CBPeripheral *)peripheral class:(NSString *)className function:(NSString *)function toConsole:(BOOL)toConsole format:(NSString *)format, ...;

@end
