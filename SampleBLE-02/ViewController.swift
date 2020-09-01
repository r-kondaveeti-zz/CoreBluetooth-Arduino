//
//  ViewController.swift
//  SampleBLE-02
//
//  Created by Radhithya Reddy Kondaveeti on 8/19/20.
//  Copyright © 2020 Radhithya Reddy Kondaveeti. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if(central.state == .poweredOn) {
            print("[BLE-02] Bluetooth powered on");
            if(central.retrieveConnectedPeripherals(withServices: [CBUUID.init(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")]).count == 1) {
                print("Found ones");
            }
            central.scanForPeripherals(withServices: nil, options: nil);
        } else if(central.state == .poweredOff) {
            print("[BLE-02] Bluetooth powered off");
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(peripheral.name == "UART Service") {
            arduino = peripheral;
            arduino.delegate = self;
            manager.connect(arduino, options: nil);
            print("[BLE-02] Peripheral discovered!");
            central.stopScan();
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("[BLE-02] Connected")
        arduino.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("[BLE-02] Disconnected]")
    }


    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = arduino.services else { return }

        for service in services {
            print("[BLE-02] service")
            arduino.discoverCharacteristics(nil, for: service);
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("[BLE-02] Chars discovered!");
        guard let characteristics = service.characteristics else { return }
        print("[BLE-02] \(service)");
        for characteristic in characteristics {
            print("[BLE-02] \(characteristic)");

            if characteristic.properties.contains(.notify) {
              print("\(characteristic.uuid): properties contains .notify")
              peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.properties.contains(.write) {
              print("\(characteristic.uuid): properties contains .write")
                character = characteristic;
              peripheral.setNotifyValue(true, for: characteristic)
                let data = "0".data(using: .ascii)!;
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("In the notification")
    }
    @IBOutlet weak var MainLabel: UILabel!
    
    var manager: CBCentralManager!
    var arduino: CBPeripheral!
    var character: CBCharacteristic?
    @IBOutlet weak var toggleOutlet: UISegmentedControl!
    @IBAction func toggle(_ sender: Any) {
        switch toggleOutlet.selectedSegmentIndex {
            case 0:
                if let char = character {
                    print("[BLE-02] Setting value...")
                    arduino.setNotifyValue(true, for: char)
                    let data = "0".data(using: .ascii)!;
                    arduino.writeValue(data, for: char, type: .withResponse)
                } else {
                    print("[BLE-02] Cannot turn off")
                }
            case 1:
                if let char = character {
                    print("[BLE-02] Setting value...")
                    arduino.setNotifyValue(true, for: char)
                    let data = "1".data(using: .ascii)!;
                    arduino.writeValue(data, for: char, type: .withResponse)
                } else {
                    print("[BLE-02] Cannot turn on")
                }
            default:
                print("[BLE-02] Default")
        }
    }

    var myString:String!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var myTextOut: UITextField!

    @IBAction func actBut(_ sender: Any) {
        print("Pressed")
        label.text =  myTextOut.text;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        manager = CBCentralManager.init(delegate: self, queue: nil)
        manager.delegate = self;
    }
}

