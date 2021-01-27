class FlightLinks {
  String flightDates;
  String flightOffers;

  FlightLinks({this.flightDates, this.flightOffers});

  factory FlightLinks.fromJson(Map<String, dynamic> json) {
    return FlightLinks(
        flightDates: json['flightDates'], flightOffers: json['flightOffers']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['flightDates'] = this.flightDates;
    data['flightOffers'] = this.flightOffers;
    return data;
  }
}
