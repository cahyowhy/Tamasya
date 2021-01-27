class MapBoxSummary {
  String type;
  List<String> query;
  List<MapBoxResult> features;
  String attribution;

  MapBoxSummary({this.type, this.query, this.features, this.attribution});

  MapBoxSummary.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['query'] != null) query = json['query'].cast<String>();
    if (json['features'] != null) {
      features = new List<MapBoxResult>();
      json['features'].forEach((v) {
        features.add(new MapBoxResult.fromJson(v));
      });
    }
    attribution = json['attribution'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['query'] = this.query;
    if (this.features != null) {
      data['features'] = this.features.map((v) => v.toJson()).toList();
    }
    data['attribution'] = this.attribution;
    return data;
  }
}

class MapBoxResult {
  String id;
  String type;
  List<String> placeType;
  num relevance;
  Properties properties;
  String text;
  String placeName;
  List<double> center;
  Geometry geometry;
  List<Context> context;
  List<double> bbox;

  MapBoxResult(
      {this.id,
      this.type,
      this.placeType,
      this.relevance,
      this.properties,
      this.text,
      this.placeName,
      this.center,
      this.geometry,
      this.context,
      this.bbox});

  MapBoxResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    if (json['place_type'] != null)
      placeType = json['place_type'].cast<String>();
    relevance = json['relevance'];
    properties = json['properties'] != null
        ? new Properties.fromJson(json['properties'])
        : null;
    text = json['text'];
    placeName = json['place_name'];
    if (json['center'] != null) center = json['center'].cast<double>();
    geometry = json['geometry'] != null
        ? new Geometry.fromJson(json['geometry'])
        : null;
    if (json['context'] != null) {
      context = new List<Context>();
      json['context'].forEach((v) {
        context.add(new Context.fromJson(v));
      });
    }
    if (json['bbox'] != null) bbox = json['bbox'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['place_type'] = this.placeType;
    data['relevance'] = this.relevance;
    if (this.properties != null) {
      data['properties'] = this.properties.toJson();
    }
    data['text'] = this.text;
    data['place_name'] = this.placeName;
    data['center'] = this.center;
    if (this.geometry != null) {
      data['geometry'] = this.geometry.toJson();
    }
    if (this.context != null) {
      data['context'] = this.context.map((v) => v.toJson()).toList();
    }
    data['bbox'] = this.bbox;
    return data;
  }
}

class Properties {
  String foursquare;
  bool landmark;
  String address;
  String category;
  String wikidata;

  Properties(
      {this.foursquare,
      this.landmark,
      this.address,
      this.category,
      this.wikidata});

  Properties.fromJson(Map<String, dynamic> json) {
    foursquare = json['foursquare'];
    landmark = json['landmark'];
    address = json['address'];
    category = json['category'];
    wikidata = json['wikidata'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['foursquare'] = this.foursquare;
    data['landmark'] = this.landmark;
    data['address'] = this.address;
    data['category'] = this.category;
    data['wikidata'] = this.wikidata;
    return data;
  }
}

class Geometry {
  List<double> coordinates;
  String type;

  Geometry({this.coordinates, this.type});

  Geometry.fromJson(Map<String, dynamic> json) {
    if (json['coordinates'] != null)
      coordinates = json['coordinates'].cast<double>();
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['coordinates'] = this.coordinates;
    data['type'] = this.type;
    return data;
  }
}

class Context {
  String id;
  String wikidata;
  String text;
  String shortCode;

  Context({this.id, this.wikidata, this.text, this.shortCode});

  Context.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    wikidata = json['wikidata'];
    text = json['text'];
    shortCode = json['short_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['wikidata'] = this.wikidata;
    data['text'] = this.text;
    data['short_code'] = this.shortCode;
    return data;
  }
}
