import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'characteristic_tile.dart';

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile({Key? key, required this.service, required this.characteristicTiles}) : super(key: key);

  Widget buildUuid(BuildContext context) {
    String uuid = '0x${service.uuid.toString().toUpperCase()}';
    return Text(uuid, style: TextStyle(fontSize: 13));
  }

  @override
  Widget build(BuildContext context) {
    if (service.uuid.toString().toUpperCase() == '937B64AA-0CBB-404D-96AC-99F8A7A5B034') {
      return characteristicTiles.isNotEmpty
          ? ExpansionTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Cart', style: TextStyle(color: Colors.blue)),
                ],
              ),
              children: characteristicTiles,
            )
          : ListTile(
              title: const Text('Service'),
              subtitle: buildUuid(context),
            );
    } else {
      // Return an empty container if the UUID doesn't match
      return Container();
    }
  }
}