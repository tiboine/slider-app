import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'dart:convert';
import 'utils/shutterTime.dart';
import 'utils/shutterTimeSeconds.dart';
import 'utils/shutterTimeMillis.dart';
import 'bt_connect.dart' as BT;
import 'reusable_card.dart';
import 'values.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'futures.dart';

class ControllerPage extends StatefulWidget {
  _ControllerPageState createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage>
    with AutomaticKeepAliveClientMixin<ControllerPage> {
  @override
  bool get wantKeepAlive => true;

  int _currentIntValue = 0;
  NumberPicker integerNumberPicker;
  NumberPicker integerInfiniteNumberPicker;
  NumberPicker decimalNumberPicker;
  int _currentFrameValue = 0;
  int _currentHourValue = 0;
  int _currentMinValue = 0;
  int _interval = 0;
  String _shutter;
  String shutter;
  int exposure = 0;
  int frames = 0;
  int number = 0;
  List times = shutterTimeMillis;
  var stopwatch = new Stopwatch()..start();
  int height = 50;
  Timer tmr;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slider controller'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
              child: ReusableButtons(
                  name: 'Frames',
                  valueName: _currentFrameValue.toString(),
                  onPress: () {
                    _showFrameDialog();
                  })),
          Expanded(
              child: ReusableButtons(
                  name: 'Exposure',
                  valueName: _shutter,
                  onPress: () {
                    _showExposureDialog(context);
                  })),
          Expanded(
              child: ReusableButtons(
                  name: 'Minutes',
                  valueName: _currentMinValue.toString(),
                  onPress: () {
                    _showMinDialog();
                  })),
          Expanded(
              child: ReusableButtons(
                  name: 'Hours',
                  valueName: _currentHourValue.toString(),
                  onPress: () {
                    _showHourDialog();
                  })),
          Expanded(
              child: ReusableButtons(
                  name: 'Interval',
                  valueName: _currentIntValue.toString(),
                  onPress: () {
                    _showInterval();
                  })),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          BT.BtConnectState().commandBluetooth('\nding 500\n');
                        });
                      },
                      child: Container(
                        color: Colors.purple,
                        child: Icon(Icons.update),
                        height: 60.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      padding: EdgeInsets.all(0.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      onPressed: () {
                        BT.BtConnectState().commandBluetooth('\nleft 500\n');
                      },
                      color: Colors.blue[400],
                      child: Icon(
                        Icons.arrow_left,
                        size: 60.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      padding: EdgeInsets.all(0.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      onPressed: () {
                        BT.BtConnectState().commandBluetooth('\nright 500\n');
                      },
                      color: Colors.blue[400],
                      child: Icon(
                        Icons.arrow_right,
                        size: 60.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      onPressed: () {
                        BT.BtConnectState().commandBluetooth('\nA\n');
                      },
                      color: Colors.blue[400],
                      child: Text(
                        'A',
                        style: TextStyle(fontSize: 55.0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      onPressed: () {
                        BT.BtConnectState().commandBluetooth('\nB\n');
                      },
                      color: Colors.blue[400],
                      child: Text(
                        'B',
                        style: TextStyle(fontSize: 55.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      onPressed: () {
                        BT.BtConnectState().commandBluetooth('\nGO\n');
                      },
                      color: Colors.green[400],
                      child: Icon(
                        Icons.photo_camera,
                        size: 60.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      onPressed: () {
                        BT.BtConnectState().commandBluetooth('\nCANCEL\n');
                      },
                      color: Colors.red[400],
                      child: Icon(
                        Icons.cancel,
                        size: 60.0,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future _showFrameDialog() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          title: new Text('Frames', textAlign: TextAlign.center),
          minValue: 0,
          maxValue: 2000,
          step: 10,
          initialIntegerValue: _currentFrameValue,
        );
      },
    ).then((num value) {
      BT.BtConnectState().commandBluetooth('\nframes $value\n');
      if (value != null) {
        setState(() => _currentFrameValue = value);
        //integerNumberPicker.animateInt(value);
      }
    });
  }

  Future _showExposureDialog(BuildContext context) async {
    new Picker(
        adapter: PickerDataAdapter<String>(
            pickerdata: JsonDecoder().convert(shutterTimes)),
        hideHeader: true,
        backgroundColor: Colors.grey[800],
        textStyle: TextStyle(color: Colors.white),
        title: new Text('Exposure', textAlign: TextAlign.center),
        onConfirm: (Picker picker, List value) {
          String shutterSpeed = times[value.first];
          print(value.toString());
          print(picker.getSelectedValues());
          String shutter1 = picker.getSelectedValues().toString();
          print(shutter);
          shutter = shutter1.substring(
              1, shutter1.length - 1); //removes brackets from string
          BT.BtConnectState().commandBluetooth('\nexposure $shutterSpeed\n');
          setState(() => _shutter = shutter);
        }).showDialog(context);
  }

  Future _showHourDialog() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          title: new Text('Hours', textAlign: TextAlign.center),
          minValue: 0,
          maxValue: 12,
          initialIntegerValue: _currentHourValue,
        );
      },
    ).then((num value) {
      BT.BtConnectState().commandBluetooth('\nhours $value\n');
      if (value != null) {
        setState(() => _currentHourValue = value);
        //integerNumberPicker.animateInt(value);
      }
    });
  }

  Future _showMinDialog() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          title: new Text('Minutes', textAlign: TextAlign.center),
          minValue: 0,
          maxValue: 60,
          initialIntegerValue: _currentMinValue,
        );
      },
    ).then((num value) {
      BT.BtConnectState().commandBluetooth('\nminutes $value\n');
      if (value != null) {
        setState(() => _currentMinValue = value);
        //integerNumberPicker.animateInt(value);
      }
    });
  }

  Future _showInterval() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          title: new Text('Interval', textAlign: TextAlign.center),
          minValue: 0,
          maxValue: 20,
          initialIntegerValue: _currentIntValue,
        );
      },
    ).then((num value) {
      BT.BtConnectState().commandBluetooth('\ninterval $value\n');

      if (value != null) {
        setState(() => _currentIntValue = value);
        //integerNumberPicker.animateInt(value);
      }
    });
  }
}
