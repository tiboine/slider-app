import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'controller_page.dart';

class BtConnect extends StatefulWidget {
  @override
  BtConnectState createState() => BtConnectState();
}

class BtConnectState extends State<BtConnect>
    with AutomaticKeepAliveClientMixin<BtConnect> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect to bluetooth'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Container(
                child: Text(
                  'Connect to bluetooth',
                  style: TextStyle(
                    fontSize: 40.0,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                DropdownButton(
                  items: _getDeviceItems(),
                  onChanged: (value) => setState(() => _device = value),
                  value: _device,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  padding: EdgeInsets.all(50.0),
                  color: Colors.red[400],
                  splashColor: Colors.blue[400],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  onPressed:
                      _pressed ? null : _connected ? _disconnect : _connect,
                  child: Text(
                    _connected ? 'Disconnect' : 'Connect',
                    style: TextStyle(fontSize: 25.0),
                  ),
                ),
                FlatButton(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(
                    Icons.arrow_right,
                    size: 60.0,
                  ),
                  color: Colors.red[400],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ControllerPage();
                    }));
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Get the instance of the bluetooth
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _pressed = false;
  String arduino;

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  @override
  void initState() {
    super.initState();
    bluetoothConnectionState();
  }

  // We are using async callback for using await
  Future<void> bluetoothConnectionState() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }
    // For knowing when bluetooth is connected and when disconnected
    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BluetoothState.STATE_ON:
          setState(() {
            _connected = true;
            _pressed = false;
            showToast("Bluetooth connected");
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ControllerPage();
            }));
          });

          break;

        case BluetoothState.STATE_OFF:
          setState(() {
            _connected = false;
            _pressed = false;
            showToast("Bluetooth disconnected", duration: Toast.LENGTH_LONG);
          });
          break;

        default:
          print(state);
          break;
      }
    }); // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  // Create the List of devices to be shown in Dropdown Menu
  /*List<List<BluetoothDevice>> _getDeviceItems() {
    List<List<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      Text('none');
    } else {
      _devicesList.forEach((device) {
        items.add(_device.name);
      });
      return items;
    }
  }*/

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _pressed = true);
  }

// Method to connect to bluetooth
  void _connect() {
    if (_device == null) {
      show('No device selected');
    } else {
      bluetooth.isEnabled.then((isConnected) {
        if (!isConnected) {
          bluetooth
              .toAddress(_device.address)
              .timeout(Duration(seconds: 10))
              .catchError((error) {
            setState(() => _pressed = false);
          });
          setState(() => _pressed = true);
        }
      });
    }
  }

// Method to disconnect bluetooth
  void msgStringBluetooth(String data) {
    bluetooth.isEnabled.then((isConnected) {
      if (isConnected) {
        bluetooth.write(data);
        //show('Device Turned On');
      }
    });
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }

  void commandBluetooth(String a) {
    bluetooth.isEnabled.then((isConnected) {
      if (isConnected) {
        bluetooth.output(a);
      }
    });
  }
}
