import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/extension_api.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';
import 'package:latlong/latlong.dart';
import 'package:tamasya/component/column-builder.dart';
import 'package:tamasya/component/common-button.dart';
import 'package:tamasya/component/dialogues.dart';
import 'package:tamasya/component/input-place.dart';
import 'package:tamasya/config/constant.dart';
import 'package:tamasya/config/env.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/model/location.dart';
import 'package:tamasya/model/mapbox-summary.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/geolocation.dart';
import 'package:tamasya/util/underscore.dart' as Underscore;

class CommonMap extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadiusMap;
  final bool interactive;
  final LatLng latLng;
  final bool initUserLocation;
  final bool showAsRaster;
  final bool showBtnSearchPlace;
  final bool hideMainMarker;
  final String exactMapUrl;
  final double iconSize;
  final Widget child;
  final Function(Location location) onCurrentLocationFetched;
  final List<LatLng> markers;
  final Function(double radius, LatLng latlng) onPositionChange;
  final Function(double latitude, double longitude) onTapLocation;
  final PopupBuilder popupBuilder;

  CommonMap({
    Key key,
    this.width,
    this.height,
    @required this.latLng,
    this.interactive = false,
    this.onCurrentLocationFetched,
    this.borderRadiusMap,
    this.showAsRaster = false,
    this.initUserLocation = false,
    this.iconSize = 1,
    this.exactMapUrl,
    this.child,
    this.markers,
    this.onPositionChange,
    this.onTapLocation,
    this.popupBuilder,
    this.hideMainMarker = false,
    this.showBtnSearchPlace = false,
  }) : super(key: key);

  @override
  CommonMapState createState() {
    return CommonMapState();
  }
}

class CommonMapState extends State<CommonMap> {
  MapController mapController;

  PopupController popupController;

  bool isLoadingGps = false;

  bool skipEmitPosChange = false;

  /// on first start onPositionChange was invoked
  /// this is to prevent
  bool hasInit = false;

  Location location;

  LatLng currentPoint;

  List<Marker> _markers = [];

  int _currMarker;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    if (!widget.showAsRaster) {
      mapController = MapController();

      if (widget.popupBuilder != null) {
        popupController = PopupController();
      }

      Future.delayed(Duration(milliseconds: 200)).then((_) {
        this.skipEmitPosChange = true;

        if ((widget?.markers?.isNotEmpty) ?? false) {
          fitToBounds();
        } else if (widget.latLng != null) {
          moveCamera(widget.latLng);
        }
      }).whenComplete(() => this.skipEmitPosChange = false);
    }

