//
//  TTMPeripheralLogger.m
//
//  Created by Shuichi Tsutsumi on 2015/03/13.
//  Copyright (c) 2015 Shuichi Tsutsumi. All rights reserved.
//

#import "TTMPeripheralLogger.h"
@import CoreBluetooth;


@interface TTMPeripheralLogger ()
@property (nonatomic, strong) NSMutableDictionary *fileHandles;
@property (nonatomic, strong) NSDateFormatter *formatter;
@end


@implementation TTMPeripheralLogger

+ (instancetype)sharedLogger {
    
    static id instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
        [instance initInstance];
    });
    
    return instance;
}

- (void)initInstance {
    
    self.fileHandles = @{}.mutableCopy;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    self.formatter = dateFormatter;
}


// =============================================================================
#pragma mark - Private

// create a file handle
- (NSFileHandle *)createLogFileForPeripheral:(CBPeripheral *)peripheral {

    NSString *uuidStr = peripheral.identifier.UUIDString;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *baseDir = [paths firstObject];
    NSString *logsDirectory = [baseDir stringByAppendingPathComponent:@"Logs"];
    
    // create the directory if needed
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logsDirectory]) {
        [fileManager createDirectoryAtPath:logsDirectory
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    
    NSString *filename = [NSString stringWithFormat:@"%@.log", uuidStr];
    NSString *filePath = [logsDirectory stringByAppendingPathComponent:filename];
    
    BOOL result = [fileManager createFileAtPath:filePath
                                       contents:nil
                                     attributes:nil];
    if (!result) {
        NSLog(@"Failed to create file with error code: %d - message: %s", errno, strerror(errno));
        return nil;
    }
    
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [handle seekToEndOfFile];
    
    self.fileHandles[uuidStr] = handle;
    
    return handle;
}

// retrieve a file handle
- (NSFileHandle *)fileHandleForPeripheral:(CBPeripheral *)peripheral {

    NSFileHandle *fileHandle = self.fileHandles[peripheral.identifier.UUIDString];
    
    // exist
    if (fileHandle) {
        return fileHandle;
    }
    
    // not exist -> create
    return [self createLogFileForPeripheral:peripheral];
}


// =============================================================================
#pragma mark - Public

- (void)logForPeripheral:(CBPeripheral *)peripheral function:(NSString *)function format:(NSString *)format, ... {
    
    NSString *stateStr;
    switch (peripheral.state) {
        case CBPeripheralStateConnected:
            stateStr = @"Connected";
            break;

        case CBPeripheralStateConnecting:
            stateStr = @"Connecting";
            break;

        case CBPeripheralStateDisconnected:
        default:
            stateStr = @"Disconnected";
            break;
    }
    

    NSString *message = [NSString stringWithFormat:@"%@ %@ name:%@ state:%@",
                         [self.formatter stringFromDate:[NSDate date]], function, peripheral.name, stateStr];
    if (format) {
        va_list ap;
        va_start(ap, format);
        NSString *formattedStr = [[NSString alloc] initWithFormat:format arguments:ap];
        message = [NSString stringWithFormat:@"%@\n%@", message, formattedStr];
    }
    
    NSLog(@"%@", message);
    
    NSFileHandle *handle = [self fileHandleForPeripheral:peripheral];
    
    [handle writeData:[[message stringByAppendingString:@"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [handle synchronizeFile];    
}

@end
