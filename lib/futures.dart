import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'bt_connect.dart' as BT;
import 'dart:async';
import 'values.dart';
import 'controller_page.dart';
/*
class Numbers extends StatelessWidget {
  dynamic showFrameDialog(String name, int number) {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          title: new Text(name, textAlign: TextAlign.center),
          minValue: 0,
          maxValue: 2000,
          step: 1,
          initialIntegerValue: number,
        );
      },
    ).then((num value) {
      BT.BtConnectState().commandBluetooth('\n$name $value\n');
      if (value != null) {
        setState(() => number = value);
        number = value;
      }
    });
  }
}
*/
