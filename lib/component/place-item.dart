import 'package:flutter/material.dart';
import 'package:tamasya/model/mapbox-summary.dart';

class PlaceItem extends StatelessWidget {
  final MapBoxResult mapBoxResult;
  final Function onClick;
  const PlaceItem({Key key, this.mapBoxResult, this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onClick,
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(mapBoxResult.text),
        SizedBox(height: 4),
        Text(mapBoxResult.placeName, style: TextStyle(fontSize: 14)),
      ]),
      leading: Icon(Icons.location_on),
    );
  }
}
