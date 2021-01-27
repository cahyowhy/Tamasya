import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:tamasya/model/airport.dart';
import 'package:tamasya/style/string-util.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/airport-reader.dart';
import 'package:tamasya/util/type-def.dart';

class AirportIataPickerController extends GetxController {
  AirportIataPickerController(
      Function(Airport airport) onSelectAirport, Airport airport) {
    this.airport.value = airport;
    this.onSelectAirport = onSelectAirport;
  }

  Rx<Airport> airport = Rx<Airport>();

  Function(Airport airoirt) onSelectAirport;

  onShowOptionsAirport() {
    showSearch<Airport>(
            context: Get.overlayContext,
            query: airport?.value?.city ?? '',
            delegate: AirportSearchDelegate())
        .then((value) {
      if (value != null) {
        airport.value = Airport.fromJson(value.toJson());
        onSelectAirport(value);
      }
    });
  }
}

class AirportSearchResultTile extends StatelessWidget {
  const AirportSearchResultTile(
      {@required this.airport, @required this.searchDelegate});

  final Airport airport;
  final SearchDelegate<Airport> searchDelegate;

  @override
  Widget build(BuildContext context) {
    final title = '${airport.name} (${airport.iata})';
    final subtitle = '${airport.city}, ${airport.country}';
    return ListTile(
      dense: true,
      title: Text(title, textAlign: TextAlign.start),
      subtitle: Text(subtitle, textAlign: TextAlign.start),
      onTap: () => searchDelegate.close(context, airport),
    );
  }
}

class AirportSearchDelegate extends SearchDelegate<Airport> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return query.isEmpty
        ? []
        : [
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            )
          ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildMatchingSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildMatchingSuggestions(context);
  }

  Widget buildMatchingSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }

    final searched = AirportDataReader.searchString(query);
    if (searched.length == 0) {
      return Center(child: Text("No Result"));
    }

    return ListView.builder(
      itemCount: searched.length,
      itemBuilder: (context, index) {
        return AirportSearchResultTile(
          airport: searched[index],
          searchDelegate: this,
        );
      },
    );
  }
}

class AirportIataPicker extends StatelessWidget {
  final Function(Airport airoirt) onSelectAirport;
  final Airport airport;
  final bool asBigLabel;
  AirportIataPicker(
      {Key key, this.onSelectAirport, this.airport, this.asBigLabel = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AirportIataPickerController>(
      tag: randomString(strlen: 6),
      init: AirportIataPickerController(onSelectAirport, airport),
      builder: (AirportIataPickerController controller) => InkWell(
        child: Obx(() {
          bool hasData = controller?.airport?.value?.iata != null;

          var textColor = asBigLabel && hasData
              ? Style.textColor
              : asBigLabel ? Style.greyDark : Colors.white;

          var textStyle = TextStyle(
              color: textColor,
              fontSize: asBigLabel ? 24 : 12,
              fontWeight: FontWeight.w500);

          var padding = EdgeInsets.only(
              left: asBigLabel ? 0 : 16,
              top: asBigLabel ? 0 : 4,
              bottom: asBigLabel ? 0 : 4,
              right: asBigLabel ? 18 : 8);

          var colorBg = asBigLabel ? Colors.white : Style.primaryLight;

          return InkWell(
              onTap: controller.onShowOptionsAirport,
              child: Container(
                  padding: padding,
                  decoration: BoxDecoration(
                      color: colorBg,
                      borderRadius: Style.borderRadius(param: 24)),
                  child: Row(children: toList(() sync* {
                    if (asBigLabel) {
                      yield Icon(Icons.keyboard_arrow_down,
                          color: textColor, size: 24);
                      yield SizedBox(width: 6);
                    }

                    String city = controller?.airport?.value?.city;
                    String iata = controller?.airport?.value?.iata;
                    String title =
                        (asBigLabel ? city : iata) ?? 'Choose airport';

                    Widget text;

                    if (asBigLabel && hasData) {
                      text = Expanded(
                        child: RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                                text: title,
                                style: textStyle,
                                children: [
                                  TextSpan(
                                      text: " ($iata)",
                                      style: TextStyle(
                                          fontSize: 12, color: textColor))
                                ])),
                      );
                    } else {
                      text = Text(title, style: textStyle);
                    }

                    yield text;

                    if (!asBigLabel) {
                      yield SizedBox(width: 6);
                      yield Icon(Icons.keyboard_arrow_down, color: textColor);
                    }
                  }))));
        }),
      ),
    );
  }
}