    super.initState();
  }

  fitToBounds({bool emitChange = false}) {
    List<LatLng> newMarkers = widget.markers;

    if (currentPoint != null) {
      newMarkers.add(currentPoint);
    }

    var latlngB = LatLngBounds.fromPoints(newMarkers);

    if (latlngB?.isValid ?? false) {
      if (emitChange) this.skipEmitPosChange = true;
      mapController.fitBounds(latlngB);
      if (emitChange) this.skipEmitPosChange = false;
    }
  }

  moveCamera(LatLng latlng, {double zoom}) async {
    if (mapController != null) {
      mapController.move(LatLng(latlng.latitude, latlng.longitude),
          zoom ?? Constant.DEFAULT_MAP_ZOOM.toDouble());
    }
  }

  onPositionChanged(MapPosition position, bool hasGesture) {
    if (widget.onPositionChange != null && !skipEmitPosChange && this.hasInit) {
      currentPoint =
          LatLng(position.center.latitude, position.center.longitude);

      double rad = _coordDistance(
          LatLng(position.center.latitude, position.bounds.west),
          LatLng(position.center.latitude, position.bounds.east));

      Underscore.debounce(400, widget.onPositionChange, [rad, currentPoint]);

      hidePopUp();
    } else if (!this.hasInit) {
      this.hasInit = true;
    }
  }

  hidePopUp() {
    if ((widget?.markers?.isNotEmpty ?? false) && (popupController != null)) {
      popupController.hidePopup();
    }
  }

  onTap(LatLng latLng) {
    if (widget.onTapLocation != null) {
      widget.onTapLocation(latLng.latitude, latLng.longitude);
      moveCamera(LatLng(latLng.latitude, latLng.longitude),
          zoom: mapController.zoom);
    }

    hidePopUp();
  }

  double _coordDistance(LatLng latlng1, LatLng latlng2) {
    return Haversine().distance(latlng1, latlng2) / 1000;
  }

  _onSearchLocation() async {
    if (!this.isLoadingGps) {
      setState(() => isLoadingGps = true);

      try {
        location = await Geolocation.getLocation();

        var latLng =
            LatLng(location?.position?.latitude, location?.position?.longitude);
        moveCamera(latLng);

        if (widget.onCurrentLocationFetched != null) {
          widget.onCurrentLocationFetched(location);
        }
      } catch (e) {
        print(e);
      }

      setState(() => isLoadingGps = false);
    }
  }

  _onShowPopUpMarker(int i) {
    if (widget.popupBuilder != null) {
      this.skipEmitPosChange = true;

      moveCamera(
          LatLng(_markers.elementAt(i).point.latitude,
              _markers.elementAt(i).point.longitude),
          zoom: mapController.zoom);
      popupController.showPopupFor(_markers.elementAt(i));

      this.skipEmitPosChange = false;
      this._currMarker = i;
    }
  }

  _onShowPrevNextPopUp({bool isPrev = false}) {
    if (_currMarker == null) {
      _currMarker = 0;
    } else if (isPrev && _currMarker != 0) {
      _currMarker -= 1;
    } else if (_currMarker != (_markers.length - 1)) {
      _currMarker += 1;
    }

    _onShowPopUpMarker(_currMarker);
  }

  _onShowInputPlace() async {
    bool skipHideAppBar =
        MainWidgetController.instance.forceHideAppbarAndBottomBar.value;

    if (!skipHideAppBar)
      MainWidgetController.instance.forceHideAppbarAndBottomBar.value = true;

    await showDialogAnimation(Get.overlayContext, SingleChildScrollView(
      child: Container(
        child: InputPlace(onSelectPlace: (MapBoxResult option) {
          bool validOption = (option?.center?.length ?? 0) > 1 &&
              (option?.bbox?.length ?? 0) > 3;

          bool valid = widget.onPositionChange != null &&
              !skipEmitPosChange &&
              validOption;

          if (valid) {
            currentPoint = LatLng(option.center[1], option.center[0]);

            mapController.fitBounds(LatLngBounds(
                LatLng(option.bbox[1], option.bbox[0]),
                LatLng(option.bbox[3], option.bbox[2])));

            hidePopUp();
            Get.back();
          }
        }),
      ),
    ));

    if (!skipHideAppBar)
      MainWidgetController.instance.forceHideAppbarAndBottomBar.value = false;
  }

  Widget renderBtAction(IconData iconData, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: Icon(iconData),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            boxShadow: Style.commonBoxShadows,
            borderRadius: Style.borderRadius(),
            color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double finalWidth = widget.width ?? Get.width;
    double finalHeight = widget.height ?? 300;

    if (widget.showAsRaster) {
      String image = (widget.exactMapUrl?.isNotEmpty ?? false)
          ? widget.exactMapUrl
          : Underscore.getMapBoxRasterMap(
              widget.latLng.latitude, widget.latLng.longitude,
              width: finalWidth, height: finalHeight);

      return Stack(
        alignment: Alignment.center,
        children: [
          Style.renderImage(image, '', finalWidth,
              hh: finalHeight, radius: widget.borderRadiusMap ?? 0),
          Icon(Icons.location_on, color: Style.danger, size: 50)
        ],
      );
    }

    List<LayerOptions> layers = [
      TileLayerOptions(
          additionalOptions: {'accessToken': env.mapBoxApiKey},
          urlTemplate:
              "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/"
              "{z}/{x}/{y}@2x?access_token={accessToken}")
    ];

    List<MapPlugin> plugins = [];
    _markers = [];

    if (widget.latLng?.latitude != null && widget.latLng?.longitude != null) {
      if (widget?.markers != null) {
        _markers.addAll(widget.markers
            .asMap()
            .entries
            .map((e) => Marker(
                  width: 50.0,
                  height: 50.0,
                  point: LatLng(e.value.latitude, e.value.longitude),
                  builder: (_) => InkWell(
                    onTap: () {
                      if (widget.popupBuilder != null) {
                        _onShowPopUpMarker(e.key);
                      }
                    },
                    child: Container(
                      child: Image.asset("assets/image/png/icon-location.png",
                          width: 50),
                    ),
                  ),
                ))
            .cast<Marker>()
            .toList());
      }

      if (!widget.hideMainMarker) {
        _markers.add(Marker(
          width: 50.0,
          height: 50.0,
          point: LatLng(widget.latLng.latitude, widget.latLng.longitude),
          builder: (ctx) => Container(
            child: Icon(Icons.location_on, color: Style.danger, size: 50),
          ),
        ));
      }
    }

    if (_markers.length > 0) {
      if (widget.popupBuilder != null) {
        layers.add(PopupMarkerLayerOptions(
            popupBuilder: widget.popupBuilder,
            markers: _markers,
            popupController: popupController,
            popupSnap: PopupSnap.top));
        plugins.add(PopupMarkerPlugin());
      } else {
        layers.add(MarkerLayerOptions(markers: _markers));
      }
    }

    Widget commonMap = FlutterMap(
      mapController: mapController,
      options: MapOptions(
        plugins: plugins,
        onPositionChanged: onPositionChanged,
        onTap: onTap,
        interactive: widget.interactive,
        center:
            LatLng(widget.latLng?.latitude ?? 0, widget.latLng?.longitude ?? 0),
        zoom: Constant.DEFAULT_MAP_ZOOM.toDouble(),
      ),
      layers: layers,
    );

    if (widget.width != null) {
      commonMap = SizedBox(
        width: widget.width,
        height: widget.height ?? 300,
        child: commonMap,
      );
    }

    if (widget.borderRadiusMap != null) {
      commonMap = ClipRRect(
        borderRadius: Style.borderRadius(param: widget.borderRadiusMap),
        child: commonMap,
      );
    }

    if (widget.onCurrentLocationFetched != null ||
        widget.child != null ||
        widget.showBtnSearchPlace) {
      var childrens = [commonMap];
      Widget renderButtonZoom({bool isZoomOut = false}) {
        return renderBtAction(isZoomOut ? Icons.zoom_out : Icons.zoom_in, () {
          moveCamera(this.currentPoint,
              zoom: mapController.zoom + (isZoomOut ? -1 : 1));
        });
      }

      Widget buttonAction;
      Widget buttonGps;
      Widget buttonSearchLoc;
      Widget buttonFitBound;

      if (widget.onCurrentLocationFetched != null) {
        buttonGps = renderBtAction(Icons.gps_fixed, _onSearchLocation);
      }

      if ((widget?.markers?.isNotEmpty) ?? false) {
        buttonFitBound = renderBtAction(Icons.crop_square, () {
          fitToBounds(emitChange: true);
        });
      }

      if (widget.showBtnSearchPlace) {
        buttonSearchLoc = renderBtAction(Icons.search, _onShowInputPlace);
      }

      var childrensFilter = [
        buttonSearchLoc,
        buttonFitBound,
        buttonGps,
        renderButtonZoom(),
        renderButtonZoom(isZoomOut: true)
      ].where((element) => element != null).toList();

      buttonAction = ColumnBuilder(
        itemCount: childrensFilter.length,
        itemBuilder: (_, i) {
          var e = childrensFilter[i];

          if (i < (childrensFilter.length - 1)) {
            return Padding(child: e, padding: const EdgeInsets.only(bottom: 8));
          }

          return e;
        },
      );

      if (buttonAction != null) {
        buttonAction = Padding(
          padding: const EdgeInsets.only(right: 16, top: 16),
          child: buttonAction,
        );

        childrens.add(buttonAction);
      }

      if (widget.child != null) {
        childrens.add(Positioned(
          child: widget.child,
          bottom: 0,
          right: 0,
        ));
      }

      bool hasMarkersPopupBuilder =
          _markers.length > 0 && widget.popupBuilder != null;

      if (hasMarkersPopupBuilder) {
        childrens.add(Positioned(
          right: 16,
          bottom: 80,
          child: Row(children: [
            CommonButton(
                height: 38,
                color: Colors.white,
                child: Row(
                  children: [
                    Icon(Icons.chevron_left, color: Style.textColor),
                    SizedBox(width: 8),
                    Text("Prev", style: TextStyle(color: Style.textColor)),
                  ],
                ),
                onPressed: () => _onShowPrevNextPopUp(isPrev: true)),
            SizedBox(width: 12),
            CommonButton(
                height: 38,
                color: Colors.white,
                child: Row(
                  children: [
                    Text("Next", style: TextStyle(color: Style.textColor)),
                    SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: Style.textColor),
                  ],
                ),
                onPressed: _onShowPrevNextPopUp)
          ]),
        ));
      }

      commonMap = Stack(
        alignment: Alignment.topRight,
        children: childrens,
      );
    }

    return commonMap;
  }
}
