import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import "../utils/snackbar.dart";

import "descriptor_tile.dart";

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;

  const CharacteristicTile({Key? key, required this.characteristic, required this.descriptorTiles}) : super(key: key);

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  List<int> _value = [];

  ////esgSgSGe

String _convertValueToString() {
  if (_value.isEmpty) {
    return 'No data';
  }

  // Assuming _value represents 4 bytes of a float
  if (_value.length != 8) {
    return 'Invalid data length';
  }

  // Create a ByteData instance from _value
  ByteData data = ByteData.sublistView(Uint8List.fromList(_value));

  // Interpret the bytes as a float
  double value = data.getFloat32(0, Endian.little); // Change Endian if necessary

  // Convert the float to a string
  String stringValue = value.toStringAsFixed(1); // Change precision as needed

  return stringValue;
}

////arehaerhaerh

  late StreamSubscription<List<int>> _lastValueSubscription;

  @override
  void initState() {
    super.initState();
    _lastValueSubscription = widget.characteristic.lastValueStream.listen((value) {
      _value = value;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _lastValueSubscription.cancel();
    super.dispose();
  }

  BluetoothCharacteristic get c => widget.characteristic;

  List<int> _getRandomBytes() {
    final math = Random();
    return [math.nextInt(255), math.nextInt(255), math.nextInt(255), math.nextInt(255)];
  }

  Future onReadPressed() async {
    try {
      await c.read();
      Snackbar.show(ABC.c, "Read: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Read Error:", e), success: false);
    }
  }

  Future onWritePressed() async {
    try {
      await c.write(_getRandomBytes(), withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  Future onSubscribePressed() async {
    try {
      String op = c.isNotifying == false ? "Subscribe" : "Unubscribe";
      await c.setNotifyValue(c.isNotifying == false);
      Snackbar.show(ABC.c, "$op : Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
      setState(() {});                    
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Subscribe Error:", e), success: false);
    }
  }

  Widget buildUuid(BuildContext context) {
    String uuid = '0x${widget.characteristic.uuid.toString().toUpperCase()}';
    return Text(uuid, style: TextStyle(fontSize: 13));
  }

  Widget buildValue(BuildContext context) {
    String data = _convertValueToString();

    Map<String, String> uuidToStringToAppend = {
      '937B65AB-0CBB-404D-96AC-99F8A7A5B034': ' V',  // Append ' V' for Battery Voltage
      '937B65AC-0CBB-404D-96AC-99F8A7A5B034': ' °C', // Append ' °C' for Fridge Temperature
      '937B65AD-0CBB-404D-96AC-99F8A7A5B034': ' V',  // Append ' V' for Solar Voltage
      // Add more UUIDs and corresponding strings to append as needed
    };
    String appendString = uuidToStringToAppend[widget.characteristic.uuid.toString().toUpperCase()] ?? '';

    return Text('$data$appendString', style: TextStyle(fontSize: 13, color: Colors.grey));

  }

  Widget buildReadButton(BuildContext context) {
    return TextButton(
        child: Text("Read"),
        onPressed: () async {
          await onReadPressed();
          setState(() {});
        });
  }

  Widget buildWriteButton(BuildContext context) {
    bool withoutResp = widget.characteristic.properties.writeWithoutResponse;
    return TextButton(
        child: Text(withoutResp ? "WriteNoResp" : "Write"),
        onPressed: () async {
          await onWritePressed();
          setState(() {});
        });
  }

  Widget buildSubscribeButton(BuildContext context) {
    bool isNotifying = widget.characteristic.isNotifying;
    return TextButton(
        child: Text(isNotifying ? "Unsubscribe" : "Subscribe"),
        onPressed: () async {
          await onSubscribePressed();
          setState(() {});
        });
  }

  Widget buildButtonRow(BuildContext context) {
    bool read = widget.characteristic.properties.read;
    bool write = widget.characteristic.properties.write;
    bool notify = widget.characteristic.properties.notify;
    bool indicate = widget.characteristic.properties.indicate;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (read) buildReadButton(context),
        if (write) buildWriteButton(context),
        if (notify || indicate) buildSubscribeButton(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    String serviceTitle;
    // Determine the title based on the service UUID
    if (widget.characteristic.uuid.toString().toUpperCase() == '937B65AB-0CBB-404D-96AC-99F8A7A5B034') {
      serviceTitle = 'Battery Voltage';
    } else if (widget.characteristic.uuid.toString().toUpperCase() == '937B65AC-0CBB-404D-96AC-99F8A7A5B034') {
      serviceTitle = 'Fridge Temperature';
    } else if (widget.characteristic.uuid.toString().toUpperCase() == '937B65AD-0CBB-404D-96AC-99F8A7A5B034') {
      serviceTitle = 'Solar Voltage';
    } else {
      // Default title if the UUID doesn't match any of the specified UUIDs
      serviceTitle = 'Unknown Characteristic';
    }

    return Card(
      child: ListTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(serviceTitle),
            buildValue(context),
          ],
        ),
        subtitle: buildButtonRow(context),
        contentPadding: const EdgeInsets.all(16.0),
      ),
    );
  }
}