class Price {
  String total;

  Price({this.total});

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(total: json['total']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    return data;
  }
}
