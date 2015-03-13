# PeripheralLogger

PeripheralLogger exports log files separately for each CBPeripheral object.



##How to use

**Just add TTMPeripheralLogger.{h,m} into your project.**

(CocoaPods will be supported soon!)

###Simplest

Use `PeripheralLog` macro.

(example)

```objc
- (void)  centralManager:(CBCentralManager *)central
    didConnectPeripheral:(CBPeripheral *)peripheral
{
    PeripheralLog(peripheral);

    // (do something)
}
```

Log files are created into `Caches/Logs` separately for each peripheral object, and each the time, method, `name`, `state` are output.

> 21:51:58 centralManager:didConnectPeripheral: name:shuPhone6plus state:Connected


###Formatted

Use `PeripheralLogF` macro.

(examples)

```objc
- (void)   centralManager:(CBCentralManager *)central
    didDiscoverPeripheral:(CBPeripheral *)peripheral
        advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    PeripheralLogF(peripheral, @"advertisementData:%@, RSSI:%@", advertisementData, RSSI);

    // do something
}
```

```objc
- (void)     peripheral:(CBPeripheral *)peripheral
    didDiscoverServices:(NSError *)error
{
    PeripheralLogF(peripheral, @"error:%@, services:%@", error, peripheral.services);

    // do something
}
```

> 21:51:58 centralManager:didDiscoverPeripheral:advertisementData:RSSI: name:shuPhone6plus state:Disconnected
advertisementData:{
    kCBAdvDataHashedServiceUUIDs =     (
        "EB115BE0-A9E8-4E11-99E1-53E510FBA9E6"
    );
    kCBAdvDataIsConnectable = 1;
}, RSSI:-49


> 21:51:59 peripheral:didDiscoverServices: name:shuPhone6plus state:Connected
error:(null), services:(
    "<CBService: 0x174079380, isPrimary = YES, UUID = EB115BE0-A9E8-4E11-99E1-53E510FBA9E6>"
)

##Sample Logs

See "SampleLogs" folder in this repository.

