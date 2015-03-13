//
//  ViewController.m
//  PeripheralLoggerDemo
//
//  Created by Shuichi Tsutsumi on 2015/03/13.
//  Copyright (c) 2015 Shuichi Tsutsumi. All rights reserved.
//

#import "ViewController.h"
@import CoreBluetooth;
#import "TTMPeripheralLogger.h"


@interface ViewController ()
<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    BOOL isScanning;
}
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSMutableArray *peripherals;
@end


@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                               queue:nil];
    self.peripherals = @[].mutableCopy;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


// =============================================================================
#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            // start scan
            [self.centralManager scanForPeripheralsWithServices:nil
                                                        options:nil];
            break;
            
        default:
            break;
    }
}

- (void)   centralManager:(CBCentralManager *)central
    didDiscoverPeripheral:(CBPeripheral *)peripheral
        advertisementData:(NSDictionary *)advertisementData
                     RSSI:(NSNumber *)RSSI
{
    PeripheralLogF(peripheral, @"advertisementData:%@, RSSI:%@", advertisementData, RSSI);
    
    [self.peripherals addObject:peripheral];
    [self.centralManager connectPeripheral:peripheral
                                   options:nil];
}

- (void)  centralManager:(CBCentralManager *)central
    didConnectPeripheral:(CBPeripheral *)peripheral
{
    PeripheralLog(peripheral);
    
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)        centralManager:(CBCentralManager *)central
    didFailToConnectPeripheral:(CBPeripheral *)peripheral
                         error:(NSError *)error
{
    PeripheralLogF(peripheral, @"error:%@", error);

    [self.peripherals removeObject:peripheral];
}

- (void)     centralManager:(CBCentralManager *)central
    didDisconnectPeripheral:(CBPeripheral *)peripheral
                      error:(NSError *)error
{
    PeripheralLogF(peripheral, @"error:%@", error);
    
    [self.peripherals removeObject:peripheral];
}


// =============================================================================
#pragma mark - CBPeripheralDelegate

- (void)     peripheral:(CBPeripheral *)peripheral
    didDiscoverServices:(NSError *)error
{
    PeripheralLogF(peripheral, @"error:%@, services:%@",
                   error, peripheral.services);
    
    if (error) {
        return;
    }
    
    NSArray *services = peripheral.services;
    for (CBService *service in services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)                      peripheral:(CBPeripheral *)peripheral
    didDiscoverCharacteristicsForService:(CBService *)service
                                   error:(NSError *)error
{
    PeripheralLogF(peripheral, @"error:%@, service:%@, characteristics:%@",
                   error, service.UUID, service.characteristics);

    if (error) {
        return;
    }
    
    NSArray *characteristics = service.characteristics;
    
    for (CBCharacteristic *characteristic in characteristics) {

        // notify
        if ((characteristic.properties & CBCharacteristicPropertyNotify) != 0) {
            
            [peripheral setNotifyValue:YES
                     forCharacteristic:characteristic];
        }
        
        // read
        if ((characteristic.properties & CBCharacteristicPropertyRead) != 0) {
            
            [peripheral readValueForCharacteristic:characteristic];
        }

        // write
        if ((characteristic.properties & CBCharacteristicPropertyWrite) != 0) {
            
            NSData *data = [@"aaaa" dataUsingEncoding:NSUTF8StringEncoding];
            [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        }
    }
}

- (void)                             peripheral:(CBPeripheral *)peripheral
    didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
                                          error:(NSError *)error
{
    PeripheralLogF(peripheral, @"error:%@, characteristic:%@, isNotifying:%d",
                   error, characteristic.UUID, characteristic.isNotifying);
}

- (void)                 peripheral:(CBPeripheral *)peripheral
    didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
                              error:(NSError *)error
{
    PeripheralLogF(peripheral, @"error:%@, characteristic:%@, value:%@",
                   error, characteristic.UUID, characteristic.value);
}

@end
