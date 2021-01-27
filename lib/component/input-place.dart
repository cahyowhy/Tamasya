import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamasya/component/empty-content.dart';
import 'package:tamasya/component/place-item.dart';
import 'package:tamasya/config/constant.dart';
import 'package:tamasya/model/mapbox-summary.dart';
import 'package:tamasya/service/mapbox-service.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/type-def.dart';
import 'package:tamasya/util/underscore.dart' as Underscore;

class InputPlace extends StatefulWidget {
  final EdgeInsets margin;

  final String query;
  final bool allCountries;
  final Function(MapBoxResult option) onSelectPlace;

  const InputPlace({
    Key key,
    this.margin,
    this.onSelectPlace,
    this.query,
    this.allCountries,
  }) : super(key: key);

  @override
  _InputPlaceState createState() => _InputPlaceState();
}

class _InputPlaceState extends State<InputPlace> {
  TextEditingController searchController;

  MapBoxService mapBoxPlaceService = MapBoxService.instance;

  bool isLoading = false;

  String query = "";

  int limit = Constant.PAGING_LIMIT;

  List<MapBoxResult> placeSuggestions = [];

  MapBoxResult selectedPlace;

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didUpdateWidget(InputPlace oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.query != oldWidget.query) {
      setState(() {
        query = widget.query;
      });

      searchController.text = query;
      searchController.selection =
          TextSelection.fromPosition(TextPosition(offset: query.length));
    }
  }

  onResetSuggestion() {
    setState(() {
      searchController.text = "";
      searchController.selection =
          TextSelection.fromPosition(TextPosition(offset: 0));

      query = "";
      selectedPlace = null;
      placeSuggestions = [];
    });
  }

  onSelectPlace(MapBoxResult option) {
    if (widget.onSelectPlace != null) {
      setState(() {
        widget.onSelectPlace(option);
        selectedPlace = option;

        searchController.text = option.text;
        searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: option.text.length));

        placeSuggestions = [];
      });
    }
  }

  onFindLocationSuggest(String e) {
    if ((e?.length ?? 0) >= 4 && selectedPlace == null) {
      doFindLocationSuggestion(e);
    }
  }

  doFindLocationSuggestion(String e) async {
    setState(() {
      isLoading = true;
      placeSuggestions = [];
    });

    try {
      MapBoxSummary mapboxSummary = await mapBoxPlaceService.findSugestion(e,
          allCountries: widget.allCountries ?? false);

      setState(() {
        placeSuggestions = mapboxSummary?.features ?? [];
        TextSelection.fromPosition(TextPosition(offset: query.length));
      });
    } catch (e) {
      print(e);
    }

    setState(() => isLoading = false);
  }

  double get fixHeightSuggestion {
    return Get.height -
        (50 +
            MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .padding
                .top +
            MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .padding
                .bottom);
  }

  @override
  void initState() {
    super.initState();

    searchController = TextEditingController(text: widget.query ?? '');
  }

  @override
  Widget build(BuildContext context) {
    Widget input = Container(
      margin: widget.margin,
      color: Colors.white,
      height: 50,
      child: Stack(
        alignment: Alignment.centerRight,
        children: toList(() sync* {
          yield Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: (val) {
                setState(() => query = val);

                Underscore.debounce(600, this.onFindLocationSuggest, [val]);
              },
              decoration:
                  Style.commonInputDecoration(hintText: 'Search location'),
            ),
          );

          if (isLoading) {
            yield Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                  height: 20, width: 20, child: CircularProgressIndicator()),
            );
          } else if (query?.isNotEmpty ?? false) {
            yield InkWell(
              onTap: () => onResetSuggestion(),
              child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(Icons.close, color: Style.greyLight)),
            );
          }
        }),
      ),
    );

    Widget suggestions = Container(
      height: fixHeightSuggestion,
      color: Colors.white,
      child: placeSuggestions.isEmpty
          ? EmptyContent(
              child: Text("Search location first",
                  style: TextStyle(fontSize: 12, color: Style.greyLight)))
          : ListView(children: toList(() sync* {
              yield* placeSuggestions.map((MapBoxResult e) {
                return PlaceItem(
                  mapBoxResult: e,
                  onClick: () => onSelectPlace(e),
                );
              }).toList();
            })),
    );

    return Column(
      children: [input, suggestions],
    );
  }
}
